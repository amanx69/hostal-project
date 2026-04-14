from PIL import Image
from django.core.files.base import ContentFile
import io
from celery import shared_task

@shared_task
def process_image(uploaded_file, image_name):
    img = Image.open(uploaded_file)

    
    img = img.resize((800, 800))

    img_io = io.BytesIO()
    img.save(img_io, format='JPEG', quality=70)

    return ContentFile(img_io.getvalue(), name= f"post_image{image_name}")