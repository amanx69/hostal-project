from  rest_framework import serializers
from post.models import comment_model


class CommentSerializer(serializers.ModelSerializer):
    #TODO in future  add  user  details
    
    class Meta:
        model= comment_model.Comment
        fields= ['id','post','user','text','created_at',]
        read_only_fields = ['id', 'created_at',  ]
        
        
    
