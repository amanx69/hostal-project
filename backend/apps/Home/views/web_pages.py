from django.shortcuts import render


def login_page(request):
    return render(request, "web/login.html")


def signup_page(request):
    return render(request, "web/signup.html")


def posts_page(request):
    return render(request, "web/posts.html")


def profile_page(request, user_id: int):
    return render(request, "web/profile.html", {"user_id": user_id})


def me_page(request):
    # Template will use `-1` and then fetch `/pro/profile/` to render the real user.
    return render(request, "web/profile.html", {"user_id": -1})


