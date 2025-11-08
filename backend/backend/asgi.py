"""
ASGI config for backend project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application

from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from chats.consumer.chat_consumer import ChatConsumer
from  django.urls import  re_path
from chats.CustomMidwereForJwt import JWTAuthMiddleware

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")



application = ProtocolTypeRouter({
    "http": get_asgi_application(),
      'websocket': JWTAuthMiddleware(
        URLRouter(
            [
                
            re_path(r'ws/chat/(?P<user2_id>\w+)/(?P<room_id>\w+)/$', ChatConsumer.as_asgi()),
           
                
            ]
        )
      )
       
 
})

