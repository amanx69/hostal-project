from  rest_framework.views import  APIView
from  rest_framework.response import Response
from  rest_framework import status
from  post.serializers import follower_serializer
from  post.models import FollowingSystem_model
from  django.shortcuts import get_object_or_404
from  users.models import User






class Follow(APIView):
   
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
    
    def delete(self,request,user_id):
       following= get_object_or_404(User,pk= user_id)
       follow = FollowingSystem_model.FollowingSystem.objects.filter(follower=request.user, following=following).first()

       if not follow:
            return Response({"error": "You are not following this user"}, status=status.HTTP_400_BAD_REQUEST)

       follow.delete()
       return Response({"message": "Unfollowed successfully"}, status=status.HTTP_200_OK)     
   



 #TODO ADD  THE GIVE FOLLOER LIST AND FOLLOWING LIST
    
       
   
   
   
