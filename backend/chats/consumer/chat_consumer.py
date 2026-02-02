from  channels.generic.websocket import AsyncWebsocketConsumer
import json
from chats.Models import ChatModel
from users.models import User
from  django.shortcuts import  get_object_or_404
from  channels.db import database_sync_to_async

class ChatConsumer(AsyncWebsocketConsumer):
    
    

    
#! connect in websocket  with login user and  user2_id from url    
    async def connect(self):
        self.user= self.scope['user']
        
       
        self.room_id=self.scope['url_route']['kwargs']['chat_id'] #~ room  id 
        self.groupe_name= 'chat_%s' % self.room_id  #~ room name for  channel layer
      
        
        
        
      
        if self.user.is_anonymous:
            await self.close()
            return
        await self.channel_layer.group_add(
            self.groupe_name,
            self.channel_name
        )
      
        await self.accept()
        
        
       
        
        await self.send(text_data=f"you are connected to {self.groupe_name} ")
        
    async def disconnect(self ):
        await self.channel_layer.group_discard(
            self.groupe_name,
            self.channel_name,
        )
        await self.send(text_data="you are disconnected")                                               

    #! handle receive  message  from  websocket
    
    async def receive(self, text_data ):
        
        data= json.loads(text_data)
        msg= data['message']
        sender_id= self.user.id
        room_id= self.room_id
        
        
        #! save massage in  db  
       
        await save_message(sender_id,room_id,msg)
        
        
        await self.channel_layer.group_send(
            self.groupe_name,
            {
                "type":"chat_message",
                "msg":msg,
                "sender_id": sender_id,
                "room_id":room_id
                
            }
         )
        #! messgae  save  in db
    async def chat_message(self,event):
         await self.send(text_data=json.dumps({
            'message': event['msg'],
            'sender_id': event['sender_id'],
            "room_id":event['room_id'],
            "username": self.user.username,
            "profile_pic": self.user.profile_pic.url if self.user.profile_pic else None
        }))



    
#! functions for  ave  massage  in db 


@database_sync_to_async
def save_message(room_id,sender_id,msg):
    
    room=  ChatModel.ChatRoom.objects.get(id= room_id)
    sender=  User.objects.filter(id= sender_id).first()
    
    
    message=  ChatModel.Message.objects.create(
        ChatRoom= room,
        sender=sender,
        text=msg,
    )
    return message



        
