from rest_framework.response import Response
from rest_framework import status
from apps.post.serializers import post_Serializer
from apps.post.models import post_model
from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.exceptions import PermissionDenied
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.cache import cache


class PostViewSet(ModelViewSet):
    queryset = (
        post_model.Post.objects.all()
        .select_related("user", "user__user_profile")
        .prefetch_related("comments", "likes")
        .order_by("-created_at")
    )
    serializer_class = post_Serializer.PostSerializer
    parser_classes = [MultiPartParser, FormParser]
    filterset_fields = ["user"]

    def get_permissions(self):
        if self.action in ["create", "update", "partial_update", "destroy"]:
            return [IsAuthenticated()]
        return [IsAuthenticatedOrReadOnly()]

    # -----------------------------------------------------------------------
    # List — cache the global feed for 30 seconds
    # -----------------------------------------------------------------------
    def list(self, request, *args, **kwargs):
        cache_key = "post_feed"
        cached = cache.get(cache_key)
        if cached and not request.query_params:
            return Response({"success": True, "posts": cached}, status=status.HTTP_200_OK)

        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        data = serializer.data
        if not request.query_params:
            cache.set(cache_key, data, timeout=30)
        return Response({"success": True, "count": len(data), "posts": data}, status=status.HTTP_200_OK)

    def retrieve(self, request, *args, **kwargs):
        pk = kwargs.get("pk")
        cache_key = f"post_{pk}"
        cached = cache.get(cache_key)
        if cached:
            return Response({"success": True, "post": cached}, status=status.HTTP_200_OK)

        instance = self.get_object()
        serializer = self.get_serializer(instance)
        data = serializer.data
        cache.set(cache_key, data, timeout=60)
        return Response({"success": True, "post": data}, status=status.HTTP_200_OK)

    # -----------------------------------------------------------------------
    # Create
    # -----------------------------------------------------------------------
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        # Invalidate feed cache
        cache.delete("post_feed")
        return Response(
            {"success": True, "message": "Post created successfully.", "post": serializer.data},
            status=status.HTTP_201_CREATED,
        )

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    # -----------------------------------------------------------------------
    # Update
    # -----------------------------------------------------------------------
    def perform_update(self, serializer):
        post = self.get_object()
        if post.user != self.request.user:
            raise PermissionDenied("You are not allowed to edit this post.")
        serializer.save()
        # Invalidate caches
        cache.delete("post_feed")
        cache.delete(f"post_{post.pk}")

    # -----------------------------------------------------------------------
    # Destroy
    # -----------------------------------------------------------------------
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.user != request.user:
            raise PermissionDenied("You are not allowed to delete this post.")
        pk = instance.pk
        instance.delete()
        cache.delete("post_feed")
        cache.delete(f"post_{pk}")
        return Response(
            {"success": True, "message": "Post deleted successfully."},
            status=status.HTTP_200_OK,
        )