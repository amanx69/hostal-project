from  django.db import models
from  users.models import  User

class ChatRoom(models.Model):
    
    user1=  models.ForeignKey(User, on_delete=models.CASCADE, related_name='chatrooms_user1')
    user2=  models.ForeignKey(User, on_delete=models.CASCADE, related_name='chatrooms_user2')
    
    created_at= models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('user1', 'user2')
        
        
    def __int__(self):
        return f"{self.user1,id} - {self.user2.id}"
    
    
    


class Message(models.Model):
    ChatRoom= models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender= models.ForeignKey(User, on_delete=models.CASCADE, related_name='sender')
    text= models.TextField()
    created_at= models.DateTimeField(auto_now_add=True)
    media= models.FileField(upload_to='chat_media/',null= True,blank= True)
    seen= models.BooleanField(default=False)
    
    
    def  __str__(self):
        return  f"message from {self.sender.email} in room {self.text[:5]}"