# A RESTful API built with Django 
## Selecting a n eural network
- Convolutional Neural Network (CNN)
- Recurrent Neural Network (RNN)


## Still considering using the Long short-term memory (LSTM) a variety of RNN but there known issues/limitations, e.g:

1. Currently there is support only for converting stateless Keras LSTM (default behavior in Keras). Stateful Keras LSTM conversion is future work.
2. It is still possible to model a stateful Keras LSTM layer using the underlying stateless Keras LSTM layer and managing the state explicitly in the user program. Such a TensorFlow program can still be converted to TensorFlow Lite using the feature being described here.
3. Bidirectional LSTM is currently modelled as two UnidirectionalSequenceLSTM operations in TensorFlow Lite. This will be replaced with a single BidirectionalSequenceLSTM op.



## Reference
https://www.tensorflow.org/lite/models/convert/rnn
