from  celery import shared_task
from  django.core.mail import EmailMultiAlternatives


@shared_task
def password_verifiction_email(email, uid, token):
    
    link = f"http://localhost:8000/auth/password-reset/confirm/{uid}/{token}/"
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