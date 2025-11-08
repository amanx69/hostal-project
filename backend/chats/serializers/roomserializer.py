from rest_framework import  serializers
from  chats.Models import  ChatModel
from  users.Serializer import  UserSerializer




class  RoomSerializer(serializers.ModelSerializer):
    user1= UserSerializer(read_only=True)
    user2= UserSerializer(read_only=True)
    class Meta:
        model= ChatModel.ChatRoom
        fields= ['id','user1','user2','created_at']
        read_only_fields = ['id', 'created_at', ]