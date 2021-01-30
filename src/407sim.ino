#include <Wire.h>
//#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>

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
  tlcmanager.broadcast().set_milliams(20, 1000);
  
  //debugging
  Serial.begin(9600);

}

void test_mode() {
  //plan is to get highest digital input pin number (based on wire numbering diagram) and output that
  //pin number, in binary, to the annunciator; lights will be lit up in order to represent that pin
  //number. Total of pins shouldn't exceed 255 so 8 lights should accurately represent it.
  //after that, use the next set of lights to represent the positive or negative value of each analog
  //input. Light on = positive.
  //all of this should allow the testing of all digital and analog inputs without even a connection
  //to a pc. A hardware switch, directly connected to a pin on the arduino, may be implemented to
  //engage this mode. 

  //declare analog inputs
  static int cylic_pitch;
  static int cylic_roll;
  static int collective;
  static int throttle;
  static int antitorque;
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
  instrument_dimmer = anex_overhead.readADC_SingleEnded(0);
  rotor_brake =  anex_overhead.readADC_SingleEnded(1);

  //read all digitals
  cyclic_inputs = ~ioex_cyclic.readGPIOAB();
  collective_inputs = ~ioex_collective.readGPIOAB();
  panel_inputs_a = ~ioex_panel1.readGPIOAB();
  panel_inputs_b = ~ioex_panel2.readGPIOAB();
  overhead_inputs_a = ~ioex_overhead1.readGPIOAB();
  overhead_inputs_b = ~ioex_overhead2.readGPIOAB();

  //output data to annunciator





}

void safe_mode() {
  //plan is to remove all extraneous functions except for the analog inputs, just in case something
  //goes wrong during a flight. This will allow the operator to set the helicopter down under
  //almost any circumstances and perform any other needed functions from inside the sim.
  //To indicate that we are in safe mode, the FADEC fail light will blink and all other annunciations
  //will be extinguished.
}

void loop() {
  //standard operations consisting of reading all analog and digital inputs, and sending them to the
  //sim as a joystick; followed by reading the air manager message port and using that data to
  //properly light up the annunciator
}
