from django.urls import path
from .views import  *




urlpatterns = [
    path('singup/',Signup.as_view(),name='signup'),
    path('Login/',Login.as_view(),name='signup'),
    path('all/',alluser.as_view(),name='signup'),
]
