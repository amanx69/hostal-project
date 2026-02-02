from django.urls import path
from .views import *


urlpatterns = [
    path('profile/', get_user_profile, name='profile'),
    path('profile/<int:user_id>/', get_profile, name='profile-view'),#! fro text on browser 
]
