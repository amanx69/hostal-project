from rest_framework import  serializers
from .models import userProfile
from post.service.image_compress import process_image




class ProfileSerializer(serializers.ModelSerializer):
    
    class Meta:
        model= userProfile
        fields=["username","bio","profile_picture","resume","github_url","linkedin_url","leetcode_url"]
        
        
    filter_words=["fuck","bitch","asshole","pussy","dick","bur","land","nipple","boobs"]
        
        
    def validate(self, data):
        for data_field in ['Bio', 'username']:
            if data.get(data_field):
                for word in self.filter_words:
                    if word in data[data_field].lower():
                        raise serializers.ValidationError(f"The {data_field} contains {word} this is inappropriate language.")
        if "username" in data and len(data["username"]) < 3:
            raise serializers.ValidationError(
            {"username": "Username must be at least 3 characters long."}
            )
            
        if "resume" in data:
            resume = data["resume"]
            if resume.size > 5 * 1024 * 1024:  # 5MB limit
                raise serializers.ValidationError(
                    {"resume": "Resume file size must be less than 5MB."}
                )
            if not resume.name.endswith(('.pdf', '.doc', '.docx')):
                raise serializers.ValidationError(
                    {"resume": "Resume must be a PDF or Word document."}
                )
        return data
        
        
 
    def update(self, instance, validated_data):
        instance.username = validated_data.get("username", instance.username)
        instance.bio = validated_data.get(
            "bio", instance.bio
        )
        profileiage = validated_data.get("profile_picture", None)
        imagename= getattr(profileiage, 'name', None) #! image name
        if profileiage:
            image= process_image(profileiage, imagename)
            instance.profile_picture = image
        instance.profile_picture = validated_data.get(
            "profile_picture", instance.profile_picture
        )
        
        instance.github_url = validated_data.get(
            "github_url", instance.github_url)
        instance.linkedin_url = validated_data.get(
            "linkedin_url", instance.linkedin_url)
        instance.leetcode_url = validated_data.get(
            "leetcode_url", instance.leetcode_url)
        
        instance.resume = validated_data.get(
            "resume", instance.resume
        )
        
     
        instance.save()
        return instance
        
        