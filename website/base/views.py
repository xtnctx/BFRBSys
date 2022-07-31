from django.http import HttpResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.core.files.base import File
from base.models import TModels
import pandas as pd
import csv
import os
import tensorflow as tf
import numpy as np
from sklearn.model_selection import train_test_split

# Create your views here.


def home(request):
    context = {}
    return render(request, 'base/home.html', context)

@login_required(login_url='login')
def app(request):
    context = {}
    return render(request, 'base/app.html', context)


def graph(request):
    context = {}
    return render(request, 'base/livePlot.html', context)




def export_data(request):
    if request.method == 'POST':

        '''
            -- 07/29/2022 --
        >> This must be a header file (model.h)
        >> will fix soon ...

            -- 07/31/2022 --
        >> normalizing data
        >> classify on and off target soon ... 
        '''

        PARAMS = ['ax', 'ay', 'az', 'gx', 'gy', 'gz']
        data = request.POST.get('data')
        parsed_csv = list(csv.reader(data.split(';')))
        df = pd.DataFrame(parsed_csv, columns=PARAMS)

        HOTSPOT = ['loc'] # known location
        NUM_HOTSPOT = len(HOTSPOT)

        df['output'] = [1] * len(df)
        outputs = df['output']

        for _ in range(NUM_HOTSPOT):
            tensor = df.drop(columns='output')

            for index in range(len(df)):
                # normalize the input data, between 0 to 1:
                # - acceleration is between: -4 to +4
                # - gyroscope is between: -2000 to +2000

                tensor['ax'][index] = (float(df['ax'][index]) + 4) / 8
                tensor['ay'][index] = (float(df['ay'][index]) + 4) / 8
                tensor['az'][index] = (float(df['az'][index]) + 4) / 8
                tensor['gx'][index] = (float(df['gx'][index]) + 2000) / 4000
                tensor['gy'][index] = (float(df['gy'][index]) + 2000) / 4000
                tensor['gz'][index] = (float(df['gz'][index]) + 2000) / 4000
                

        inputs = np.array(tensor).tolist()
        outputs = np.array(outputs).tolist()

        X_train, X_test, Y_train, Y_test = train_test_split(inputs, outputs, test_size=0.2)

        # # build the model and train it
        model = tf.keras.Sequential()
        model.add(tf.keras.layers.Dense(2, activation='relu')) # relu is used for performance
        model.add(tf.keras.layers.Dense(1, activation='relu'))
        model.add(tf.keras.layers.Dense(NUM_HOTSPOT, activation='softmax')) # softmax is used, because we only expect one hotspot to occur per input
        model.compile(optimizer='rmsprop', loss='mse', metrics=['mae'])
        history = model.fit(X_train, Y_train, epochs=100)

        print("Evaluate on test data")
        results = model.evaluate(X_test, Y_test)
        print("test loss, test acc:", results)
        
        # use the model to predict the test inputs
        feed = [[1,1,1,1,1,1]]
        predictions = model.predict(feed)

        # print the predictions and the expected ouputs
        print("predictions =\n", np.round(predictions, decimals=3))
        # print("actual =\n", Y_test)

        # df.to_csv('static/temp.csv', encoding='utf-8', index=False)

        # with open('static/temp.csv', 'rb') as f:
        #     fs = TModels(owner=request.user, file=File(f, name=os.path.basename(f.name)))
        #     fs.save()
        
        # os.remove('static/temp.csv')
    
    return HttpResponse('')


