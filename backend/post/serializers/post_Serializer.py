from  rest_framework import serializers
from post.models import post_model
from .PostUserSerializer import  postUserSerializer
from .comment_Serializer import CommentSerializer

class PostSerializer(serializers.ModelSerializer):
    post_user= postUserSerializer(source= 'user',read_only=True)
    comments= CommentSerializer(many=True, read_only=True)
    class Meta:
        model= post_model.Post
        fields= ['id','title','dec','media','created_at','updated_at','post_user','comments']
        read_only_fields = ['id', 'created_at', 'updated_at', ]
        
        
        
    def create(self, validated_data):
        user= self.context['request'].user
        post= post_model.Post.objects.create(user=user, **validated_data)
        return  post
        
        
  