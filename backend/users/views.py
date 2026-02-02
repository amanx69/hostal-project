from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .Serializer import UserSerializer
from .models import User
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.exceptions import AuthenticationFailed
from  service.SendEmail import SendWelcomeEmail
from django.contrib.auth import authenticate
from datetime import datetime
from  drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
#! FOR  TOKEN  gerneted
def get_token(user):
    if not user.is_active:
      raise AuthenticationFailed("User is not active")

    refresh = RefreshToken.for_user(user)

    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
    } 



class Signup(APIView):
    
 
    def post(self,request):
        email= request.data.get('email')
        if not  email:
            return Response({
                "error":"Email is required"
            })
        ser= UserSerializer(data=request.data)
        if ser.is_valid():
            user=  ser.save()
        
            SendWelcomeEmail(user)#! senfd the  email 
          
            token= get_token(user)
            return Response({
                "message":"user created successfully",
                "data":ser.data,
                "access": token['access'],
                "refresh": token['refresh'],
              
			
    
                
            })
        return Response(ser.errors,status=status.HTTP_400_BAD_REQUEST)

#! Login view

class Login(APIView):
    
    @swagger_auto_schema(
        operation_description="User login using email and password",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='User Email'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='User Password'),
            },
            required=['email', 'password']
        ),
        responses={200: "Login successful"}
    )
    def  post(self,request):
        email= request.data.get('email')
        password= request.data.get('password')
        if not email or not password:
            return Response({
                "error":"Email and password are required"
            },status=status.HTTP_400_BAD_REQUEST)
            
        user= authenticate(email=email,password=password)
      
        if not user:
            return Response({
                "error":"Invalid email or password"
            },status=status.HTTP_401_UNAUTHORIZED)
            
        token= get_token(user)
        
        return Response({
            "message":"Login successful",
            "access": token['access'],
            "refresh": token['refresh'],
            "user": UserSerializer(user).data
            
            
        })
        
        
        
        
        
class alluser(APIView):
    def get(self,request):
        users= User.objects.all()
        ser= UserSerializer(users,many=True)
        return Response({
            "users":ser.data
        })        