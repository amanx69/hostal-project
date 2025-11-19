from django.db import models
from users.models import User   
# Create your models here.
class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.TextField()
    title= models.CharField(max_length=100)
    body= models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    is_read= models.BooleanField(default=False)
    
    
    class  Meta:
        ordering = ['-created_at']