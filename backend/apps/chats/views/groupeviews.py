from apps.chats.Models import GroupeChatModel
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from  apps.users.Serializer import UserSerializer
from  drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from rest_framework.parsers import MultiPartParser, FormParser

User=get_user_model()


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])

def create_groupe(request):
    Groupe_name= request.data.get("groupe_name")
    image = request.FILES.get('profile_image')
    
    if not Groupe_name or Groupe_name.strip() == "":
        return Response({
            "error":"Groupe name cannot be empty."
        },status=status.HTTP_400_BAD_REQUEST)
        
        #! if groupe name is exit
        
    if GroupeChatModel.GroupesChat.objects.filter(groupe_name=Groupe_name).exists():
        return Response({
            "error":"Groupe name already exists."
        },status=status.HTTP_400_BAD_REQUEST)
        
    groupe= GroupeChatModel.GroupesChat.objects.create(
        groupe_name= Groupe_name,
        owner= request.user,
        groupe_profile_image= image or None
    )
    groupe.members.add(request.user)
    return Response({
        "message":"Groupe created successfully",
        "groupe_id": groupe.id,
        "groupe_name": groupe.groupe_name,
        "ownner": groupe.owner.email
    })
    
    
    
    
    
#! add the  user  in the  groupe  
@api_view(['POST'])
@permission_classes([IsAuthenticated])

def add_memeber(request,groupe_id):
    
    not_found_user=[]
    already_in_groupe=[]
    
    users:list= request.data.get("users",[])
    
    #! these  code  only  for add  one  person in groupe
    if not users:
        return Response({
            "error":"User list is required."
        },status=status.HTTP_400_BAD_REQUEST)
    
    try:
        groupe= GroupeChatModel.GroupesChat.objects.get(id= groupe_id)
    except GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error":"Groupe not found."
        },status=status.HTTP_404_NOT_FOUND)
        
    #! if  user in groupe  than add  memebr  in groupe
    if request.user == groupe.owner or request.user in groupe.members.all():
        
        if len(users)==1:
            
            user= users[0]
         
            try:
                adduser= User.objects.get(id= user)
                
            except User.DoesNotExist:
            
                return Response({
                    "error":"User not found."
                },status=status.HTTP_404_NOT_FOUND)
                #! if user already  in groupe
            if adduser in groupe.members.all():
                
                return Response({
                    "error":"user already in groupe"
                },status=status.HTTP_400_BAD_REQUEST)
                
                

            groupe.members.add(adduser)#! add  in groupe member
            groupe.save()
            
            return Response({
                "message": f"user{request.user.email} add in {adduser.email} in {groupe.groupe_name}" })
            
        else:
            
        #! these  code  for  add multiple  user  in  one  time
            if len(users)>1:
            
                for user_id in users:
                    
                    try:
                        adduser= User.objects.get(id= user_id)
                    except User.DoesNotExist:
                        not_found_user.append(user_id)
                        
                        #! if user already  in groupe
                    if adduser in groupe.members.all():
                        already_in_groupe.append(adduser.email)
                        continue
                    
                
                        
                
                    groupe.members.add(adduser)#! add  in groupe member
                
            
            groupe.save()
            added_users = [user.email for user in groupe.members.all()]
            return Response({
                "not_found_user":not_found_user,
                "already in groupe":already_in_groupe,
                "message": f"user{request.user.email} add in {added_users} in {groupe.groupe_name}"
            })     







