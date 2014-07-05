/*
*  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L.
*  http://www.libelium.com
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see .
*
*  Version 0.1
*  Author: Alejandro Gállego
*/


int led = 13;
int onModulePin = 2;        // the pin to switch on the module (without press on button) 

char data[256];
int x=0;

//char server[]="simcomtest.smartfile.com";
//char port[]="21";
//char user_name[]="simcomuser";
//char password[]="1111abcd";

void switchModule(){
    digitalWrite(onModulePin,HIGH);
    delay(2000);
    digitalWrite(onModulePin,LOW);
}

void setup(){

    Serial.begin(115200);                // UART baud rate
    delay(2000);
    pinMode(led, OUTPUT);
    pinMode(onModulePin, OUTPUT);
    switchModule();                    // switches the module ON

    for (int i=0;i< 5;i++){
        delay(5000);
    } 

    Serial.println("AT+CGSOCKCONT=1,\"IP\",\"wap.cingular\"");    
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;                        
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));
}

void loop()
{

    Serial.println("AT+CFTPSERV=\"simcomtest.smartfile.com\""); //Sets the FTP server 
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    Serial.println("AT+CFTPPORT=21");    //Sets FTP port
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    Serial.println("AT+CFTPUN=\"simcomuser\""); //Sets the user name	
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    Serial.println("AT+CFTPPW=\"1111abcd\""); //Sets password     
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    Serial.println("AT+CFTPMODE=1");    //Selects pasive mode
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    //Selecciona el tipo ASCII
    Serial.println("AT+CFTPTYPE=A");    //Selects ASCII mode
    Serial.flush();
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read();  
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));
    
    Serial.println("AT+CFTPPUTFILE=\"/testfile.txt\",4");    //Uploads a test file into FTP server.
    Serial.flush(); 
    x=0;
    do{
        while(Serial.available()==0);
        data[x]=Serial.read(); 
        x++;  
    }while(!(data[x-1]=='K'&&data[x-2]=='O'));

    while(1);

}
