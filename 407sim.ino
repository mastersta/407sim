#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Joystick.h>

//misc defines
#define i2c_speed 100000 //increase later after testing
#define toggle_time 100  //time to press joystick button for toggles
#define encoder_time 50  //time to press joystick button for encoder increments/decrements

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
#define addr_ioex_panel3 0x24
#define addr_ioex_overhead1 0x25
#define addr_ioex_overhead2 0x26
#define addr_ioex_overhead3 0x27

//ledd = TLC59017 led driver
#define addr_ledd_overhead1 0x60
#define addr_ledd_overhead2 0x61
#define addr_ledd_overhead3 0x62
#define addr_ledd_panel1 0x63
#define addr_ledd_panel2 0x64
#define addr_ledd_panel3 0x65




struct anex {  //define
  Adafruit_ADS1015 cyclic;
  Adafruit_ADS1015 collective;
  Adafruit_ADS1015 panel;
  Adafruit_ADS1015 overhead;

  struct struct_anex_values {  //stores analog input values
    int cyclic[4];
    int collective[4];
    int panel[4];
    int overhead[4];
  };

  struct struct_anex_values values { //init to zero
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0}
  };
};

struct anex anexmanager{  //initialize
  Adafruit_ADS1015(addr_anex_cyclic),
  Adafruit_ADS1015(addr_anex_collective),
  Adafruit_ADS1015(addr_anex_panel),
  Adafruit_ADS1015(addr_anex_overhead)
};


bool read_all_analogs() {  //sets global anexmanager.values struct
  anexmanager.values.cyclic[0] =       anexmanager.cyclic.readADC_SingleEnded(0);     //pitch
  anexmanager.values.cyclic[1] =       anexmanager.cyclic.readADC_SingleEnded(1);     //roll
  anexmanager.values.collective[0] =   anexmanager.collective.readADC_SingleEnded(0); //collective
  anexmanager.values.collective[1] =   anexmanager.collective.readADC_SingleEnded(1); //throttle
  anexmanager.values.panel[0] =        anexmanager.panel.readADC_SingleEnded(0);      //antitorque
  anexmanager.values.panel[1] =        anexmanager.panel.readADC_SingleEnded(1);      //gtn1 vol
  anexmanager.values.panel[2] =        anexmanager.panel.readADC_SingleEnded(2);      //gtn2 vol
  anexmanager.values.overhead[0] =     anexmanager.overhead.readADC_SingleEnded(0);   //instrument dimmer
  anexmanager.values.overhead[1] =     anexmanager.overhead.readADC_SingleEnded(1);   //rotor brake
  return true;  //if something goes wrong, might return false and we can use that to go to safe mode
};




struct ioex {
  Adafruit_MCP23017 cyclic;
  Adafruit_MCP23017 collective;
  Adafruit_MCP23017 panel1;
  Adafruit_MCP23017 panel2;
  Adafruit_MCP23017 panel3;
  Adafruit_MCP23017 overhead1;
  Adafruit_MCP23017 overhead2;
  Adafruit_MCP23017 overhead3;
  
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

