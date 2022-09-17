"""project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, re_path, include
from django.conf import settings
from django.conf.urls.static import static
from django.apps import apps
from channels.auth import AuthMiddlewareStack
from channels.routing import URLRouter
import objdetection.urls

websocket_urlpatterns = URLRouter([
    path('detect/', objdetection.urls.websocket_urlpatterns),
])

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('userAccount.urls')),
    path('detect/', include('objdetection.urls')),
    path('meal/', include('schoolMeal.urls')),
    re_path(r'^robots\.txt', include('robots.urls')),
]

apps.populate('objdetection')
