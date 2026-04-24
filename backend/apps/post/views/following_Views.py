from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from apps.post.serializers import follower_serializer
from apps.post.models import FollowingSystem_model
from django.shortcuts import get_object_or_404
from apps.users.models import User
from django.core.cache import cache


from service.response import success_response as _success, error_response as _error


class Follow(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, user_id):
        if request.user.id == user_id:
            return _error("You cannot follow yourself.", http_status=status.HTTP_400_BAD_REQUEST)

        following = get_object_or_404(User, pk=user_id)
        follow, created = FollowingSystem_model.FollowingSystem.objects.get_or_create(
            follower=request.user, following=following
        )

        if not created:
            return _error("You are already following this user.", http_status=status.HTTP_400_BAD_REQUEST)

        # Invalidate follow-related caches
        cache.delete(f"profile_{user_id}")
        cache.delete(f"profile_{request.user.id}")
        cache.delete(f"my_profile_{request.user.id}")

        ser = follower_serializer.FollowSerializer(follow)
        return _success(
            {"message": "Followed successfully.", "data": ser.data},
            http_status=status.HTTP_201_CREATED,
        )


class unfollow(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, user_id):
        following = get_object_or_404(User, pk=user_id)
        follow = FollowingSystem_model.FollowingSystem.objects.filter(
            follower=request.user, following=following
        ).first()

        if not follow:
            return _error("You are not following this user.", http_status=status.HTTP_400_BAD_REQUEST)

        follow.delete()

        # Invalidate follow-related caches
        cache.delete(f"profile_{user_id}")
        cache.delete(f"profile_{request.user.id}")
        cache.delete(f"my_profile_{request.user.id}")

        return _success({"message": "Unfollowed successfully."})


class FollowingList(APIView):
    """GET users that `user_id` is following."""

    permission_classes = [IsAuthenticated]

    def get(self, request, user_id: int):
        cache_key = f"following_list_{user_id}"
        cached = cache.get(cache_key)
        if cached:
            return Response(cached, status=status.HTTP_200_OK)

        following_qs = FollowingSystem_model.FollowingSystem.objects.filter(
            follower_id=user_id
        ).select_related("following__user_profile")

        users = [
            {
                "id": rel.following.id,
                "email": rel.following.email,
                "username": getattr(rel.following, "user_profile", None) and rel.following.user_profile.username,
            }
            for rel in following_qs
        ]

        data = {"success": True, "count": len(users), "users": users}
        cache.set(cache_key, data, timeout=60)
        return Response(data, status=status.HTTP_200_OK)


class FollowersList(APIView):
    """GET users that follow `user_id`."""

    permission_classes = [IsAuthenticated]

    def get(self, request, user_id: int):
        cache_key = f"followers_list_{user_id}"
        cached = cache.get(cache_key)
        if cached:
            return Response(cached, status=status.HTTP_200_OK)

        followers_qs = FollowingSystem_model.FollowingSystem.objects.filter(
            following_id=user_id
        ).select_related("follower__user_profile")

        users = [
            {
                "id": rel.follower.id,
                "email": rel.follower.email,
                "username": getattr(rel.follower, "user_profile", None) and rel.follower.user_profile.username,
            }
            for rel in followers_qs
        ]

        data = {"success": True, "count": len(users), "users": users}
        cache.set(cache_key, data, timeout=60)
        return Response(data, status=status.HTTP_200_OK)
