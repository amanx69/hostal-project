from  django.urls import path
from .views import ProfileOrBioView


urlpatterns = [
    path('profileorbio/',ProfileOrBioView.as_view(),name='profileorbio'),
]
