import base64
from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from .models import Item, TrainedModel

from .serializers import (ItemSerializer, TrainedModelSerializer, UserSerializer,
    RegisterSerializer, LoginSerializer)

from rest_framework.permissions import IsAuthenticated
from rest_framework import status, generics
from rest_framework.authentication import TokenAuthentication, SessionAuthentication, BasicAuthentication
from rest_framework.authtoken.models import Token
from .utils import *
from django.conf import settings
import os

from knox.models import AuthToken
from knox.views import LoginView as KnoxLoginView

from rest_framework.permissions import AllowAny
from rest_framework.authtoken.serializers import AuthTokenSerializer
from django.contrib.auth import login

from django.core.files.base import ContentFile
import pandas as pd
import numpy as np
import tensorflow as tf



PARAMS = ['ax', 'ay', 'az', 'gx', 'gy', 'gz', 'class']
SAMPLES_PER_HOTSPOT = 1

def home(request):
    return render(request, 'apis/home.html', {})

class NeuralNetworkBuilder(APIView):
    """
    TEST TEST TEST TEST TEST TEST TEST TEST 
    """
    
    permission_classes = (IsAuthenticated,)

    def get(self, request, format=None):
        items = Item.objects.all()
        serializer = ItemSerializer(items, many=True)
        # token, _ = Token.objects.get(user=request.user)
        

        return Response(serializer.data)
    
    def post(self, request, format=None):
        data = request.data.get('data')
        named_model = request.data.get('model_name')
        file = request.data.get("file")
        fileName = request.data.get("fileName")

        df = pd.read_csv(file)

        off_target = pd.DataFrame(df[df['class']==0].values.tolist(), columns=PARAMS)
        on_target = pd.DataFrame(df[df['class']==1].values.tolist(), columns=PARAMS)

        HOTSPOT = [off_target, on_target] # known location / class
        NUM_HOTSPOT = len(HOTSPOT)
        ONE_HOT_ENCODED_HOTSPOT = np.eye(NUM_HOTSPOT)
        N_EPOCH = 100

        inputs = []
        outputs = []

        for hotspot_index in range(NUM_HOTSPOT):

            target = HOTSPOT[hotspot_index]

            num_recordings = int(target.shape[0] / SAMPLES_PER_HOTSPOT)

            output = ONE_HOT_ENCODED_HOTSPOT[hotspot_index]

            print(f"\tThere are {num_recordings} recordings.")

            for i in range(num_recordings):
                tensor = []
                for j in range(SAMPLES_PER_HOTSPOT):
                    index = i * SAMPLES_PER_HOTSPOT + j
                    # normalize the input data, between 0 to 1:
                    # - acceleration is between: -4 to +4
                    # - gyroscope is between: -2000 to +2000
                    tensor += [
                        (target['ax'][index]) + 4 / 8,
                        (target['ay'][index]) + 4 / 8,
                        (target['az'][index]) + 4 / 8,
                        (target['gx'][index]) + 2000 / 4000,
                        (target['gy'][index]) + 2000 / 4000,
                        (target['gz'][index]) + 2000 / 4000
                    ]
                inputs.append(tensor)
                outputs.append(output)

        # convert the list to numpy array
        inputs = np.array(inputs)
        outputs = np.array(outputs)

        # Randomize the order of the inputs, so they can be evenly distributed for training, testing, and validation
        # https://stackoverflow.com/a/37710486/2020087
        num_inputs = len(inputs)
        randomize = np.arange(num_inputs)
        np.random.shuffle(randomize)

        # Swap the consecutive indexes (0, 1, 2, etc) with the randomized indexes
        inputs = inputs[randomize]
        outputs = outputs[randomize]

        # Split the recordings (group of samples) into three sets: training, testing and validation
        TRAIN_SPLIT = int(0.6 * num_inputs)
        TEST_SPLIT = int(0.2 * num_inputs + TRAIN_SPLIT)

        inputs_train, inputs_test, inputs_validate = np.split(inputs, [TRAIN_SPLIT, TEST_SPLIT])
        outputs_train, outputs_test, outputs_validate = np.split(outputs, [TRAIN_SPLIT, TEST_SPLIT])

        # build the model and train it
        model = tf.keras.Sequential()
        model.add(tf.keras.layers.Dense(50, activation='relu')) # relu is used for performance
        model.add(tf.keras.layers.Dense(15, activation='relu'))
        model.add(tf.keras.layers.Dense(NUM_HOTSPOT, activation='softmax')) # softmax is used, because we only expect one hotspot to occur per input
        model.compile(optimizer='rmsprop', loss='mse', metrics=['mae'])
        history = model.fit(inputs_train, outputs_train, epochs=N_EPOCH, batch_size=1,
                            validation_data=(inputs_validate, outputs_validate))


        # print("Evaluate on test data")
        # results = model.evaluate(inputs_test, outputs_test)
        # print("test loss, test acc:", results)


        predictions = model.predict(inputs_test)
        # print the predictions and the expected ouputs
        print("predictions =\n", np.round(predictions, decimals=3))
        print("actual =\n", outputs_test)

        # # use the model to predict the test inputs
        # feed = [[1,1,1,1,1,1]]
        # predictions = model.predict(feed)

        # # print the predictions and the expected ouputs
        # print("predictions =\n", np.round(predictions, decimals=3))

        # Convert the model to the TensorFlow Lite format with quantization
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
        tflite_model = converter.convert()

        data = {
            'owner': request.user.id,
            'model_name': named_model,
            'file': ContentFile(bytes(hex_to_c_array(tflite_model), 'utf-8'), name=named_model+'.h')
        }
        
        

        serializer = TrainedModelSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



    # def post(self, request, format=None):
    #     data = request.data.get('data')
    #     named_model = request.data.get('model_name')
    #     file = request.data.get("file") # Must be csv encoded
    #     fileName = request.data.get("fileName") # Must be csv file format

    #     dataset = ContentFile(base64.b64decode(file), fileName)
    #     df = pd.read_csv(dataset)
    #     print(df)

    #     if named_model == '':
    #         named_model = 'NO_NAME'
    #     # Save as temporary
    #     USER_TEMP_FILE = os.path.join(settings.MEDIA_ROOT, request.user.username + '_TEMPFILE.h')
    #     with open(USER_TEMP_FILE, 'w') as temp:
    #         # temp.write(hex_to_c_array(tflite_model))
    #         temp.write('hello')

    #     # Then save to database
    #     f = open(USER_TEMP_FILE, 'rb')
    #     data = {
    #         'owner': request.user.id,
    #         'model_name': named_model,
    #         'file': File(f, name=str(named_model).replace(" ", "_") + f'--{request.user.username}' + '.h')
    #     }
            
    #     model_string = rmv_file_spaces(USER_TEMP_FILE)
    #     print(model_string)

    #     serializer = TrainedModelSerializer(data=data)
    #     if serializer.is_valid():
    #         serializer.save()
    #         f.close()
    #         remove_file(USER_TEMP_FILE) # end of using temp model
    #         return Response(serializer.data, status=status.HTTP_201_CREATED)

    #     f.close()
    #     remove_file(USER_TEMP_FILE)
    #     return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# class UserCreation(APIView):
