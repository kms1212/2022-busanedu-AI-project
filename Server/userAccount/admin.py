from django.contrib import admin
from .models import User
import django.contrib.auth.models as authmodels

# Register your models here.
admin.site.register(User)
