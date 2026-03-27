from  django.core.mail import send_mail
from django.conf import settings
import  random
from  celery import shared_task
from  django.template.loader import render_to_string
from  django.core.mail import EmailMultiAlternatives


@shared_task   
def SendWelcomeEmail(email:str):
    subject = "Welcome 🚀"
    from_email = settings.EMAIL_HOST_USER
    to = [email]

    html_content = render_to_string("email/Welcome.html", {
        "email": email,
    })

    msg = EmailMultiAlternatives(subject, "", from_email, to)
    msg.attach_alternative(html_content, "text/html")
    msg.send()
    
        
#     """        subject = "Welcome to Our App!"
#             message = f"Hi {email},\n\nThank you for registering with us!"
#             from_email = settings.EMAIL_HOST_USER
#             recipient_list = [email]

#             send_mail(subject, message, from_email, recipient_list, fail_silently=False)
#  """


def generate_otp():
    otp_code = ''.join(random.choices('0123456789', k=6))
    return otp_code






#! send  verify email
@shared_task
def send_verification_email(email, uid, token):
    
    link = f"http://localhost:8000/auth/verify-email/{uid}/{token}/"

    html = f"""
    <h2>Verify your email</h2>
    <p>Click below:</p>
    <a href="{link}">Verify Email</a>
    """

    msg = EmailMultiAlternatives(
        "Verify your email",
        "Click link to verify",
        "noreply@yourapp.com",
        [email]
    )
    msg.attach_alternative(html, "text/html")
    msg.send()