#     """
#     API View to create or get a list of all the registered
#     users. GET request returns the registered users whereas
#     a POST request allows to create a new user.
#     """
#     permission_classes = [AllowAny]
    

#     # Delete later
#     def get(self, format=None):
#         users = User.objects.all()
#         serializer = UserSerializer(users, many=True)
#         return Response(serializer.data)

#     def post(self, request):
#         serializer = UserSerializer(data=request.data)
#         if serializer.is_valid(raise_exception=ValueError):
#             serializer.create(validated_data=request.data)
#             return Response(
#                 serializer.data,
#                 status=status.HTTP_201_CREATED
#             )
#         return Response(
#             {
#                 "error": True,
#                 "error_msg": serializer.error_messages,
#             },
#             status=status.HTTP_400_BAD_REQUEST
#         )

class RegisterAPI(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        _, token = AuthToken.objects.create(user)
        return Response({
            "user": UserSerializer(user, context=self.get_serializer_context()).data,
            "token": token
        })



class LoginAPI(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = ()

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        _, token = AuthToken.objects.create(user)
        return Response({
            "user": UserSerializer(user, context=self.get_serializer_context()).data,
            "token": token
        })


class UserAPI(generics.RetrieveAPIView):
  permission_classes = [IsAuthenticated]
  serializer_class = UserSerializer

  def get_object(self):
    return self.request.user