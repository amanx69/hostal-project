from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import *


urlpatterns = [
    path("signup/", Signup.as_view(), name="signup"),
    path("Login/", Login.as_view(), name="login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("verify-email/<uid>/<token>/", VerifyEmail.as_view()),
]
