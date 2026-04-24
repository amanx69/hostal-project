from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from django.core.cache import cache
from django.utils.decorators import method_decorator
from django_ratelimit.decorators import ratelimit

from apps.users.models import User
from apps.Profile.models import userProfile
from apps.post.models import post_model, FollowingSystem_model
from apps.post.serializers.post_Serializer import PostSerializer
from .Serializer import ProfileSerializer


from service.response import success_response as _success, error_response as _error



@api_view(["GET"])
@permission_classes([permissions.AllowAny])
def get_profile(request, user_id: int):
    """
    Returns a user's public profile + their posts.
    Cached for 60 seconds; cache is invalidated on profile update.
    """
    cache_key = f"profile_{user_id}"
    cached = cache.get(cache_key)
    if cached:
        return Response(cached, status=status.HTTP_200_OK)

    target_user = get_object_or_404(User, pk=user_id)
    profile = get_object_or_404(userProfile, user=target_user)

    posts = post_model.Post.objects.filter(user_id=user_id).order_by("-created_at")
    posts_serializer = PostSerializer(posts, many=True, context={"request": request})

    followers_count = FollowingSystem_model.FollowingSystem.objects.filter(
        following_id=user_id
    ).count()
    following_count = FollowingSystem_model.FollowingSystem.objects.filter(
        follower_id=user_id
    ).count()

    is_following = False
    if request.user.is_authenticated and request.user.id != user_id:
        is_following = FollowingSystem_model.FollowingSystem.objects.filter(
            follower=request.user, following_id=user_id
        ).exists()

    data = {
        "success": True,
        "profile": {
            "id": profile.id,
            "user_id": target_user.id,
            "username": profile.username,
            "email": target_user.email,
            "profile_picture": profile.profile_picture.url if profile.profile_picture else None,
            "profile_cover": profile.profile_cover.url if profile.profile_cover else None,
            "bio": profile.bio,
            "location": profile.location,
            "phone_number": profile.phone_number,
            "github_url": profile.github_url,
            "linkedin_url": profile.linkedin_url,
            "leetcode_url": profile.leetcode_url,
        },
        "stats": {
            "followers_count": followers_count,
            "following_count": following_count,
        },
        "is_following": is_following,
        "posts": posts_serializer.data,
    }

    cache.set(cache_key, data, timeout=60)
    return Response(data, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([permissions.IsAuthenticated])
def get_user_profile(request):
    """
    Profile for the currently logged-in user.
    Short cache (30 s) keyed by user id.
    """
    cache_key = f"my_profile_{request.user.id}"
    cached = cache.get(cache_key)
    if cached:
        return Response(cached, status=status.HTTP_200_OK)

    profile = get_object_or_404(userProfile, user=request.user)

    followers_count = FollowingSystem_model.FollowingSystem.objects.filter(
        following_id=request.user.id
    ).count()
    following_count = FollowingSystem_model.FollowingSystem.objects.filter(
        follower_id=request.user.id
    ).count()

    posts = post_model.Post.objects.filter(user_id=request.user.id).order_by("-created_at")
    posts_serializer = PostSerializer(posts, many=True, context={"request": request})

    data = {
        "success": True,
        "profile": {
            "id": profile.id,
            "user_id": request.user.id,
            "username": profile.username,
            "email": request.user.email,
            "profile_picture": profile.profile_picture.url if profile.profile_picture else None,
            "profile_cover": profile.profile_cover.url if profile.profile_cover else None,
            "bio": profile.bio,
            "location": profile.location,
            "phone_number": profile.phone_number,
            "github_url": profile.github_url,
            "linkedin_url": profile.linkedin_url,
            "leetcode_url": profile.leetcode_url,
        },
        "stats": {
            "followers_count": followers_count,
            "following_count": following_count,
        },
        "is_following": False,
        "posts": posts_serializer.data,
    }

    cache.set(cache_key, data, timeout=30)
    return Response(data, status=status.HTTP_200_OK)


class UpdateProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    @method_decorator(ratelimit(key="ip", rate="2/m", method="PATCH"))
    def patch(self, request):
        profile = get_object_or_404(userProfile, user=request.user)
        ser = ProfileSerializer(profile, data=request.data, partial=True, context={"request": request})
        if ser.is_valid(raise_exception=True):
            ser.save()
            # Invalidate cached profiles for this user
            cache.delete(f"profile_{request.user.id}")
            cache.delete(f"my_profile_{request.user.id}")
            return _success(
                {
                    "message": "Profile updated successfully.",
                    "data": ser.data,
                }
            )
        return _error("Profile update failed.", errors=ser.errors)


@api_view(["POST"])
@permission_classes([permissions.IsAuthenticated])
def resume_rating(request) -> Response:
    """Rate an uploaded resume (PDF/DOCX, max 5 MB)."""
    resume = request.FILES.get("resume")
    if not resume:
        return _error("No resume file provided.", http_status=status.HTTP_400_BAD_REQUEST)
    if resume.size > 5 * 1024 * 1024:
        return _error("Resume file size must be less than 5 MB.", http_status=status.HTTP_400_BAD_REQUEST)

    
    from .service import resume_rating as resume_rating_service

    score, rating = resume_rating_service.analyze_resume(resume)
    return _success({"score": score, "rating": rating})
