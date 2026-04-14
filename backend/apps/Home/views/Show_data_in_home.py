from  rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from users.Serializer import UserSerializer
from users.models import User


#! show  welcome  text  in  home  page
@api_view(['GET'])
def Show_first_text(request):
    
    return Response({
        "message":"welocome to my community",
        
    })



#! show  random profile in home page

