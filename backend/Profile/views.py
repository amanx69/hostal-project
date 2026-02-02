from rest_framework.decorators import api_view ,permission_classes

from rest_framework.response import Response
from  rest_framework import permissions
from django.shortcuts import render
from users.models import User
from users.Serializer import UserSerializer
from django.shortcuts import get_object_or_404




#! for  web
@api_view(['GET'])


def get_profile(request, user_id):
    profile = User.objects.filter(id=user_id).first()
    return render(request, 'profile.html', {'profile': profile})

    return Response({
        "username": user.username,
        "email": user.email,
        "profile_pic": user.profile_pic.url if user.profile_pic else None,
        "Bio": user.bio,
        "phone": user.phone
        
    })
    
    
#! for  api
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated ,permissions.IsAdminUser])

def get_user_profile(request):
    if request.method == 'GET':
        user= request.user
        
        return Response({
            "username":user.username,
            "email":user.email,
            "profile_pic": user.profile_pic.url if user.profile_pic else None,
            "Bio": user.bio,
            
        })