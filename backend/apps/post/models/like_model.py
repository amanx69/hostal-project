from django.db import  models
from apps.post.models.post_model import Post
from django.contrib.auth import get_user_model

User= get_user_model()


class Likes(models.Model):
    post= models.ForeignKey(Post, on_delete=models.CASCADE, related_name='likes')
    user= models.ForeignKey(User, on_delete=models.CASCADE, related_name='likes')
    created_at= models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"like by{self.user.email} on {self.post.title}"
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ('post', 'user')  #! Ensure a user can like a post only once