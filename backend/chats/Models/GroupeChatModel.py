from django.db  import  models
from users.models import  User
import uuid


class GroupesChat(models.Model):
    private= models.BooleanField(default=False)
    groupe_name= models.CharField(max_length=100,blank=False,null=False)
    groupe_description= models.TextField()
    created_at= models.DateTimeField(auto_now_add=True)
    owner= models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_groupes')
    members= models.ManyToManyField(User, related_name='groupes_members')
    groupe_profile_image= models.ImageField(upload_to='groupes_profile_images/', null=True, blank=True)
    qr_code= models.ImageField(upload_to='groupes_qr_codes/', null=True, blank=True)
    groupe_link= models.URLField(default= uuid.uuid4,unique=True,editable=False) 
    def __str__(self):
        return self.groupe_name
    
    
    
class Groupemessgae(models.Model):
    groupe= models.ForeignKey(GroupesChat, on_delete=models.CASCADE, related_name='messages')
    sender= models.ForeignKey(User, on_delete=models.CASCADE)
    messsage_text= models.TextField()
    sent_at= models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.messsage_text
    
    
    
    
    
class Groupemembers(models.Model):
    groupe=models.ForeignKey(GroupesChat, on_delete=models.CASCADE, related_name='groupemembers')
    member=models.ForeignKey(User, on_delete=models.CASCADE)
    joined_at=models.DateTimeField(auto_now_add=True)
    leave_at= models.DateTimeField(null=True,blank=True)
    
    def __str__(self):
        return self.member.email