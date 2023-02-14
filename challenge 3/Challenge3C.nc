#include "Timer.h"
#include "printf.h"

module Challenge3C @safe()
{	
  uses interface Timer<TMilli> as Timer;
  uses interface Leds;
  uses interface Boot;
}

implementation
{
	uint32_t cod_pers = 10566536;
	uint8_t remainder = -1;
	uint8_t iteration = 1;
	
	//values of the leds at each step (on/off = 1/0), initialized at 0
	uint8_t led0 = 0;
	uint8_t led1 = 0;
	uint8_t led2 = 0;

	uint32_t ms = 60000;
	
	event void Boot.booted()
  	{
		//start the timer, fires once every 60 000 ms = 1 minute
		call Timer.startPeriodic(ms);
	}	

	event void Timer.fired()
	{
		if (cod_pers != 0)	//encoding not completed yet
		{
			remainder = cod_pers % 3;
			cod_pers = cod_pers / 3;

			switch(remainder)
				{
					case 0: //toggle led 0
					{						
						call Leds.led0Toggle(); //r
						if(led0==0){led0=1;}else{led0=0;}						
						break;
					}
					case 1: //toggle led 1
					{
						call Leds.led1Toggle(); //g
						if(led1==0){led1=1;}else{led1=0;}					
						break;
					}
					case 2: //toggle led 2
					{
						call Leds.led2Toggle(); //b
						if(led2==0){led2=1;}else{led2=0;}					
						break;
					}
					default:  break;
				}

			iteration++;

			//print the leds states, this message is printed on cooja's dashboard
			printf("%u%u%u\n",led0,led1,led2);
			printfflush();	
		}
		else //stop the timer
		{
			call Timer.stop();		
		}		
	}	 
}
