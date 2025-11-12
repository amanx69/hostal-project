from django.shortcuts import render
from  rest_framework.views import APIView
from  rest_framework.response import Response
from .models import  complain
from .serializer import ComplainSerializer
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
# Create your views here.



#! create  a  complain

class Createcomplain(APIView):
    permission_classes= [IsAuthenticated]
    
    def post(self,request):
        
        ser= ComplainSerializer(data= request.data, context={'request': request})
        if ser.is_valid():
            ser.save()
            return Response({
                "message":"complain created successfully",
                "data":ser.data
            })
        return Response(ser.errors,status=status.HTTP_400_BAD_REQUEST)