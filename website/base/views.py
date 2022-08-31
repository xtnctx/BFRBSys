from django.http import HttpResponse, JsonResponse
from django.contrib.auth.decorators import login_required
from base.utils import hex_to_c_array, rmv_file_spaces
from base.models import TrainedModel, TrainingStatus
from accounts.models import Profile
from django.core.files.base import File
from django.shortcuts import render
from tensorflow import keras
import tensorflow as tf
import pandas as pd
import numpy as np
import csv
import os

PARAMS = ['ax', 'ay', 'az', 'gx', 'gy', 'gz', 'class']
SAMPLES_PER_HOTSPOT = 1

def home(request):
    if request.user.is_authenticated:
        profile = Profile.objects.get(user=request.user)
        return render(request, 'base/home.html',  {'profile':profile})
    return render(request, 'base/home.html', {})


@login_required(login_url='login')
def app(request):
    profile = Profile.objects.get(user=request.user)
    return render(request, 'base/livePlot.html', {'profile':profile})




def train_model(request):
    if request.method == 'POST':

        '''
            -- 07/29/2022 --
        >> This must be a header file (model.h)
        >> will fix soon ...

            -- 07/31/2022 --
        >> normalizing data
        >> classify on and off target soon ... 
        '''

        data = request.POST.get('data')
        named_model = request.POST.get('model_name')
        if named_model == '':
            named_model = request.user.username + '_no_name_model'

        parsed_csv = list(csv.reader(data.split(';')))

        df = pd.DataFrame(parsed_csv, columns=PARAMS)
        off_target = pd.DataFrame(df[df['class']=='0'].values.tolist(), columns=PARAMS)
        on_target = pd.DataFrame(df[df['class']=='1'].values.tolist(), columns=PARAMS)

        HOTSPOT = [off_target, on_target] # known location / class
        NUM_HOTSPOT = len(HOTSPOT)
        ONE_HOT_ENCODED_HOTSPOT = np.eye(NUM_HOTSPOT)
        N_EPOCH = 600

        inputs = []
        outputs = []

        # -------------------- INFORM USER --------------------
        msg = TrainingStatus.objects.get(owner=request.user)
        msg.message_status = 'Normalizing data ...' 
        msg.save()
        # -----------------------------------------------------

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
                        (float(target['ax'][index]) + 4) / 8,
                        (float(target['ay'][index]) + 4) / 8,
                        (float(target['az'][index]) + 4) / 8,
                        (float(target['gx'][index]) + 2000) / 4000,
                        (float(target['gy'][index]) + 2000) / 4000,
                        (float(target['gz'][index]) + 2000) / 4000
                    ]
                inputs.append(tensor)
                outputs.append(output)

        msg.message_status = 'Randomizing data ...' 
        msg.save()

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
                            validation_data=(inputs_validate, outputs_validate),
                            callbacks=[CustomCallback(msg)])


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

        msg.message_status = 'Converting to tflite ...' 
        msg.save()

        # Convert the model to the TensorFlow Lite format without quantization
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
        tflite_model = converter.convert()

        # Save as temporary
        with open('static/temp_model.h', 'w') as temp:
            temp.write(hex_to_c_array(tflite_model))

        # Then save to database
        with open('static/temp_model.h', 'rb') as f:
            fs = TrainedModel(
                owner=request.user, 
                model_name=named_model, 
                file=File(f, name=str(named_model).replace(" ", "_") + '.h')
                )
            fs.save()
        
        model_string = rmv_file_spaces('static/temp_model.h', exclude='unsigned char model[] = {')
        
        msg.message_status = 'Done!' 
        msg.save()

        os.remove('static/temp_model.h') # end of using temp model

        context = {'model_string': model_string}
        return JsonResponse(context)
    
    return HttpResponse('')


def get_status(request):
    if request.method == 'POST':
        msg = TrainingStatus.objects.get(owner=request.user)
        context = {'message_status': msg.message_status}
        return JsonResponse(context)
    return HttpResponse('')



class CustomCallback(keras.callbacks.Callback):
    def __init__(self, callback_handler):
        self.callback_handler = callback_handler

    def on_epoch_begin(self, epoch, logs=None):
        if epoch % 50 == 0:
            self.callback_handler.message_status = f'Training your model (Epoch: {epoch})...'
            self.callback_handler.save()
            print('###############################################################')

    

