#include <SD.h>
uint8_t *loadedModel;
bool x = true;
File myFile;

constexpr int32_t file_maximum_byte_count = (120 * 1024);
uint8_t file_buffers[file_maximum_byte_count];

void setup() {
  Serial.begin(9600);
  bool sdBegin = SD.begin(10);
  while (!sdBegin) {
    Serial.println("Trying to initialize...");
    sdBegin = SD.begin(10);
    delay(500);
  }
  Serial.println("SD Card Initialized.");


}

String getPreviousFile() {
  myFile = SD.open("info.h");
  String file = "";
    if (myFile) {
      while (myFile.available()) {
        uint8_t readByte = myFile.read();
        // Skip carriage return (CR) and line feed (LF) characters
        if (readByte != 13 && readByte != 10) {
          file += (char) readByte;
        }
      } 
    }
    myFile.close();
    return file;
}

void setCurrentFile(String file_name) {
  myFile = SD.open("info.h", FILE_WRITE | O_TRUNC);
  if (myFile) myFile.println(file_name); 
  myFile.close();
}

void loop() {
  // put your main code here, to run repeatedly:
  // re-open the file for reading:
  delay(5000);
  if (x) {
    String previous_file = getPreviousFile();
    myFile = SD.open(previous_file);
    if (myFile) {
      // Convert each value separated with spaces to int using the String.toInt()
      // then assign it to the file_buffers index
      String code = "";
      uint32_t file_length = myFile.size();
      uint32_t new_size = 0; 

      for (uint32_t i=0; i<file_length; i++) {
        uint8_t readByte = myFile.read();
        code += (char)readByte;
        // 32 = space in ASCII code
        if(readByte == 32 || i == file_length-1) {
          file_buffers[new_size] = code.toInt();
          new_size++;
          code = "";
        }
      }
      myFile.close();

      // Assign 0 to remaining indexes (considered as padding, does not affect the model)
      for (size_t i=new_size; i<file_maximum_byte_count; i++) {
        file_buffers[i] = 0;
      }
      Serial.println("Done!");

      
    } else {
      // if the file didn't open, print an error:
      Serial.println("error opening xtnctx.h");
      if (SD.exists("xtnctx.h")) Serial.println("xtnctx.h exist.");
    }
  }
  x = false;
  

}

// void loadModel() {
//     File file = SD.open("/header--ryan.h", FILE_READ);
//     size_t modelSize = file.size();

//     Serial.print("Found model on filesystem of size ");
//     Serial.println(modelSize);

//     // allocate memory
//     loadedModel = (uint8_t*) malloc(modelSize);

//     // copy data from file
//     for (size_t i = 0; i < modelSize; i++)
//         loadedModel[i] = file.read();

//     file.close();
// }
