from  django.db import  models
from apps.post.models.post_model import Post
from django.contrib.auth import get_user_model



User=get_user_model()


class Comment(models.Model):
    post= models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    user= models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    text= models.TextField(null= True,blank= True)
    created_at= models.DateTimeField(auto_now_add=True)
    
    
    
    def __str__(self):
        return f"comment by{self.user.email} on {self.post.title}"
    class Mata:
        ordering = ['-created_at']
    

