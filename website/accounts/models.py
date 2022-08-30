from django.db import models
from django.contrib.auth.models import User
from PIL import Image

class Profile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="user")
    image = models.ImageField(default='default.jpg', upload_to='ProfilePics')
    phone = models.CharField(max_length=50, default='Not set')
    organization = models.CharField(max_length=150, default='Not set')

    def __str__(self):
        return self.user.username
    
    def save(self):
        super().save()

        img = Image.open(self.image.path)
        
        if img.height > 300 or img.width > 300:
            output_size = (300, 300)
            img.thumbnail(output_size)
            img.save(self.image.path)
