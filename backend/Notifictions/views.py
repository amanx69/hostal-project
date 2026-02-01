from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from service import FirebaseNotifictions

# Create your views here.

#! send the notification



def send_post_notification(request):
    
    token= request.data.get('token')
    
    FirebaseNotifictions.send_notification
    
    