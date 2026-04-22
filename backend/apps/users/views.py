from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .Serializer import UserSerializer
from .models import User
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate
from django.utils.http import urlsafe_base64_decode
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth import get_user_model
from .Serializer import LoginSerializer
from service.gernateToken import generate_verification_token 
from  service.SendEmail import send_verification_email
from django.utils.decorators import method_decorator
from django_ratelimit.decorators import ratelimit

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
    @method_decorator(ratelimit(key='ip', rate='4/m', method='POST'))
    def post(self,request)->Response:
        
        
        ser= UserSerializer(data=request.data)
        if ser.is_valid(raise_exception=True):
            user=  ser.save()
            return Response({
                    "message":"signup successfully check your register email",
                    "email":user.email,
                    "id":user.id,
                    "status":201
                
                },status.HTTP_201_CREATED)
        else:
                return Response({
                    "error":"somthing went wrong",
                    "done":False,
                    "status":400
                },status=status.HTTP_400_BAD_REQUEST)
       
        
     
#! Login view
#TODO  in future  add  verification check  for login  if user is not verified then  return  error message to verify email first
class Login(APIView):
    throttle_scope = 'login'  #! for  login throtling
    
    @method_decorator(ratelimit(key='ip', rate='3/m', method='POST'))
    def  post(self,request):
        serializer= LoginSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            email= serializer.validated_data['email']
            password= serializer.validated_data['password']
            user= authenticate(email=email,password=password)
            if user is None:
             return Response(
                {"error": "Invalid email or password"},
                status=status.HTTP_401_UNAUTHORIZED
            )
            token= get_token(user)
            return Response({
                    "message":"Login successful",
                    "status":200,
                    "access": token['access'],
                    "refresh": token['refresh'],
                    "user": UserSerializer(user).data   
                },status.HTTP_200_OK)
       
        

        

#! verify email view

class VerifyEmail(APIView):
    def get(self, request, uid, token):
        try:
            # Decode the user ID
            try:
                user_id = urlsafe_base64_decode(uid).decode()
            except Exception:
                return Response({"error": "Invalid UID"}, status=status.HTTP_400_BAD_REQUEST)

            # Fetch the user
            try:
                user = User.objects.get(pk=user_id)
            except User.DoesNotExist:
                return Response({"error": "User matching query does not exist."}, status=status.HTTP_404_NOT_FOUND)

            # Verify the token
            if default_token_generator.check_token(user, token):
                user.is_verified = True
                user.save()
                     
                token= get_token(user)
                
                return Response({
                    "message": "Email verified",
                    "access": token['access'],
                    "refresh": token['refresh'],
                    
                    })
            else:
                return Response({"error": "Invalid or expired token"}, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
        
class ResendVerificationView(APIView):
    """Resend the email verification link for an unverified account."""
    authentication_classes = []
    permission_classes = []
    #@method_decorator(ratelimit(key="ip", rate=config("resend_email_verification"), block=True, method="POST"))
   # @method_decorator(ratelimit(key="post:email", rate="3/m", block=True, method="POST"))
    def post(self, request):
        email = (request.data.get("email") or "").strip()
        if not email:
            return Response(
                {"detail": "Email is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response(
                {"message": "No account found for this email."},
                status=status.HTTP_404_NOT_FOUND,
            )
        if user.is_verified:
            return Response(
                {
                    "message": "This email is already verified.",
                    "is_verified": True,
                }
            )
       
        uid, token = generate_verification_token(user)
        send_verification_email.delay(email=user.email, uid=uid, token=token)
        return Response(
            {"message": "Verification link sent to your email."},
            status=status.HTTP_200_OK,
        )
