/***********************************************************************************
    Arduino Uno Memory Expansion Sample Program
    Author:  J. B. Gallaher       07/09/2016

   Sample program to use a Serial SRAM chip to expand memory for an Arduino Uno
   giving access to an additional 128kB of random access memory.  The 23LC1024 uses
   the Serial Peripheral Interface (SPI) to transfer data and commands between the
   UNO and the memory chip.  Note that the functions could be extracted as a beginning
   for a library for this chip.
   
   Used the following components:
   (1) Arduino Uno
   (2) Microchip 23LC1024 SPI SRAM chip soldered on an Arduino Protoshield
***********************************************************************************/
 
#include <SPI.h>

/************SRAM opcodes: commands to the 23LC1024 memory chip ******************/
#define RDMR        5       // Read the Mode Register
#define WRMR        1       // Write to the Mode Register
#define READ        3       // Read command
#define WRITE       2       // Write command
#define RSTIO     0xFF      // Reset memory to SPI mode
#define ByteMode    0x00    // Byte mode (read/write one byte at a time)
#define Sequential  0x40    // Sequential mode (read/write blocks of memory)
// #define CS          10      // Chip Select Line for Uno
uint8_t CS[2] = {10, 9};
/******************* Function Prototypes **************************/
void SetMode(char Mode);
byte ReadByte(uint32_t address);
void WriteByte(uint32_t address, byte data_byte);
void WriteArray(uint32_t address, byte *data, uint16_t big);
void ReadArray(uint32_t address, byte *data, uint16_t big);

/*******************  Create Global Variables *********************/
byte x[] = {"abcdefghij"};         // array data to write
byte y[] = {"klmnopqrst"};
byte read_data[10];                           // arrary to hold data read from memory
byte i = 0;                                   // loop counter variable
constexpr int32_t file_block_byte_count = 2;

/*******  Set up code to define variables and start the SCI and SPI serial interfaces  *****/
void setup(void) {
  pinMode(CS[0], OUTPUT);                        // Make pin 10 of the Arduino an output
  pinMode(CS[1], OUTPUT);                        // Make pin 10 of the Arduino an output
  Serial.begin(9600);                         // set communication speed for the serial monitor
  SPI.begin();                                // start communicating with the memory chip    

/************  Write a Sequence of Bytes from an Array *******************/
  Serial.println("\nWriting array using Sequential: ");
  SetMode(Sequential, CS[0]);
  SetMode(Sequential, CS[1]);
                                                // set to send/receive multiple bytes of data
  WriteArray10(0, x, sizeof(x));    
  WriteArray9(0, y, sizeof(y));                  // Use the array of characters defined in x above
                                                // write to memory starting at address 0
}
 
void loop() {                                   // we have nothing to do in the loop
  /************ Read a Sequence of Bytes from Memory into an Array **********/
  Serial.println("Reading array using sequential: ");
  SetMode(Sequential, CS[0]);                          // set to send/receive multiple bytes of data
  ReadArray10(0, read_data, sizeof(read_data));   // Read from memory into empty array read_data
                                                // starting at memory address 0
  for(uint16_t i=0; i<sizeof(read_data); i++)  {         // print the array just read using a for loop
    Serial.print("Printing ");
    Serial.println(i+1);
    Serial.println((char)read_data[i]);         // We need to cast it as a char
  }                                             // to make it print as a character

  Serial.println();

  SetMode(Sequential, CS[1]);                          // set to send/receive multiple bytes of data
  ReadArray9(0, read_data, sizeof(read_data));   // Read from memory into empty array read_data
                                                // starting at memory address 0
  for(uint16_t i=0; i<sizeof(read_data); i++)  {         // print the array just read using a for loop
    Serial.print("Printing ");
    Serial.println(i+1);
    Serial.println((char)read_data[i]);         // We need to cast it as a char
  }                                             // to make it print as a character

  // delay(3000);
                                                
}


/*  Functions to Set the Mode, and Read and Write Data to the Memory Chip ***********/

/*  Set up the memory chip to either single byte or sequence of bytes mode **********/
void SetMode(char Mode, uint8_t CS){                        // Select for single or multiple byte transfer
  digitalWrite(CS, LOW);                        // set SPI slave select LOW;
  SPI.transfer(WRMR);                           // command to write to mode register
  SPI.transfer(Mode);                           // set for sequential mode
  digitalWrite(CS, HIGH);                       // release chip select to finish command
}

/*********** Sequential data transfer functions using Arrays ************************/
void WriteArray10(uint32_t address, byte *data, uint16_t big){
  uint16_t i = 0;                                 // loop counter
  digitalWrite(CS[0], LOW);                          // start new command sequence
  SPI.transfer(WRITE);                            // send WRITE command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  SPI.transfer(data, big);                        // transfer an array of data => needs array name & size
  digitalWrite(CS[0], HIGH);                         // set SPI slave select HIGH
}

void WriteArray9(uint32_t address, byte *data, uint16_t big){
  uint16_t i = 0;                                 // loop counter
  digitalWrite(CS[1], LOW);                          // start new command sequence
  SPI.transfer(WRITE);                            // send WRITE command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  SPI.transfer(data, big);                        // transfer an array of data => needs array name & size
  digitalWrite(CS[1], HIGH);                         // set SPI slave select HIGH
}

void ReadArray10(uint32_t address, byte *data, uint16_t big){
  digitalWrite(CS[0], LOW);                          // start new command sequence
  SPI.transfer(READ);                             // send READ command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  for(uint16_t i=0; i<big; i++){
    data[i] = SPI.transfer(0x00);                 // read the data byte
  }
  digitalWrite(CS[0], HIGH);                         // set SPI slave select HIGH
}

void ReadArray9(uint32_t address, byte *data, uint16_t big){
  digitalWrite(CS[1], LOW);                          // start new command sequence
  SPI.transfer(READ);                             // send READ command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  for(uint16_t i=0; i<big; i++){
    data[i] = SPI.transfer(0x00);                 // read the data byte
  }
  digitalWrite(CS[1], HIGH);                         // set SPI slave select HIGH
}
