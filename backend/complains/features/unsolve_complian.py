from  rest_framework.decorators  import api_view,permission_classes
from rest_framework.response import  Response
from complains.models import complain
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from  complains.serializer import ComplainSerializer





@api_view(['GET'])
@permission_classes([IsAuthenticated])

def Unsolved_complain(request):
    
    comp= complain.objects.filter(status=False)
    ser= ComplainSerializer(comp,many=True)
    return Response(ser.data,status=status.HTTP_200_OK)  