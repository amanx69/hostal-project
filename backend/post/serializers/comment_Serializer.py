from  rest_framework import serializers
from post.models import comment_model


class CommentSerializer(serializers.ModelSerializer):
    #TODO in future  add  user  details
    user_email = serializers.EmailField(source="user.email", read_only=True)
    
    class Meta:
        model= comment_model.Comment
        fields= ['id', 'text', 'created_at', 'user_email']
        read_only_fields = ['id', 'created_at']
        
        
    
