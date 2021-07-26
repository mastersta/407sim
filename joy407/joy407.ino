//407sim Joystick Board main code

/*
-test, test, test!
*/

#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Joystick.h>

#include "lib407_joy.h"
#include "lib407_io.h"
#include "lib407_interlock.h"

const byte interlock_pin = 4;
const unsigned long interlock_wait = 1000;
interlock interlock(interlock_pin, interlock_wait);



/*-------------------------------------------------------------

JOYSTICK CONFIGURATION
Defines how many buttons and which axes to report to the PC/sim

-------------------------------------------------------------*/
Joystick_ joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_JOYSTICK,
  6,      //buttons
  1,      //hats
  true,   //x axis [roll]
  true,   //y axis [pitch]
  true,   //z axis [collective]
  false,  //xR
  false,  //yR
  false,  //zR
  true,   //rudder [anti-torque]
  true,   //throttle [throttle]
  false,  //accelerator
  false,  //brake
  false   //steering
);




/*-------------------------------------------------------------

IO SETUP
Declare objects needed to access the MCP and ADS boards

-------------------------------------------------------------*/
digital_expander mcp_cyclic      (addr_mcp_cyclic);
analog_expander ads_cyclic       (addr_ads_cyclic);
analog_expander ads_collective   (addr_ads_collective);
analog_expander ads_panel        (addr_ads_panel);




/*-------------------------------------------------------------

ARDUINO SETUP

-------------------------------------------------------------*/
void setup() {

  /*===Setup the debug LED===================================*/
  pinMode(17, OUTPUT);
  digitalWrite(17, LOW);


  /*===Grab the I2C bus via interlock========================*/
  interlock.engage();


  /*===Init the ADSs to read the primary flight controls=====*/
  ads_cyclic.init();            //pitch[0] and roll[1]
  ads_collective.init();        //collective[0] and throttle[1]
  ads_panel.init();             //pedals[0]


  /*===Init the cyclic MCP to read the momentary switches====*/
  mcp_cyclic.init_as_switches();    //cyclic buttons only


  /*===Release the interlock line============================*/
  interlock.disengage();


  /*===Start the joystick, set the axes ranges==============*/
  joystick.begin(false);

  joystick.setXAxisRange(     0,2048);
  joystick.setYAxisRange(     0,2048);
  joystick.setZAxisRange(     0,2048);
  joystick.setThrottleRange(  0,2048);
  joystick.setRudderRange(    0,2048);

}




/*-------------------------------------------------------------

MAIN LOOP
Reads the appropriate analog and digital input boards and
applies their values to the joystick. Waits for the messageport
board to release the interlock line before using the I2C bus

-------------------------------------------------------------*/
void loop() {

  /*===Interlock Handling=====================================*/
  interlock.wait_for_interlock();
  interlock.engage();


  /*===Read, store, and apply the analog board values========*/
  joystick.setXAxis(      ads_cyclic.read_and_return(0));      //pitch
  joystick.setYAxis(      ads_cyclic.read_and_return(1));      //roll
  joystick.setZAxis(      ads_collective.read_and_return(0));  //collective
  joystick.setThrottle(   ads_collective.read_and_return(1));  //throttle
  joystick.setRudder(     ads_panel.read_and_return(0));       //A/T pedals


  /*===read and store the digital board values===============*/
  mcp_cyclic.read_and_store();


  /*===disengage the interlock===============================*/
  interlock.disengage();


  /*===apply the cyclic momentary buttons to the joystick====*/
  for (byte i = 0; i < 5; i++) {
    joystick.setButton(i, !bitRead(mcp_cyclic.values, i));
  };
  joystick.setButton(5, !bitRead(mcp_cyclic.values, 9));


  /*===apply the cyclic hat inputs to the joystick hat=======*/
  int cyclic_hat_array[4] {};
  for (byte i = 0; i < 4; i++) {
    cyclic_hat_array[i] = !bitRead(mcp_cyclic.values, (i + 5));
  };
  joystick.setHatSwitch(0, hat_direction(cyclic_hat_array));


  /*===send the joystick data to the sim=====================*/
  joystick.sendState();


  /*===debug to let us know the main loop is still running===*/
  digitalWrite(17, millis()%1000>500);

}
