from  django.urls import path
from  post.views import post_views,comment_views,like_views,following_Views
from rest_framework.routers import DefaultRouter

router= DefaultRouter()
router.register('posts', post_views.PostViewSet, basename='post-viewset')
urlpatterns= router.urls

   
