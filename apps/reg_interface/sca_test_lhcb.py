from rw_reg import *
from vfat_config import *
from time import *

SLEEP_BETWEEN_COMMANDS=0.1
DEBUG=True

class Colors:            
    WHITE   = '\033[97m' 
    CYAN    = '\033[96m' 
    MAGENTA = '\033[95m' 
    BLUE    = '\033[94m' 
    YELLOW  = '\033[93m' 
    GREEN   = '\033[92m' 
    RED     = '\033[91m' 
    ENDC    = '\033[0m'  

def main():

    instructions=""

    if len(sys.argv) < 2:
        print('Usage: sca_test.py <instructions>')
        print('instructions: if contains i, then SCA initialization will be done, if contains h then hard reset will be asserted, if contains d then hard reset will be de-asserted.')
        return
    else:
        instructions = sys.argv[1]

    parseXML()

    heading("Hola, I'm SCA tester :)")

    #clear the reply fifo
    while not isReplyFifoEmpty():
        parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.REPLY')))

    state = readControlReg()
    if state == 0x44:
        printRed("WARNING: ECS state is 0x44 which means that there is an unread reply availbale (I think).. Not sure if this is critical though, but you might want to reset the ECS and SCA..")

    if (state != 0x40) and (state != 0x44):
        printRed("SCA is not in a good state, try to reset it or just wait a bit if it has been recently reset" + "(state=" + hex(state) + ")")
        exit()

    subheading("OK, SCA communication seems good: state = " + hex(state))

    if "i" in instructions:
        # enable GPIO                                  
        subheading("Sending SCA command to enable GPIO and SPI")
        sendScaCommand(0x0, 0x02, 1, 0xfe, 0x0, 0x0, 0x0)                            
        #sendScaCommand(0x0, 0x04, 1, 0xff, 0x0, 0x0, 0x0)                            

        # set GPIO direction to all outputs
        subheading("Sending SCA command to set the direction of GPIO to be all outputs")
        sendScaCommand(0x2, 0x20, 4, 0xffffffff, 0x0, 0x0, 0x0) 

    # read GPIO direction
    #subheading("Sending SCA command to read the GPIO direction")
    #sendScaCommand(0x2, 0x21, 0, 0x0, 0x0, 0x0, 0x0) 

    if "d" in instructions:
        # set all GPIO outputs high                                                                                                                     
        subheading("Sending SCA command to set all GPIO outputs high")
        #sendScaCommand(0x2, 0x10, 4, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff)                                    
        #sendScaCommand(0x2, 0x10, 1, 0x00000080, 0x00000001, 0x00000001, 0x00000001)                                    
        sendScaCommand(0x2, 0x11, 0, 0x00000080, 0x00000001, 0x00000001, 0x00000001)                                    

    if "h" in instructions:
        # set all GPIO outputs low                                                     
        subheading("Sending SCA command to set all GPIO outputs low")                  
        #sendScaCommand(0x2, 0x10, 4, 0x0, 0x0, 0x0, 0x0)    
        #sendScaCommand(0x2, 0x10, 4, 0x00000000, 0x00000000, 0x00000000, 0x00000000)    
        sendScaCommand(0x2, 0x10, 4, 0x6CBAE98F, 0x6CBAE98F, 0x6CBAE98F, 0x6CBAE98F)    
    
