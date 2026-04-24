from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import *


urlpatterns = [
    path("signup/", Signup.as_view(), name="signup"),
    path("Login/", Login.as_view(), name="login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("resend-code/",ResendVerificationView.as_view(),name="resend_verify"),
    path("verify-email/<uid>/<token>/", VerifyEmail.as_view()),
    path('password-reset/', RequestPasswordResetView.as_view()),
    path('password-reset/confirm/<uid>/<token>/', ConfirmPasswordResetView.as_view()),
    path("logout/",LogoutView.as_view(),name="logout"),
    path("search/", SearchUsers.as_view(), name="search_users"),
]
