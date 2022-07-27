from django.db import models
from django.contrib.auth.models import User

class TData(models.Model):    
    owner = models.ForeignKey(User, default=None, on_delete=models.CASCADE)

    # Accelerometer
    ax = models.FloatField()
    ay = models.FloatField()
    az = models.FloatField()

    # Gyroscope
    gx = models.FloatField()
    gy = models.FloatField()
    gz = models.FloatField()

    # Distance

    # Temperature

    
