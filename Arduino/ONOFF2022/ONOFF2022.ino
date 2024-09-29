/* Quantum Eraser control
   Stepper motor part. Hans T. Benze
   ON/OFF laser and detectors part. Kiko Galvez
   Colgate University Physics and Astronomy
   26 March 2020
*/

//String onoff="";
//String Lon="1";
//String Loff="2";
//String Don="3";
//String Doff="4";
String eraser = "out";
#include <Stepper.h>
const int ledPin = 13;
const int stepsPerRevolution = 200;
//int steps = stepsPerRevolution;
int analogPin = A1; 
char receivedChar;
boolean newData = false;
int alignmentlaser = 0; // laser blocked = 0, unblocked = 1
int detectors = 0; // dttectors off = 0,on = 1
int detvi;
float detv;

void setup() {
  Serial.begin(38400);
  while (!Serial) {
    ;
  }
  pinMode(3, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  
      Serial.println("");
      Serial.println(" Laser should be ON for at least 15 min before taking data");
      Serial.println(" Display menu =0");
      Serial.println(" Laser 1=ON, 2=OFF:");
      Serial.println(" Detectors 3=ON, 4=OFF:");
      Serial.println(" Alignment laser 5=ON, 6=OFF");
      Serial.println(" View Detector Voltage = 9");
      Serial.println(" Enter Command ");
}

void loop() {
        if (Serial.available() > 0) {
    receivedChar = Serial.read();
    newData = true;
  }
 if (newData == true) {
    if (receivedChar == '0')
    {
      Serial.println(" Laser should be ON for at least 15 min before taking data");
      Serial.println(" Display menu =0");
      Serial.println(" Laser 1=ON, 2=OFF:");
      Serial.println(" Detectors 3=ON, 4=OFF:");
      Serial.println(" Alignment laser 5=ON, 6=OFF");
      Serial.println(" View Detector Voltage = 9");
      Serial.println(" Enter Command ");
    }

    if (receivedChar == '1')
    {
      // digitalWrite(13, HIGH);
      digitalWrite(3, HIGH);
      Serial.println("Laser ON");
    }
    if (receivedChar == '2') {
      // digitalWrite(13,LOW);
      digitalWrite(3, LOW);
      Serial.println("Laser OFF");
    }
    if (receivedChar == '3')
    {
      // digitalWrite(13, HIGH);
      if (alignmentlaser == 0) {
      digitalWrite(5, HIGH);
      Serial.println("Detectors ON");
      detectors = 1;}
      else {
      Serial.println("Alignment laser is on!");
      }
      
    }
    if (receivedChar == '4') {
      //digitalWrite(13,LOW);
      digitalWrite(5, LOW);
      Serial.println("Detectors OFF");
      detectors = 0;
    }
        if (receivedChar == '5')
    {
      // digitalWrite(13, HIGH);
      if (detectors == 0) {
      digitalWrite(6, HIGH);
      Serial.println("Alignment laser ON");
      alignmentlaser = 1;}
      else {
      Serial.println("Detectors are on!");
      }
    }
    if (receivedChar == '6') {
      //digitalWrite(13,LOW);
      digitalWrite(6, LOW);
      Serial.println("Alignment laser OFF");
      alignmentlaser = 0;
    }

    if (receivedChar == '9') {
      //digitalWrite(13,LOW);
      detvi=analogRead(analogPin);
      detv=detvi/1023.0*5.0;
      Serial.print("Detector voltage = ");
      Serial.print(detv,3);
      Serial.println(" V");
      
    }

            
            newData = false;
 }
}


