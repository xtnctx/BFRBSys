# A RESTful API for building minimal neural network for wearables

## Selecting a neural network
- Convolutional Neural Network (CNN)
- Recurrent Neural Network (RNN)


### Still considering using the variety of RNN -- Long short-term memory (LSTM) but there are known issues/limitations, e.g:

1. Currently there is support only for converting stateless Keras LSTM (default behavior in Keras). Stateful Keras LSTM conversion is future work.
2. It is still possible to model a stateful Keras LSTM layer using the underlying stateless Keras LSTM layer and managing the state explicitly in the user program. Such a TensorFlow program can still be converted to TensorFlow Lite using the feature being described [here](https://www.tensorflow.org/lite/models/convert/rnn).
3. Bidirectional LSTM is currently modelled as two UnidirectionalSequenceLSTM operations in TensorFlow Lite. This will be replaced with a single BidirectionalSequenceLSTM op.

------------------

## Backend config

When setting up on production, the timeout value in `app.yaml` (for Google App Engine) must be zero otherwise, it will cause a request time out for every post request in the api. This has been tested and proven from previous [project](https://github.com/xtnctx/bfrbsys/tree/main/website).

## Reference
TensorFlow RNN conversion to TensorFlow Lite: https://www.tensorflow.org/lite/models/convert/rnn
