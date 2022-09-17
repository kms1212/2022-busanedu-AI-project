from django.apps import AppConfig
from . import detect


class ObjdetectionConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'objdetection'

    def ready(self):
        detect.start_worker('best.pt', 'cpu')

