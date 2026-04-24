from rest_framework import serializers
from .models import userProfile
from apps.post.service.image_compress import process_image


class ProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = userProfile
        fields = [
            "username",
            "bio",
            "profile_picture",
            "resume",
            "github_url",
            "linkedin_url",
            "leetcode_url",
        ]

    FILTER_WORDS = [
        "fuck", "bitch", "asshole", "pussy", "dick", "bur", "land", "nipple", "boobs"
    ]

    def validate(self, data):
        # BUG FIX: was checking 'Bio' (capital B) — field name is 'bio', so filter never triggered.
        for field in ["bio", "username"]:
            value = data.get(field)
            if value:
                for word in self.FILTER_WORDS:
                    if word in value.lower():
                        raise serializers.ValidationError(
                            {field: f"The {field} contains inappropriate language: '{word}'."}
                        )

        if "username" in data and len(data["username"]) < 3:
            raise serializers.ValidationError(
                {"username": "Username must be at least 3 characters long."}
            )

        if "resume" in data:
            resume = data["resume"]
            if resume.size > 5 * 1024 * 1024:
                raise serializers.ValidationError(
                    {"resume": "Resume file size must be less than 5 MB."}
                )
            if not resume.name.lower().endswith((".pdf", ".doc", ".docx")):
                raise serializers.ValidationError(
                    {"resume": "Resume must be a PDF or Word document."}
                )

        return data

    def update(self, instance, validated_data):
        instance.username = validated_data.get("username", instance.username)
        instance.bio = validated_data.get("bio", instance.bio)


        # 
        profile_image = validated_data.get("profile_picture", None)
        if profile_image:
            image_name = getattr(profile_image, "name", None)
            instance.profile_picture = process_image(profile_image, image_name)
        

        instance.github_url = validated_data.get("github_url", instance.github_url)
        instance.linkedin_url = validated_data.get("linkedin_url", instance.linkedin_url)
        instance.leetcode_url = validated_data.get("leetcode_url", instance.leetcode_url)
        instance.resume = validated_data.get("resume", instance.resume)

        instance.save()
        return instance