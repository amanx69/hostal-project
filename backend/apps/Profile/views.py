from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import permissions
from django.shortcuts import get_object_or_404

from apps.users.models import User
from apps.Profile.models import userProfile
from apps.post.models import post_model, FollowingSystem_model
from apps.post.serializers.post_Serializer import PostSerializer
from .Serializer import ProfileSerializer
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from django.utils.decorators import method_decorator
from django_ratelimit.decorators import ratelimit


@api_view(["GET"])
@permission_classes([permissions.AllowAny])
def get_profile(request, user_id: int):
    """
    Returns a user's profile + their posts (for social feed / social media UI).
    """
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

    return Response(
        {
            "profile": {
                "id": profile.id,
                "user_id": target_user.id,
                "username": profile.username,
                "email": target_user.email,
                "profile_picture": profile.profile_picture.url
                if profile.profile_picture
                else None,
                "bio": profile.bio,
                "location": profile.location,
                "phone_number": profile.phone_number,
            },
            "stats": {
                "followers_count": followers_count,
                "following_count": following_count,
            },
            "is_following": is_following,
            "posts": posts_serializer.data,
        }
    )
    
    
@api_view(["GET"])
@permission_classes([permissions.IsAuthenticated])
def get_user_profile(request):
    """
    Profile for the currently logged-in user (same format as `get_profile`).
    """
    profile = get_object_or_404(userProfile, user=request.user)

    followers_count = FollowingSystem_model.FollowingSystem.objects.filter(
        following_id=request.user.id
    ).count()
    following_count = FollowingSystem_model.FollowingSystem.objects.filter(
        follower_id=request.user.id
    ).count()

    posts = post_model.Post.objects.filter(user_id=request.user.id).order_by("-created_at")
    posts_serializer = PostSerializer(posts, many=True, context={"request": request})

    return Response(
        {
            "profile": {
                "id": profile.id,
                "user_id": request.user.id,
                "username": profile.username,
                "email": request.user.email,
                "profile_picture": profile.profile_picture.url
                if profile.profile_picture
                else None,
                "bio": profile.bio,
                "location": profile.location,
                "phone_number": profile.phone_number,
            },
            "stats": {
                "followers_count": followers_count,
                "following_count": following_count,
            },
            "is_following": False,
            "posts": posts_serializer.data,
        }
    )
    
    
#! update profile view


class UpdateProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @method_decorator(ratelimit(key='ip', rate='2/m', method='POST'))

    def patch(self,request):
        profile= get_object_or_404(userProfile,user=request.user)
        ser= ProfileSerializer(profile,data=request.data,partial=True, context={'request': request})
        if ser.is_valid(raise_exception= True):
            ser.save()
            return Response({
                "stutas": "success",
                "message": "Profile updated successfully",
                "data": ser.data
                
            },)
        return Response(ser.errors,status=400)
    
 #! rating the resume   
@api_view(["GET"])
@method_decorator(ratelimit(key='ip', rate='4/m', method='GET'))
@permission_classes([permissions.IsAuthenticated])
def resume_rating(request)->Response:
    resume= request.FILES["resume"] if "resume" in request.FILES else None
    if not resume :
        return Response({"error": "No resume provided or checkFileType"}, status=400)
    if resume.size > 5 * 1024 * 1024:  # 5MB limit
        return Response({"error": "Resume file size must be less than 5MB."}, status=400)
   
    #! resume  rating logic  here
    from .service import  resume_rating
    
    score ,rating = resume_rating.analyze_resume(resume)
    print(f"Resume rating: {rating}")
    return Response({"rating": rating
                     ,"score": score})
    
    
