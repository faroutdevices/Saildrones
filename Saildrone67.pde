#include <Servo.h> 
 
Servo servoRudder;  // create servo object to control a servo 
Servo servoSheet;  // create servo object to control a servo 

int servoRudderDegrees;
int servoSheetDegrees;
int readPin0 = 0;                // This is rudder to starboard pin
int readPin1 = 1;                // This is rudder to port pin
int readPin2 = 2;                // This is the sheet pin
int readValueA = 0;
int readValueB = 0;
int readValueC = 0;

void setup()                    // run once, when the sketch starts
{
  //pinMode(ledPin, OUTPUT);
  //pinMode(readPin0, INPUT);  // sets the digital pin as input
  //pinMode(readPin1, INPUT);  // sets the digital pin as input
  //pinMode(readPin2, INPUT);  // sets the digital pin as input  
  //analogReference(EXTERNAL); 
  analogReference(INTERNAL);   
  
  servoRudder.attach(8);  // attaches the servo on pin 8 to the servo object
  servoSheet.attach(9);  // attaches the servo on pin 9 to the servo object

  servoRudderDegrees = 85; //rudder center
  servoSheetDegrees = 130; //sheet in 
 
  delay(1000);
  Serial.begin(9600);
}

void loop()                     // run over and over again
{  
    //digitalWrite(14, LOW);  // set pullup on analog pin 0  
    readValueA = analogRead(readPin0); 
    delay(15); //lets put the delay up here, thus using for it's intented use AND giving a little delay between reading the pins    
    readValueB = analogRead(readPin1);
    readValueC = analogRead(readPin2);    

    if (readValueA > 400)
    {
        servoRudderDegrees = 135;  //rudder to starboard 

        int var = 0;
        while(var < 150) //doing this for about 2 seconds
        {          
          //servos are constantly refreshing with last value set
          servoRudder.write(servoRudderDegrees);   
          delay(15);
  
          // print the results to the serial monitor:                       
          Serial.println("Turning 1");                    
          var++;
        }
        
        servoRudderDegrees = 85;  //rudder back to center after turning       
    }
    else if (readValueB > 400)
    {
         servoRudderDegrees = 35;  //rudder to port 

        int var = 0;
        while(var < 150) //doing this for about 2 seconds
        {          
          //servos are constantly refreshing with last value set
          servoRudder.write(servoRudderDegrees);   
          delay(15);
  
          // print the results to the serial monitor:                       
          Serial.println("Turning 2");                    
          var++;
        }
  
        servoRudderDegrees = 85;  //rudder back to center after turning        
    }    
    else if (readValueC > 400) //toggle sheet position
    {
      if (servoSheetDegrees == 70)
      {
        servoSheetDegrees = 130;  //let sheet out
    
        int var = 0;
        while(var < 150) //since sheet is going to be held in position until next sheet command, shouldn't have to do this while, but it was tweaking without it
        {          
          //servos are constantly refreshing with last value set
          servoSheet.write(servoSheetDegrees);   
          delay(15);
  
          // print the results to the serial monitor:                       
          Serial.println("Letting sheet out");                    
          var++;
        }    
        
      }
      else
      {
        servoSheetDegrees = 70;  //put sheet in 
 
        int var = 0;
        while(var < 150) //since sheet is going to be held in position until next sheet command, shouldn't have to do this while, but it was tweaking without it
        {          
          //servos are constantly refreshing with last value set
          servoSheet.write(servoSheetDegrees);   
          delay(15);
  
          // print the results to the serial monitor:                       
          Serial.println("Pulling sheet in");                    
          var++;
        }       
      }
    }    
    else
    {
         servoRudderDegrees = 85;  //rudder to center      
    }


    //servos are constantly refreshing with last value set
    servoRudder.write(servoRudderDegrees);
    servoSheet.write(servoSheetDegrees);  
  
    // print the results to the serial monitor:                       
    Serial.print(readValueA);
    Serial.print("\t");    
    Serial.print(readValueB);
    Serial.print("\t");    
    Serial.println(readValueC);    
}
