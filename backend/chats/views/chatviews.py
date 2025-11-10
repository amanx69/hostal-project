from  rest_framework.views import  APIView
from  rest_framework.response import  Response
from rest_framework import status
from  chats.Models import ChatModel
from users.models import  User
from  django.shortcuts import  get_object_or_404
from rest_framework.permissions import  IsAuthenticated
from  chats.serializers import roomserializer
from  chats.serializers import  msgserializer



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
        
        
            

            
                
#! send  massage  in chatroom


class Sendmessage(APIView):
     permission_classes= [IsAuthenticated]
     
     def post(self,request,room_id):
         sender=  request.user
         message= request.data.get("msg")
         
         room= ChatModel.ChatRoom.objects.filter(id= room_id).first()
         if room is  None:
                return  Response({
                    "error":"Chatroom  does  not  exist",
                }, status=status.HTTP_404_NOT_FOUND
                )
         
         
         if room.user1 != sender and room.user2 != sender:
                return  Response({
                    "error":"You  are  not  a  member  of  this  chatroom",
                }, status=status.HTTP_403_FORBIDDEN
                )
         
         if message is  None:
                return  Response({
                    "error":"Message  text  is  required",
                }, status=status.HTTP_400_BAD_REQUEST
                )
                
         msg= ChatModel.Message.objects.create(ChatRoom=room,sender= sender,text=message)
         
         ser= msgserializer.msgserializer(msg)
         return  Response({
            "message":"Message  sent  successfully",
            "msgdata": ser.data,
          
         }, status=status.HTTP_201_CREATED
         )
     