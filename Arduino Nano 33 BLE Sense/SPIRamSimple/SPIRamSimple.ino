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
#define CS          10      // Chip Select Line for Uno

/******************* Function Prototypes **************************/
void SetMode(char Mode);
byte ReadByte(uint32_t address);
void WriteByte(uint32_t address, byte data_byte);
void WriteArray(uint32_t address, byte *data, uint16_t big);
void ReadArray(uint32_t address, byte *data, uint16_t big);

/*******************  Create Global Variables *********************/
byte x[] = {"abcdefghijklmnopqrst"};         // array data to write
byte read_data[20];                           // arrary to hold data read from memory
byte i = 0;                                   // loop counter variable

/*******  Set up code to define variables and start the SCI and SPI serial interfaces  *****/
void setup(void) {
  uint32_t address = 0;                       // create a 32 bit variable to hold the address
  byte value;                                 // create variable to hold the data value read
  byte data;                                  // create variable to hold the data value sent
  pinMode(CS, OUTPUT);                        // Make pin 10 of the Arduino an output
  Serial.begin(9600);                         // set communication speed for the serial monitor
  SPI.begin();                                // start communicating with the memory chip    

/**********Write a Single Byte Each Time to Memory *******************/
  Serial.println("Writing data bytes individually: ");
  SetMode(ByteMode);                          // set to send/receive single byte of data
  data = 0;                                   // initialize the data
  for(i = 0; i <=5; i++){                     // Let's write 5 individual bytes to memory 
    address = i;                              // use the loop counter as the address                     
    WriteByte(address, data);                 // now write the data to that address
    data+=2;                                  // increment the data by 2 
  }
  
/********* Read a single Byte Each Time to Memory *********************/
  Serial.println("Reading each data byte individually: ");
  SetMode(ByteMode);                          // set to send/receive single byte of data
  for(i = 0; i <=5; i++){                     // start at memory location 0 and end at 5
    address = i;                              // use the loop counter as the memory address
    value = ReadByte(address);                // reads a byte of data at that memory location
    Serial.println(value);                    // Let's see what we got
  }

/************  Write a Sequence of Bytes from an Array *******************/
  Serial.println("\nWriting array using Sequential: ");
  SetMode(Sequential);                          // set to send/receive multiple bytes of data
  WriteArray(0, x, sizeof(x));                  // Use the array of characters defined in x above
                                                // write to memory starting at address 0

/************ Read a Sequence of Bytes from Memory into an Array **********/
  Serial.println("Reading array using sequential: ");
  SetMode(Sequential);                          // set to send/receive multiple bytes of data
  ReadArray(0, read_data, sizeof(read_data));   // Read from memory into empty array read_data
                                                // starting at memory address 0
  for(i=0; i<sizeof(read_data); i++)            // print the array just read using a for loop
    Serial.println((char)read_data[i]);         // We need to cast it as a char
                                                // to make it print as a character
}
 
void loop() {                                   // we have nothing to do in the loop
  /************ Read a Sequence of Bytes from Memory into an Array **********/
  Serial.println("Reading array using sequential: ");
  SetMode(Sequential);                          // set to send/receive multiple bytes of data
  ReadArray(0, read_data, sizeof(read_data));   // Read from memory into empty array read_data
                                                // starting at memory address 0
  for(i=0; i<sizeof(read_data); i++)  {         // print the array just read using a for loop
    Serial.println((char)read_data[i]);         // We need to cast it as a char
  }                                             // to make it print as a character

  delay(5000);
                                                
}


/*  Functions to Set the Mode, and Read and Write Data to the Memory Chip ***********/

/*  Set up the memory chip to either single byte or sequence of bytes mode **********/
void SetMode(char Mode){                        // Select for single or multiple byte transfer
  digitalWrite(CS, LOW);                        // set SPI slave select LOW;
  SPI.transfer(WRMR);                           // command to write to mode register
  SPI.transfer(Mode);                           // set for sequential mode
  digitalWrite(CS, HIGH);                       // release chip select to finish command
}

/************ Byte transfer functions ***************************/
byte ReadByte(uint32_t address) {
  char read_byte;
  digitalWrite(CS, LOW);                         // set SPI slave select LOW;
  SPI.transfer(READ);                            // send READ command to memory chip
  SPI.transfer((byte)(address >> 16));           // send high byte of address
  SPI.transfer((byte)(address >> 8));            // send middle byte of address
  SPI.transfer((byte)address);                   // send low byte of address
  read_byte = SPI.transfer(0x00);                // read the byte at that address
  digitalWrite(CS, HIGH);                        // set SPI slave select HIGH;
  return read_byte;                              // send data back to the calling function
}
  
void WriteByte(uint32_t address, byte data_byte) {
  digitalWrite(CS, LOW);                         // set SPI slave select LOW;
  SPI.transfer(WRITE);                           // send WRITE command to the memory chip
  SPI.transfer((byte)(address >> 16));           // send high byte of address
  SPI.transfer((byte)(address >> 8));            // send middle byte of address
  SPI.transfer((byte)address);                   // send low byte of address
  SPI.transfer(data_byte);                       // write the data to the memory location
  digitalWrite(CS, HIGH);                        //set SPI slave select HIGH
}

/*********** Sequential data transfer functions using Arrays ************************/
void WriteArray(uint32_t address, byte *data, uint16_t big){
  uint16_t i = 0;                                 // loop counter
  digitalWrite(CS, LOW);                          // start new command sequence
  SPI.transfer(WRITE);                            // send WRITE command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  SPI.transfer(data, big);                        // transfer an array of data => needs array name & size
  digitalWrite(CS, HIGH);                         // set SPI slave select HIGH
}

void ReadArray(uint32_t address, byte *data, uint16_t big){
  uint16_t i = 0;                                 // loop counter
  digitalWrite(CS, LOW);                          // start new command sequence
  SPI.transfer(READ);                             // send READ command
  SPI.transfer((byte)(address >> 16));            // send high byte of address
  SPI.transfer((byte)(address >> 8));             // send middle byte of address
  SPI.transfer((byte)address);                    // send low byte of address
  for(i=0; i<big; i++){
    data[i] = SPI.transfer(0x00);                 // read the data byte
  }
  digitalWrite(CS, HIGH);                         // set SPI slave select HIGH
}
