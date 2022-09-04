from django.contrib import admin
from . models import Profile
from django.db.models.signals import pre_delete
from django.dispatch.dispatcher import receiver

admin.site.register(Profile)

@receiver(pre_delete, sender=Profile)
def onProfileDelete(sender, instance, **kwargs):
    # Pass false so ImageField doesn't save the model.
    if instance.image.name != 'default.jpg':
        instance.image.delete(False)