from rest_framework import views, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from apps.post.models import post_model, like_model
from django.shortcuts import get_object_or_404

class Likepost(views.APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self,request,post_id):
        
        post= get_object_or_404(post_model.Post,pk= post_id)
        
        like= like_model.Likes.objects.filter(user= request.user,post= post).first()
        if like:
            like.delete()
            return Response({
               "message":"remove like done" 
            },status=status.HTTP_200_OK)
            
        else:
            
            like_model.Likes.objects.create(user=request.user,post=post)
            return Response({
                "message":"like sussifully ",
                "stutes":status.HTTP_200_OK
                
            })
