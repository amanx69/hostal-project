from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from apps.users.models import User
from  apps.users.Serializer import UserSerializer
from apps.chats.Models import GroupeChatModel
from rest_framework.views import APIView
from apps.chats.serializers.groupeser import groupeserializer
from service.custom_permissions import  Isowner
from  rest_framework.parsers import MultiPartParser, FormParser

#! remove  users in  groupe  by only  owner  
@api_view(['PATCH'])
@permission_classes([Isowner])
def remove_member(request,g_id):
    
    users = request.data.get("users", [])
    if not users:
        return Response({
            "error": "User list is required.",
            "status": status.HTTP_400_BAD_REQUEST
        })
    
    try:
        groupe = GroupeChatModel.GroupesChat.objects.get(id=g_id)
    except GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error": "Group not found."
        }, status=status.HTTP_404_NOT_FOUND)
    
    removed_users = []
    not_found_users = []
    not_in_group = []
    #! only owner  can  remove  user  from  the  groupe
    if request.user== groupe.owner:

        for user_id in users:
            try:
                remove_user = User.objects.get(id=user_id)
            except User.DoesNotExist:
                not_found_users.append(user_id)
                continue
            
            if remove_user not in groupe.members.all():
                not_in_group.append(remove_user.email)
                continue
            
            groupe.members.remove(remove_user)
            removed_users.append(remove_user.email)

        groupe.save()

        return Response({
            "message": f"Action by {request.user.email} on group {groupe.groupe_name}",
            "removed_users": removed_users,
            "not_found_users": not_found_users,
            "not_in_group": not_in_group,
            "remaining_members": [user.email for user in groupe.members.all()]
        }, status=status.HTTP_200_OK)
    else:
        return Response({
            "error":"you are not owner of this group"
        })
        
   

#!change profile and  name  by groupe  owner 


@api_view(['PATCH'])
@permission_classes([Isowner])
@parser_classes([MultiPartParser, FormParser])

def update_name_profile(request,g_id):
    if not request.data.get("groupe_name"):
        
         return Response({
             "error":"groupe name is required"
         })
    image= request.FILES.get('profile_image')
    
    
    try:
        groupe= GroupeChatModel.GroupesChat.objects.get(id=g_id)
        
    except  GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error":"groupe dont found"
        })
        
    
    ser= groupeserializer.GroupesSerializer(groupe,data=request.data,partial= True)
    if ser.is_valid():
        ser.save()
        return Response({
            "message":"update done",
            "stutas":status.HTTP_200_OK,
            "data":ser.data,
            
            
        })




#! deleted the groupe
@api_view(['DELETE'])
@permission_classes([Isowner])

def delete_groupe(request,g_id):

    try:
        groupe= GroupeChatModel.GroupesChat.objects.get(id=g_id)
    except  GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error":"groupe dont found"
        })
        
    if request.user== groupe.owner:
        groupe.delete()
        return Response({
            "message":"groupe deleted",
            "status":status.HTTP_200_OK
        })
    else:
        return Response({
            "error":"you are not owner of this group"
        })

#! give all memebr  of groupe

@api_view(['GET'])
@permission_classes([Isowner])
def all_groupe_member(request,g_id):
    
    
    groupe= GroupeChatModel.GroupesChat.objects.get(id= g_id)
    mem= groupe.members.all()
    ser= UserSerializer(mem,many=True)
    return Response({
        "memebr":ser.data,
    })
    
    
    
    
#! make  if user want  to add in the groupe  tha show request list  of users
class request_to_add_groupe(APIView):
    pass
    

