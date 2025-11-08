import jwt
from channels.middleware import BaseMiddleware
from django.conf import settings
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.tokens import UntypedToken
from jwt import InvalidTokenError
from urllib.parse import parse_qs
from channels.db import database_sync_to_async
from  users.models import User




@database_sync_to_async
def get_user(validated_token):
    try:
        user_id = validated_token['user_id']
        return User.objects.get(id=user_id)
    except User.DoesNotExist:
        return AnonymousUser()


class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        # Extract token from query string
        query_string = parse_qs(scope["query_string"].decode())
        token = query_string.get("token", [None])[0]

        if token is None:
            scope["user"] = AnonymousUser()
            return await super().__call__(scope, receive, send)

        try:
            # Decode the JWT
            validated_token = UntypedToken(token)
            decoded_data = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
            scope["user"] = await get_user(decoded_data)
        except InvalidTokenError:
            scope["user"] = AnonymousUser()

        return await super().__call__(scope, receive, send)