# for now it only supports one word commands
def sendScaCommand(sca_channel, sca_command, data_length, data0, data1, data2, data3):
    #write header0
    header0 = (sca_channel << 8) + (sca_command)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), header0)
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x08)
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()
    if DEBUG:
        print "header0: writing " + hex(header0) + " to address 0x08. Reply = " + hex(reply)
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #write header1
    header1 = (data_length << 16)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), header1)
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x0c)                                                                                 
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()
    if DEBUG:                                                                                                                                  
        print "header1: writing " + hex(header1) + " to address 0x0c. Reply = " + hex(reply)
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #write data0
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), data0)                                                                             
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x10)                                                                                
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                                                                    
    if DEBUG:                                                                                                                                  
        print "data0: writing " + hex(data0) + " to address 0x10. Reply = " + hex(reply)                                                                 
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #write data1                                                                                                                                                                                 
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), data1)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x14)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    reply = readLastReply()                                                                                                                                                                      
    if DEBUG:                                                                                                                                                                                    
        print "data1: writing " + hex(data1) + " to address 0x14. Reply = " + hex(reply)                                                                                                          
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #write data2                                                                                                                                                                                 
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), data2)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x18)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    reply = readLastReply()                                                                                                                                                                      
    if DEBUG:                                                                                                                                                                                    
        print "data2: writing " + hex(data2) + " to address 0x18. Reply = " + hex(reply)                                                                                                          
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #write data3                                                                                                                                                                                 
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), data3)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x1c)                                                                                                                                  
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                                                                
    reply = readLastReply()                                                                                                                                                                      
    if DEBUG:                                                                                                                                                                                    
        print "data3: writing " + hex(data3) + " to address 0x1c. Reply = " + hex(reply)                                                                                                          
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    
    #execute the command                                                                                                                               
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), 0x1)                                                                                
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x0)                                                                                
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                                                                    
    if DEBUG:                                                                               
        print "requesting execution of the command: writing 0x1 to address 0x0. Reply = " + hex(reply)
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    

    #setting reply address
    replyAddress = header0 #sca_channel
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), replyAddress)                                                                                 
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x4)                                                                                 
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                                                                    
    if DEBUG:                                                                                                                                  
        print "setting reply address: writing " + hex(replyAddress) + " to address 0x4. Reply = " + hex(reply)                                         
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)


    if DEBUG:
        print "Waiting for SCA reply"

    #wait for SCA reply (bit 2 should be set in the control reg once reply is available)
    controlReg = readControlReg()
    sleep(SLEEP_BETWEEN_COMMANDS)
    if check_bit(controlReg,2):
        if DEBUG:
            print "Reply is ready. Control reg = " + hex(controlReg)

    iteration = 0
    while not check_bit(controlReg, 2):
        if iteration > 1000:
            printRed("Timeout while waiting for SCA reply!")
            exit()
        controlReg = readControlReg()
        sleep(SLEEP_BETWEEN_COMMANDS)
       
        if DEBUG:
            print "waiting for control reg bit 2 to be set... control reg value = " + hex(controlReg)
        iteration = iteration + 1
        sleep(0.01)

    #request the update of reply registers
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.COMMAND'), 0x2)                                                                        
    sleep(SLEEP_BETWEEN_COMMANDS)
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x0)                                                                                 
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                                                                    
    if DEBUG:                                                                                                                                  
        print "Requesting to update ECS reply registers: writing 0x2 to address 0x0. Reply = " + hex(reply)                                  
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
 
    #read reply header0
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x20)                                        
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                           
    if DEBUG:                                                                                         
        print "Reading reply header0 (should be equal to command header0). Reply = " + hex(reply) 
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)
    if reply != header0:
        printRed("Error: reply header0 != command header0.. command header0 = " + hex(header0) + ", reply header0 = " + hex(reply))
        exit()

    #read reply header1                                                                                      
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x24)                                       
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                           
    replyLength = (reply & 0x00ff0000) >> 16
    if DEBUG:                                                                                              
        print "Reading reply header1 and checking the reply data length and error bits. Reply = " + hex(reply) + ". Reply data length = " + str(replyLength)

    if check_bit(reply, 24):
        printRed('Reply error bit 0 is set: SOL40_SCA "problem during the execution of the ECS packet"')
        #exit()
    
    if check_bit(reply, 25):                                                                                                                                
        printRed('Reply error bit 1 is set: Invalid channel request"')                                                    
        exit()                                                                                                                                              
    
    if check_bit(reply, 26):                                                                                                                                
        printRed('Reply error bit 2 is set: Invalid command request"')                                                                                      
        exit()                                                                                                                                              

    if check_bit(reply, 27):                                                                                                                                
        printRed('Reply error bit 3 is set: Invalid transaction number request"')                                                                                      
        exit()                                                                                                                                              
 
    if check_bit(reply, 28):                                                                                                                                
        printRed('Reply error bit 4 is set: Invalid request length"')                             
        exit()                                                                                                

    if check_bit(reply, 29):                                                                                                                                
        printRed('Reply error bit 5 is set: Channel disabled"')                                                                                       
        exit()                                                                                                

    if check_bit(reply, 30):                                                                                                                                
        printRed('Reply error bit 6 is set: Channel busy"')                                               
        exit()                                                                                                

    if check_bit(reply, 31):                                                                                                                                
        printRed('Reply error bit 7 is set: Command in treatment"')                                                   
        exit()                                                                                                

    #read reply data0                                                                                                                       
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x28)                                                                                
    sleep(SLEEP_BETWEEN_COMMANDS)
    reply = readLastReply()                                                                                                                    
    if DEBUG:                                                                                                                                  
        print "Reading reply data0. Reply = " + hex(reply)
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())
        #sleep(SLEEP_BETWEEN_COMMANDS)

    #read reply data1                                          
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x2c)
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                           
    reply = readLastReply()                                   
    if DEBUG:                                                  
        print "Reading reply data1. Reply = " + hex(reply)                                              
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())              
        #sleep(SLEEP_BETWEEN_COMMANDS)

    #read reply data2                                          
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x30)
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                           
    reply = readLastReply()                                   
    if DEBUG:                                                  
        print "Reading reply data2. Reply = " + hex(reply)                                              
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())              
        #sleep(SLEEP_BETWEEN_COMMANDS)

    #read reply data3                                          
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x34)
    sleep(SLEEP_BETWEEN_COMMANDS)                                                                                                                           
    reply = readLastReply()                                   
    if DEBUG:                                                  
        print "Reading reply data3. Reply = " + hex(reply)                                              
        sleep(SLEEP_BETWEEN_COMMANDS)
        #print "control reg = " + hex(readControlReg())              
        #sleep(SLEEP_BETWEEN_COMMANDS)

    return reply

