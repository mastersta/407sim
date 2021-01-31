#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Joystick.h>

//misc defines
#define i2c_speed 100000 //increase later after testing

//anex = ADS1015 analog input expander
#define addr_anex_cyclic 0x48
#define addr_anex_collective 0x49
#define addr_anex_panel 0x4A
#define addr_anex_overhead 0x4B

//ioex = MCP23017 digital I/O expander
#define addr_ioex_cyclic 0x20
#define addr_ioex_collective 0x21
#define addr_ioex_panel1 0x22
#define addr_ioex_panel2 0x23
#define addr_ioex_overhead1 0x24
#define addr_ioex_overhead2 0x25
#define addr_ioex_offset 0x20

//ledd = TLC59017 led driver
#define addr_ledd_overhead1 0x60
#define addr_ledd_overhead2 0x61
#define addr_ledd_overhead3 0x62
#define addr_ledd_panel1 0x63
#define addr_ledd_panel2 0x64
#define addr_ledd_panel3 0x65

Adafruit_ADS1015 anex_cyclic(addr_anex_cyclic);
Adafruit_ADS1015 anex_collective(addr_anex_collective);
Adafruit_ADS1015 anex_panel(addr_anex_panel);
Adafruit_ADS1015 anex_overhead(addr_anex_overhead);

Adafruit_MCP23017 ioex_cyclic;
Adafruit_MCP23017 ioex_collective;
Adafruit_MCP23017 ioex_panel1;
Adafruit_MCP23017 ioex_panel2;
Adafruit_MCP23017 ioex_overhead1;
Adafruit_MCP23017 ioex_overhead2;

TLC59116Manager tlcmanager(Wire, i2c_speed);

//init joystick
Joystick_ joystick(JOYSTICK_DEFAULT_REPORT_ID,JOYSTICK_TYPE_JOYSTICK,
  70, 2,              //button count, hat switch count
  true,true,false,    //X(roll), Y(pitch), Z
  true,true,true,  //Rx(dimmer), Ry(gtn1 vol), Rz(gtn2 vol)
  true,true,          //rudder(a/t), throttle(throttle)
  true,true,false  //accelerator(collective), brake(rotor brake), steering
  );

const int temp_time = 100; //time ot momentarily activate toggle switch outputs for

void setup() {
  //anex setup
  anex_cyclic.begin();
  anex_collective.begin();
  anex_panel.begin();
  anex_overhead.begin();

  //ioex setup
  ioex_cyclic.begin(addr_ioex_cyclic - addr_ioex_offset);
  ioex_collective.begin(addr_ioex_collective - addr_ioex_offset);
  ioex_panel1.begin(addr_ioex_panel1 - addr_ioex_offset);
  ioex_panel2.begin(addr_ioex_panel2 - addr_ioex_offset);
  ioex_overhead1.begin(addr_ioex_overhead1 - addr_ioex_offset);
  ioex_overhead2.begin(addr_ioex_overhead2 - addr_ioex_offset);

  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  
  //debugging
  //Serial.begin(9600);

}

//takes in an array of the four hat switch states (up, right, down, left) already inverted so 1 = engaged
//outputs the degrees that the joystick library expects for the hat position
int hat_read(int input_array) {
  int output_array[4] = {
    input_array[0],
    input_array[1] * 2,
    input_array[2] * 4,
    input_array[3] * 8
  };

  int mask = B0000;
  for (int i = 0; i < 4; i++) {
    mask = output_array[i] | mask;
  }

  switch (mask) {
    case B0000:
      return -1;
      break;
    case B0001:
      return 0;
      break;
    case B0011:
      return 45;
      break;
    case B0010:
      return 90;
      break;
    case B0110:
      return 135;
      break;
    case B0100:
      return 180;
      break;
    case B1100:
      return 225;
      break;
    case B1000:
      return 270;
      break;
    case B1001:
      return 315;
      break;
    default:
      return -1;
  }
}

