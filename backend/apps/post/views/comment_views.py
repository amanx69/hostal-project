from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import get_object_or_404

from apps.post.models import comment_model, post_model
from apps.post.serializers.comment_Serializer import CommentSerializer


class CommentsForPost(APIView):
    """
    GET: list comments for a post (public)
    POST: create a comment (auth required)
    """

    def get_permissions(self):
        if self.request.method in ["POST", "DELETE"]:
            return [IsAuthenticated()]
        return [AllowAny()]

    def get(self, request, post_id: int):
        post = get_object_or_404(post_model.Post, pk=post_id)
        comments = (
            comment_model.Comment.objects.filter(post=post)
            .select_related("user")
            .order_by("-created_at")
        )
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, post_id: int):
        post = get_object_or_404(post_model.Post, pk=post_id)

        text = (request.data.get("text") or "").strip()
        if not text:
            return Response(
                {"error": "Comment text is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        comment = comment_model.Comment.objects.create(
            post=post,
            user=request.user,
            text=text,
        )
        serializer = CommentSerializer(comment)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
