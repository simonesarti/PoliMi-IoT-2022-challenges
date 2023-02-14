#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration Challenge3AppC{}

implementation
{
  //define the components used
  components MainC, Challenge3C, LedsC;
  components new TimerMilliC() as Timer;
  components SerialPrintfC;
  components SerialStartC;
  
  //wire the components together
  Challenge3C -> MainC.Boot;
  Challenge3C.Timer -> Timer;
  Challenge3C.Leds -> LedsC;
}

