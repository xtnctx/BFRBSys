// split string to array (c++)
#include "Arduino.h"

String serialResponse = "";
char sz[] = "Here; is some; sample;100;data;1.414;1020";

void setup()
{
 Serial.begin(9600);
 Serial.setTimeout(5);
}

void loop()
{
  if ( Serial.available()) {
    serialResponse = Serial.readStringUntil('\r\n');

    // Convert from String Object to String.
    char buf[sizeof(sz)];
    serialResponse.toCharArray(buf, sizeof(buf));
    char *p = buf;
    char *str;
    while ((str = strtok_r(p, ";", &p)) != NULL) // delimiter is the semicolon
      Serial.println(str);
  }
}
