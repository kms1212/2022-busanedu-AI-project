from rest_framework.response import Response
from django.shortcuts import render
from .serializers import DetailedUserProfileSerializer, UserSerializer, UserProfileSerializer
from .models import User
from rest_framework import generics, status
from django.contrib.auth.mixins import LoginRequiredMixin


class UserCreate(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserProfile(generics.RetrieveAPIView):
    http_method_names = ['get']

    def get(self, request):
        userid = request.GET.get('userid', None)
        if userid is None: 
            if request.user.is_authenticated:
                userobj = User.objects.get(userid=request.user.userid)
                userser = DetailedUserProfileSerializer(userobj, many=False)

                return Response(data=userser.data)
            else:
                return Response(status=status.HTTP_401_UNAUTHORIZED)
        else:
            try:
                userobj = User.objects.get(userid=userid)
                userser = UserProfileSerializer(userobj, many=False)

                return Response(data=userser.data)
            except:
                return Response(status=status.HTTP_404_NOT_FOUND)

class UserGreet(LoginRequiredMixin, generics.GenericAPIView):
    http_method_names = ['get']

    def get(self, request):
        return Response(data='Hello, ' + request.user.username)
