from rest_framework import  serializers
from  chats.Models import GroupeChatModel




class  GroupesSerializer(serializers.ModelSerializer):
    class Meta:
        model= GroupeChatModel.GroupesChat
        fields= ['id','groupe_name','created_at','members','groupe_description','groupe_profile_image','owner']
        
        
        
        
        
        
        
        
    def validate_groupe_name(self, value):
        if not value or value.strip() == "":
            raise serializers.ValidationError("Groupe name cannot be empty.")
        if value and len(value) > 50:
            raise serializers.ValidationError("Groupe name must be less than 50 characters.")
        return value
        
        
       