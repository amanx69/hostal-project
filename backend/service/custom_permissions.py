from rest_framework.permissions import BasePermission

class Isowner(BasePermission):
    def ha_object_permission(self, request, view, obj):
        return   request.user.is_authenticated and obj.owner == request.users