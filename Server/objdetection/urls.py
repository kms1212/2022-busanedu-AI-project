from channels.routing import URLRouter
from django.urls import path, include
from . import views, consumers
from rest_framework import urls

websocket_urlpatterns = URLRouter([
    path('response', consumers.InferenceDataConsumer.as_asgi()),
])

urlpatterns = [
    path('request', views.RequestDetection.as_view()),
    path('monitor', views.monitor),
]
