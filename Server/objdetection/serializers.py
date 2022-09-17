from rest_framework import serializers


class ResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    class_num = serializers.IntegerField(required=True)
    xpos = serializers.IntegerField(required=True)
    ypos = serializers.IntegerField(required=True)
    width = serializers.IntegerField(required=True)
    height = serializers.IntegerField(required=True)


class RequestSerializer(serializers.Serializer):
    image = serializers.ImageField(required=True)
