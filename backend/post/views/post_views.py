from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from post.serializers import post_Serializer
from  post.models import post_model






#! create  a post


class CreatePost(APIView):
    def post(self,request):
        try:
            ser= post_Serializer.PostSerializer(data=request.data, context={'request': request})
            if ser.is_valid():
                post= ser.save()
                #TODO in future  send notification to  followers
                
                return Response({
                    "message":"post created successfully",
                    "data":ser.data
                })
            return Response(ser.errors,status=status.HTTP_400_BAD_REQUEST)
           
        except Exception as e:
            return Response({
                "error":str(e)
            },status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            
            
            
            
#! show all  post 

class  Post(APIView):
    def get(self,request):
        posts= post_model.Post.objects.all()
        ser= post_Serializer.PostSerializer(posts,many=True)
        return Response({
            "message":"all posts",
            "data":ser.data,
           
            
        
        })
 