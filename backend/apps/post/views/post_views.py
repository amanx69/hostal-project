from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from apps.post.serializers import post_Serializer
from  apps.post.models import post_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated


from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.exceptions import PermissionDenied
from rest_framework.parsers import MultiPartParser, FormParser

class PostViewSet(ModelViewSet):
    queryset = (
        post_model.Post.objects.all()
        .select_related("user", "user__user_profile")
        .prefetch_related("comments", "likes")
        .order_by("-created_at")
    )
    serializer_class = post_Serializer.PostSerializer
    parser_classes = [MultiPartParser, FormParser]
    filterset_fields = ["user"]

    #  Permissions
    def get_permissions(self):
        if self.action in ["create", "update", "partial_update", "destroy"]:
            return [IsAuthenticated()]
        return [IsAuthenticatedOrReadOnly()]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    #  Only owner can update
    def perform_update(self, serializer):
        post = self.get_object()
        if post.user != self.request.user:
            raise PermissionDenied("You can't edit this post")
        serializer.save()

    #  Only owner can delete
    def perform_destroy(self, instance):
        if instance.user != self.request.user:
            raise PermissionDenied("You can't delete this post")
        instance.delete()    
    
    
    
    
    
    
    
    
# class CreatePost(APIView):
#     def post(self,request):
     
#         try:
#             ser= post_Serializer.PostSerializer(data=request.data, context={'request': request})
#             if ser.is_valid():
#                 post= ser.save()
#                 #TODO in future  send notification to  followers
#                 #! for testing

             
#                 #! create  a notifiction
              
#                 return Response({
#                     "message":"post created successfully",
#                     "data":ser.data
#                 })
#             return Response(ser.errors,status=status.HTTP_400_BAD_REQUEST)
           
#         except Exception as e:
#             return Response({
#                 "error":str(e)
#             },status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            
            
            
            
#! show all  post 


 #TODO towmarow make follow following  url and  like  and  uploade  and  give rateing work on post  