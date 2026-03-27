from django.urls import path
from .views import  *




urlpatterns = [
    path('signup/',Signup.as_view(),name='signup'),
    path('Login/',Login.as_view(),name='signup'),
    path('verify-email/<uid>/<token>/', VerifyEmail.as_view())
    
 
]