  const struct struct_ioex_type types {
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

  struct struct_ioex_values values {0,0,0,0,0,0,0,0}; //init at 0

};

struct ioex ioexmanager;




bool read_all_digitals() {  //invert due to pullups
  ioexmanager.values.cyclic =     ~ioexmanager.cyclic.readGPIOAB();
  ioexmanager.values.collective = ~ioexmanager.collective.readGPIOAB();
  ioexmanager.values.panel1 =     ~ioexmanager.panel1.readGPIOAB();
  ioexmanager.values.panel2 =     ~ioexmanager.panel2.readGPIOAB();
  ioexmanager.values.panel3 =     ~ioexmanager.panel3.readGPIOAB();
  ioexmanager.values.overhead1 =  ~ioexmanager.overhead1.readGPIOAB();
  ioexmanager.values.overhead2 =  ~ioexmanager.overhead2.readGPIOAB();
  ioexmanager.values.overhead3 =  ~ioexmanager.overhead3.readGPIOAB();
  return true;  //if something goes wrong, might return false and we can use that to go to safe mode
};




int& get_ioex_values_by_index(byte index) {
  switch(index) {
    case 0:
      return ioexmanager.values.cyclic;
      break;
    case 1:
      return ioexmanager.values.collective;
      break;
    case 2:
      return ioexmanager.values.panel1;
      break;
    case 3:
      return ioexmanager.values.panel2;
      break;
    case 4:
      return ioexmanager.values.panel3;
      break;
    case 5:
      return ioexmanager.values.overhead1;
      break;
    case 6:
      return ioexmanager.values.overhead2;
      break;
    case 7:
      return ioexmanager.values.overhead3;
      break;
    default:
      return ioexmanager.values.cyclic;
      break;
  };
};




int& get_ioex_types_by_index(byte index) {
  switch(index) {
    case 0:
      return ioexmanager.types.cyclic;
      break;
    case 1:
      return ioexmanager.types.collective;
      break;
    case 2:
      return ioexmanager.types.panel1;
      break;
    case 3:
      return ioexmanager.types.panel2;
      break;
    case 4:
      return ioexmanager.types.panel3;
      break;
    case 5:
      return ioexmanager.types.overhead1;
      break;
    case 6:
      return ioexmanager.types.overhead2;
      break;
    case 7:
      return ioexmanager.types.overhead3;
      break;
    default:
      return ioexmanager.types.cyclic;
      break;
  };
};




struct struct_toggle_data {
  bool state[128];
  unsigned long timer[256];
};

struct struct_toggle_data toggle_data;



struct struct_encoder_data {
  byte state[128];
  unsigned long timer[128];
};

struct struct_encoder_data encoder_data;




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




void setup() {

  //anex setup
  anexmanager.cyclic.begin();
  anexmanager.collective.begin();
  anexmanager.panel.begin();
  anexmanager.overhead.begin();

  //ioex setup
  ioexmanager.cyclic.begin(addr_ioex_cyclic);
  ioexmanager.collective.begin(addr_ioex_collective);
  ioexmanager.panel1.begin(addr_ioex_panel1);
  ioexmanager.panel2.begin(addr_ioex_panel2);
  ioexmanager.panel3.begin(addr_ioex_panel3);
  ioexmanager.overhead1.begin(addr_ioex_overhead1);
  ioexmanager.overhead2.begin(addr_ioex_overhead2);
  ioexmanager.overhead3.begin(addr_ioex_overhead3);

  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  
};




int hat_direction(int input_array[]) {
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
  };

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
  };
};




void test_mode() {
  //plan is to get highest digital input pin number (based on wire numbering diagram) and output that
  //pin number, in binary, to the annunciator; lights will be lit up in order to represent that pin
  //number. Total of pins shouldn't exceed 255 so 8 lights should accurately represent it.
  //after that, use the next set of lights to represent the analog input value of the axis
  //all of this should allow the testing of all digital and analog inputs without even a connection
  //to a pc. A hardware switch, directly connected to a pin on the arduino, may be implemented to
  //engage this mode. 


  if (read_all_analogs()) {}; //ignore return, we don't care if something goes wrong
  if (read_all_digitals()) {};


  //get highest digital input pin number
  static unsigned long all_digital_inputs_a = 0; //read LS 32 inputs
  all_digital_inputs_a = (
    (ioexmanager.values.panel2<<24) +
    (ioexmanager.values.panel1<<16) +
    (ioexmanager.values.collective<<8) +
    (ioexmanager.values.cyclic)
  );

  static unsigned long all_digital_inputs_b = 0; //read MS 32 inputs
  all_digital_inputs_b = (
    (ioexmanager.values.overhead3<<24) +
    (ioexmanager.values.overhead2<<16) +
    (ioexmanager.values.overhead1<<8) +
    (ioexmanager.values.panel3)
  );
  
  unsigned int highest_input = 0; //run through MS inputs, bit by bit, to find first high input

  for (int i = 32; i >= 0; i--) {
    if (bitRead(all_digital_inputs_b, 31)) { //if current bit is high
      highest_input = i + 32; //set as highest input, accounting for the LS set of inputs
      break; //and break out
    };
    all_digital_inputs_b << i; //else shift it and loop around to look at the next bit
  };

  if highest_input = 0 { //only do if we had no high inputs from before
    for (int i = 32; i >= 0; i--) { //same thing as previous
      if (bitRead(all_digital_inputs_a, 31)) {
        highest_input = i;
        break;
      };
      all_digital_inputs_a << i;
    };
  };




  //output data to annunciator

  
  //blink the RPM low light to indicate that we're in test mode
  leddmanager.panel3.group_blink(3,1,128);

  //set first 8 lights to represent highest input in binary
  leddmanager.panel1.on_pattern(highest_input<<8).off_pattern(~highest_input<<8);
  
  //set second 8 lights to reflect pwm values of analog axes
  byte pwm_values_a[8] = {
    map(anexmanager.values.cyclic[0],      -2048,2048,0,255), //pitch
    map(anexmanager.values.cyclic[1],      -2048,2048,0,255), //roll
    map(anexmanager.values.collective[0],  -2048,2048,0,255), //collective
    map(anexmanager.values.collective[1],  -2048,2048,0,255), //throttle
    map(anexmanager.values.panel[0],       -2048,2048,0,255), //antitorque
    map(anexmanager.values.panel[1],       -2048,2048,0,255), //gtn1 vol
    map(anexmanager.values.panel[2],       -2048,2048,0,255), //gtn2 vol
    map(anexmanager.values.overhead[0],    -2048,2048,0,255)  //instrument dimmer
  };

  //set following 1 light for remaining axis
  byte pwm_values_b[1] = {
    map(anexmanager.values.overhead[1],    -2048,2048,0,255)  //rotor brake
  };

  //set following lights for analog inputs
  leddmanager.panel1.set_outputs(8,15,pwm_values_a);
  leddmanager.panel1.set_outputs(0,0,pwm_values_b);


};




