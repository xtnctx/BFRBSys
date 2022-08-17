from django.contrib import admin
from .models import TrainedModel, TrainingStatus

# Register your models here.
admin.site.register(TrainedModel)
admin.site.register(TrainingStatus)