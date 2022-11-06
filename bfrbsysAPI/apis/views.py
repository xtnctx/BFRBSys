from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from .models import Item, TrainedModel
from .serializers import ItemSerializer, TrainedModelSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from rest_framework.authentication import TokenAuthentication, SessionAuthentication
from rest_framework.authtoken.models import Token
from .utils import hex_to_c_array, rmv_file_spaces
from django.conf import settings
from django.core.files.base import File
import os

# Create your views here.


def home(request):
    return render(request, 'apis/home.html', {})

class NeuralNetworkBuilderApi(APIView):
    """
    TEST TEST TEST TEST TEST TEST TEST TEST 
    """
    
    # permission_classes = (IsAuthenticated,)
    # authentication_classes = (SessionAuthentication, TokenAuthentication,)



    def get(self, request, format=None):
        items = Item.objects.all()
        serializer = ItemSerializer(items, many=True)
        # token, _ = Token.objects.get(user=request.user)
        

        return Response(serializer.data)

    def post(self, request, format=None):
        data = request.data.get('data')
        named_model = request.data.get('model_name')

        if named_model == '':
            named_model = 'NO_NAME'
        # Save as temporary
        USER_TEMP_FILE = os.path.join(settings.MEDIA_ROOT, request.user.username + '_TEMPFILE.h')
        with open(USER_TEMP_FILE, 'w') as temp:
            # temp.write(hex_to_c_array(tflite_model))
            temp.write('hello')

        # Then save to database
        f = open(USER_TEMP_FILE, 'rb')
        data = {
            'owner': request.user.id,
            'model_name': named_model,
            'file': File(f, name=str(named_model).replace(" ", "_") + f'--{request.user.username}' + '.h')
        }
            
        model_string = rmv_file_spaces(USER_TEMP_FILE)
        print(model_string)

        serializer = TrainedModelSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            f.close()
            os.remove(USER_TEMP_FILE) # end of using temp model
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
