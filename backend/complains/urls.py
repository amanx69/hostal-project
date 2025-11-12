from django.urls import path
from .views import *




urlpatterns = [
    path("create/",Createcomplain.as_view(),name="createcomplain"),
    
]
