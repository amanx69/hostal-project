from rest_framework import serializers
from .models import User
import re


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone', 'bio', 
            'profile_pic', 'dateofbirth', 'created_at', 'password'
        ]
        read_only_fields = ['id', 'created_at']


    def create(self, validated_data):
        email = validated_data.get('email')
        password = validated_data.pop('password', None)

        if not email:
            raise serializers.ValidationError({"email": "Email is required"})
        if not password:
            raise serializers.ValidationError({"password": "Password is required"})

        user = User.objects.create_user( password=password, **validated_data)
        return user


    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
        if not re.search(r"\d", value):
            raise serializers.ValidationError("Password must contain at least one digit.")
        if not re.search(r"[A-Z]", value):
            raise serializers.ValidationError("Password must contain at least one uppercase letter.")
        return value  

    def validate_email(self, value):
        if not value or value.strip() == "":
            raise serializers.ValidationError("Email cannot be empty.")
        return value
