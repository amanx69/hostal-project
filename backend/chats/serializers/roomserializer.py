from rest_framework import  serializers
from  chats.Models import  ChatModel
from  users.Serializer import  UserSerializer




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
                "username":obj.user2.username,
              
              
                
            }
        else:
            return obj.user1.username