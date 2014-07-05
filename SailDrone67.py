import MDM
import MOD
import SER
import GPIO
import CHAT
import SER

cr = "\x0d"
ctrlZ = "\x1a"
atGuardTime = 5
networkGuardTime = 300
sendTimeout = 10
receiveTimeout = 50
testString = "begin" + "_" * 150 + "end"
smsTestTele = "2067909610"
smsTestMessage = "Test1"

def submit (cmd, responseWaitTime):
    MOD.sleep (atGuardTime);
    MDM.send (cmd, sendTimeout)
    MOD.sleep (responseWaitTime)
    print MDM.receive (receiveTimeout)
    return

def init ():
    submit ("AT+CMGF=1" + cr, 0) #set SMS format type to text
    SER.set_speed('115200','8N1') #Baud, 8-bit data, 1 stop bit

    ########################################################################
    #####3 get rid of this if not necesary
    #res = GPIO.setIOdir(9,1,1) #set this for use by the arduino aref pin
    ########################################################################
    
    return

def connect ():
    return

def sendSMS (phoneNumber, message):
    res = MDM.send('AT+CMGS=' + phoneNumber + '' + cr, 0) #provide a tele
    res = MDM.receive(10) # 1 sec
    MOD.sleep(1) # wait 0.1sec
    MDM.send(message,0) #provide a message
    MDM.sendbyte(0x1A,0) #End SMS
    res=MDM.receive(10)
    return

def main ():
    init ()
    #MOD.sleep (100)
    #Open an internal log file in the module
    #file = open('sms_send.txt', 'w')
    #file.write('Log file open\r\n')
    MOD.sleep (100)

    # Define how received messages are indicated to the terminal equipment
    res = MDM.send('at+cnmi=2,1\r',0)
    data = MDM.receive(5)
    while data.find('OK') == -1 & data.find('ERROR') == -1:
        res = MDM.receive(5)
        data = data + res
        
    # Listen to the AT interface
    while 1:
        data = MDM.receive(5)

        # CMTI indicates that a new message is received
        while data.find('CMTI') == -1:
            res = MDM.receive(5)
            data = data + res
            #SER.send(data + 'waiting for SMS')

        #SER.send(data + 'GOT an SMS')

        # A new message is received
        # Deactivate the indication of new messages to the terminal
        res = MDM.send('at+cnmi=0,1\r', 0)
        ok = MDM.receive(5)
        while ok.find('OK') == -1:
            res = MDM.receive(5)
            ok = ok + res

        #Read and perform command in SMS body, then extract the sender's phone number for replying
        test2 = readSMSCommand()       

        # Activate the indication of new messages to the terminal equipment
        res = MDM.send('at+cnmi=2,1\r',0)
        data = MDM.receive(5)
        while data.find('OK') == -1 & data.find('ERROR') == -1:
            res = MDM.receive(5)
            data = data + res 
        
    return    



