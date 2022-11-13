from rest_framework import serializers
from .models import Item, TrainedModel
from django.contrib.auth.models import User
from rest_framework.validators import UniqueTogetherValidator
from django.contrib.auth import authenticate

class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = '__all__'

class TrainedModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainedModel
        fields = '__all__'



# class UserSerializer(serializers.ModelSerializer):
#     def create(self, validated_data):
#         user = User.objects.create_user(**validated_data)
#         return user

#     class Meta:
#         model = User
#         fields = (
#             'username',
#             'first_name',
#             'last_name',
#             'email',
#             'password',
#         )
#         validators = [
#             UniqueTogetherValidator(
#                 queryset=User.objects.all(),
#                 fields=['username', 'password']
#             )
#         ]

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email',)

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password',)
        extra_kwargs = {'password': {'write_only': True}}
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Incorrect Credentials")
