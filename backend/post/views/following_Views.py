from  rest_framework.views import  APIView
from  rest_framework.response import Response
from  rest_framework import status
from rest_framework.permissions import IsAuthenticated
from  post.serializers import follower_serializer
from  post.models import FollowingSystem_model
from  django.shortcuts import get_object_or_404
from  users.models import User






class Follow(APIView):
    permission_classes = [IsAuthenticated]
   
    def post( self,request,user_id):
        
        following= get_object_or_404(User,pk=user_id)
        
        if  request.user ==following:
            return  Response({
                "status":status.HTTP_400_BAD_REQUEST,
                "error":"You can't follow yourself"
            })
        follow,create= FollowingSystem_model.FollowingSystem.objects.get_or_create(follower= request.user,following=following)   
        if not create:
            return Response({
                "status":status.HTTP_400_BAD_REQUEST,
                "error":"You are already following this user"
            })

        ser= follower_serializer.FollowSerializer(follow)
        return Response({

            "data":ser.data,
            "status":status.HTTP_201_CREATED,
            "message":"followed successfully"
        })
        
#! unfollow the user


class unfollow(APIView):
    permission_classes = [IsAuthenticated]
    
    def delete(self,request,user_id):
       following= get_object_or_404(User,pk= user_id)
       follow = FollowingSystem_model.FollowingSystem.objects.filter(follower=request.user, following=following).first()

       if not follow:
            return Response({"error": "You are not following this user"}, status=status.HTTP_400_BAD_REQUEST)

       follow.delete()
       return Response({"message": "Unfollowed successfully"}, status=status.HTTP_200_OK)     
   



# TODO: add richer paging + include user profile data


class FollowingList(APIView):
    """
    GET users that `user_id` is following.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request, user_id: int):
        following_qs = FollowingSystem_model.FollowingSystem.objects.filter(
            follower_id=user_id
        ).select_related("following")

        users = [
            {"id": rel.following.id, "email": rel.following.email}
            for rel in following_qs
        ]
        return Response({"users": users}, status=status.HTTP_200_OK)


class FollowersList(APIView):
    """
    GET users that follow `user_id`.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request, user_id: int):
        followers_qs = FollowingSystem_model.FollowingSystem.objects.filter(
            following_id=user_id
        ).select_related("follower")

        users = [
            {"id": rel.follower.id, "email": rel.follower.email}
            for rel in followers_qs
        ]
        return Response({"users": users}, status=status.HTTP_200_OK)

