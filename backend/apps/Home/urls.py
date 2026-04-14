from django.urls import path

from .views.web_pages import login_page, signup_page, posts_page, profile_page, me_page

urlpatterns = [
    path("", posts_page, name="web-posts"),
    path("login/", login_page, name="web-login"),
    path("signup/", signup_page, name="web-signup"),
    path("profile/<int:user_id>/", profile_page, name="web-profile"),
    path("me/", me_page, name="web-my-profile"),
]

