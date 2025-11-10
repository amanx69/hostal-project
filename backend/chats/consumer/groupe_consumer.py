from  channels.generic.websocket  import AsyncWebsocketConsumer
import json





class  groupeConsumer(AsyncWebsocketConsumer):
    
    async def connect(self):
        user= self.scope['user']
        # if not user.is_authenticated:
        #     await self.close()
        #     return
        self.groupe_name= self.scope['url_route']['kwargs']['groupe_name']
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
        id= self.scope['user'].id
        message= data['message']
        

        
        
        self.channel_layer.group_send(
            self.room_name,
            {
                "type":"chat_message",
                "message": message,
                "sender_id": id
            }
        )
        
        
    async def chat_message(self, event):
        
        
        await self.send(data= json.dumps({
            "message": event['message'],
            "sender_id": event['sender_id']
        }))
        