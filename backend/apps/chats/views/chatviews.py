from  rest_framework.views import  APIView
from  rest_framework.response import  Response
from rest_framework import status
from  apps.chats.Models import ChatModel
from apps.users.models import  User
from  django.shortcuts import  get_object_or_404
from rest_framework.permissions import IsAuthenticated
from apps.chats.serializers import roomserializer, msgserializer
from django.db.models import Q
from service.response import success_response as _success, error_response as _error


    #! create  a  chatroom  between  two users
class chatview(APIView):
    permission_classes=[IsAuthenticated]
    def post(self,  request):
        user1= request.user
        user2= request.data.get("user2_id")
        if not user2:
            return _error("user2_id is required", http_status=status.HTTP_400_BAD_REQUEST)
            
        if user1.id == int(user2):
            return _error("Cannot create chatroom with yourself", http_status=status.HTTP_400_BAD_REQUEST)
            
        target_user = get_object_or_404(User, id=user2)
        
        # Check if chatroom already exists
        existing_room = ChatModel.ChatRoom.objects.filter(
            Q(user1=user1, user2=target_user) | Q(user1=target_user, user2=user1)
        ).first()
        
        if existing_room:
            ser = roomserializer.RoomSerializer(existing_room, context={"request": request})
            return _success({
                "message": "Chatroom already exists",
                "chatroom_id": existing_room.id,
                "userdata": ser.data,
            }, http_status=status.HTTP_200_OK)
            
        create = ChatModel.ChatRoom.objects.create(user1=user1, user2=target_user)
        ser = roomserializer.RoomSerializer(create, context={"request": request})
        return _success({
            "message": "Chatroom created successfully",
            "chatroom_id": create.id,
            "userdata": ser.data,
        }, http_status=status.HTTP_201_CREATED) 
        
        
            

            
                
#! fatch  all  list of  login user  chatmodel



class Chatroomlist(APIView):
    permission_classes= [IsAuthenticated]
    
    def get(self, request):
        rooms = ChatModel.ChatRoom.objects.filter(Q(user1=request.user) | Q(user2=request.user))
        ser = roomserializer.RoomSerializer(rooms, many=True, context={"request": request})
        return _success({"rooms": ser.data}, http_status=status.HTTP_200_OK)

class GetMessages(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request, room_id):
        # First try 1-on-1 chat
        try:
            room = ChatModel.ChatRoom.objects.get(id=room_id)
            if room.user1 != request.user and room.user2 != request.user:
                return _error("Not authorized", http_status=status.HTTP_403_FORBIDDEN)
                
            messages = ChatModel.Message.objects.filter(ChatRoom=room).order_by('-created_at')[:50]
            
            formatted_messages = []
            for msg in messages:
                formatted_messages.append({
                    "message": msg.text,
                    "sender_id": msg.sender.id,
                    "sender_email": msg.sender.email,
                    "room_id": room_id,
                })
            return _success({"messages": formatted_messages}, http_status=status.HTTP_200_OK)
            
        except ChatModel.ChatRoom.DoesNotExist:
            from apps.chats.Models import GroupeChatModel
            # Try Group Chat
            try:
                group = GroupeChatModel.GroupesChat.objects.get(id=room_id)
                if request.user not in group.members.all() and group.owner != request.user:
                    return _error("Not authorized", http_status=status.HTTP_403_FORBIDDEN)
                    
                messages = GroupeChatModel.Groupemessgae.objects.filter(groupe=group).order_by('-sent_at')[:50]
                
                formatted_messages = []
                for msg in messages:
                    formatted_messages.append({
                        "message": msg.messsage_text,
                        "sender_id": msg.sender.id,
                        "sender_email": msg.sender.email,
                        "room_id": room_id,
                    })
                return _success({"messages": formatted_messages}, http_status=status.HTTP_200_OK)
                
            except GroupeChatModel.GroupesChat.DoesNotExist:
                return _error("Room not found", http_status=status.HTTP_404_NOT_FOUND)
        
        



     