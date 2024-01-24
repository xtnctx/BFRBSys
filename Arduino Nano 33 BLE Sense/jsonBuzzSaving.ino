#include <ArduinoJson.h>
#include <SdFat.h>

SdFat sd;

File dashboardFile;
int flag = 0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  // SD card setup
  bool sdBegin = sd.begin(10);
  while (!sdBegin) {
    Serial.println("Trying to initialize...");
    sdBegin = sd.begin(10);
    delay(500);
  }
  Serial.println("SD Card Initialized.");
  
  

  

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

void updateOrAddDatetime(JsonDocument& doc, const char* targetDatetime) {
  // Check if the datetime already exists in the "data" array
  bool datetimeExists = false;

  // Iterate through the "data" array
  JsonArray dataArray = doc["data"];
  for (JsonObject obj : dataArray) {
    const char* datetime = obj["datetime"];
    if (strcmp(datetime, targetDatetime) == 0) {
      // Datetime exists, increment the "buzz" value
      obj["buzz"] = obj["buzz"].as<int>() + 1;

      datetimeExists = true;
      break;
    }
  }

  // If the datetime does not exist, add a new object
  if (!datetimeExists) {
    JsonObject newObj = doc["data"].createNestedObject();
    newObj["datetime"] = targetDatetime;
    newObj["buzz"] = 1;
    dataArray.add(newObj);
  }
}

void loop() {
  delay(2000);
  // if (flag == 0){
    // UPDATE REQUEST
    // xupdaterequestx-all
    // xupdaterequestx-01/22/2024 - start
    
    // char value[] = "dummy-01/22/2024";
    // String xupdaterequestx = "";
    
    // for (uint32_t i=0; i<26; i++) {
    //   // uint8_t dataByte = file_data[i]
    //   // xupdaterequestx += (char)dataByte;
    //   xupdaterequestx += value[i];
    // }

    // int index = xupdaterequestx.indexOf("xupdaterequestx");

    // if (index != -1) {
    //   Serial.println("Update is requested");
    //   int delimiterIndex = xupdaterequestx.indexOf("-");
    //   String request = xupdaterequestx.substring(delimiterIndex + 1);
    //   Serial.println(request);
    // } else {
    //   Serial.println("Substring not found");
    // }

    // dashboardFile = sd.open("ryan.json", FILE_READ);
    // JsonDocument jsonDocument;
    // if (dashboardFile) {

    //   DeserializationError error = deserializeJson(jsonDocument, dashboardFile);
    //   dashboardFile.close();

    //   if (error) {
    //     Serial.println("Failed to read JSON file");
    //     return;
    //   }

    //   // Print original JSON content
    //   Serial.println("Original JSON content:");
    //   serializeJsonPretty(jsonDocument, Serial);
    //   Serial.println();
      
    //   // Specify the datetime you want to update
    //   const char* targetDatetime = "02/25/2024";

    //   // Call the function to update or add the datetime
    //   updateOrAddDatetime(doc, targetDatetime);
      

    
    // } else {
    //   // if the file didn't open, print an error:
    //   Serial.println("error opening xtnctx.h");
    // }

    // // UPDATE
    // dashboardFile = sd.open("ryan.json", FILE_WRITE | O_TRUNC);

    // JsonObject obj = jsonDocument["data"].createNestedObject();
    // obj["datetime"] = "56/78/5678";
    // obj["buzz"] = 88;

    // if (dashboardFile) {
    //   serializeJson(jsonDocument, dashboardFile);
    //   dashboardFile.close();
    //   Serial.println("JSON content updated in config.json");
    // } else {
    //   Serial.println("Failed to open config.json for writing");
    // }
    
    const char* targetDatetime = "02/25/2024";
    JsonDocument jsonDocument;
    dashboardFile = sd.open("ryan.json", FILE_READ);

    if (dashboardFile) {
      DeserializationError error = deserializeJson(jsonDocument, dashboardFile);
      dashboardFile.close();
      if (error) {
        Serial.println("Failed to read JSON file");
        return;
      }

      Serial.println("Original JSON content:");
      serializeJsonPretty(jsonDocument, Serial);
      Serial.println();

    } else {
      Serial.println("Error opening JSON file");
    }
    

    dashboardFile = sd.open("ryan.json", FILE_WRITE | O_TRUNC);
    if (dashboardFile) {
      // Check if the datetime already exists in the "data" array
      bool datetimeExists = false;

      // Iterate through the "data" array
      JsonArray dataArray = jsonDocument["data"];
      for (JsonObject obj : dataArray) {
        const char* datetime = obj["datetime"];
        if (strcmp(datetime, targetDatetime) == 0) {
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
    }

    


    // // READ NEW
    // dashboardFile = sd.open("ryan.json", FILE_READ);
    // JsonDocument jsonDocument;
    // if (dashboardFile) {
    //   DeserializationError error = deserializeJson(jsonDocument, dashboardFile);
    //   dashboardFile.close();
    //   if (error) {
    //     Serial.println("Failed to read JSON file");
    //     return;
    //   }

    //   // Print original JSON content
    //   Serial.println("Original JSON content:");
    //   serializeJsonPretty(jsonDocument, Serial);
    //   Serial.println();

    // } else {
    //   // if the file didn't open, print an error:
    //   Serial.println("error opening xtnctx.h");
    // }
    
    
    // if (dashboardFile) {
    //   Serial.println("Success to read JSON file");
    //   DeserializationError error = deserializeJson(jsonDocument, dashboardFile);
    //   dashboardFile.close();
    //   if (error) {
    //     Serial.println("Failed to read JSON file");
    //     return;
    //   }

    //   // Print original JSON content
    //   Serial.println("Original JSON content:");
    //   serializeJsonPretty(jsonDocument, Serial);
    //   Serial.println();

    // }

    flag = 1;
  // }

  

}
