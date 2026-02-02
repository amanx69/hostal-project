from rest_framework import  serializers 
from users.models import User


class ProfileOrBioSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['profile_pic', 'bio']

    def validate(self, attrs):
        if not attrs.get('profile_pic') and not attrs.get('bio'):
            raise serializers.ValidationError("At least one field (bio or profile_pic) must be provided.")
        return attrs

    def validate_profile_pic(self, value):
        if not value:
            raise serializers.ValidationError("No profile picture provided.")
        if value.size > 2 * 1024 * 1024:
            raise serializers.ValidationError("Profile picture must be less than 2MB.")
        return value

    def validate_bio(self, value):
        if value and len(value) > 50:
            raise serializers.ValidationError("Bio must be less than 50 characters.")
        if not value:
            return "Hey there! I’m using this app 😄"
        return value

    def update(self, instance, validated_data):
        instance.profile_pic = validated_data.get('profile_pic', instance.profile_pic)
        instance.bio = validated_data.get('bio', instance.bio)
        instance.save()
        return instance