//===============COMPILES UP TO HERE=================//




bool go_to_safe_mode = false;
void safe_mode() {
  //plan is to remove all extraneous functions except for the analog inputs, just in case something
  //goes wrong during a flight. This will allow the operator to set the helicopter down under
  //almost any circumstances and then perform any other needed functions from inside the sim.
  //To indicate that we are in safe mode, the FADEC fail light will blink and all other annunciations
  //will be extinguished.


  //read (do this directly instead of using function so we can focus on only the necessary axes)
  anexmanager.values.cyclic[0] =       anexmanager.cyclic.readADC_SingleEnded(0);     //pitch
  anexmanager.values.cyclic[1] =       anexmanager.cyclic.readADC_SingleEnded(1);     //roll
  anexmanager.values.collective[0] =   anexmanager.collective.readADC_SingleEnded(0); //collective
  anexmanager.values.collective[1] =   anexmanager.collective.readADC_SingleEnded(1); //throttle
  anexmanager.values.panel[0] =        anexmanager.panel.readADC_SingleEnded(0);      //antitorque
  
  //output
  joystick.setYAxis                   (anexmanager.values.cyclic[0]);
  joystick.setXAxis                   (anexmanager.values.cyclic[1]);
  joystick.setRudder                  (anexmanager.values.collective[0]);
  joystick.setThrottle                (anexmanager.values.collective[1]);
  joystick.setAccelerator             (anexmanager.values.panel[0]);

  //blink fadec
  static TLC59116 &ledd_panel_2 = tlcmanager[4];
  //blink the FADEC Fail and FADEC Degraded lights to indicate that we're in safe mode
  ledd_panel_2.group_blink(2,1,128);
  ledd_panel_2.group_blink(3,1,128);

};




