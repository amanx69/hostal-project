from rest_framework import  serializers
from users.models import User




class postUserSerializer(serializers.ModelSerializer):
    class Meta:
        model= User
        fields= ['id','username','profile_pic']
        read_only_fields = ['id', 'username', 'profile_pic']
