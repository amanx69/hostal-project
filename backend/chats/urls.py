from django.urls import path
from .views import chatviews ,groupeviews

urlpatterns = [
    path('create_chat/', chatviews.chatview.as_view(), name='create_chat'),
    path("<int:room_id>/send-message/", chatviews.Sendmessage.as_view(), name='send_message'),
    path("create_groupe/", groupeviews.create_groupe, name='create_groupe'),
]
