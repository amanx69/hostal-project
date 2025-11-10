from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from post.models import post_model
from post.serializers import post_Serializer





@api_view(['GET'])

def show_all_post(request):
    posts= post_model.Post.objects.all().order_by('-created_at')
    ser= post_Serializer.PostSerializer(posts,many=True )
    
    return Response({
        "posts":ser.data,
        
    })