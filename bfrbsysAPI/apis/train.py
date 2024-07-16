''' Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
========================================================================='''

import pandas as pd
import tensorflow as tf
import numpy as np


class BFRBNeuralNetwork:
    PARAMS = ['ax', 'ay', 'az', 'gx', 'gy', 'gz', 'class']
    SAMPLES_PER_HOTSPOT = 1
    HOTSPOT = [] 
    NUM_HOTSPOT = 0
    ONE_HOT_ENCODED_HOTSPOT = []
    N_EPOCH = 100
    model = tf.keras.Sequential()

    def __init__(self, data):
        df = pd.read_csv(data)

        off_target = pd.DataFrame(df[df['class']==0].values.tolist(), columns=self.PARAMS)
        on_target = pd.DataFrame(df[df['class']==1].values.tolist(), columns=self.PARAMS)

        self.HOTSPOT = [off_target, on_target] # known location / class
        self.NUM_HOTSPOT = len(self.HOTSPOT)
        self.ONE_HOT_ENCODED_HOTSPOT = np.eye(self.NUM_HOTSPOT)

    def preprocessData(self, train_rate: float, val_rate: float) -> tf.data.Dataset:
        assert train_rate + val_rate == 1, 'train_rate + val_rate must be equal to 1'

        inputs = []
        outputs = []

        # Preprocess
        for hotspot_index in range(self.NUM_HOTSPOT):

            target = self.HOTSPOT[hotspot_index]

            num_recordings = int(target.shape[0] / self.SAMPLES_PER_HOTSPOT)

            output = self.ONE_HOT_ENCODED_HOTSPOT[hotspot_index]

            print(f"\tThere are {num_recordings} recordings.")

            for i in range(num_recordings):
                tensor = []
                for j in range(self.SAMPLES_PER_HOTSPOT):
                    index = i * self.SAMPLES_PER_HOTSPOT + j
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
                inputs.append([tensor])
                outputs.append([output])
        

        # Split
        data = tf.data.Dataset.from_tensor_slices((inputs, outputs)).shuffle(1000)
        TRAIN_SPLIT = int(train_rate * len(data))
        VAL_SPLIT = int(val_rate * len(data))
        assert TRAIN_SPLIT + VAL_SPLIT == len(data)

        train = data.take(TRAIN_SPLIT)
        val = data.skip(TRAIN_SPLIT).take(VAL_SPLIT)

        return train, val

    def build(self):
        ''' CNN 1D '''
        self.model.add(tf.keras.layers.Conv1D(64, kernel_size=1, activation='relu', 
                       input_shape=(len(self.PARAMS)-1, self.SAMPLES_PER_HOTSPOT))
                       )
        self.model.add(tf.keras.layers.MaxPooling1D())

        self.model.add(tf.keras.layers.Conv1D(32, kernel_size=1, activation='relu'))
        self.model.add(tf.keras.layers.MaxPooling1D())

        self.model.add(tf.keras.layers.Conv1D(40, kernel_size=1, activation='relu'))
        self.model.add(tf.keras.layers.Dropout(0.5))

        self.model.add(tf.keras.layers.Flatten())
        self.model.add(tf.keras.layers.Dense(50, activation='relu'))
        self.model.add(tf.keras.layers.Dense(15, activation='relu'))

        self.model.add(tf.keras.layers.Dense(self.NUM_HOTSPOT, activation='softmax')) 

        self.model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

        return self
    
    def train(self, trainData, valData):
        history = self.model.fit(trainData, epochs=self.N_EPOCH, batch_size=self.SAMPLES_PER_HOTSPOT, validation_data=valData)
        return history, self.model

    def to_tflite(self, model:tf.keras.Sequential):
        # Convert the model to the TensorFlow Lite format with quantization
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
        return converter.convert()
