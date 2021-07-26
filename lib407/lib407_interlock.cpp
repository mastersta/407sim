#include "lib407_interlock.h"

//Constructor to define interlock pin and wait time
interlock::interlock(
  byte pin_input,
  unsigned long wait_input) {

  //store the passed in interlock pin in the class
  pin = pin_input;

  //store the passed interlock wait time in the class
  wait = wait_input;

  //default hang to false
  hang = false;

 //setup the interlock pin as an input for now to avoid
  //pulling the bus in any particular direction
  pinMode(pin, INPUT);
};

//Engage the interlock from our end
void interlock::engage() {

  //check if we're interlocked already
  if (!hang) {

    //if not, pull the line low to engage the interlock
    digitalWrite(pin, LOW);
    
  } else {
    
    //if it is already locked, wait for it to unlock
    wait_for_interlock();

  };
};


//Disengage our interlock by switching to an input
void interlock::disengage() {
  pinMode(pin, INPUT);
};


//Check if we're under interlock by another device
bool interlock::is_locked() {

  //disengage our interlock if we're in one, also sets as input
  disengage();

  //read the line, see if it's low, return the results
  return ~digitalRead(pin);
}


//Wait for an external interlock to release, up to [wait_time]
//If [wait_time] has passed, declare the bus as hung, lock
//the line ourselves, and don't attempt to wait again
void interlock::wait_for_interlock() {

  //tracks the start time of the interlock wait
  unsigned long timer = millis();

  //exit the empty loop when the interlock pin goes high or one
  //second has passed, or we have already had an interlock hang
  while (
    !hang                     ||
    digitalRead(pin) == LOW   ||
    (millis() - timer < wait) 
  ) {
    //do nothing while we wait for the interlock to go high
    //TODO: allow for passing in a function to perform while
    //waiting
  };

  //if we waited too long for the interlock to clear
  if (millis() - timer >= wait) {

    //remember that we got stuck on the interlock so we don't
    //try again
    hang = true;

    //pulse the clock pin a bunch to clear any data on the bus
    for (byte i = 0; i < 32; i++) {
      digitalWrite(3, LOW);
      digitalWrite(3, HIGH);
    };
  };
};
