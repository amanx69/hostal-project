from django.conf import settings
import  random
from  celery import shared_task
from  django.template.loader import render_to_string
from  django.core.mail import EmailMultiAlternatives

#TODO this fuction for send passwword reset chnage name in later 
@shared_task   
def SendWelcomeEmail(email ,uid,token):
    link = f"http://localhost:8000/api/auth/password-reset/confirm/{uid}/{token}/"
    print(link)

    html = f"""
    <h2>for reset your password</h2>
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
   



def generate_otp():
    otp_code = ''.join(random.choices('0123456789', k=6))
    return otp_code






#! send  verify email

@shared_task
def send_verification_email(email, uid, token):
    
    link = f"http://localhost:8000/api/auth/verify-email/{uid}/{token}/"
    print(link)

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