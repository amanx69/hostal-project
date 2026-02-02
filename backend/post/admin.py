from django.contrib import admin

# Register your models hererom 
from .models import  post_model, comment_model ,like_model,FollowingSystem_model


admin.site.register(post_model.Post)
admin.site.register(comment_model.Comment)
admin.site.register(like_model.Likes)
admin.site.register(FollowingSystem_model.FollowingSystem)