def readControlReg():
    writeReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.ADDRESS'), 0x0)
    sleep(SLEEP_BETWEEN_COMMANDS)
    return readLastReply()

def readReply():
    iteration = 0
    while isReplyFifoEmpty():
        if iteration > 200:
            printRed("Timeout while waiting for ECS reply!")
            exit()
        iteration = iteration + 1
        sleep(0.01)
    value = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.REPLY')))
    sleep(SLEEP_BETWEEN_COMMANDS)
    return value

def readLastReply():                                                                                                                               
    value = readReply()
    while not isReplyFifoEmpty():
        value = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.REPLY')))
        sleep(SLEEP_BETWEEN_COMMANDS)
    return value
 
def isReplyFifoEmpty():
    isEmpty = parseInt(readReg(getNode('GEM_AMC.SLOW_CONTROL.SCA.FIFO_STATUS.REPLY_EMPTY')))
    return isEmpty == 1

def check_bit(byteval,idx):
    return ((byteval&(1<<idx))!=0);

def heading(string):                                                                    
    print Colors.BLUE                                                             
    print '\n>>>>>>> '+str(string).upper()+' <<<<<<<'
    print Colors.ENDC                   
                                                      
def subheading(string):                         
    print Colors.YELLOW                                        
    print '---- '+str(string)+' ----',Colors.ENDC                    
                                                                     
def printCyan(string):                                                
    print Colors.CYAN                                    
    print string, Colors.ENDC                                                                     
                                                                      
def printRed(string):                                                                                                                       
    print Colors.RED                                                                                                                                                            
    print string, Colors.ENDC                                           

def hex(number):
    if number is None:
        return 'None'
    else:
        return "{0:#0x}".format(number)

if __name__ == '__main__':
    main()
