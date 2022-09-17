import os
from uuid import uuid4
from django.utils.deconstruct import deconstructible


@deconstructible
class PathAndRename(object):
    def __init__(self, subdir):
        self.path = subdir

    def __call__(self, instance, filename):
        ext = filename.split('.')[-1]
        # get filename
        if instance.pk:
            filename = '{}.{}'.format(instance.pk, ext)
        else:
            # set filename as random string
            filename = '{}.{}'.format(uuid4().hex, ext)
        # return the whole path to the file
        return os.path.join(self.path, filename)