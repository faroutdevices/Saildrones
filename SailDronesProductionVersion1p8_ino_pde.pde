int led = 13;
int onModulePin = 2;        // the pin to switch on the module (without press on button) 
char phone_number[]="2067909610";     // ********* is the number to send SMS to
 
void setup()
{
    Serial.begin(115200);                // UART baud rate
    delay(2000);
    pinMode(led, OUTPUT);
    pinMode(onModulePin, OUTPUT);
    switchModule();                    // switches the module ON

    for (int i=0;i< 5;i++){            //Give it 25 seconds to start up
        delay(5000);
    } 

    Serial.println("AT+CPMS=\"SM\",\"SM\",\"SM\"");    //selects SIM memory
    Serial.flush();      
}

void loop()
{   int x;
    char data[256];

    delay(3000);
    Serial.println("AT+CMGF=1");         // sets the SMS mode to text
    delay(4000);        
    Serial.println("AT+CNMI=2,1");        //set notification mode, when a new SMS arrives let us know
    Serial.flush();

        delay(2000);  
        for (x=0;x< 255;x++){            
            data[x]='\0';                        
        } 
        x=0;
        do{  
          //wait for a new SMS to arrive
            while(Serial.available()==0);
            data[x]=Serial.read();  
            x++;                        

        }while(!(data[x-1]=='I'&&data[x-2]=='T'));   //we received a new SMS

        delay(2000);        
        readNewSMS();
        delay(2000);       
}

void switchModule()
{
    //Turn on cellular module
    digitalWrite(onModulePin,HIGH);
    delay(2000);
    digitalWrite(onModulePin,LOW);
}


void readNewSMS()
{
        int x;
        char data[256];

        Serial.println("AT+CMGR=0");    //Reads the first and should be only SMS 
        Serial.flush();
        for (x=0;x< 255;x++){            
            data[x]='\0';                        
        } 
        x=0;
        do{
            while(Serial.available()==0);
            data[x]=Serial.read();  
            x++;           
            if(data[x-1]==0x0D&&data[x-2]=='"'){
                x=0;
            }
        }while(!(data[x-1]=='K'&&data[x-2]=='O'));

        data[x-3]='\0';        //finish the string before the OK

        //cj: Now that we have our data with instuctions of what to do, delete the SMS
        Serial.println("AT+CMGD=0,4");    //Delete all messages
        Serial.flush();
  
        //Reading the SMS and deciding what to do
        if (data[1] == '0' && data[2] == '1'){reportLocation();}        
        if (data[1] == '0' && data[2] == '2') {takeAndSendPhoto();}
        //if (data[1] == '0' && data[2] == '3') {sailTrim(12);}
        //if (data[1] == '0' && data[2] == '4') {rudderPosition(4, 5);}
        if (data[1] == '0' && data[2] == '9') {sendSMS2();}        
}

void reportLocation()
{
  digitalWrite(led,HIGH);  
  delay(2000);
 
    do
    {
      Serial.read();  //just read everything in buffer to clear it out, since flush doesn't seem to work    
    }
    while(Serial.available()>0); 
 
  int x,y;
  char inChar2[38];       
              
  Serial.println("AT+CGPS=1,1");         // starts GPS session in stand-alone mode
  while(Serial.read()!='K');
               
  
    //Open Data Connection
    Serial.println("AT+CGSOCKCONT=1,\"IP\",\"wap.cingular\""); //ATT GO Phone Card
    //Serial.println("AT+CGSOCKCONT=1,\"IP\",\"PTA\""); //EDO Card
    while(Serial.read()!='K');

  digitalWrite(led,LOW);  
  delay(2000);  
  
              
  int v = 0;
  do
  {      
    do
    {
      Serial.read();  //just read everything in buffer to clear it out, since flush doesn't seem to work    
    }
    while(Serial.available()>0);
    
    Serial.println("AT+CGPSINFO"); // request GPS info
            
    while(Serial.read()!=':');  //Now read until the start of the gps data /////////////////////////
    delay(2000);    

    for (x=0;x< 38;x++){            
        inChar2[x]='\0';                        
    }
     
    inChar2[0]='G';
    inChar2[1]='P'; 
    inChar2[2]='S'; 
    inChar2[3]='d'; 
    inChar2[4]='a'; 
    inChar2[5]='t';
    inChar2[6]='a'; 
    inChar2[7]='=';
       
    y = 8;
    do{
      inChar2[y] = Serial.read();    
       y++;
       delay(00);       
    }while (y < 37);  
      
    do
    {
      Serial.read();  //just read everything in buffer to clear it out, since flush doesn't seem to work    
    }
    while(Serial.available()>0);

    //Send the data to web service
    ////////Serial.println("AT+CGSOCKCONT=1,\"IP\",\"wap.cingular\""); //ATT GO Phone Card
    //Serial.println("AT+CGSOCKCONT=1,\"IP\",\"PTA\""); //EDO Card
    //while(Serial.read()!='K');  /////////////////
 
    delay(5000); 

    Serial.println("AT+CHTTPACT=\"faroutdevices.com\",80");	//Connects with the HTTP server
        
    delay(10000);  //Well we just never seem to get the REQUEST above, so screw it, we're just going to delay then go on, note it works in a test harness
    
    int msgLength = 38;
    
    Serial.println("POST /saildrone3.asmx/VesselStatus HTTP/1.1");    
    Serial.println("Host: faroutdevices.com");
    Serial.println("Content-Type: application/x-www-form-urlencoded");
    Serial.print("Content-Length: ");
    Serial.println(msgLength);
    Serial.println("");
    Serial.println(inChar2);    
    Serial.write(0x1A);       //sends ++
    Serial.write(0x0D);
    Serial.write(0x0A);
 
    delay(30000); 
    
    blinkLightFast();    
    
    v++;
    }
    while (v < 50);
}


