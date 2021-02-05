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
#define addr_ioex_cyclic 0     //0x20
#define addr_ioex_collective 1 //0x21
#define addr_ioex_panel1 2     //0x22
#define addr_ioex_panel2 3     //0x23
#define addr_ioex_panel3 4     //0x24
#define addr_ioex_overhead1 5  //0x25
#define addr_ioex_overhead2 6  //0x26
#define addr_ioex_overhead3 7  //0x27

//ledd = TLC59017 led driver
#define addr_ledd_overhead1 0x60
#define addr_ledd_overhead2 0x61
#define addr_ledd_overhead3 0x62
#define addr_ledd_panel1 0x63
#define addr_ledd_panel2 0x64
#define addr_ledd_panel3 0x65




struct anex {
  Adafruit_ADS1015 cyclic(addr_anex_cyclic);
  Adafruit_ADS1015 collective(addr_anex_collective);
  Adafruit_ADS1015 panel(addr_anex_panel);
  Adafruit_ADS1015 overhead(addr_anex_overhead);
};

struct anex anexmanager;




struct ioex {
  Adafruit_MCP23017 cyclic;
  Adafruit_MCP23017 collective;
  Adafruit_MCP23017 panel1;
  Adafruit_MCP23017 panel2;
  Adafruit_MCP23017 panel3;
  Adafruit_MCP23017 overhead1;
  Adafruit_MCP23017 overhead2;
  Adafruit_MCP23017 overhead3;
};

struct ioex ioexmanager;




TLC59116Manager tlcmanager(Wire, i2c_speed);

struct ledd {
  TLC59116 &panel1 = tlcmanager[3];
  TLC59116 &panel2 = tlcmanager[4];
  TLC59116 &panel3 = tlcmanager[5];
};

struct ledd leddmanager;


//init joystick
Joystick_ joystick(JOYSTICK_DEFAULT_REPORT_ID,JOYSTICK_TYPE_JOYSTICK,
  70, 2,              //button count, hat switch count
  true,true,false,    //X(roll), Y(pitch), Z
  true,true,true,  //Rx(dimmer), Ry(gtn1 vol), Rz(gtn2 vol)
  true,true,          //rudder(a/t), throttle(throttle)
  true,true,false  //accelerator(collective), brake(rotor brake), steering
  );



struct struct_anex_values {  //stores analog input values
  int cyclic[4];
  int collective[4];
  int panel[4];
  int overhead[4];
};

struct anex_input_values struct_anex_values { //init to zero
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0}
};




//type of input for every pin on each ioex
//0 for unused/NYI, 1 for momentary, 2 for toggle, 3 for encoder phase A, 4 for encoder phase B.
//Hats are handled elsewhere, so they get a 0
struct struct_ioex_type { //struct to ease passing through functions
  byte cyclic[16];
  byte collective[16];
  byte panel1[16];
  byte panel2[16];
  byte panel3[16];
  byte overhead1[16];
  byte overhead2[16];
  byte overhead3[16];
};

const struct ioex_input_types struct_ioex_type {
  {1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0}, //cyclic
  {1,1,2,2,1,0,0,0,0,1,0,0,0,0,0,0}, //collective
  {2,1,1,1,1,1,1,1,3,4,3,4,3,4,1,1}, //panel1
  {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0}, //panel2
  {1,1,1,3,4,3,4,1,1,1,1,3,4,3,4,1}, //panel3
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}, //overhead1
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}, //overhead2
  {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}  //overhead3
};




struct struct_ioex_values { //struct to ease passing through functions, used to store read values
  unsigned int cyclic;
  unsigned int collective;
  unsigned int panel1;
  unsigned int panel2;
  unsigned int panel3;
  unsigned int overhead1;
  unsigned int overhead2;
  unsigned int overhead3;
};

struct ioex_input_values struct_ioex_values {0,0,0,0,0,0,0,0}; //init at 0



void setup() {

  //anex setup
  anexmanager.cyclic.begin();
  anexmanager.collective.begin();
  anexmanager.panel.begin();
  anexmanager.overhead.begin();

  //ioex setup
  ioexmanager.cyclic.begin(addr_ioex_cyclic - addr_ioex_offset);
  ioexmanager.collective.begin(addr_ioex_collective - addr_ioex_offset);
  ioexmanager.panel1.begin(addr_ioex_panel1 - addr_ioex_offset);
  ioexmanager.panel2.begin(addr_ioex_panel2 - addr_ioex_offset);
  ioexmanager.overhead1.begin(addr_ioex_overhead1 - addr_ioex_offset);
  ioexmanager.overhead2.begin(addr_ioex_overhead2 - addr_ioex_offset);

  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  
}




