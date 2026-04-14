from rest_framework import  serializers
from  apps.chats.Models import  ChatModel
from  apps.users.Serializer import  UserSerializer




class  RoomSerializer(serializers.ModelSerializer):
    
    secound_user= serializers.SerializerMethodField(read_only=True)
 
    user2= UserSerializer(read_only=True)
    class Meta:
        model= ChatModel.ChatRoom
        fields= ['id','user2','created_at',"secound_user"]
        read_only_fields = ['id', 'created_at', ]
        
        
        
        
    def  get_secound_user(self,obj):
        if  obj.user1.id== self.context['request'].user.id:
            return {
                "email": obj.user2.email,
              
              
                
            }
        else:
            return {"email": obj.user1.email}