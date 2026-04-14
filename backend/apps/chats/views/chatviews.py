from  rest_framework.views import  APIView
from  rest_framework.response import  Response
from rest_framework import status
from  apps.chats.Models import ChatModel
from apps.users.models import  User
from  django.shortcuts import  get_object_or_404
from rest_framework.permissions import  IsAuthenticated
from  apps.chats.serializers import roomserializer
from  apps.chats.serializers import  msgserializer
from  apps.chats.serializers import roomserializer


    #! create  a  chatroom  between  two users
class chatview(APIView):
    permission_classes=[IsAuthenticated]
    def post(self,  request):
        user1= request.user
        user2= request.data.get("user2_id")
        if  not  user2:
            return  Response({
                "error":"user2_id  is  required",
            }, status=status.HTTP_400_BAD_REQUEST
            )
        if  user1.id== int(user2):
            return  Response({
                "error":"Cannot  create  chatroom  with  yourself",
            }, status=status.HTTP_400_BAD_REQUEST
            )
            
        targateuser= get_object_or_404(User,id= user2)
        create= ChatModel.ChatRoom.objects.create(user1=user1,user2=targateuser)
        ser= roomserializer.RoomSerializer(create)
        return  Response({
            "message":"chatroom  created  successfully",
            "chatroom_id": create.id,
            "userdata":ser.data,
        }, status=status.HTTP_201_CREATED
        ) 
        
        
            

            
                
#! fatch  all  list of  login user  chatmodel



class Chatroomlist(APIView):
    permission_classes= [IsAuthenticated]
    
    def get(self, request):
        rooms = ChatModel.ChatRoom.objects.filter(user1=request.user) | ChatModel.ChatRoom.objects.filter(user2=request.user)
        ser = roomserializer.RoomSerializer(rooms, many=True, context={"request": request})
        return Response({"rooms": ser.data}, status=status.HTTP_200_OK)
        
        



     