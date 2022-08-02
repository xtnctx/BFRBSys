import pandas as pd
import tensorflow as tf
import numpy as np

PARAMS = ['ax', 'ay', 'az', 'gx', 'gy', 'gz', 'class']
# data = request.POST.get('data')
# parsed_csv = list(csv.reader(data.split(';')))
# df = pd.DataFrame(parsed_csv, columns=PARAMS)

df = pd.read_csv('data.csv')
off_target = pd.DataFrame(df[df['class']==0].values.tolist(), columns=PARAMS)
on_target = pd.DataFrame(df[df['class']==1].values.tolist(), columns=PARAMS)


HOTSPOT = [off_target, on_target] # known location / class
NUM_HOTSPOT = len(HOTSPOT)
SAMPLES_PER_HOTSPOT = 1
ONE_HOT_ENCODED_HOTSPOT = np.eye(NUM_HOTSPOT)

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
                (target['ax'][index] + 4) / 8,
                (target['ay'][index] + 4) / 8,
                (target['az'][index] + 4) / 8,
                (target['gx'][index] + 2000) / 4000,
                (target['gy'][index] + 2000) / 4000,
                (target['gz'][index] + 2000) / 4000
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

# print(inputs_train, outputs_train)


# build the model and train it
model = tf.keras.Sequential()
model.add(tf.keras.layers.Dense(50, activation='relu')) # relu is used for performance
model.add(tf.keras.layers.Dense(15, activation='relu'))
model.add(tf.keras.layers.Dense(NUM_HOTSPOT, activation='softmax')) # softmax is used, because we only expect one hotspot to occur per input
model.compile(optimizer='rmsprop', loss='mse', metrics=['mae'])
history = model.fit(inputs_train, outputs_train, epochs=600, batch_size=1, 
                    validation_data=(inputs_validate, outputs_validate))


# print("Evaluate on test data")
# results = model.evaluate(inputs_test, outputs_test)
# print("test loss, test acc:", results)


# predictions = model.predict(inputs_test)
# # print the predictions and the expected ouputs
# print("predictions =\n", np.round(predictions, decimals=3))
# print("actual =\n", outputs_test)

# # use the model to predict the test inputs
# feed = [[1,1,1,1,1,1]]
# predictions = model.predict(feed)

# # print the predictions and the expected ouputs
# print("predictions =\n", np.round(predictions, decimals=3))
