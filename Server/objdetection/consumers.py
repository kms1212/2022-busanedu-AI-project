from channels.generic.websocket import WebsocketConsumer
import json
from rest_framework.renderers import JSONRenderer
from . import detect
from django.core.cache import cache
from objdetection.serializers import ResponseSerializer
from os import path

def callback(caller):
    def func(data):
        ser = ResponseSerializer(data, many = True)
        jsondata = JSONRenderer().render(ser.data)

        if caller.open:
            caller.data = jsondata.decode('utf-8')
            caller.send_message('INFERENCEOK')

    return func


class InferenceDataConsumer(WebsocketConsumer):
    user = None
    data = None
    open = False

    def do_inference(self, filepath):
        detect.request_inference(callback(self), filepath)

    def send_message(self, message):
        self.send(text_data=json.dumps({
            'message': message
        }))

    def connect(self):
        self.user = self.scope['user']
        self.accept()
        self.open = True

        self.send_message('READY')

    def disconnect(self, close_code):
        self.open = False

    def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        if message == 'START':
            filepath = cache.get('objdetection.cache!request_image@' + self.user.userid)
            if filepath is not None and path.exists(filepath):
                self.do_inference(filepath)
                self.send_message('OK')
            else:
                self.send_message('NOFILE')
        elif message == 'GETDATA':
            if self.data is None:
                self.send_message("NODATA")
            else:
                self.send_message(self.data)
        else:
            self.send_message('NOP')
