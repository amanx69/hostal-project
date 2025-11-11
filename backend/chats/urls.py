from django.urls import path
from .views import chatviews ,groupeviews
from .views.groupe_features import owner_feathures
urlpatterns = [
    path('create_chat/', chatviews.chatview.as_view(), name='create_chat'),
    path("<int:room_id>/send-message/", chatviews.Sendmessage.as_view(), name='send_message'),


    path("create_groupe/", groupeviews.create_groupe, name='create_groupe'),
    path("<int:groupe_id>/add_users/", groupeviews.add_memeber, name='add_member'),
    #! groupe feature
    path("<int:g_id>/remove/", owner_feathures.remove_member, name='add_member'),
    path("<int:g_id>/groupe_edit/",owner_feathures.update_name_profile,name= "groupd_update"),
    path("<int:g_id>/all/", groupeviews.member, name=''),
]
