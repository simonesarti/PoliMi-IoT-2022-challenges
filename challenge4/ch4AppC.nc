#include "ch4.h"

configuration ch4AppC {}

implementation {

  /****** COMPONENTS *****/
  components MainC, ch4C as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC();
  components ActiveMessageC;
  components new FakeSensorC();
  
  /****** INTERFACES *****/
  App.Boot -> MainC.Boot;
  
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC.Acks;
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  //Timer interface
  App.MilliTimer -> TimerMilliC;
  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  //Fake Sensor read
  App.Read -> FakeSensorC;


}

