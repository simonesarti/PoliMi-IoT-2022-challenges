#include "ch4.h"
#include "Timer.h"

#define REQ 1
#define RESP 2

module ch4C {

  uses {
    /****** INTERFACES *****/
	interface Boot; 
    interface Timer<TMilli> as MilliTimer;
	    
    interface Receive;
    interface AMSend;
    interface SplitControl;// as AMControl;
    interface Packet;
	interface PacketAcknowledgements;
	 
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t> as Read;
  }
} 

implementation {

  message_t packet;
  uint8_t counter = 0;
  uint8_t x = 7;
  bool locked;
  uint8_t dest = 1;
  uint8_t n_received_acks=0;

  void sendReq();
  void sendResp();
  void sendPacket(uint8_t msg_type, uint16_t value);


  void sendPacket(uint8_t msg_type, uint16_t value){
	  /* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

	//1. Prepare the msg
	my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	if (rcm == NULL) {
		dbgerror("message", "failed to create the message\n");
		return;
	}

	rcm->counter = counter;
	rcm->value = value;
	rcm->msg_type = msg_type;
	dbg("message", "inserting COUNTER:%u VALUE:%u, MSG_TYPE:%u into the message to be sent\n",rcm->counter,rcm->value,rcm->msg_type);
	
	//2. Set the ACK flag for the message using the PacketAcknowledgements interface
	call PacketAcknowledgements.requestAck(&packet);
	dbg("message", "Setting ack flag for the message\n");		
	
	//3. Send an UNICAST message to the correct node
	if (TOS_NODE_ID == 1) dest = 2;
	else dest = 1;
	dbg("message", "message will be sent from mote%u to mote %u\n", TOS_NODE_ID,dest);		

	if (call AMSend.send(dest, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet from %u to %u", TOS_NODE_ID, dest);	
		locked = TRUE;
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
		dbg("radio", "radio on mote%u has been locked\n",TOS_NODE_ID);
	}

  }
  
  //***************** Send request function ********************//
  void sendReq() {
	sendPacket(REQ,0);
  }
      
  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
	//dbg("sensor", "Calling sensor read\n");	
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted on node %u.\n",TOS_NODE_ID);
	call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
  	if (err == SUCCESS) {
      dbg("radio","Radio ON on node %u!\n", TOS_NODE_ID);
      if ( TOS_NODE_ID == 1 ) {
		  dbg("timer","Started timer on mote1\n");
	      call MilliTimer.startPeriodic(1000); 
      }
    }
    else {
      dbgerror("radio", "Radio failed to start on node %u, retrying...\n",TOS_NODE_ID);
      call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    dbg("radio", "Radio on mote %u stopped!\n", TOS_NODE_ID);
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
    /* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
	
    counter++;
    dbg("timer", "\n\nTimer fired, counter is %hu.\n", counter);
    
    if (locked) {
      dbg("radio_send", "Radio on mote1 is locked, when timer fired, do nothing\n");
      return;
    }
    else {
		dbg("radio_send", "Radio on mote1 not locked, sending the request\n");
		sendReq();
   }  
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf, error_t err) {
	/* This event is triggered when a message is sent */
	
	// 1. Check if the packet is sent
	if (err != SUCCESS){
	    dbgerror("radio_send", "Packet sending from mote%u failed to be sent\n", TOS_NODE_ID);	
	}
	else {
		dbg("radio_send", "Packet sending from mote%u sent correctly\n", TOS_NODE_ID);
		
		locked = FALSE;
		dbg("radio", "radio on mote%u has been unlocked\n",TOS_NODE_ID);
		
		{
		//parse the message
		my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(buf, sizeof(my_msg_t));
		if (rcm == NULL){
			dbgerror("message", "failed to parse the sent message in sendDone\n");
			return;
		}
		// 2. Check if the ACK is received (read the docs)	
		// 2a. If yes, stop the timer when the program is done
		// 2b. Otherwise, send again the request
		if (!call PacketAcknowledgements.wasAcked(buf)){
			if(TOS_NODE_ID==2){
				dbg("radio_ack", "ack not received by mote%u, trying to send packet again\n",TOS_NODE_ID);
				sendPacket(rcm->msg_type,rcm->value);
			}
			else{
				dbg("radio_ack", "ack not received by mote%u, waiting for next timer cycle to resend\n",TOS_NODE_ID);
				//do nothing, wait for next timer
			}
			
		
		}else{
			dbg("radio_ack", "ack received by mote%u\n",TOS_NODE_ID);			
			if(TOS_NODE_ID==1){
				n_received_acks++;
				dbg("radio_ack", "number of REQ_ACK received is %u\n",n_received_acks);	
				if(n_received_acks==x){
					call MilliTimer.stop();
		  			dbg("timer","stopping timer\n");
				}	
			}
		}
		}
		
	}
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf, void* payload, uint8_t len) {
	/* This event is triggered when a message is received */
	 // 1. Read the content of the message
	 if (len != sizeof(my_msg_t)) {
	 	dbgerror("message", "failed to read the content of the received message\n");
	 	return buf;
 	 }
     else {
		  my_msg_t* rcm = (my_msg_t*)payload;
      
		  dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
		  dbg("radio_pack",">>>Pack \n \t Payload length %u \n", call Packet.payloadLength(buf));
		  
		  dbg_clear("radio_pack","\t\t Payload \n" );
		  dbg_clear("radio_pack", "\t\t counter: %u \n", rcm->counter);
		  dbg_clear("radio_pack", "\t\t value: %u \n", rcm->value);
		  dbg_clear("radio_pack", "\t\t msg_type: %u \n", rcm->msg_type);
		  
		  
	   	  // 2. Check if the type is request (REQ)
 		  if (rcm->msg_type == REQ){
		  	 	// 3. If a request is received, send the response
				counter=rcm->counter;
				sendResp();
		  }	
      }
	 		  
	return buf;
	 // X. Use debug statements showing what's happening (i.e. message fields)
  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) */
	sendPacket(RESP,data);
  }
}

