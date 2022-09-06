from django.contrib import admin
from .models import TrainedModel, TrainingStatus
from django.db.models.signals import pre_delete
from django.dispatch.dispatcher import receiver

# Register your models here.
admin.site.register(TrainedModel)
admin.site.register(TrainingStatus)

admin.site.site_header = 'BFRBSys Admin'
admin.site.site_title = 'BFRBSys'

@receiver(pre_delete, sender=TrainedModel)
def onTrainedModelDelete(sender, instance, **kwargs):
    # Pass false so FileField doesn't save the model.
    instance.file.delete(False)