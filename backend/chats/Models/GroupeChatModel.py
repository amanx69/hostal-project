from django.db  import  models
from users.models import  User


class GroupesChat(models.Model):
    
    groupe_name= models.CharField(max_length=100,blank=False,null=False)
    groupe_description= models.TextField()
    created_at= models.DateTimeField(auto_now_add=True)
    owner= models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_groupes')
    members= models.ManyToManyField(User, related_name='groupes_members')
    groupe_profile_image= models.ImageField(upload_to='groupes_profile_images/', null=True, blank=True)
    
    def __str__(self):
        return self.groupe_name
    
    
    
class Groupemessgae(models.Model):
    groupe= models.ForeignKey(GroupesChat, on_delete=models.CASCADE, related_name='messages')
    sender= models.ForeignKey(User, on_delete=models.CASCADE)
    messsage_text= models.TextField()
    sent_at= models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.messsage_text