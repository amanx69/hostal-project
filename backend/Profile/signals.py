from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import userProfile
from users.service import gernate_username
from users.models import User

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        username = gernate_username()
        user= userProfile.objects.create(
            user=instance,username=username)
        user.save()
  
        
        
    
        
        
        