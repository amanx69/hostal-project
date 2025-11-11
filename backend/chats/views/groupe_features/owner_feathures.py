from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from users.models import User
from  users.Serializer import UserSerializer
from chats.Models import GroupeChatModel
from rest_framework.views import APIView
from chats.serializers.groupeser import groupeserializer


#! remove  users in  groupe  by only  owner  
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
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
                not_in_group.append(remove_user.username)
                continue
            
            groupe.members.remove(remove_user)
            removed_users.append(remove_user.username)

        groupe.save()

        return Response({
            "message": f"Action by {request.user.username} on group {groupe.groupe_name}",
            "removed_users": removed_users,
            "not_found_users": not_found_users,
            "not_in_group": not_in_group,
            "remaining_members": [user.username for user in groupe.members.all()]
        }, status=status.HTTP_200_OK)
    else:
        return Response({
            "error":"you are not owner of this group"
        })
        
   

#!change profile and  name  by groupe  owner 


@api_view(['PATCH'])

def update_name_profile(request,g_id):
    
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
            
            
        })




#! deleted the groupe
#! change the owner of groupe