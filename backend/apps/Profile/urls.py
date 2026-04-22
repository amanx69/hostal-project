from django.urls import path
from .views import *


urlpatterns = [
    path('profile/', get_user_profile, name='profile'),
    path('profile/<int:user_id>/', get_profile, name='profile-view'),#! fro text on browser 
    path('profile/update/', UpdateProfileView.as_view(), name='update_profile'),
    path("resume-rating/",resume_rating, name='resume_rating'),
]
