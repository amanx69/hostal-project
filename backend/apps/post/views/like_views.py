from rest_framework import views, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from apps.post.models import post_model, like_model
from django.shortcuts import get_object_or_404
from django.core.cache import cache


class Likepost(views.APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(post_model.Post, pk=post_id)

        like = like_model.Likes.objects.filter(user=request.user, post=post).first()

        # Invalidate post feed cache after like/unlike
        cache.delete("post_feed")
        cache.delete(f"profile_{request.user.id}")
        cache.delete(f"my_profile_{request.user.id}")

        if like:
            like.delete()
            return Response(
                {"success": True, "message": "Like removed.", "liked": False},
                status=status.HTTP_200_OK,
            )

        like_model.Likes.objects.create(user=request.user, post=post)
        return Response(
            {"success": True, "message": "Post liked successfully.", "liked": True},
            status=status.HTTP_201_CREATED,
        )
