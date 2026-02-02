from django.db import  models
from post.models.post_model import Post
from users.models import  User




class Likes(models.Model):
    post= models.ForeignKey(Post, on_delete=models.CASCADE, related_name='likes')
    user= models.ForeignKey(User, on_delete=models.CASCADE, related_name='likes')
    created_at= models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"like by{self.user.email} on {self.post.title}"
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ('post', 'user')  #! Ensure a user can like a post only once