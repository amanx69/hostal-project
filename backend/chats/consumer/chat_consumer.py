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
        
        self.user2=self.scope['url_route']['kwargs']['user2_id']
        self.room_id=self.scope['url_route']['kwargs']['room_id'] #~ room  id 
        
        self.user2=  int(self.user2)
        
        
        
        self.groupe_name= f'chat_{min(self.user.id,self.user2)}to{max(self.user.id,self.user2)}'
       
        if self.user.is_anonymous:
            await self.close()
            return
        await self.channel_layer.group_add(
            self.groupe_name,
            self.channel_name
        )
           
        await self.accept()
        
        #! create  a chat if not  exit
        
        await self.send(text_data=f"you are connected to {self.groupe_name} ")
        
    async def disconnect(self ):
        await self.channel_layer.group_discard(
            self.channel_name,
        )
        await self.send(text_data="you are disconnected")                                               

    #! handle receive  message  from  websocket
    
    async def receive(self, text_data ):
        
        data= json.loads(text_data)
        msg=data.get("msg")
        sender_id= self.user.id
        room_id= self.room_id
        
        
        #! save massage in  db  
      #  await self.save_message(sender_id,room_id,msg)
       
        
        await self.channel_layer.group_send(
            self.groupe_name,
            {
                "type":"chat_message",
                "msg":msg,
                "sender_id": sender_id,
                "room_id":room_id
                
            }
        )
    async def chat_message(self,event):
         await self.send(text_data=json.dumps({
            'message': event['msg'],
            'sender_id': event['sender_id'],
            "room_id":event['room_id'],
        }))


        
        
        


    
    
#! functions for  ave  massage  in db 


@database_sync_to_async
def save_message(room_id,sender_id,msg):
    
    room=  ChatModel.ChatRoom.objects.filter(id= room_id).first()
    sender=  User.objects.filter(id= sender_id).first()
    
    
    ChatModel.Message.objects.create(
        ChatRoom= room,
        sender=sender,
        text=msg,
    )


    @database_sync_to_async
#! function  for  create  chatroom  if  not  exit
    def create_chatroom(user,user2):
        user1=  get_object_or_404(User,id= user)
        user2=  get_object_or_404(User,id= user2)
        if user1.id== user2.id:
            return 
        if ChatModel.ChatRoom.objects.filter(user1=user1,user2=user2).exists() or ChatModel.ChatRoom.objects.filter(user1=user2,user2=user1).exists():
            return
        
        ChatModel.ChatRoom.objects.get_or_create(
            user1=user1,
            user2=user2,
        )
        
        