void loop() {
  //standard operations consisting of reading all analog and digital inputs, and sending them to the
  //sim as a joystick; followed by reading the air manager message port and using that data to
  //properly light up the annunciator

  if read_all_analogs() {

    joystick.setYAxis                   (anexmanager.values.cyclic[0]);
    joystick.setXAxis                   (anexmanager.values.cyclic[1]);
    joystick.setRudder                  (anexmanager.values.collective[0]);
    joystick.setThrottle                (anexmanager.values.collective[1]);
    joystick.setAccelerator             (anexmanager.values.panel[0]);

  } else {go_to_safe_mode = true;};



  if read_all_digitals() {






    //joystick button number iterator
    int button_i = 0;

    //grab millis now to ensure we're working with the same data throughout
    unsigned long current_millis = millis();

    //run through all the ioexs
    for (byte j = 0; j < 8; j++) {

      //grab the ioex of the index we're working on
      int ioex_values = get_ioex_values_by_index(j);

      //run through all inputs of the ioex, checking against input type
      for ( byte i = 0; i < 16; i++) {

        byte ioex_types = get_ioex_types_by_index(i);

        //if momentary
        if (ioex_types[i] = 1) {
          //set next joystick button to state of input 
          Joystick.setButton(button_i, bitRead(ioex_values, i));
          button_i++;
        };


        //the joystick button nunber for the inverse will be the number following the non-inverse
        //the timer array locations will be the non-inverse PLUS 128

        
        //if toggle
        else if (ioex_types[i] = 2) {
          
          if                                                        //switch on, change
          (!toggle_data.state[i])                                   //state         0  
          && (bitRead(ioex_values, i))                  //input         1
          && (current_millis - toggle_data.timer[i] > 0) {          //past timer    1
              
            toggle_data.timer[i] = current_millis + toggle_time;    //set timer
            toggle_data.state[i] = 1;                               //set state 1
            joystick.pressButton(button_i);                         //send [on] press


          } else if                                                 //switch on, ready for release/already released
          (toggle_data.state[i])                                    //state         1 
          && (bitRead(ioex_values, i))                  //input         1
          && (current_millis - toggle_data.timer[i] > 0) {          //past timer    1
            
            joystick.releaseButton(button_i);                       //send [on] release

          } else if                                                 //switch off, change
          (toggle_data.state[i])                                    //state         1
          && (!bitRead(ioex_values, i))                //input         0
          && (current_millis - toggle_data.timer[i + 128] > 0) {    //past timer    1

            toggle_data.timer[i + 128] = current_millis + toggle_time; //set timer
            toggle_data.state[i] = 0;                                  //set state 0
            joystick.pressButton(button_i + 1);                        //send [off] press
              
          } else if                                                 //switch off, ready for release
          (!toggle_data.state[i])                                   //state         0
          && (!bitRead(ioex_values, i))                //input         0
          && (current_millis - toggle_data.timer[i + 128] > 0) {    //past timer    1

            joystick.releaseButton(button_i + 1);                          //send [off] release
          };

          
          //if it's a toggle, the immediate next joystick button will be the [off] button
          //since the offs aren't separate physical switches, they aren't listed in the input_types
          //list and thus need to be tracked separately to keep the iterator from getting out of sync
          button_i = button_i + 2; 
        };
        
        


        //if encoder
        else if (ioex_types[i] = 3) {

          //if phaseA != previous state
          if (bitRead(ioex_values, i) != bitRead(encoder_data.state[i], 0)) {

            //if phaseB != phaseA
            if (bitRead(ioex_values, i + 1) != bitRead(encoder_data.state[i], 0)) {

              //send increment press
              if (!encoder_data.state[i]) {

                encoder_data.timer[i] = current_millis + encoder_time;
                encoder_data.state[i] = 1;
                joystick.pressButton(button_i);

              } else {
                
                if (current_millis - encoder_data.timer[i] > 0) {

                  joystick.releaseButton(button_i);

                };
              };

            //if phaseB == phaseA
            } else {
              
              //send decrement press
              if (!encoder_data.state[i + 1]) {

                encoder_data.timer[i + 1] = current_millis + encoder_time;
                encoder_data.state[i + 1] = 1;
                joystick.pressButton(button_i);

              } else {
                
                if (current_millis - encoder_data.timer[i + 1] > 0) {

                  joystick.releaseButton(button_i);

                };
              };
            };
          };
        };
      };
    };




    //hat switches
    static int cyclic_hat_array[4] {
      bitRead(ioexmanager.values.cyclic, 5), //up
      bitRead(ioexmanager.values.cyclic, 6), //right
      bitRead(ioexmanager.values.cyclic, 8), //down
      bitRead(ioexmanager.values.cyclic, 7) //left
    };

    joystick.setHatSwitch(0, hat_direction(cyclic_hat_array));


    static int collective_hat_array[4] {
      bitRead(ioexmanager.values.collective, 5), //up
      bitRead(ioexmanager.values.collective, 6), //right
      bitRead(ioexmanager.values.collective, 8), //down
      bitRead(ioexmanager.values.collective, 7)  //left
    };

    joystick.setHatSwitch(1, hat_direction(collective_hat_array));


  } else {go_to_safe_mode = true;};


  if go_to_safe_mode {
    safe_mode();
  };


};