void test_mode() {
  //plan is to get highest digital input pin number (based on wire numbering diagram) and output that
  //pin number, in binary, to the annunciator; lights will be lit up in order to represent that pin
  //number. Total of pins shouldn't exceed 255 so 8 lights should accurately represent it.
  //after that, use the next set of lights to represent the analog input value of the axis
  //all of this should allow the testing of all digital and analog inputs without even a connection
  //to a pc. A hardware switch, directly connected to a pin on the arduino, may be implemented to
  //engage this mode. 

  //declare analog inputs
  static int cyclic_pitch;
  static int cyclic_roll;
  static int collective;
  static int throttle;
  static int antitorque;
  static int gtn1_vol;
  static int gtn2_vol;
  static int instrument_dimmer;
  static int rotor_brake;

  //declare digital inputs
  static unsigned int cyclic_inputs;
  static unsigned int collective_inputs;
  static unsigned int panel_inputs_a;
  static unsigned int panel_inputs_b;
  static unsigned int overhead_inputs_a;
  static unsigned int overhead_inputs_b;

  //declare digital outputs
  static unsigned int annunciator_output1;
  static unsigned int annunciator_output2;

  //read all analogs
  cyclic_pitch =  anex_cyclic.readADC_SingleEnded(0);
  cyclic_roll =  anex_cyclic.readADC_SingleEnded(1);
  collective =  anex_collective.readADC_SingleEnded(0);
  throttle =  anex_collective.readADC_SingleEnded(1);
  antitorque =  anex_panel.readADC_SingleEnded(0);
  gtn1_vol = anex_panel.readADC_SingleEnded(1);
  gtn2_vol = anex_panel.readADC_SingleEnded(2);
  instrument_dimmer = anex_overhead.readADC_SingleEnded(0);
  rotor_brake =  anex_overhead.readADC_SingleEnded(1);

  //read all digitals
  cyclic_inputs = ~ioex_cyclic.readGPIOAB();
  collective_inputs = ~ioex_collective.readGPIOAB();
  panel_inputs_a = ~ioex_panel1.readGPIOAB();
  panel_inputs_b = ~ioex_panel2.readGPIOAB();
  overhead_inputs_a = ~ioex_overhead1.readGPIOAB();
  overhead_inputs_b = ~ioex_overhead2.readGPIOAB();

  
  //get highest digital input pin number
  static unsigned long all_digital_inputs_a = 0; //read LS 32 inputs
  all_digital_inputs_a = (
    (overhead_inputs_a<<24) +
    (overhead_inputs_b<<16) +
    (collective_inputs<<8) +
    (cyclic_inputs)
  );

  static unsigned int all_digital_inputs_b = 0; //read remaining 16 inputs
  all_digital_inputs_b = (
    (panel_inputs_b) +
    (panel_inputs_a) 
  );
  
  unsigned int highest_input = 0; //run through MS inputs, bit by bit, to find first high input

  for (i = 15; i >= 0; i--) {
    if bitread(all_digital_inputs_b, 15) { //if current bit is high
      highest_input = i + 32; //set as highest input, accounting for the LS set of inputs
      break; //and break out
    }
    all_digital_inputs_b << i; //else shift it and loop around to look at the next bit
  }

  if highest_input = 0 { //only do if we had no high inputs from before
    for (i = 32; i >= 0; i--) { //same thing as previous but with larger datatype
      if bitread(all_digital_inputs_a, 31) {
        highest_input = i;
        break;
      }
      all_digital_inputs_a << i;
    }
  }

  //output data to annunciator
  //set references to the drivers
  static TLC59116 &ledd_panel_1 = tlcmanager[3];
  static TLC59116 &ledd_panel_2 = tlcmanager[4];
  static TLC59116 &ledd_panel_3 = tlcmanager[5];
  
  //blink the RPM low light to indicate that we're in test mode
  ledd_panel_3.group_blink(3,1,128);

  //set first 8 lights to represent highest input in binary
  ledd_panel_1.on_pattern(highest_input<<8).off_pattern(~highest_input<<8);
  
  //set second 8 lights to reflect pwm values of analog axes
  int pwm_values_a[8] = {
    map(cyclic_pitch,-2048,2048,0,256),
    map(cyclic_roll,-2048,2048,0,256),
    map(collective,-2048,2048,0,256),
    map(throttle,-2048,2048,0,256),
    map(antitorque,-2048,2048,0,256),
    map(gtn1_vol,-2048,2048,0,256),
    map(gtn2_vol,-2048,2048,0,256),
    map(instrument_dimmer,-2048,2048,0,256)
  };
  //set following 1 light for remaining axis
  int pwm_values_b[1] = {
    map(rotor_brake,-2048,2048,0,256)
  };
  ledd_panel_1.set_outputs(8,15,pwm_values_a);
  ledd_panel_1.set_outputs(0,0,pwn_values_b);
}

void safe_mode() {
  //plan is to remove all extraneous functions except for the analog inputs, just in case something
  //goes wrong during a flight. This will allow the operator to set the helicopter down under
  //almost any circumstances and then perform any other needed functions from inside the sim.
  //To indicate that we are in safe mode, the FADEC fail light will blink and all other annunciations
  //will be extinguished.

  //initialize
  static int cyclic_pitch;
  static int cyclic_roll;
  static int collective;
  static int throttle;
  static int antitorque;

  //read
  cyclic_pitch =  anex_cyclic.readADC_SingleEnded(0);
  cyclic_roll =  anex_cyclic.readADC_SingleEnded(1);
  collective =  anex_collective.readADC_SingleEnded(0);
  throttle =  anex_collective.readADC_SingleEnded(1);
  antitorque =  anex_panel.readADC_SingleEnded(0);
  
  //output
  joystick.setYAxis(cyclic_pitch);
  joystick.setXAxis(cyclic_roll);
  joystick.setRudder(antitorque);
  joystick.setThrottle(throttle);
  joystick.setAccelerator(collective);

  //blink fadec
  static TLC59116 &ledd_panel_2 = tlcmanager[4];
  //blink the FADEC Fail and FADEC Degraded lights to indicate that we're in safe mode
  ledd_panel_2.group_blink(2,1,128);
  ledd_panel_2.group_blink(3,1,128);

}

void loop() {
  //standard operations consisting of reading all analog and digital inputs, and sending them to the
  //sim as a joystick; followed by reading the air manager message port and using that data to
  //properly light up the annunciator
}
