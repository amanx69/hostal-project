from django.db import models
from  users.models import User
# Create your models here.
class complain(models.Model):
    
    user= models.ForeignKey(User, on_delete=models.CASCADE, related_name='complain_user')
    complain_title= models.TextField(max_length=250,blank=False,null=False)
    complain_text= models.TextField(blank=False,null=False)
    created_at= models.DateTimeField(auto_now_add=True)
    status=models.BooleanField(default= False)
    media= models.FileField(upload_to='complain_media/',null= True,blank= True)
    room_number= models.IntegerField(null=True,blank=True)
    
    
    def __str__(self):
        return self.complain_title
    
    class Meta:
        ordering = ["-created_at"]
        