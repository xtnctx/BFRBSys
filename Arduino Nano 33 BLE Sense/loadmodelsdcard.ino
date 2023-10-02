#include <SD.h>
uint8_t *loadedModel;
bool x = true;
File myFile;

uint8_t file_buffers[120 * 1024];
size_t file_buffer_length = sizeof(file_buffers) / sizeof(file_buffers[0]);

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

void loop() {
  // put your main code here, to run repeatedly:
  // re-open the file for reading:
  delay(5000);
  if (x){
    myFile = SD.open("xtnctx.h");
    if (myFile) {
      Serial.println("xtnctx.h:");
      String file = "";
      String code = "";
      uint32_t file_length = myFile.size();
      
      // read all values
      while (myFile.available()) {
        file = myFile.readString();
      }
      // close the file:
      myFile.close();
      
      
      // Convert each value separated with spaces to int using the String.toInt()
      // then assign it to the file_buffers index

      
      uint32_t new_size = 0; 

      for (uint32_t i=0; i<file_length; i++) {
        code += file[i];
        if(file[i] == ' ') {
          file_buffers[new_size] = code.toInt();
          new_size++;
          code = "";
        }
        // get last code
        if(i == file_length-1) {
          file_buffers[new_size] = code.toInt();
          new_size++;
          code = "";
        }

      }

      for (size_t i=new_size; i<file_buffer_length; i++) {
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
