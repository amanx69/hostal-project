from django.contrib import admin
from  .Models import  ChatModel, GroupeChatModel
# Register your models here.
admin.site.register(ChatModel.ChatRoom)
admin.site.register(ChatModel.Message)
admin.site.register(GroupeChatModel.GroupesChat)
admin.site.register(GroupeChatModel.Groupemessgae)