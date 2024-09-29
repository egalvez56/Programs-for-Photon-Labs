// Arduinolaviewdac16
//
// Program to generate a voltage from the Labview program 
// to record single-photon interference.
// based on analog_out.ino and dacarduino with much input 
// from Shannon Zachow, 2014-2015
// Most recent update and revision by Kiko Galvez 6/16
//
//
// Primary computer writes instructions to serial port (COM1, COM2, etc).
// Arduino reads from serial port, and outputs that analog voltage.
//
// 02mar2015, stz -- remove all Serial.print() statements.
//                   these are implicated in serial coms slow-downs!

#include <SPI.h>  // use Arduino's SPI library
// digital pins used by the SPI library:
#define PIN_MOSI  11    // Connected to PIN 2 Din of DAC
#define PIN_MISO  12    // Not used
#define PIN_SCK   13    // Connected to PIN 1 of DAC
#define PIN_SS    10    // Not used
#define PIN_nLOAD  9    // Connected to PIN 3 of DAC
#define VOLTAGE_MAX  (9.0)  // max output of DAC = Vref pin 6
#define DIGITAL_MAX  (4095) // biggest 12bit integer + 1.
//#define PIN_COUNT 10  // using this many digital pins for output
//#define PIN_BASE  4   // this is the lowest digital pin number used for output
#define BIGGEST_WORD (1<<PIN_COUNT)  // largest # we can output = 2^PIN_COUNT
#define BUFLEN    128

#define OUTMIN  (0.0)
#define OUTMAX (9.0)


// setup()
//
// arduino required function.
// runs once only at power-up or at reset
//
void setup()
{ int i,p;
  

  
  // start Arduino's serial port @ 9600 baud.
//  Serial.begin(9600);
//  Serial.begin(115200);

  pinMode(PIN_nLOAD, OUTPUT); // configure our load pin
  
  SPI.begin();                // start SPI bus (configs all SPI pins automatically)
  SPI.setClockDivider(SPI_CLOCK_DIV16);
                              // arduino runs at 16MHz
                              // LTC1257 DAC max speed 1.4MHz
                              // divide arduino clock speed by 16 to clock LTC1257 @ 1MHz
  SPI.setBitOrder(MSBFIRST);  // LTC1257 expects bits to arrive MSB first
  SPI.setDataMode(SPI_MODE0);
  Serial.begin(115200);
  
}



// loop()

void loop()
{ int cmd;
  char b[BUFLEN];
  float x,y;
  
  if(Serial.available() > 0)  // if bytes are waiting for us in the serial port...
  {
    x = Serial.parseFloat();  // try to read them as a floating point number
    if(x >= OUTMIN
    && x <= OUTMAX)
    { 
      transferFloat(x);
//      y = BIGGEST_WORD * ((x - OUTMIN) / (OUTMAX - OUTMIN));  // range mapping
//      digitalWriteWord((int)y);  // express that voltage at the output.
    }
    else // out of range
    { // send an error message back through the serial port.
      // You won't see this, unless you have opened the Serial Monitor in
      //  the arduino IDE, while the program is running.
      
      // found hint online that Serial.print is implicated in
      // slow-down of serial coms -- don't do this!
      
      /**
      Serial.print("Range Error: asked to output ");
      Serial.println(x);
      Serial.print("  OUTMIN = ");
      Serial.println(OUTMIN);
      Serial.print("  OUTMAX = ");
      Serial.println(OUTMAX);
      **/
    }
    Serial.readBytesUntil('\n',b,BUFLEN);  // read & discard newline
  }
}

/***********************************************/

void transferFloat(float v)
{ int d, lob, hib, bits, bitshift, Nmax, volt, voltlow;
float voltf;
  bits = 12;
  bitshift = 12-bits;
  volt = (int) DIGITAL_MAX * (v/VOLTAGE_MAX);
  voltlow = volt >>  bitshift;
  Nmax = DIGITAL_MAX >> bitshift;
  voltf = (float) voltlow/Nmax;
  d = (int) (DIGITAL_MAX * voltf);
     
  // SPI library is set up to transfer one byte (8bits) at a time.
  // we have 12bits, so we need 2 bytes.
  // separate the integer value 'd' into a low-byte and a high-byte.
  lob = (d & 0x00ff);
  hib = (d & 0x0f00) >> 8;
     
  // LTC1257 expects MSB first, so make sure we ship 'hib' first!
  SPI.transfer(hib);
  SPI.transfer(lob);
  
  // 12bits are now in LTC1257's serial-in-shift-register.
  // Toggle ~LOAD pin so this is latched to LTC1257's DAC output register.
  // minimum toggle time = 150ns.
  // include delayMicroseconds(1); call just to make sure.
  digitalWrite(PIN_nLOAD, LOW);
  delayMicroseconds(1);
  digitalWrite(PIN_nLOAD, HIGH); 
  
  // if our peripheral had a Chip-Select pin, we would need to disable that here.
  //    digitalWrite(pinCS, HIGH);
}

/***********************************************/


// eof

