import os
from django.shortcuts import render
import project.settings as settings
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.files.base import ContentFile
from rest_framework import generics, status
from rest_framework.response import Response
from .serializers import ResponseSerializer, RequestSerializer
from django.core.cache import cache


# Create your views here.
class RequestDetection(generics.CreateAPIView, LoginRequiredMixin):
    http_method_names = ['post']
    serializer_class = RequestSerializer

    def post(self, request):
        # create the folder if it doesn't exist.
        try:
            os.mkdir(os.path.join(settings.MEDIA_ROOT, 'odRequest'))
        except:
            pass

        # save the uploaded file inside that folder.
        full_filename = os.path.join(settings.MEDIA_ROOT, 'odRequest', request.user.userid)
        fout = open(full_filename, 'wb+')

        file_content = ContentFile(request.FILES['image'].read())

        # Iterate through the chunks.
        for chunk in file_content.chunks():
            fout.write(chunk)
        fout.close()

        cache.set('objdetection.cache!request_image@' + request.user.userid, full_filename)

        return Response(data="OK", status=status.HTTP_202_ACCEPTED)

def monitor(request):
    return render(request, 'ResponseMonitor.html', {})
