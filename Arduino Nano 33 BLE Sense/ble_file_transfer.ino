/* Copyright 2021 The TensorFlow Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

// This is part of a simple demonstration of how to transfer small (tens of
// kilobytes) files over BLE onto an Arduino Nano BLE Sense board. Most of this
// sketch is internal implementation details of the protocol, but if you just
// want to use it you can look at the bottom of this file.
// The API is that you call setupBLEFileTransfer() in your setup() function to
// open up communication with any clients that want to send you files, and then
// onBLEFileReceived() is called when a file has been downloaded.

#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>
#include "Adafruit_VL53L0X.h"
#include <Adafruit_MLX90614.h>

#include <TensorFlowLite.h>
#include <tensorflow/lite/micro/all_ops_resolver.h>
#include <tensorflow/lite/micro/micro_interpreter.h>
#include <tensorflow/lite/schema/schema_generated.h>

#include <SdFat.h>
#include <ArduinoJson.h>

SdFat sd;
File modelFile;
Adafruit_VL53L0X lox = Adafruit_VL53L0X();
Adafruit_MLX90614 mlx = Adafruit_MLX90614();

bool isConnected = false;
bool isBLEBusy = false;

int buzzerPin = 8;
int buzzTime = 200; // buzzer frequency
unsigned long buzzStartTime = 0;
const unsigned long buzzDuration = 5000; // buzz and vibrate for 5 seconds
int vibrationPin = 6;

// global variables used for TensorFlow Lite (Micro)
// pull in all the TFLM ops, you can remove this line and
// only pull in the TFLM ops you need, if would like to reduce
// the compiled size of the sketch.
tflite::AllOpsResolver tflOpsResolver;

const tflite::Model* tflModel = nullptr;
tflite::MicroInterpreter* tflInterpreter = nullptr;
TfLiteTensor* tflInputTensor = nullptr;
TfLiteTensor* tflOutputTensor = nullptr;

// Create a static memory buffer for TFLM, the size may need to
// be adjusted based on the model you are using
constexpr int tensorArenaSize = 8 * 1024;
byte tensorArena[tensorArenaSize] __attribute__((aligned(16)));

// array to map gesture index to a name
const char* HOTSPOT[] = {
  "off_target",
  "on_target"
};
String previous_file;
String currentDate = "";
String currentUser = "";
double on_target_threshold = 0.8;

bool isModelInitialized = false;

#define NUM_HOTSPOT (sizeof(HOTSPOT) / sizeof(HOTSPOT[0]))

// Uncomment this macro to log received data to the serial UART.
#define ENABLE_LOGGING

// Forward declare the function that will be called when data has been delivered to us.
void onBLEFileReceived(uint8_t* file_data, int file_length);

namespace {

// Controls how large a file the board can receive.
constexpr int32_t file_maximum_byte_count = (120 * 1024);

// Macro based on a master UUID that can be modified for each characteristic.
#define FILE_TRANSFER_UUID(val) ("bf88b656-" val "-4a61-86e0-769c741026c0")

BLEService service(FILE_TRANSFER_UUID("0000"));

// How big each transfer block can be. In theory this could be up to 512 bytes, but
// in practice I've found that going over 128 affects reliability of the connection.
constexpr int32_t file_block_byte_count = 128;

// Where each data block is written to during the transfer.
BLECharacteristic file_block_characteristic(FILE_TRANSFER_UUID("3000"), BLEWrite, file_block_byte_count);

// Write the expected total length of the file in bytes to this characteristic
// before sending the command to transfer a file.
BLECharacteristic file_length_characteristic(FILE_TRANSFER_UUID("3001"), BLERead | BLEWrite, sizeof(uint32_t));

// Read-only attribute that defines how large a file the sketch can handle.
BLECharacteristic file_maximum_length_characteristic(FILE_TRANSFER_UUID("3002"), BLERead, sizeof(uint32_t));

// Write the checksum that you expect for the file here before you trigger the transfer.
BLECharacteristic file_checksum_characteristic(FILE_TRANSFER_UUID("3003"), BLERead | BLEWrite, sizeof(uint32_t));

// Writing a command of 1 starts a file transfer (the length and checksum characteristics should already have been set).
// A command of 2 tries to cancel any pending file transfers. All other commands are undefined.
BLECharacteristic command_characteristic(FILE_TRANSFER_UUID("3004"), BLEWrite, sizeof(uint32_t));

// A status set to 0 means a file transfer succeeded, 1 means there was an error, and 2 means a file transfer is
// in progress.
BLECharacteristic transfer_status_characteristic(FILE_TRANSFER_UUID("3005"), BLERead | BLENotify, sizeof(uint32_t));

// Informative text describing the most recent error, for user interface purposes.
constexpr int32_t error_message_byte_count = 128;
BLECharacteristic error_message_characteristic(FILE_TRANSFER_UUID("3006"), BLERead | BLENotify, error_message_byte_count);

// Data parameters
constexpr int32_t data_size_count = 32;
BLECharacteristic accelerometer_characteristic(FILE_TRANSFER_UUID("3007"), BLERead | BLENotify, data_size_count);
BLECharacteristic gyroscope_characteristic(FILE_TRANSFER_UUID("3008"), BLERead | BLENotify, data_size_count);
BLECharacteristic distance_temperature_characteristic(FILE_TRANSFER_UUID("3009"), BLERead | BLENotify, data_size_count);

BLECharacteristic file_update_characteristic(FILE_TRANSFER_UUID("3010"), BLERead | BLENotify, file_block_byte_count);




// Internal globals used for transferring the file.
uint8_t file_buffers[file_maximum_byte_count];
int finished_file_buffer_index = -1;
uint8_t* finished_file_buffer = nullptr;
int32_t finished_file_buffer_byte_count = 0;

uint8_t* in_progress_file_buffer = nullptr;
int32_t in_progress_bytes_received = 0;
int32_t in_progress_bytes_expected = 0;
uint32_t in_progress_checksum = 0;

String file_name = "";

// Training notification
uint32_t on_training = 0;

void notifyError(const String& error_message) {
  Serial.println(error_message);
  constexpr int32_t error_status_code = 1;
  transfer_status_characteristic.writeValue(error_status_code);
 
  const char* error_message_bytes = error_message.c_str();
  uint8_t error_message_buffer[error_message_byte_count];
  bool at_string_end = false;
  for (int i = 0; i < error_message_byte_count; ++i) {
    const bool at_last_byte = (i == (error_message_byte_count - 1));
    if (!at_string_end && !at_last_byte) {
      const char current_char = error_message_bytes[i];
      if (current_char == 0) {
        at_string_end = true;
      } else {
        error_message_buffer[i] = current_char;
      }
    }

    if (at_string_end || at_last_byte) {
      error_message_buffer[i] = 0;
    }
  }
  error_message_characteristic.writeValue(error_message_buffer, error_message_byte_count);
}

// [send == true] : notifies app for model received 
// [send == false] : notifies app for dashboard update received 
void notifySuccess(bool send) {
  constexpr int32_t success_status_code = 0;
  constexpr int32_t without_message_status_code = 3;
  if (send) {
    transfer_status_characteristic.writeValue(success_status_code);
  } else {
    transfer_status_characteristic.writeValue(without_message_status_code);
  }
}

void notifyInProgress() {
  constexpr int32_t in_progress_status_code = 2;
  transfer_status_characteristic.writeValue(in_progress_status_code);
}

// See http://home.thep.lu.se/~bjorn/crc/ for more information on simple CRC32 calculations.
uint32_t crc32_for_byte(uint32_t r) {
  for (int j = 0; j < 8; ++j) {
    r = (r & 1? 0: (uint32_t)0xedb88320L) ^ r >> 1;
  }
  return r ^ (uint32_t)0xff000000L;
}

uint32_t crc32(const uint8_t* data, size_t data_length) {
  constexpr int table_size = 256;
  static uint32_t table[table_size];
  static bool is_table_initialized = false;
  if (!is_table_initialized) {
    for(size_t i = 0; i < table_size; ++i) {
      table[i] = crc32_for_byte(i);
    }
    is_table_initialized = true;
  }
  uint32_t crc = 0;
  for (size_t i = 0; i < data_length; ++i) {
    const uint8_t crc_low_byte = static_cast<uint8_t>(crc);
    const uint8_t data_byte = data[i];
    const uint8_t table_index = crc_low_byte ^ data_byte;
    crc = table[table_index] ^ (crc >> 8);
  }
  return crc;
}

void onFileTransferComplete() {
  uint32_t computed_checksum = crc32(in_progress_file_buffer, in_progress_bytes_expected);;
  if (in_progress_checksum != computed_checksum) {
    notifyError(String("File transfer failed: Expected checksum 0x") + String(in_progress_checksum, 16) + 
      String(" but received 0x") + String(computed_checksum, 16));
    in_progress_file_buffer = nullptr;
    return;
  }

  if (finished_file_buffer_index == 0) {
    finished_file_buffer_index = 1;
  } else {
    finished_file_buffer_index = 0;
  }
  finished_file_buffer = &file_buffers[0];
  finished_file_buffer_byte_count = in_progress_bytes_expected;

  in_progress_file_buffer = nullptr;
  in_progress_bytes_received = 0;
  in_progress_bytes_expected = 0;
  

  onBLEFileReceived(finished_file_buffer, finished_file_buffer_byte_count);
  isBLEBusy = false;
}

void onFileBlockWritten(BLEDevice central, BLECharacteristic characteristic) {  
  if (in_progress_file_buffer == nullptr) {
    notifyError("File block sent while no valid command is active");
    isBLEBusy = false;
    return;
  }
  isBLEBusy = true;
  const int32_t file_block_length = characteristic.valueLength();
  if (file_block_length > file_block_byte_count) {
    notifyError(String("Too many bytes in block: Expected ") + String(file_block_byte_count) + 
      String(" but received ") + String(file_block_length));
    in_progress_file_buffer = nullptr;
    return;
  }
  
  const int32_t bytes_received_after_block = in_progress_bytes_received + file_block_length;
  if ((bytes_received_after_block > in_progress_bytes_expected) ||
    (bytes_received_after_block > file_maximum_byte_count)) {
    notifyError(String("Too many bytes: Expected ") + String(in_progress_bytes_expected) + 
      String(" but received ") + String(bytes_received_after_block));
    in_progress_file_buffer = nullptr;
    return;
  }

  uint8_t* file_block_buffer = in_progress_file_buffer + in_progress_bytes_received;
  characteristic.readValue(file_block_buffer, file_block_length);
  
// Enable this macro to show the data in the serial log.
#ifdef ENABLE_LOGGING
  Serial.print("Data received: length = ");
  Serial.println(file_block_length);

  char string_buffer[file_block_byte_count + 1];
  for (int i = 0; i < file_block_byte_count; ++i) {
    unsigned char value = file_block_buffer[i];
    if (i < file_block_length) {
      string_buffer[i] = value;
    } else {
      string_buffer[i] = 0;
    }
  }
  string_buffer[file_block_byte_count] = 0;
  Serial.println(String(string_buffer));
#endif  // ENABLE_LOGGING

  if (bytes_received_after_block == in_progress_bytes_expected) {
    onFileTransferComplete();
  } else {
    in_progress_bytes_received = bytes_received_after_block;    
  }
}

void startFileTransfer() {
  if (in_progress_file_buffer != nullptr) {
    notifyError("File transfer command received while previous transfer is still in progress");
    return;
  }

  int32_t file_length_value; 
  file_length_characteristic.readValue(file_length_value);
  Serial.print("file_length_value = ");
  Serial.println(file_length_value);
  if (file_length_value > file_maximum_byte_count) {
    notifyError(
       String("File too large: Maximum is ") + String(file_maximum_byte_count) + 
       String(" bytes but request is ") + String(file_length_value) + String(" bytes"));
    return;
  }
  
  file_checksum_characteristic.readValue(in_progress_checksum);
  Serial.print("in_progress_checksum = ");
  Serial.println(in_progress_checksum);

  int in_progress_file_buffer_index;
  if (finished_file_buffer_index == 0) {
    in_progress_file_buffer_index = 1;
  } else {
    in_progress_file_buffer_index = 0;
  }
  
  in_progress_file_buffer = &file_buffers[0];
  in_progress_bytes_received = 0;
  in_progress_bytes_expected = file_length_value;

  notifyInProgress();
}

void cancelFileTransfer() {
  if (in_progress_file_buffer != nullptr) {
    notifyError("File transfer cancelled");
    in_progress_file_buffer = nullptr;
  }
}

void onCommandWritten(BLEDevice central, BLECharacteristic characteristic) {  
  int32_t command_value;
  characteristic.readValue(command_value);

  if ((command_value != 1) && (command_value != 2)) {
    notifyError(String("Bad command value: Expected 1 or 2 but received ") + String(command_value));
    return;
  }

  if (command_value == 1) {
    startFileTransfer();
  } else if (command_value == 2) {
    cancelFileTransfer();
  }

}

// Starts the BLE handling you need to support the file transfer.
void setupBLEFileTransfer() {
  // Start the core BLE engine.
  if (!BLE.begin()) {
    Serial.println("Failed to initialized BLE!");
    while (1);
  }
  String address = BLE.address();

  // Output BLE settings over Serial.
  Serial.print("address = ");
  Serial.println(address);

  address.toUpperCase();

  static String device_name = "BFRB Sense";

  Serial.print("device_name = ");
  Serial.println(device_name);

  // Set up properties for the whole service.
  BLE.setLocalName(device_name.c_str());
  BLE.setDeviceName(device_name.c_str());
  BLE.setAdvertisedService(service);

  // Add in the characteristics we'll be making available.
  file_block_characteristic.setEventHandler(BLEWritten, onFileBlockWritten);
  service.addCharacteristic(file_block_characteristic);

  service.addCharacteristic(file_length_characteristic);

  file_maximum_length_characteristic.writeValue(file_maximum_byte_count);
  service.addCharacteristic(file_maximum_length_characteristic);

  service.addCharacteristic(file_checksum_characteristic);

  command_characteristic.setEventHandler(BLEWritten, onCommandWritten);
  service.addCharacteristic(command_characteristic);

  service.addCharacteristic(transfer_status_characteristic);
  service.addCharacteristic(error_message_characteristic);

  service.addCharacteristic(accelerometer_characteristic);
  service.addCharacteristic(gyroscope_characteristic);
  service.addCharacteristic(distance_temperature_characteristic);
  
  service.addCharacteristic(file_update_characteristic);


  // Start up the service itself.
  BLE.addService(service);
  BLE.advertise();
}

// Called in your loop function to handle BLE housekeeping.
void updateBLEFileTransfer() {
  BLE.poll();
  BLEDevice central = BLE.central(); 
  static bool was_connected_last = false;  
  if (central && !was_connected_last) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
  }
  was_connected_last = central;
  isConnected = central.connected();
}

}  // namespace

void buzzVibrate(bool enable) {
  if (enable) {
    buzzStartTime = millis();
    digitalWrite(vibrationPin, HIGH);
    while (millis() - buzzStartTime < buzzDuration) {
      digitalWrite(buzzerPin, HIGH);
      delayMicroseconds(buzzTime);
      digitalWrite(buzzerPin, LOW);
      delayMicroseconds(buzzTime);
    }
    digitalWrite(buzzerPin, LOW);
    digitalWrite(vibrationPin, LOW);
  } else {
    digitalWrite(buzzerPin, LOW);
    digitalWrite(vibrationPin, LOW);
  }
}

void setup() {
  // Start serial
  Serial.begin(9600);

  // BLE setup
  setupBLEFileTransfer();

  // SD card setup
  bool sdBegin = sd.begin(10);
  while (!sdBegin) {
    Serial.println("Trying to initialize...");
    sdBegin = sd.begin(10);
    delay(500);
  }
  Serial.println("SD Card Initialized.");

  // LSM9DS1 setup
  bool imuInit = IMU.begin();
  while (!imuInit) {
    Serial.println("Failed to initialize IMU, retrying...");
    imuInit = IMU.begin();
    delay(500);
  }
  Serial.println("LSM9DS1 successfully initialized.");


  // VL53L0X setup
  Serial.println("Adafruit VL53L0X test.");
  bool loxInit = lox.begin();
  while (!loxInit) {
    Serial.println("Failed to boot VL53L0X, retrying...");
    loxInit = lox.begin();
    delay(500);
  }
  Serial.println(F("VL53L0X API Continuous Ranging example\n\n"));
  lox.startRangeContinuous();
  Serial.println("Adafruit VL53L0X successfully initialized.");

  // MLX90614 setup
  Serial.println("Adafruit MLX90614 test.");
  bool mlxInit = mlx.begin();
  while (!mlxInit) {
    Serial.println("Failed to boot MLX90614, retrying...");
    mlxInit = mlx.begin();
    delay(500);
  }
  Serial.println("Adafruit MLX90614 successfully initialized.");
  Serial.print("Emissivity = "); Serial.println(mlx.readEmissivity());


  pinMode(buzzerPin, OUTPUT);
  pinMode(vibrationPin, OUTPUT);

  previous_file = getPreviousFile();
}

char *dtostrf (double val, signed char width, unsigned char prec, char *sout) {
  char fmt[9];
  sprintf(fmt, "%%%d.%df", width, prec);
  sprintf(sout, fmt, val);
  return sout;
}


char *IMU_read (float x, float y, float z, char *sout) {
  char Xreadings[9]; // buffer
  dtostrf(x, 0, 3, Xreadings);
  
  char Yreadings[9];
  dtostrf(y, 0, 3, Yreadings);
  
  char Zreadings[9];
  dtostrf(z, 0, 3, Zreadings);

  sprintf(sout, "%s,%s,%s", Xreadings, Yreadings, Zreadings);

  return sout;
  
}

bool isNumeric(String str) {
    unsigned int stringLength = str.length();
    if (stringLength == 0) {
        return false;
    }
 
    bool seenDecimal = false;
    for(unsigned int i=0; i<stringLength; ++i) {
        if (isDigit(str.charAt(i))) {
            continue;
        }
 
        if (str.charAt(i) == '.') {
            if (seenDecimal) {
                return false;
            }
            seenDecimal = true;
            continue;
        }
        return false;
    }
    return true;
}

void initializeTFL(uint8_t model[]){
  // get the TFL representation of the model byte array
  tflModel = tflite::GetModel(model);
  if (tflModel->version() != TFLITE_SCHEMA_VERSION) {
    Serial.println("Model schema mismatch!");
    while (1);
  }
  
  // Create an interpreter to run the model
  tflInterpreter = new tflite::MicroInterpreter(tflModel, tflOpsResolver, tensorArena, tensorArenaSize);
  
  // Allocate memory for the model's input and output tensors
  tflInterpreter->AllocateTensors();

  // Get pointers for the model's input and output tensors
  tflInputTensor = tflInterpreter->input(0);
  tflOutputTensor = tflInterpreter->output(0);
  isModelInitialized = true;
}

// void runClassification(float aX, float aY, float aZ, float gX, float gY, float gZ, uint16_t dist, double temp) {
// return null if one of the parameters is nan or null
void runClassification(float aX, float aY, float aZ, float gX, float gY, float gZ) {
  // normalize the IMU data between 0 to 1 and store in the model's
  // input tensor
  tflInputTensor->data.f[0] = (aX + 4.0) / 8.0;
  tflInputTensor->data.f[1] = (aY + 4.0) / 8.0;
  tflInputTensor->data.f[2] = (aZ + 4.0) / 8.0;
  tflInputTensor->data.f[3] = (gX + 2000.0) / 4000.0;
  tflInputTensor->data.f[4] = (gY + 2000.0) / 4000.0;
  tflInputTensor->data.f[5] = (gZ + 2000.0) / 4000.0;


  // Run inferencing
  TfLiteStatus invokeStatus = tflInterpreter->Invoke();
  if (invokeStatus != kTfLiteOk) {
    Serial.println("Invoke failed!");
    while (1);
    return;
  }

  double onTargetPredictValue = tflOutputTensor->data.f[1];
  if (onTargetPredictValue > on_target_threshold) {
      buzzVibrate(true);
      // saveBuzz(currentDate, currentUser);
      delay(1000);
  } else {
      buzzVibrate(false);
  }

  // Loop through the output tensor values from the model
  for (int i = 0; i < NUM_HOTSPOT; i++) {
    Serial.print(HOTSPOT[i]);
    Serial.print(": ");
    Serial.println(tflOutputTensor->data.f[i], 6);
  }
  Serial.println();
}

String getPreviousFile() {
  modelFile = sd.open("info.h");
  String file = "";
    if (modelFile) {
      while (modelFile.available()) {
        uint8_t readByte = modelFile.read();
        file += (char) readByte;
      } 
    }
    modelFile.close();
    return file;
}

void setPreviousFile(String file_name) {
  modelFile = sd.open("info.h", FILE_WRITE | O_TRUNC);
  if (modelFile) modelFile.print(file_name); 
  modelFile.close();
}

void saveModel(String file_name, uint8_t* model) {
  modelFile = sd.open(file_name + ".h", FILE_WRITE);
  if (modelFile) modelFile.print((char*)model); 
  modelFile.close();
}

void initOldModel(String fileName) {
  if (sd.exists(fileName)) {
    modelFile = sd.open(fileName);
  } else {
    return;
  }

  if (modelFile) {
    // Convert each value separated with spaces to int using the String.toInt()
    // then assign it to the file_buffers index
    String code = "";
    uint32_t file_length = modelFile.size();
    uint32_t new_size = 0; 

    for (uint32_t i=0; i<file_length; i++) {
      uint8_t readByte = modelFile.read();
      code += (char)readByte;
      // 32 = space in ASCII code
      if (readByte == 32 || i == file_length-1) {
        code.trim();
        if (isNumeric(code)) {
          file_buffers[new_size] = code.toInt();
          new_size++;
        } else {
          file_name = code;
        }
        code = "";
      }
    }
    modelFile.close();

    // Assign 0 to remaining indexes (considered as padding, does not affect the model)
    for (size_t i=new_size; i<file_maximum_byte_count; i++) {
      file_buffers[i] = 0;
    }
    Serial.println("Done!");

  } else {
    // if the file didn't open, print an error:
    Serial.println("error opening xtnctx.h");
  }
}

void saveBuzz(String targetDatetime, String filename) {
  // String targetDatetime = "02/25/2024";
  JsonDocument jsonDocument;
  File dashboardFile = sd.open(filename + ".json", FILE_READ);

  if (dashboardFile) {
    DeserializationError error = deserializeJson(jsonDocument, dashboardFile);
    dashboardFile.close();
    if (error) {
      Serial.println("Failed to read JSON file");
      return;
    }
  } else {
    Serial.println("Error opening JSON file");
    return;
  }

  dashboardFile = sd.open(filename + ".json", FILE_WRITE | O_TRUNC);
  if (dashboardFile) {
    // Check if the datetime already exists in the "data" array
    bool datetimeExists = false;

    // Iterate through the "data" array
    JsonArray dataArray = jsonDocument["data"];
    for (JsonObject obj : dataArray) {
      String datetime = obj["datetime"];
      if (datetime.equals(targetDatetime)) {
        // Datetime exists, increment the "buzz" value
        obj["buzz"] = obj["buzz"].as<int>() + 1;
        serializeJson(jsonDocument, dashboardFile);
        dashboardFile.close();
        datetimeExists = true;
        break;
      }
    }

    // If the datetime does not exist, add a new object
    if (!datetimeExists) {
      JsonObject newObj = jsonDocument["data"].createNestedObject();
      newObj["datetime"] = targetDatetime;
      newObj["buzz"] = 1;
      serializeJson(jsonDocument, dashboardFile);
      dashboardFile.close();
    }
  } else {
    Serial.println("Error opening JSON file");
    return;
  }
}

// Function to send data in chunks
void writeUpdatedChunks(const String& data) {
  int dataSize = data.length();
  int chunkSize = 64;
  
  for (int i = 0; i < dataSize; i += chunkSize) {
    String chunk = data.substring(i, min(i + chunkSize, dataSize));
    const char* chunkCStr = chunk.c_str();
    file_update_characteristic.writeValue(chunkCStr);
    isBLEBusy = true;
    Serial.print("Data to send: ");
    Serial.println(chunk);
    delay(100);  // Adjust delay as needed based on your requirements
  }
  isBLEBusy = false;
}

void sendData(String filename) {
  File dataFile = sd.open(filename + ".json");
  JsonDocument jsonDoc;
  DeserializationError error = deserializeJson(jsonDoc, dataFile);
  // Check for parsing errors
  if (error) {
    Serial.print(F("JSON parsing failed: "));
    Serial.println(error.c_str());
  } else {
    // Get the last two "data" array from the JSON document
    JsonArray data = jsonDoc["data"];
    JsonDocument newObj;
    int idx = 1;
    for (int i=data.size()-1; i>=data.size()-2; i--) {
      JsonObject obj = data[i];
      const char* datetime = obj["datetime"];
      int buzz = obj["buzz"].as<int>();
      newObj[idx]["datetime"] = datetime;
      newObj[idx]["buzz"] = buzz;
      idx--;
    }

    
    // Send the string through BLE
    String dataContents;
    serializeJson(newObj, dataContents);
    writeUpdatedChunks(dataContents);
    dataFile.close();
  }
}

void sendAllData(String filename) {
  const int bufferSize = 64;
  char buffer[bufferSize];
  
  File dataFile = sd.open(filename + ".json");
  if (dataFile) {
    bool isReading = true;
    while (isReading) {
      int bytesRead = dataFile.read(buffer, bufferSize);
      if (bytesRead > 0) {
        String dataChunk = "";
        for (int i = 0; i < bytesRead; i++) {
          dataChunk += (char)buffer[i];
        }
        const char* chunkCStr = dataChunk.c_str();
        file_update_characteristic.writeValue(chunkCStr);
        isBLEBusy = true;
        delay(100);
      } else {
        isReading = false;
        dataFile.close();
      }
    }
    isBLEBusy = false;
  } else {
    return;
  }
}


void onBLEFileReceived(uint8_t* file_data, int file_length) {
  // Do something here with the file data that you've received. The memory itself will
  // remain untouched until after a following onFileReceived call has completed, and
  // the BLE module retains ownership of it, so you don't need to deallocate it.
  
  // xupdaterequestx-<currentUser>-<request>-<currentDate>-
  // 
  // UPDATE REQUEST
  // all
  //  - sends all dashboard data
  // last
  //  - sends the last two data (yesterday & today)
  String xupdaterequestx = "";
  for (uint32_t i=0; i<50; i++) {
    uint8_t dataByte = file_data[i];
    if (dataByte == 0) {
      break;
    } else {
      xupdaterequestx += (char)dataByte;
    }
  }

  int index = xupdaterequestx.indexOf("xupdaterequestx");
  if (index != -1) {
    // Parse code to "requests"
    String requests[4];
    String code = "";
    int arraySize  = 0;
    for (int i=0; i<xupdaterequestx.length(); i++) {
      char currentChar = xupdaterequestx.charAt(i);
      if (currentChar != '-') {
        code += xupdaterequestx.charAt(i);
      } else {
        if (arraySize < sizeof(requests) / sizeof(requests[0])) {
          requests[arraySize] = code;
          arraySize++;
          code = "";
        } else {
          Serial.println("Array is full, cannot add more items.");
        }
      }
   
    }

    currentUser = requests[1];
    currentDate = requests[3];
    // Send dashboard data using BLE
    if (requests[2].equals("all")) {
      sendAllData(currentUser);
    } else if (requests[2].equals("last")) {
      sendData(currentUser);
    }

    // Initialize TFL after successful connection
    initOldModel(previous_file);
    initializeTFL(file_buffers);
    delay(100);
    notifySuccess(false);
    

  } else {
    String code = "";
    uint32_t new_size = 0;

    for (uint32_t i=0; i<file_length; i++) {
      uint8_t dataByte = file_data[i];
      code += (char)dataByte;
      // 32 = space in ASCII code
      if (dataByte == 32 || i == file_length-1) {
        code.trim();
        if (isNumeric(code)) {
          file_buffers[new_size] = code.toInt();
          new_size++;
        } else {
          file_name = code;
        }
        code = "";
      }
    }

    // Assign 0 to remaining indexes (considered as padding, does not affect the model)
    for (size_t i=new_size; i<file_maximum_byte_count; i++) {
      file_buffers[i] = 0;
    }

    saveModel(file_name, file_buffers);
    setPreviousFile(file_name);
    initializeTFL(file_buffers);
    delay(100);
    notifySuccess(true);
  }
}

void loop() {
  updateBLEFileTransfer(); // Keep the BLE service open
  if (isBLEBusy) return;

  // Accelerometer & Gyroscope read values
  float aX, aY, aZ, gX, gY, gZ;
  if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && lox.isRangeComplete()) {
    IMU.readAcceleration(aX, aY, aZ);
    char accReadings[data_size_count];
    IMU_read(aX, aY, aZ, accReadings);
    
    IMU.readGyroscope(gX, gY, gZ);
    char gyroReadings[data_size_count];
    IMU_read(gX, gY, gZ, gyroReadings);

    // VL53L0X & MLX90614 read values
    uint16_t lox_read = lox.readRange();
    double mlx_read = mlx.readObjectTempC();
    Serial.print("Distance in mm: ");
    Serial.println(lox_read);
    Serial.print("*C\tObject = "); Serial.print(mlx_read); Serial.println("*C");
    
    // Check if sensor readings are valid
    if (!isnan(lox_read) && !isnan(mlx_read)) {
      String distance = String(lox_read);
      String temperature = String(mlx_read);

      if (isConnected) {
        String distance_temperature = distance + "," + temperature;
        const char* distance_temperature_cstr = distance_temperature.c_str();
        distance_temperature_characteristic.writeValue(distance_temperature_cstr);
        accelerometer_characteristic.writeValue(accReadings);
        gyroscope_characteristic.writeValue(gyroReadings);
      }
      delay(100); // adds 0.1s for the mobile app to keep up - ( for smooth plotting )
    }
  }

  // TFLite classification
  if (isModelInitialized && !currentDate.equals("") && !currentUser.equals("")) {
    runClassification(aX, aY, aZ, gX, gY, gZ);
  }
  delay(10);
}
