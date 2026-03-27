from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .Serializer import UserSerializer
from .models import User
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.exceptions import AuthenticationFailed
from  service.SendEmail import SendWelcomeEmail, send_verification_email
from django.contrib.auth import authenticate
from datetime import datetime
from  drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from rest_framework.permissions import IsAuthenticated
from service.gernateToken import  generate_verification_token
from django.utils.http import urlsafe_base64_decode
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth import get_user_model
from .Serializer import LoginSerializer
from .service import gernate_username



User= get_user_model()
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
    throttle_scope = 'signup'  #! for  signup throtling
    
    def post(self,request)->Response:
        
        email= request.data.get('email')
        try:
            ser= UserSerializer(data=request.data)
            if ser.is_valid(raise_exception=True):
            
                user=  ser.save()
                email= user.email
                SendWelcomeEmail.delay(email)#! send the  email 
                uid, token = generate_verification_token(user) #! gernate token 
                print(uid, token)
                send_verification_email.delay(email,uid,token)#! send the  email
            
                token= get_token(user)
                return Response({
                    "message":"user created successfully",
                    "email":user.email,
                    "id":user.id,
                    "access": token['access'],
                    "refresh": token['refresh'],
         
                })
            else:
                return Response({
                    "error":"somthing went wrong",
                },status=status.HTTP_400_BAD_REQUEST)
       
            
        except Exception as e:
            return Response({
                "error":"SOMTHING WENT WRONG",
            },status=status.HTTP_400_BAD_REQUEST)
      
     
#! Login view
#TODO  in future  add  verification check  for login  if user is not verified then  return  error message to verify email first
class Login(APIView):
    throttle_scope = 'login'  #! for  login throtling
    
    def  post(self,request):
        serializer= LoginSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            email= serializer.validated_data['email']
            password= serializer.validated_data['password']
            user= authenticate(email=email,password=password)
        
            if not user:
                return Response({
                    "error":"Invalid email or password"
                },status=status.HTTP_401_UNAUTHORIZED)
                
            else:
                token= get_token(user)
            
                return Response({
                    "message":"Login successful",
                    "access": token['access'],
                    "refresh": token['refresh'],
                    "user": UserSerializer(user).data
                    
                    
                })
        
            
       
        

        

#! verify email view

class VerifyEmail(APIView):
       def get(self, request, uid, token):
        try:
            user_id = urlsafe_base64_decode(uid).decode()
            user = User.objects.get(pk=user_id)

            if default_token_generator.check_token(user, token):
                user.is_verified = True
                usename=gernate_username()
                user.username= usename #! set  random username for user 
                user.save()
                return Response({"message": "Email verified"})
            else:
                return Response({"error": "Invalid token"})

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)