from rest_framework import  serializers
from  chats.Models import GroupeChatModel



class  GroupesSerializer(serializers.ModelSerializer):
    groupe_name = serializers.CharField(required=True, allow_blank=False)
    class Meta:
        model= GroupeChatModel.GroupesChat
        fields= ['id','groupe_name','created_at','members','groupe_description','groupe_profile_image','owner']
        

    
    def validate(self, attrs):
     
        groupe_name = attrs.get('groupe_name')

      
        if not groupe_name or groupe_name.strip() == "":
            raise serializers.ValidationError({
                "groupe_name": "Groupe name cannot be empty."
            })

        if len(groupe_name) > 50:
            raise serializers.ValidationError({
                "groupe_name": "Groupe name must be less than 50 characters."
            })

        return attrs
    def update(self,instance, validated_data):
        instance.groupe_name=validated_data.get("groupe_name",instance.groupe_name)
        instance.groupe_profile_image=validated_data.get("groupe_profile_image",instance.groupe_profile_image)
        instance.groupe_description= validated_data.get("groupe_description",instance.groupe_description)
        instance.save()
        return instance
        
       