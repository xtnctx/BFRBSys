from django.db import models
from django.contrib.auth.models import User


class TModels(models.Model):    
    owner = models.ForeignKey(User, default=None, on_delete=models.CASCADE)
    file = models.FileField(
                            upload_to='TrainedModels', 
                            default='settings.MEDIA_ROOT/default.jpg'
                            )
    
