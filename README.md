# PoliMi ***Internet of Things*** 2022 course challenges

## Challenge 2: ThingSpeak and Node-Red

The goal of the challenge is to generate messages from a CSV files to be sent to a ThingSpeak channel through Node-Red using MQTT.

Using Node-Red, read the file iot feeds.csv and extract a subset of rows. For each selected row, send an MQTT message to a ThingSpeak channel containing the values of fields 1,2 and 5, and then plot the sequence of field5 values.
In ThingSpeak, the values of the fields received via the MQTT messages are read and plotted. 
Lamps that turn on and off when certain thresholds are reached are also used.



## Challenge 3: TinyOS, Cooja, Node-Red and ThingSpeak

The goal of the challenge is to send data corresponding to the updating status of 3 LEDs of a mote to ThingSpeak using MQTT.

Using TinyOS, create a mote with three LEDs and iteratively update the status of the LEDs according to a specific criterion. 
The mote is simulated in Cooja and the LED states are both tracked in the dashboard and written to a serial port.
Node-Red listens to the updated LED states and sends them via MQTT messages to a ThingSpeak channel where they are plotted.



## Challenge 4: TinyOS and TOSSIM

The goal of the challeng is to develop a TinyOS application to let two motes communicate and simulate it with TOSSIM.

Mote1 should periodically send requests (REQ) with a counter value.
Mote2 should send a response (RESP) with the received counter value and a value sampled from a sensor.
All messages, requests and responses, must be acknowledged to be valid.
N values must be successfully exchanged to complete the simulation.
Mote2 powers up T seconds after Mote1.

