from  rest_framework import  serializers
from apps.chats.Models import  ChatModel
from apps.users.Serializer import  UserSerializer





class msgserializer(serializers.ModelSerializer):
    sender= UserSerializer(read_only=True)
    class Meta:
        model= ChatModel.Message
        fields= ['id','ChatRoom','sender','text','created_at','media','seen']
        read_only_fields = ['id', 'created_at', ]
        
        
        
        
   
