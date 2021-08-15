//407sim Joystick Board main code

#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Joystick.h>

#include "lib407_joy.h"
#include "lib407_io.h"


/*-------------------------------------------------------------

JOYSTICK CONFIGURATION
Defines how many buttons and which axes to report to the PC/sim

-------------------------------------------------------------*/
Joystick_ joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_JOYSTICK,
  15,      //buttons
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
digital_expander mcp_collective  (addr_mcp_collective);
analog_expander ads_cyclic       (addr_ads_cyclic);
analog_expander ads_collective   (addr_ads_collective);




/*-------------------------------------------------------------

ARDUINO SETUP

-------------------------------------------------------------*/
void setup() {

  /*===Setup the debug LED===================================*/
  pinMode(17, OUTPUT);
  digitalWrite(17, LOW);


  /*===Init the ADSs to read the primary flight controls=====*/
  ads_cyclic.init();            //pitch[0] roll[1] and yaw[2]
  ads_collective.init();        //collective[0] and throttle[1]


  /*===Init the cyclic MCP to read the momentary switches====*/
  mcp_cyclic.init_as_switches();
  mcp_collective.init_as_switches();


  /*===Start the joystick, set the axes ranges==============*/
  joystick.begin(false);

  joystick.setXAxisRange(     0,2048);
  joystick.setYAxisRange(     0,2048);
  joystick.setRudderRange(    0,2048);
  joystick.setZAxisRange(     0,2048);
  joystick.setThrottleRange(  0,2048);

}




/*-------------------------------------------------------------

MAIN LOOP
Reads the appropriate analog and digital input boards and
applies their values to the joystick. Waits for the messageport
board to release the interlock line before using the I2C bus

-------------------------------------------------------------*/
void loop() {

  /*===Read, store, and apply the analog board values========*/
  joystick.setXAxis(      ads_cyclic.read_and_return(0));      //pitch
  joystick.setYAxis(      ads_cyclic.read_and_return(1));      //roll
  joystick.setRudder(     ads_cyclic.read_and_return(2));       //A/T pedals
  joystick.setZAxis(      ads_collective.read_and_return(0));  //collective
  joystick.setThrottle(   ads_collective.read_and_return(1));  //throttle


  /*===read and store the digital board values===============*/
  mcp_cyclic.read_and_store();
  mcp_collective.read_and_store();


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


  //store the lowest throttle value for the idle stop detection,
  //throttle is reversed so max is used
  static int lowest_throttle = 0;
  lowest_throttle = max(
    lowest_throttle,
    ads_collective.values[1]
  );

  //if the throttle is in detent
  if (ads_collective.values[1] > (lowest_throttle * 0.9)) {
    ads_collective.values[1] = lowest_throttle;

    //apply the idle stop
    joystick.setButton(6, 1);
      
  } else {
    joystick.setButton(6, 0);
  }


  for (byte i = 7; i < 13; i++) {
    joystick.setButton(i, !bitRead(mcp_collective.values, i - 7));
  };
  
  bool ll_fwd = (
    bitRead(mcp_collective.values, 2) &&
    bitRead(mcp_collective.values, 3)
  );
  joystick.setButton(13, ll_fwd);
  joystick.setButton(14, bitRead(mcp_collective.values, 5)); //float arm off


  /*===send the joystick data to the sim=====================*/
  joystick.sendState();

}
