from  rest_framework import  serializers
from chats.Models import  ChatModel
from users.Serializer import  UserSerializer





class msgserializer(serializers.ModelSerializer):
    sender= UserSerializer(read_only=True)
    class Meta:
        model= ChatModel.Message
        fields= ['id','ChatRoom','sender','text','created_at','media','seen']
        read_only_fields = ['id', 'created_at', ]
        
        
        
        
   
