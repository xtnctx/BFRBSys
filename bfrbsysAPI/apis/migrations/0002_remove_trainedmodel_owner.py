# Generated by Django 4.1.3 on 2022-11-08 09:19

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('apis', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='trainedmodel',
            name='owner',
        ),
    ]