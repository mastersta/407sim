/*-------------------------------------------------------------

INTERLOCK LIBRARY
Provides functions to allow for multi-master I2C communication
via an open-drain interlock line; One master at a time may
seize control of the I2C bus by pulling the interlock line low.
Functions are provided to check if another master has pulled
the line low (and thus is using the bus), as well as the
ability to detect if another master has hung; if so, an attempt
is made to clear the bus and seize control from the hung master
This will currently not work with more than two masters.

-------------------------------------------------------------*/

#ifndef LIB407_INTERLOCK_H
#define LIB407_INTERLOCK_H

#include <Arduino.h>

class interlock {
  public:
    interlock(byte, unsigned long);
    void engage();
    void disengage();
    bool is_locked();
    bool is_hung() { return hang; };
    void wait_for_interlock();
    void clear_hang() { hang = false; };

  //private:
    bool hang;
    byte pin;
    unsigned long wait;
};

#endif
