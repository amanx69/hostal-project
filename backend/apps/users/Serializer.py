from rest_framework import serializers
from .models import User
import re
from rest_framework.exceptions import ValidationError
from service.gernateToken import  generate_verification_token
from  service.SendEmail import  send_verification_email
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
             'email',  
             'password'
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
         # SendWelcomeEmail.delay(email)#! send the  email 
        uid, token = generate_verification_token(user) #! gernate token 
        print(uid, token)
        send_verification_email.delay(email,uid,token)#! send the  email
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


#! Serializer for login view
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    
    
    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        if not email or email.strip() == "":
            raise serializers.ValidationError({"email": "Email is required"})
        if not password or password.strip() == "":
            raise serializers.ValidationError({"password": "Password is required"})

        return data
    
    
    
    
    