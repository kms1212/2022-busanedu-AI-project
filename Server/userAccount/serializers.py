from .models import User
from rest_framework import serializers


class UserSerializer(serializers.ModelSerializer):
    def create(self, validated_data):
        user = User.objects.create_user(
            userid=validated_data['userid'],
            username=validated_data['username'],
            email=validated_data['email'],
            usertype=validated_data['usertype'],
            password=validated_data['password'],
            firstname=validated_data['firstname'],
            lastname=validated_data['lastname'],
            birthdate=validated_data['birthdate'],
            schoolcode1=validated_data['schoolcode1'],
            schoolcode2=validated_data['schoolcode2'],
            schoolgrade=validated_data['schoolgrade'],
            schoolclass=validated_data['schoolclass'],
            schoolpid=validated_data['schoolpid'],
            allergyinfo=validated_data['allergyinfo']
        )
        return user

    class Meta:
        model = User
        fields = ['userid',
                  'username',
                  'email',
                  'usertype',
                  'password',
                  'firstname',
                  'lastname',
                  'birthdate',
                  'schoolcode1',
                  'schoolcode2',
                  'schoolgrade',
                  'schoolclass',
                  'schoolpid',
                  'allergyinfo']


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['userid',
                  'username',
                  'profileimage',
                  'description']


class DetailedUserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['userid',
                  'username',
                  'email',
                  'profileimage',
                  'description',
                  'usertype',
                  'firstname',
                  'lastname',
                  'birthdate',
                  'schoolcode1',
                  'schoolcode2',
                  'schoolgrade',
                  'schoolclass',
                  'schoolpid',
                  'allergyinfo']
