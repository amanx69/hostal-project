import qrcode
from rest_framework.decorators import  api_view,permission_classes
from rest_framework.response import  Response
from rest_framework.permissions import  IsAuthenticated
from chats.Models import GroupeChatModel
import json
from io import BytesIO
from django.core.files import File

#! gernate  the  url to join the group

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def  qr_code(request, g_id:int):
    
    try:
        groupe= GroupeChatModel.GroupesChat.objects.get(id=g_id)
    except  GroupeChatModel.GroupesChat.DoesNotExist:
        return Response({
            "error":"groupe dont found",
        })
        
    data= {
        "groupe_id":groupe.id,
        "groupe_name":groupe.groupe_name,
        "profile":groupe.groupe_profile_image.url if groupe.groupe_profile_image else None,
        "groupe_owner":groupe.owner.username,
        "memeber":groupe.members.all().count(),
        
    }
    jsondata= json.dumps(data)


    qr= qrcode.QRCode(
        
        version=1,  
        error_correction=qrcode.constants.ERROR_CORRECT_L,  # error correction level
        box_size=10,  # size of each box in pixels
        border=4,
        
    )
    qr.add_data(jsondata)
    qr.make(fit=True)
    
    
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)

    
    file_name = f"qr_{groupe.groupe_name}.png"
    groupe.qr_code.save(file_name, File(buffer), save=True)
    buffer.close()

    return Response({
        "success": True,
        "message": "QR code generated successfully!",
        "qr_code_url": groupe.qr_code.url,
        "file":file_name,
    })
    
  
    
    
   

    
   
    
   
    
    
    
    


#! gernate the qr code for the group to join the user  



#! scan the qr to jion the groupe  

