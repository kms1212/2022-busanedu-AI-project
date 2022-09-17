"""
ASGI config for project project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.0/howto/deployment/asgi/
"""

import os

import django.dispatch
from django.core.asgi import get_asgi_application
import atexit

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')

http_application = get_asgi_application()

import project.urls as urls
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path
import objdetection.detect as detect


def exit_handler():
    detect.stop_worker()

atexit.register(exit_handler)

application = ProtocolTypeRouter({
    'http': http_application,

    'websocket': AuthMiddlewareStack(
        URLRouter([
            path('ws/', urls.websocket_urlpatterns)
        ])
    ),
})
