from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import get_object_or_404
from django.core.cache import cache

from apps.post.models import comment_model, post_model
from apps.post.serializers.comment_Serializer import CommentSerializer


class CommentsForPost(APIView):
 

    def get_permissions(self):
        if self.request.method in ["POST", "DELETE"]:
            return [IsAuthenticated()]
        return [AllowAny()]

    def get(self, request, post_id: int):
        cache_key = f"comments_{post_id}"
        cached = cache.get(cache_key)
        if cached:
            return Response(cached, status=status.HTTP_200_OK)

        post = get_object_or_404(post_model.Post, pk=post_id)
        comments = (
            comment_model.Comment.objects.filter(post=post)
            .select_related("user")
            .order_by("-created_at")
        )
        serializer = CommentSerializer(comments, many=True)
        data = {
            "success": True,
            "count": comments.count(),
            "comments": serializer.data,
        }
        cache.set(cache_key, data, timeout=30)
        return Response(data, status=status.HTTP_200_OK)

    def post(self, request, post_id: int):
        post = get_object_or_404(post_model.Post, pk=post_id)

        text = (request.data.get("text") or "").strip()
        if not text:
            return Response(
                {"success": False, "message": "Comment text is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        comment = comment_model.Comment.objects.create(
            post=post,
            user=request.user,
            text=text,
        )

        # Invalidate comment cache for this post
        cache.delete(f"comments_{post_id}")

        serializer = CommentSerializer(comment)
        return Response(
            {"success": True, "message": "Comment added.", "comment": serializer.data},
            status=status.HTTP_201_CREATED,
        )
