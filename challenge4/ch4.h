#ifndef SENDACK_H
#define SENDACK_H

#define REQ 1
#define RESP 2

//payload of the msg
typedef nx_struct my_msg 
{
	nx_uint8_t msg_type;
	nx_uint8_t counter;
	nx_uint16_t value;
	
} my_msg_t;
 

enum
{
	AM_MY_MSG = 6,
};

#endif
