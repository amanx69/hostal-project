from django.db import models
from django.contrib.auth import get_user_model



User= get_user_model()



class FollowingSystem(models.Model):
    follower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='following')
    following = models.ForeignKey(User, on_delete=models.CASCADE, related_name='followers')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta: 
        ordering = ['-created_at']
        unique_together = ('follower', 'following')
        
    def __str__(self):
        return f"{self.follower.email} follows {self.following.email}"