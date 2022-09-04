from django.db import models
from django.contrib.auth.models import User


class TrainedModel(models.Model):
    owner = models.ForeignKey(User, default=None, on_delete=models.CASCADE)
    model_name = models.CharField(max_length=150)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    file = models.FileField(
                            upload_to='TrainedModels', 
                            default='settings.MEDIA_ROOT/default.jpg'
                            )
    def __str__(self) -> str:
        return f'{self.owner.username}__{self.model_name}'


class TrainingStatus(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE)
    message_status = models.CharField(max_length=150)

    def __str__(self) -> str:
        return self.owner.username




