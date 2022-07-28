from django.db import models
from django.contrib.auth.models import User
from django.core.files.storage import FileSystemStorage
from django.conf import settings


class TModels(models.Model):    
    owner = models.ForeignKey(User, default=None, on_delete=models.CASCADE)
    file = models.FileField(
                            upload_to='TrainedModels', 
                            default='settings.MEDIA_ROOT/default.jpg'
                            )
    
