from  django.urls import path
from  post.views import post_views,comment_views,like_views,following_Views

urlpatterns= [
    #! post  related  url
     path("uploadpost/",post_views.CreatePost.as_view(),name="uploadpost"),
     #!  following  system  related  url
   
]