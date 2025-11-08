from rest_framework.views import APIView
from rest_framework.response import Response    
from rest_framework import status
from .Serlializer import ProfileOrBioSerializer
from users.models import User
from django.shortcuts import get_object_or_404  
# Create your views here.


class ProfileOrBioView(APIView):
    
    #! in future  profile  pic  check karn   haiye
    
    def patch(self,request):

        # Assuming you have authentication set up and the user is logged in
        id = request.user.id
        
        targateuser= get_object_or_404(User, id=id)
        ser= ProfileOrBioSerializer(targateuser,data=request.data, partial=True)
        if ser.is_valid():
            ser.save()
            return Response({
                "message":"profile updated successfully",
                "data":ser.data
            })
        return Response(ser.errors,status=status.HTTP_400_BAD_REQUEST)
        