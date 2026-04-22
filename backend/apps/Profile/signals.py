from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import userProfile

from apps.users.models import User



import  random


def gernate_username():
    name= random.choices('abcdefghijklmnopqrstuvwxyz0123456789', k=8)
    return ''.join(name)
        
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        username = gernate_username()
        user= userProfile.objects.create(
            user=instance,username=username)
        user.save()
  
        

    
        
        
        
        
        
