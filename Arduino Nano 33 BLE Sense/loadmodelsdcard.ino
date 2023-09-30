#include <SD.h>
uint8_t *loadedModel;
bool x = true;
File myFile;

void setup() {
  Serial.begin(9600);
  while (!Serial);

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
    myFile = SD.open("head.h");
    if (myFile) {
      Serial.println("head.h:");
      size_t modelSize = myFile.size();

      for (size_t i = 0; i < modelSize; i++) {
        Serial.println(myFile.read());
      }


      // // read from the file until there's nothing else in it:
      // while (myFile.available()) {
      //   Serial.write(myFile.read());
      // }
      // close the file:
      myFile.close();
    } else {
      // if the file didn't open, print an error:
      Serial.println("error opening head--ryan.h");
      if (SD.exists("head.h")) Serial.println("head.h exist.");
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
