from django.db import models
from django.contrib.auth import get_user_model
# Create your models here.
user= get_user_model()
class userProfile(models.Model):
    user= models.OneToOneField(user,on_delete=models.CASCADE,related_name='user_profile')
    username= models.CharField(max_length=255,unique=True)
    profile_picture= models.ImageField(upload_to='profile_pictures/',null=True,blank=True,default='default/profile-pic.webp')
    bio= models.TextField(blank=True,null=True)
    location= models.CharField(max_length=255,blank=True,null=True)
    date_of_birth= models.DateField(blank=True,null=True)
    created_at= models.DateTimeField(auto_now_add=True)
    updated_at= models.DateTimeField(auto_now=True)
    phone_number= models.CharField(max_length=10,blank=True,null=True)
    profile_cover= models.ImageField(upload_to="bg_image",blank= True,default='default/bg.jpg')
    github_url= models.URLField(max_length=300, blank= True)
    linkedin_url= models.URLField(max_length=300,blank= True)
    leetcode_url= models.URLField(max_length=300, blank=True)
    resume= models.FileField(upload_to='resumes/', blank=True, null=True)
    
    def __str__(self):
        return self.username
    
    