int hat_direction(int input_array) {
//takes in an array of the four hat switch states (up, right, down, left) already inverted so 1 = engaged
//outputs the degrees that the joystick library expects for the hat position

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




bool read_all_analogs() {  //sets global anex_input_values struct
  anex_input_values.cyclic[0] =       anexmanager.cyclic.readADC_SingleEnded(0);     //pitch
  anex_input_values.cyclic[1] =       anexmanager.cyclic.readADC_SingleEnded(1);     //roll
  anex_input_values.collective[0] =   anexmanager.collective.readADC_SingleEnded(0); //collective
  anex_input_values.collective[1] =   anexmanager.collective.readADC_SingleEnded(1); //throttle
  anex_input_values.panel[0] =        anexmanager.panel.readADC_SingleEnded(0);      //antitorque
  anex_input_values.panel[1] =        anexmanager.panel.readADC_SingleEnded(1);      //gtn1 vol
  anex_input_values.panel[2] =        anexmanager.panel.readADC_SingleEnded(2);      //gtn2 vol
  anex_input_values.overhead[0] =     anexmanager.overhead.readADC_SingleEnded(0);   //instrument dimmer
  anex_input_values.overhead[1] =     anexmanager.overhead.readADC_SingleEnded(1);   //rotor brake
  return true;  //if something goes wrong, might return false and we can use that to go to safe mode
};




bool read_all_digitals() {  //invert due to pullups
  ioex_input_values.cyclic =     ~ioexmanager.cyclic.readGPIOAB();
  ioex_input_values.collective = ~ioexmanager.collective.readGPIOAB();
  ioex_input_values.panel1 =     ~ioexmanager.panel1.readGPIOAB();
  ioex_input_values.panel2 =     ~ioexmanager.panel2.readGPIOAB();
  ioex_input_values.panel3 =     ~ioexmanager.panel3.readGPIOAB();
  ioex_input_values.overhead1 =  ~ioexmanager.overhead1_inputs.readGPIOAB();
  ioex_input_values.overhead2 =  ~ioexmanager.overhead2_inputs.readGPIOAB();
  ioex_input_values.overhead3 =  ~ioexmanager.overhead3_inputs.readGPIOAB();
  return true;  //if something goes wrong, might return false and we can use that to go to safe mode
};




void test_mode() {
  //plan is to get highest digital input pin number (based on wire numbering diagram) and output that
  //pin number, in binary, to the annunciator; lights will be lit up in order to represent that pin
  //number. Total of pins shouldn't exceed 255 so 8 lights should accurately represent it.
  //after that, use the next set of lights to represent the analog input value of the axis
  //all of this should allow the testing of all digital and analog inputs without even a connection
  //to a pc. A hardware switch, directly connected to a pin on the arduino, may be implemented to
  //engage this mode. 


  if read_all_analogs() {}; //ignore return, we don't care if something goes wrong
  if read_all_digitals() {};


  //get highest digital input pin number
  static unsigned long all_digital_inputs_a = 0; //read LS 32 inputs
  all_digital_inputs_a = (
    (ioex_input_values.panel2<<24) +
    (ioex_input_values.panel1<<16) +
    (ioex_input_values.collective<<8) +
    (ioex_input_values.cyclic)
  );

  static unsigned long all_digital_inputs_b = 0; //read MS 32 inputs
  all_digital_inputs_b = (
    (ioex_input_values.overhead3<<24)
    (ioex_input_values.overhead2<<16) +
    (ioex_input_values.overhead1<<8) +
    (ioex_input_values.panel3) +
  );
  
  unsigned int highest_input = 0; //run through MS inputs, bit by bit, to find first high input

  for (i = 32; i >= 0; i--) {
    if bitread(all_digital_inputs_b, 31) { //if current bit is high
      highest_input = i + 32; //set as highest input, accounting for the LS set of inputs
      break; //and break out
    }
    all_digital_inputs_b << i; //else shift it and loop around to look at the next bit
  }

  if highest_input = 0 { //only do if we had no high inputs from before
    for (i = 32; i >= 0; i--) { //same thing as previous
      if bitread(all_digital_inputs_a, 31) {
        highest_input = i;
        break;
      }
      all_digital_inputs_a << i;
    }
  }




  //output data to annunciator

  
  //blink the RPM low light to indicate that we're in test mode
  leddmanager.panel3.group_blink(3,1,128);

  //set first 8 lights to represent highest input in binary
  leddmanager.panel1.on_pattern(highest_input<<8).off_pattern(~highest_input<<8);
  
  //set second 8 lights to reflect pwm values of analog axes
  int pwm_values_a[8] = {
    map(anex_input_values.cyclic[0],      -2048,2048,0,256), //pitch
    map(anex_input_values.cyclic[1],      -2048,2048,0,256), //roll
    map(anex_input_values.collective[0],  -2048,2048,0,256), //collective
    map(anex_input_values.collective[1],  -2048,2048,0,256), //throttle
    map(anex_input_values.panel[0],       -2048,2048,0,256), //antitorque
    map(anex_input_values.panel[1],       -2048,2048,0,256), //gtn1 vol
    map(anex_input_values.panel[2],       -2048,2048,0,256), //gtn2 vol
    map(anex_input_values.overhead[0]     -2048,2048,0,256), //instrument dimmer
  };

  //set following 1 light for remaining axis
  int pwm_values_b[1] = {
    map(anex_input_values.overhead[1],    -2048,2048,0,256)  //rotor brake
  };

  //set following lights for analog inputs
  leddmanager.panel1.set_outputs(8,15,pwm_values_a);
  leddmanager.panel1.set_outputs(0,0,pwn_values_b);


}




bool go_to_safe_mode = false;
void safe_mode() {
  //plan is to remove all extraneous functions except for the analog inputs, just in case something
  //goes wrong during a flight. This will allow the operator to set the helicopter down under
  //almost any circumstances and then perform any other needed functions from inside the sim.
  //To indicate that we are in safe mode, the FADEC fail light will blink and all other annunciations
  //will be extinguished.


  //read
  anex_input_values.cyclic[0] =       anexmanager.cyclic.readADC_SingleEnded(0);     //pitch
  anex_input_values.cyclic[1] =       anexmanager.cyclic.readADC_SingleEnded(1);     //roll
  anex_input_values.collective[0] =   anexmanager.collective.readADC_SingleEnded(0); //collective
  anex_input_values.collective[1] =   anexmanager.collective.readADC_SingleEnded(1); //throttle
  anex_input_values.panel[0] =        anexmanager.panel.readADC_SingleEnded(0);      //antitorque
  
  //output
  joystick.setYAxis                   (anex_input_values.cyclic[0]);
  joystick.setXAxis                   (anex_input_values.cyclic[1]);
  joystick.setRudder                  (anex_input_values.collective[0]);
  joystick.setThrottle                (anex_input_values.collective[1]);
  joystick.setAccelerator             (anex_input_values.panel[0]);

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

  if read_all_analogs() {

    joystick.setYAxis                   (anex_input_values.cyclic[0]);
    joystick.setXAxis                   (anex_input_values.cyclic[1]);
    joystick.setRudder                  (anex_input_values.collective[0]);
    joystick.setThrottle                (anex_input_values.collective[1]);
    joystick.setAccelerator             (anex_input_values.panel[0]);

  } else {go_to_safe_mode = true;};



  if read_all_digitals() {


    //hat switches
    static int cyclic_hat_array[4] {
      bitRead(ioex_input_values.cyclic, 5), //up
      bitRead(ioex_input_values.cyclic, 6), //right
      bitRead(ioex_input_values.cyclic, 8), //down
      bitRead(ioex_input_values.cyclic, 7) //left
    }
    joystick.setHatSwitch(0, hat_direction(cyclic_hat_array));


    static int collective_hat_array[4] {
      bitRead(ioex_input_values.collective, 5), //up
      bitRead(ioex_input_values.collective, 6), //right
      bitRead(ioex_input_values.collective, 8), //down
      bitRead(ioex_input_values.collective, 7), //left
    }
    joystick.setHatSwitch(1, hat_direction(collective_hat_array));



    //joystick button number iterator
    //run through all inputs, checking against input type

      //if momentary
        //set next joystick button to state of input 
        //increment joystick button

      //if toggle
        //toggle method:
        //state for each toggle
        //timer for each state of each toggle [array?]

        //switch
          //switch off, no change
            //state         0
            //input         0
            //past timer    1
              //nop
          //switch on, change
            //state         0
            //input         1
            //past timer    1
              //set timer
              //set state 1
              //send [on] press
          //switch on, waiting for release
            //state         1
            //input         1
            //past timer    0
              //nop
          //switch on, ready for release
            //state         1
            //input         1
            //past timer    1
              //send release
          //switch on, no change (same as previous)
            //state         1
            //input         1
            //past timer    1
              //send [on] release
          //switch off, change
            //state         1
            //input         0
            //past timer    1
              //set timer
              //set state 0
              //send [off] press
          //switch off, waiting for release
            //state         0
            //input         0
            //past timer    0
              //nop
          //switch off, ready for release
            //state         0
            //input         0
            //past timer    1
              //send [off] release
      
      //if encoder
      //previous state bool
        //if phaseA != previous state
          //if phaseB != phaseA
            //send increment press
          //if phaseB == phaseA
            //send decrement press




  } else {go_to_safe_mode = true;};

  


  if go_to_safe_mode {
    safe_mode();
  }


}