# Extracts command in message body, and senders tele, and performs command
def readSMSCommand(): 

    # Get the unread messages stored in the modules memory
    res = MDM.send('at+cmgl="REC UNREAD"\r',0)
    data = MDM.receive(20)

    # The answer received is in the following form (defined with AT+CNMI command):
    # +CMGL:<mem>,<read>,<num>\r\n<text>\r\nOK,
    # where <mem> is the location (id) of the message in the memory
    # <read> REC UNREAD, <num> is the sender's phone number
    # and <text> is the message body
    
    # Read message information from the AT interface until the final 'OK' is received
    while data.find('OK') == -1:
        res = MDM.receive(5)
        data = data + res

    # Remove the 'OK' from the end
    data = data[0:(data.find('OK'))]

    # Split the data to smaller parts at every comma (returns a list containing the parts)
    data_parts = data.split(',')

    # The third index '2' contains the phone number and the message body
    #num_and_text = data_parts[2]
    num_raw = data_parts[2]
    
    # Extract the phone number
    #phoneNumber = num_and_text[num_and_text.find('"')+1:num_and_text.rfind('"')]
    phoneNumber = num_raw[num_raw.find('"')+1:num_raw.rfind('"')]
    
    # Extract the message body
    #text = num_and_text[num_and_text.rfind('"')+1:len(num_and_text)]
    text = data_parts[5]
    #file.write(text)

    cmdPerformed = 0

    # If the command starts with a 1, then the command is to be performed only on the Telit module
    # If the command starts with a 2, then the command is to be passed on to the microcontroller.
    #change test below to a "starts with" search

    cmdParts = text.split(',')
    cmdCode = cmdParts[0]
    
    if cmdCode.find('101') != -1:
        sendSMS2('12067909610', 'The module is alive and understood your command 101.')
        cmdPerformed = 1
            
    if cmdCode.find('102') != -1:
        res = CHAT.Chat('AT$GPSACP\r', 'OK\r\n', 2)
        resarr = res.split('\r\n')
        acp = resarr[1]            
        sendSMS2('12067909610', acp)           
        cmdPerformed = 1

    if cmdCode.find('103') != -1:
        res = MDM.send('AT+CMGF=1\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=30\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=29\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=28\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=27\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=26\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=25\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=24\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=23\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=22\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=21\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=20\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=19\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=18\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=17\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=16\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=15\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=14\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=13\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=12\r', 0)
        ok = MDM.receive(10)
        res = MDM.send('AT+CMGD=11\r', 0)
        ok = MDM.receive(10)
        sendSMS2('12067909610', 'The module is alive and understood your command 103 and deleted 20 messages')           
        cmdPerformed = 1

    if cmdCode.find('201') != -1:
        #this serial stuff isn't working, so revert to setting analog pins        
        #a = SER.set_speed('9600')
        #a = SER.set_speed('9600','8N1')
        #b = SER.send(text)
        #c = SER.sendbyte(0x0d)
        #d = SER.receive(15)

        #set analog pins
        #tack to starboard
        res = GPIO.setIOdir(8,1,1) #rudder to starboard
        MOD.sleep (10) #wait one second
        res = GPIO.setIOdir(8,1,0)       
        #res = GPIO.setIOdir(13,1,1) #sheet out
        #MOD.sleep (20) #wait three seconds

        #res = GPIO.setIOdir(8,1,0) #rudder to center
        #res = GPIO.setIOdir(13,1,0) #sheet in
        
        sendSMS2('12067909610', 'The module passed the command to the microcontroller, and tacked to starboard')
        cmdPerformed = 1 

    if cmdCode.find('202') != -1:
        #set analog pins
        #tack to port
        res = GPIO.setIOdir(9,1,1) #rudder to port
        MOD.sleep (10) #wait one second
        res = GPIO.setIOdir(9,1,0)
        #res = GPIO.setIOdir(13,1,1) #sheet out
        #MOD.sleep (20) #wait three seconds

        #res = GPIO.setIOdir(9,1,0) #rudder to center
        #res = GPIO.setIOdir(13,1,0) #sheet in
        
        sendSMS2('12067909610', 'The module passed the command to the microcontroller, and tacked to port')
        cmdPerformed = 1 

    if cmdCode.find('203') != -1:
        #set analog pins
        #let sheet out
        res = GPIO.setIOdir(13,1,1) #letting sheet in or out, arduino will toggle from last position
        MOD.sleep (10) #wait one second
        res = GPIO.setIOdir(13,1,0)       
        #res = GPIO.setIOdir(13,1,1) #sheet out
        #MOD.sleep (20) #wait three seconds

        #res = GPIO.setIOdir(9,1,0) #rudder to center
        #res = GPIO.setIOdir(13,1,0) #sheet in
        
        sendSMS2('12067909610', 'The module passed the command to the microcontroller, and toggled the sheet position')
        cmdPerformed = 1

    if cmdPerformed == 0:
        sendSMS2('12067909610', 'The module is alive but did NOT understand your commanddeddv.' + cmdCode)            

    test1 = 'testtt'
    return test1

# Sends a SMS
def sendSMS2(phoneNumber, message):
    # Initialize the message
    res = MDM.send('at+cmgs="'+ phoneNumber +'"\r',0)
    res = MDM.receive(5)

    # If the '>' character is received, the message body can be entered
    pos = res.find('>')

    # If the '>' character was not found, the sending failed
    if pos == -1:
        #file.write('The '>' character was not found. The sending failed.\r\n')
        return        

    # Enter the message body
    res = MDM.send(message, 0)
    ret = MDM.sendbyte(0x1A, 0) # Ctrl-z indicates the end of the message
    ok = MDM.receive(5)

    # Check if the sending succeeded or not.
    # If the message was sent, the '+CMGS:<mr>' string is received.
    # <mr> is the message's referer.
    while ok.find('CMGS:') == -1 & ok.find('ERROR') == -1:
        res = MDM.receive(5)
        ok = ok + res
    
    if ok.find('ERROR') != -1:
        #file.write('The '+CMGS:<mr>' was not received. The message was not send.\r\n')
        return

    #file.write('The message was sent.\r\n')
    return


main ()