from  channels.generic.websocket  import AsyncWebsocketConsumer
import json

from chats.Models.GroupeChatModel import Groupemessgae
from chats.Models.GroupeChatModel import GroupesChat
from users.models import User

from asgiref.sync import sync_to_async



class  groupeConsumer(AsyncWebsocketConsumer):
    
    async def connect(self):
        user= self.scope['user']
        # if not user.is_authenticated:
        #     await self.close()
        #     return
        if  user.is_authenticated:
            self.groupe_name= self.scope['url_route']['kwargs']['groupe_id']
            self.room_name= 'groupe_%s' % self.groupe_name
            
            # !Join groupe group
            await self.channel_layer.group_add(
                self.room_name,
                self.channel_name
            )
            
            await self.accept()
    
#! disconnect
    async def disconnect(self,):
        #! leave  the  groupe
        await self.channel_layer.group_discard(
            self.room_name,
            self.channel_name
        )
        
        
#! receive message from websocket
    async def receive(self, text_data):
        data= json.loads(text_data)
        
        message= data['message']
        id=  self.scope['user'].id
        
        

        
        
        await self.channel_layer.group_send(
            self.room_name,
            {
                "type":"chat_message",
                "message": message,
                "sender_id": self.scope['user'].id,
            }
        )
        
        #! save message to database
        await save_groupe_message(self.groupe_name,id, message)
            
        
        
        
    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'message': event['message'],
            'sender_id': event['sender_id'],
            "name": self.groupe_name,
            "username": self.scope['user'].username,
            "profile_pic": self.scope['user'].profile_pic.url if self.scope['user'].profile_pic else None
        }))
        
        
     
     
@sync_to_async
def save_groupe_message(groupe_id, sender, message_text):
    
    groupe= GroupesChat.objects.get(id= groupe_id)
    user= User.objects.get(id= sender)
    message= Groupemessgae.objects.create(
        groupe=groupe,
        sender=user,
        messsage_text= message_text
        
    )
    return message