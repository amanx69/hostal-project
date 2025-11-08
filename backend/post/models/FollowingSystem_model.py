from django.db import models
from users.models import User



class FollowingSystem(models.Model):
    follower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='following')
    following = models.ForeignKey(User, on_delete=models.CASCADE, related_name='followers')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta: 
        ordering = ['-created_at']
        unique_together = ('follower', 'following')
        
    def __str__(self):
        return f"{self.follower.username} follows {self.following.username}"