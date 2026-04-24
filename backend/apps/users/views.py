from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .Serializer import UserSerializer, LoginSerializer
from rest_framework.permissions import IsAuthenticated
from .models import User
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate
from django.utils.http import urlsafe_base64_decode
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth import get_user_model
from service.gernateToken import generate_verification_token
from service.SendEmail import send_verification_email, SendWelcomeEmail
from django.utils.decorators import method_decorator
from django_ratelimit.decorators import ratelimit
from django.utils.encoding import force_str
from django.core.cache import cache
from django.db.models import Q

User = get_user_model()


from service.jwt_utils import get_token
from service.response import success_response, error_response


# ---------------------------------------------------------------------------
# Auth views
# ---------------------------------------------------------------------------

class Signup(APIView):
    throttle_scope = "signup"

    @method_decorator(ratelimit(key="ip", rate="4/m", method="POST"))
    def post(self, request) -> Response:
        ser = UserSerializer(data=request.data)
        if ser.is_valid(raise_exception=True):
            user = ser.save()
            return success_response(
                {
                    "message": "Signup successful. Please check your email to verify your account.",
                    "email": user.email,
                    "id": user.id,
                },
                http_status=status.HTTP_201_CREATED,
            )
        return error_response("Something went wrong.", errors=ser.errors)


class Login(APIView):
    throttle_scope = "login"

    @method_decorator(ratelimit(key="ip", rate="3/m", method="POST"))
    def post(self, request) -> Response:
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            email = serializer.validated_data["email"]
            password = serializer.validated_data["password"]
            user = authenticate(email=email, password=password)
            if user is None:
                return error_response(
                    "Invalid email or password.",
                    http_status=status.HTTP_401_UNAUTHORIZED,
                )
            token = get_token(user)
            return success_response(
                {
                    "message": "Login successful.",
                    "access": token["access"],
                    "refresh": token["refresh"],
                    "user": UserSerializer(user).data,
                }
            )


class VerifyEmail(APIView):
    """Verify a user's email address via uid + token link."""

    def get(self, request, uid, token):
        # -- cache check: avoid re-verifying the same token --
        cache_key = f"email_verify_{uid}_{token}"
        if cache.get(cache_key):
            return error_response(
                "This verification link has already been used.",
                http_status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            try:
                user_id = urlsafe_base64_decode(uid).decode()
            except Exception:
                return error_response("Invalid verification link.", http_status=status.HTTP_400_BAD_REQUEST)

            try:
                user = User.objects.get(pk=user_id)
            except User.DoesNotExist:
                return error_response("User not found.", http_status=status.HTTP_404_NOT_FOUND)

            if user.is_verified:
                return success_response({"message": "Email is already verified."})

            if not default_token_generator.check_token(user, token):
                return error_response(
                    "Invalid or expired verification token.",
                    http_status=status.HTTP_400_BAD_REQUEST,
                )

            user.is_verified = True
            user.save(update_fields=["is_verified"])

            # Mark link as used (token validity window ~1 day, cache for 2 days)
            cache.set(cache_key, True, timeout=172800)

            jwt_token = get_token(user)
            return success_response(
                {
                    "message": "Email verified successfully.",
                    "access": jwt_token["access"],
                    "refresh": jwt_token["refresh"],
                }
            )
        except Exception as e:
            return error_response(str(e), http_status=status.HTTP_400_BAD_REQUEST)


class ResendVerificationView(APIView):
    """Resend the email verification link for an unverified account."""

    #! This endpoint must be public so unauthenticated users can request a resend.
    permission_classes = []

    def post(self, request):
        email = (request.data.get("email") or "").strip()
        if not email:
            return error_response("Email is required.", http_status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.filter(email__iexact=email).first()
        if not user:
            # Don't reveal whether the email exists (security)
            return success_response(
                {"message": "If that email is registered, a verification link has been sent."}
            )
        if user.is_verified:
            return success_response({"message": "This email is already verified.", "is_verified": True})

        uid, token = generate_verification_token(user)
        send_verification_email.delay(email=user.email, uid=uid, token=token)
        return success_response(
            {"message": "Verification link sent to your email."},
            http_status=status.HTTP_200_OK,
        )


class RequestPasswordResetView(APIView):
    """Send a password-reset link to the user's email."""

    permission_classes = []  

    @method_decorator(ratelimit(key="ip", rate="3/m", method="POST"))
    def post(self, request):
        email = (request.data.get("email") or "").strip()
        if not email:
            return error_response("Email is required.", http_status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.filter(email__iexact=email).first()
        if user:
            uid, token = generate_verification_token(user)
            SendWelcomeEmail.delay(email=user.email, uid=uid, token=token)

        return success_response(
            {"message": "If that email is registered, a password reset link has been sent."},
            http_status=status.HTTP_200_OK,
        )


class ConfirmPasswordResetView(APIView):
    """Confirm password reset using uid + token from the email link."""

    permission_classes = []  # public — user is not authenticated

    @method_decorator(ratelimit(key="ip", rate="3/m", method="POST"))
    def post(self, request, uid, token):
        new_password = (request.data.get("new_password") or "").strip()
        if not new_password:
            return error_response("New password is required.", http_status=status.HTTP_400_BAD_REQUEST)

        try:
            user_pk = force_str(urlsafe_base64_decode(uid))
            user = User.objects.get(pk=user_pk)
        except (User.DoesNotExist, ValueError):
            return error_response("Invalid reset link.", http_status=status.HTTP_400_BAD_REQUEST)

        if not default_token_generator.check_token(user, token):
            return error_response(
                "Invalid or expired reset token.",
                http_status=status.HTTP_400_BAD_REQUEST,
            )

        user.set_password(new_password)
        user.save(update_fields=["password"])
        return success_response({"message": "Password reset successful."})


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get("refresh")
        if not refresh_token:
            return error_response("Refresh token is required.", http_status=status.HTTP_400_BAD_REQUEST)

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except TokenError:
            return error_response("Invalid or expired token.", http_status=status.HTTP_400_BAD_REQUEST)

        return success_response({"message": "Logged out successfully."})

class SearchUsers(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        if not query:
            return success_response({"users": []})
            
        users = User.objects.filter(
            Q(email__icontains=query) | Q(username__icontains=query)
        ).exclude(id=request.user.id)[:20]
        
        results = []
        for u in users:
            results.append({
                "id": u.id,
                "email": u.email,
                "username": u.username,
            })
            
        return success_response({"users": results})