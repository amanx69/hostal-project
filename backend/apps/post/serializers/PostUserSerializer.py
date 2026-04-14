from rest_framework import  serializers
from apps.Profile.models import  userProfile




class postUserSerializer(serializers.ModelSerializer):
    class Meta:
        model= userProfile
        fields= ['id','username','profile_picture']
        read_only_fields = ['id', 'username', 'profile_picture']
