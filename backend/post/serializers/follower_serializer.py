from  rest_framework import serializers
from post.models import FollowingSystem_model

class FollowSerializer(serializers.ModelSerializer):
    class Meta:
        model= FollowingSystem_model.FollowingSystem
        fields= ['id','follower','following','created_at']
        read_only_fields = ['id', 'created_at',]