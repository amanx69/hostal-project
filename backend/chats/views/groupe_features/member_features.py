from  rest_framework.decorators import api_view, permission_classes
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from chats.Models import GroupeChatModel 
from datetime import datetime




#! user  leave  the  groupe  
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])

def leave_groupe(request,g_id):
    
    try:
        groupe= GroupeChatModel.GroupesChat.objects.get(id= g_id)
    except GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error":"groupe dont found"
        })
        
    if request.user in groupe.members.all():
        groupe.members.remove(request.user)
        #! make  in groupemeber  leave  the  groupe
        leave_user= GroupeChatModel.Groupemembers.objects.get(member=request.user,groupe=groupe)
        leave_user.leave_at= datetime.now()
        leave_user.save()
        groupe.save()
        
        return Response({
            "message":"leave done",
            "leaved_user":request.user.username,
            "join_at":leave_user.joined_at,
            "leave_at":leave_user.leave_at,
            "status":status.HTTP_200_OK
        })
        
    else:
        return Response({
            "error":"you are not member of this group"
        })


