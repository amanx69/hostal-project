from django.urls import path
from .views import *
from apps.complains.features import solved_comnplain,unsolve_complian



urlpatterns = [
    path("create/",Createcomplain.as_view(),name="createcomplain"),
    path("get/", Createcomplain.as_view(),name="getcomplain"),
    
    #! solve complain
    path("unsolved/",unsolve_complian.Unsolved_complain,name="unsolved_complain"),
    
]
