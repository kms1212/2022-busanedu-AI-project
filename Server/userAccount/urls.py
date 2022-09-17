from django.urls import path, include
from . import views

urlpatterns = [
    path('signup', views.UserCreate.as_view()),
    path('profile', views.UserProfile.as_view()),
    path('greet', views.UserGreet.as_view()),
    path('', include('rest_framework.urls')),
]
