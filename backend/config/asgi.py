"""
ASGI config for backend project.
"""

import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import re_path


from apps.chats.CustomMidwereForJwt import JWTAuthMiddleware
import apps.chats.routing

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddleware(
        URLRouter(
            apps.chats.routing.websocket_urlpatterns
        )
    )
})