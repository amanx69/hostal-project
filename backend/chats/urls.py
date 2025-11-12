from django.urls import path
from .views import chatviews ,groupeviews
from .views.groupe_features import owner_feathures, member_features, Groupe_features

urlpatterns = [
    path('create_chat/', chatviews.chatview.as_view(), name='create_chat'),
    path("<int:room_id>/send-message/", chatviews.Sendmessage.as_view(), name='send_message'),


    path("create_groupe/", groupeviews.create_groupe, name='create_groupe'),
    path("<int:groupe_id>/add_users/", groupeviews.add_memeber, name='add_member'),
    
    
    #! groupe 
    path("<int:g_id>/qr_code/", Groupe_features.qr_code, name='qr_code'),
    
    
    
    #! owner feathures
    path("<int:g_id>/remove/", owner_feathures.remove_member, name='add_member'),
    path("<int:g_id>/groupe_edit/",owner_feathures.update_name_profile,name= "groupd_update"),
    path("<int:g_id>/all/", owner_feathures.all_groupe_member, name=''),
    path("<int:g_id>/delete/", owner_feathures.delete_groupe, name='delete_groupe'),
    
    #! user based feathures
    path("<int:g_id>/leave/", member_features.leave_groupe, name='leave_groupe'),
    
]

