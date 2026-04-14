from  django.urls import path
from apps.post.views import post_views,comment_views,like_views,following_Views
from rest_framework.routers import DefaultRouter

router= DefaultRouter()
router.register('posts', post_views.PostViewSet, basename='post-viewset')
urlpatterns= router.urls

   
urlpatterns += [
    # Likes
    path("like/<int:post_id>/", like_views.Likepost.as_view(), name="toggle_like"),
    # Comments
    path("comments/<int:post_id>/", comment_views.CommentsForPost.as_view(), name="comments_for_post"),
    # Follow / unfollow
    path("follow/<int:user_id>/", following_Views.Follow.as_view(), name="follow_user"),
    path("follow/<int:user_id>/unfollow/", following_Views.unfollow.as_view(), name="unfollow_user"),
    # Following / followers lists
    path("following/<int:user_id>/", following_Views.FollowingList.as_view(), name="following_list"),
    path("followers/<int:user_id>/", following_Views.FollowersList.as_view(), name="followers_list"),
]