from chats.Models import GroupeChatModel
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status




@api_view(['POST'])
@permission_classes([IsAuthenticated])

def create_groupe(request):
    Groupe_name= request.data.get("groupe_name")
    if not Groupe_name or Groupe_name.strip() == "":
        return Response({
            "error":"Groupe name cannot be empty."
        },status=status.HTTP_400_BAD_REQUEST)
        
    if GroupeChatModel.GroupesChat.objects.filter(groupe_name=Groupe_name).exists():
        return Response({
            "error":"Groupe name already exists."
        },status=status.HTTP_400_BAD_REQUEST)
        
    groupe= GroupeChatModel.GroupesChat.objects.create(
        groupe_name= Groupe_name,
        owner= request.user,
    )
    return Response({
        "message":"Groupe created successfully",
        "groupe_id": groupe.id,
        "groupe_name": groupe.groupe_name,
        "ownner": groupe.owner.username
    })