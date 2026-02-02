from  django.core.mail import send_mail
from django.conf import settings




    
def SendWelcomeEmail(user):
    
            subject = "Welcome to Our App!"
            message = f"Hi {user.username or user.email},\n\nThank you for registering with us!"
            from_email = settings.EMAIL_HOST_USER
            recipient_list = [user.email]

            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
