from django.conf import settings
from django.core.files.storage import default_storage
from django.shortcuts import render

# ML models
import tensorflow as tf
from tensorflow.keras import Sequential
from tensorflow.keras.layers import Flatten, Dropout, BatchNormalization
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Dense
from tensorflow.keras.optimizers import Adam

# Data frames
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder



def index(request):
    print(request)
    if request.method == 'POST':
        return render(request, 'index.html', {'predictions' : 10})
    else:
        return render(request, 'index.html')


class RenderTraining:
    def __init__(self) -> None:

        # Set a fixed random seed value, for reproducibility, this will allow us to get
        # the same random numbers each time the notebook is run
        SEED = 1337
        np.random.seed(SEED)
        tf.random.set_seed(SEED)

        # the list of gestures that data is available for
        GESTURES = [
            "punch",
            "flex",
        ]

        SAMPLES_PER_GESTURE = 119

        NUM_GESTURES = len(GESTURES)

        # create a one-hot encoded matrix that is used in the output
        ONE_HOT_ENCODED_GESTURES = np.eye(NUM_GESTURES)

        inputs = []
        outputs = []

        # read each csv file and push an input and output
        for gesture_index in range(NUM_GESTURES):
            gesture = GESTURES[gesture_index]
            print(f"Processing index {gesture_index} for gesture '{gesture}'.")
            
            output = ONE_HOT_ENCODED_GESTURES[gesture_index]
            
            df = pd.read_csv('Run_or_Walk_Dataset_Reduced.csv')
            
            # calculate the number of gesture recordings in the file
            num_recordings = int(df.shape[0] / SAMPLES_PER_GESTURE)
            
            print(f"\tThere are {num_recordings} recordings of the {gesture} gesture.")
            
            for i in range(num_recordings):
                tensor = []
                for j in range(SAMPLES_PER_GESTURE):
                    index = i * SAMPLES_PER_GESTURE + j
                    # normalize the input data, between 0 to 1:
                    # - acceleration is between: -4 to +4
                    # - gyroscope is between: -2000 to +2000
                    tensor += [
                        (df['aX'][index] + 4) / 8,
                        (df['aY'][index] + 4) / 8,
                        (df['aZ'][index] + 4) / 8,
                        (df['gX'][index] + 2000) / 4000,
                        (df['gY'][index] + 2000) / 4000,
                        (df['gZ'][index] + 2000) / 4000
                    ]

                    inputs.append(tensor)
                    outputs.append(output)

                # convert the list to numpy array
                inputs = np.array(inputs)
                outputs = np.array(outputs)

            print("Data set parsing and preparation complete.")


        



rt = RenderTraining()


