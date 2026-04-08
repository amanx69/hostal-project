from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.core.exceptions import ValidationError
import re


# Custom Manager
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Users must have an email address")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)   
        user.full_clean()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, password, **extra_fields)


 ##!Custom User Model
class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True,blank=False)   # used for login
    created_at = models.DateTimeField(auto_now_add=True)
    is_verified = models.BooleanField(default=False)
   
    # Required fields
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = "email"   # login field
    REQUIRED_FIELDS = [""]   # when creating superuser
    read_only_fields = ["id", "email","created_at"]

    def __str__(self):
        return self.email
    
    
    
