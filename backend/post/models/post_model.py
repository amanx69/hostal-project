from django.db import  models
from users.models import  User

class Post(models.Model):
    user= models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    title= models.CharField(null= True,blank= True,max_length=255)
    dec= models.TextField(null= True,blank= True)
    created_at= models.DateTimeField(auto_now_add=True)
    updated_at= models.DateTimeField(auto_now=True)
    media= models.FileField(upload_to='post_media/',null= True,blank= True)
    
    
    
    def __str__(self):
        return f"Post by {self.user.email} - {self.title}"
    class Mata:
        ordering = ['-created_at']
        
        
        