void takeAndSendPhoto()
{  
    delay(10000);  
    int x = 0;
    
    char photoName[20];
    digitalWrite(led,HIGH);    

    Serial.println("AT+CCAMS");     //starts the camera
    while(Serial.read()!='K');
    delay(2000);

    digitalWrite(led,LOW);

    Serial.println("AT+CCAMSETD=640,480");     //sets VGA (640*480) resolution
    while(Serial.read()!='K');
    delay(2000);
    digitalWrite(led,HIGH);     
    
    Serial.println("AT+FSLOCA=0");     //stores the image file in the 3G module
    while(Serial.read()!='K');   

    delay(2000); 
    digitalWrite(led,LOW);
    delay(2000); 

    Serial.println("AT+CCAMTP");     //takes a picture, but not saved it
    digitalWrite(led,HIGH);
    
    //wait for an OK or and Error
    while(Serial.read()!='K');

    delay(2000);    

    Serial.println("AT+CCAMEP");     // saves the picture into D:/Picture    
    Serial.flush();
    
    while(Serial.read()!='/');
    while(Serial.read()!='/');

    digitalWrite(led,LOW);
    delay(2000); 

    x=0;
    do{
        while(Serial.available()==0);
        photoName[x]=Serial.read();
        x++;
    }while(x < 19);

    while(Serial.read()!='K');  

    digitalWrite(led,HIGH);
    delay(2000); 

    Serial.println("AT+CCAME");     // stops the camera
    while(Serial.read()!='K');

    digitalWrite(led,LOW);
    delay(2000); 
    
    sendFTPFile(photoName);
}

void sendFTPFile(char* photoNameLocal)
{
    digitalWrite(led,HIGH);
    delay(10000);
  
    int x;
    char data[256];
    
    Serial.println("AT+CGSOCKCONT=1,\"IP\",\"wap.cingular\"");
    //Serial.println("AT+CGSOCKCONT=1,\"IP\",\"PTA\"");    
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;                        
    }while(!(data[x-1]=='K'&&data[x-2]=='O')); 
 
    digitalWrite(led,LOW); 
     delay(2000);
     
    Serial.println("AT+CFTPSERV=\"simcomtest.smartfile.com\""); //Sets the FTP server 
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));


    digitalWrite(led,HIGH); 
    delay(2000);

    Serial.println("AT+CFTPPORT=21");    //Sets FTP port
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));


    digitalWrite(led,LOW); 
    delay(2000);

    Serial.println("AT+CFTPUN=\"simcomuser\""); //Sets the user name	
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    digitalWrite(led,HIGH); 
    delay(2000);

    Serial.println("AT+CFTPPW=\"1111abcd\""); //Sets password     
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));


    digitalWrite(led,LOW); 
    delay(2000);

    Serial.println("AT+CFTPMODE=1");    //Selects pasive mode
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    digitalWrite(led,HIGH); 
    delay(2000);

    //Selecciona el tipo ASCII
    Serial.println("AT+CFTPTYPE=I");    //Selects ASCII mode
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    digitalWrite(led,LOW); 
    delay(2000);
    
    Serial.print("AT+CFTPPUTFILE=\"");
    Serial.print(photoNameLocal);
    Serial.println("\",1");
    //Serial.println("\",4"); 
    delay(1500);
    
    //Serial.println("AT+CFTPPUTFILE=\"/19800106_000725.jpg\",4");    //Uploads a test file into FTP server.    
    Serial.flush(); 
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read(); 
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));  
 
    digitalWrite(led,HIGH);  
    delay(1000);
    digitalWrite(led,LOW);  
    delay(1000);
    digitalWrite(led,HIGH);  
    delay(1000);
    digitalWrite(led,LOW);  
    delay(1000);    
 
}




void sendSMS2()
{  
    delay(1500);
    Serial.print("AT+CMGS=\"");		// send the SMS number
    Serial.print(phone_number);
		Serial.println("\""); 
    delay(1500);      
    Serial.print("Hola caracola...2");     // the SMS body
    delay(500);
    Serial.write(0x1A);       //sends ++
    Serial.write(0x0D);
    Serial.write(0x0A);

    delay(5000);
}

void blinkLightFast()
{
    digitalWrite(led,HIGH);  
    delay(300); 
    digitalWrite(led,LOW);  
    delay(300); 
    digitalWrite(led,HIGH);  
    delay(300);
    digitalWrite(led,LOW);  
    delay(300); 
    digitalWrite(led,HIGH);  
    delay(300); 
    digitalWrite(led,LOW);  
    delay(300); 
    digitalWrite(led,HIGH);  
    delay(300);
    digitalWrite(led,LOW);  
    delay(300);    
}
  
