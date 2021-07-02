#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <si_message_port.hpp>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Joystick.h>
#include <avr/wdt.h>

//misc defines
#define i2c_speed 100000 //increase later after testing
#define outgoing_delay 50

//ledd = TLC59017 led driver
#define addr_ledd_panel1 0
#define addr_ledd_panel2 1
#define addr_ledd_panel3 2

//anex = ADS1X15 analog input expander
#define addr_anex_cyclic 0x48
#define addr_anex_collective 0x49
#define addr_anex_panel 0x4A
#define addr_anex_overhead 0x4B

//ioex = MCP23017 digital I/O expander
#define addr_ioex_cyclic 0 //0x20 do not use, leave blank in call
#define addr_ioex_collective 1 //0x21
#define addr_ioex_panel1 2 //0x22
#define addr_ioex_panel2 3 //0x23

//interrupt handling
#define encoder_interrupt_pin 7
volatile bool encoder_flag = false;

//ISR for encoder interrupt
void encoder_interrupt() {
  encoder_flag = true;
}




//setup tlcmanager
TLC59116Manager tlcmanager(Wire, i2c_speed);

//init messageport
SiMessagePort* messagePort;




/*-------------------------------------------------------------

AIR MANAGER CALLBACK FUNCTION
When `Tick()` is called in the main loop, and a fresh payload
is ready from Air Manager, this function is called. It splits
the payload into ints (casting from the 32 bits recieved into
16 bits), applies the pwm value for brightness to each of them,
and then sends it to the LED drivers.

Only one of the drivers will update at a time, to help avoid
overwhelming them and locking up the bus. This is a workaround
and may be removed when a real solution is found to the issue.

-------------------------------------------------------------*/
static void new_message_callback(uint16_t message_id, struct SiMessagePortPayload* payload) {

  static int volts_pwm = 255;                           //bus volts pwm value from instrument
  static unsigned int annunciator_data[3] = {0, 0, 0};  //binary annunciator light status
  static byte annunciator_pwm[3][16];                   //above with pwm value applied
  static byte counter = 0;                              //counts from 0-2 to cycle which driver to update

  //0 = annunciator light status data
  if (message_id == 0) {
    
    volts_pwm = payload->data_int[3];
    
    //iterate over each int32 in the payload
    for (byte i = 0; i < 3; i++) {
      
      //drop into annunciator data (uint16 casted automatically)
      annunciator_data[i] = payload->data_int[i];

      //iterate over each bit, apply current bus voltage pwm value
      for (byte j = 0; j < 16; j++) {
        annunciator_pwm[i][j] = (bitRead(annunciator_data[i], j) * volts_pwm);
      };

      //set the outputs according to the pwm data
      tlcmanager[counter].set_outputs(annunciator_pwm[counter]);
      
    };

  };

  //increments the counter and wraps it back to zero if necessary
  counter++;
  if (counter == 3) { counter = 0; };

};




/*-------------------------------------------------------------

JOYSTICK CONFIGURATION

-------------------------------------------------------------*/
Joystick_ joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_JOYSTICK,
  6,  //buttons
  1,  //hats
  true, //x axis [roll]
  true, //y axis [pitch]
  true, //z axis [collective]
  false, //xR
  false, //yR
  false, //zR
  true, //rudder [anti-torque]
  true, //throttle [throttle]
  false, //accelerator
  false, //brake
  false  //steering
);


int hat_direction(int input_array[4]) {
//takes in an array of the four hat switch states (up, right, down, left) (pullups)
//outputs the degrees that the joystick library expects for the hat position

  int output_array[4] = {
    input_array[0],
    input_array[1] * 2,
    input_array[3] * 4, //swapped for cyclic input order
    input_array[2] * 8
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




/*-------------------------------------------------------------

ANALOG EXPANDER SETUP

-------------------------------------------------------------*/
struct anex {  //define
  Adafruit_ADS1015 cyclic = Adafruit_ADS1015(addr_anex_cyclic);
  Adafruit_ADS1015 collective = Adafruit_ADS1015(addr_anex_collective);
  Adafruit_ADS1015 panel = Adafruit_ADS1015(addr_anex_panel);
  Adafruit_ADS1015 overhead = Adafruit_ADS1015(addr_anex_overhead);

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

struct anex anexmanager{}; //initialize




/*-------------------------------------------------------------

DIGITAL EXPANDER SETUP

-------------------------------------------------------------*/
struct ioex {  //define
  Adafruit_MCP23017 cyclic;
  Adafruit_MCP23017 collective;
  Adafruit_MCP23017 panel1;
  Adafruit_MCP23017 panel2;

  struct struct_ioex_values {  //stores analog input values
    uint16_t cyclic;
    uint16_t collective;
    uint16_t panel1;
    uint16_t panel2;
  };

  struct struct_ioex_values values {}; //init to 0
};

struct ioex ioexmanager{}; //initialize




/*--------------------------------------------------------------

ENCODER INTERRUPT HANDLING

Triggered on an encoder interrupt, this function reads the last
interrupt pin on the panel2 ioex, and gets it value. It then
looks at the previous state of the encoders and determines which
encoder triggered the interrupt and then determines which
direction it moved. It then updates the array tracking total
increments/decrements since startup, and passes it to the main
loop which then gets sent to air manager to apply the proper
increment/decrement to the dataraf in question

-------------------------------------------------------------*/
uint32_t * handle_encoders() {
  
  encoder_flag = false;

  static uint32_t encoder_counts[3] = {}; //tracks number of turns since boot
  static uint16_t previous_encoder_data= 0;  //tracks previous state of encoders

  uint8_t last_int_pin = ioexmanager.panel2.getLastInterruptPin();
  uint8_t last_int_val = ioexmanager.panel2.getLastInterruptPinValue();

  switch (last_int_pin) {

    //altimeter encoder
    case 0: //pin A
      if (last_int_val == bitRead(previous_encoder_data,1)) {
        if (last_int_val == 1) {
          encoder_counts[0]++;
        } else {
          encoder_counts[0]--;
        };
      };
      bitWrite(previous_encoder_data, 0, last_int_val);
      break;

    case 1: //pin B
      if (last_int_val == bitRead(previous_encoder_data,0)) {
        if (last_int_val == 1) {
          encoder_counts[0]--;
        } else {
          encoder_counts[0]++;
        };
      };
      bitWrite(previous_encoder_data, 1, last_int_val);
      break;


    //heading bug encoder
    case 2: //pin A
      if (last_int_val == bitRead(previous_encoder_data,3)) {
        if (last_int_val == 1) {
          encoder_counts[1]++;
        } else {
          encoder_counts[1]--;
        };
      };
      bitWrite(previous_encoder_data, 2, last_int_val);
      break;

    case 3: //pin B
      if (last_int_val == bitRead(previous_encoder_data,2)) {
        if (last_int_val == 1) {
          encoder_counts[1]--;
        } else {
          encoder_counts[1]++;
        };
      };
      bitWrite(previous_encoder_data, 3, last_int_val);
      break;


    //HSI course indicator encoder
    case 4: //pin A
      if (last_int_val == bitRead(previous_encoder_data,5)) {
        if (last_int_val == 1) {
          encoder_counts[2]++;
        } else {
          encoder_counts[2]--;
        };
      };
      bitWrite(previous_encoder_data, 4, last_int_val);
      break;

    case 5: //pin B
      if (last_int_val == bitRead(previous_encoder_data,4)) {
        if (last_int_val == 1) {
          encoder_counts[2]--;
        } else {
          encoder_counts[2]++;
        };
      };
      bitWrite(previous_encoder_data, 5, last_int_val);
      break;
  };

  return encoder_counts;

};




/*-------------------------------------------------------------

SETUP

-------------------------------------------------------------*/
void setup() {
  
  pinMode(17, OUTPUT);
  digitalWrite(17, LOW);

  attachInterrupt(digitalPinToInterrupt(encoder_interrupt_pin), encoder_interrupt, FALLING);

  //tlc init 
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  tlcmanager.broadcast().on_pattern(0xAAAA);  //checkerboard pattern

  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_LEONARDO,     //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );

  //initialize the analog boards
  anexmanager.cyclic.begin();
  anexmanager.cyclic.setGain(GAIN_ONE);
  
  anexmanager.collective.begin();
  anexmanager.collective.setGain(GAIN_ONE);
  
  anexmanager.panel.begin();
  anexmanager.panel.setGain(GAIN_ONE);

  //initialize the digital boards
  ioexmanager.cyclic.begin();
  ioexmanager.collective.begin(addr_ioex_collective);
  ioexmanager.panel1.begin(addr_ioex_panel1);
  ioexmanager.panel2.begin(addr_ioex_panel2);
 
  for (byte i = 0; i < 16; i++) {
    ioexmanager.cyclic.pullUp(i, HIGH);
    ioexmanager.collective.pullUp(i, HIGH);
    ioexmanager.panel1.pullUp(i, HIGH);
    ioexmanager.panel2.pullUp(i, HIGH);
  }

  //setup the correct MCP pins as interrupt-triggers
  //do not mirror INTA and INTB, open-drain, trigger with low state
  ioexmanager.panel1.setupInterrupts(true,false,LOW);
  
  //set all pins on panel2 ioex as interrupts on change in value
  for (int i = 0; i++; i < 16) {
    ioexmanager.panel2.setupInterruptPin(i, CHANGE);
  };
  
  //initialize the joystick
  joystick.begin(false);

  joystick.setXAxisRange(0,2048);
  joystick.setYAxisRange(0,2048);
  joystick.setZAxisRange(0,2048);
  joystick.setThrottleRange(0,2048);
  joystick.setRudderRange(0,2048);

  
};




/*-------------------------------------------------------------

MAIN LOOP

-------------------------------------------------------------*/
void loop() {


  //read the analog boards, store the values in the array
  anexmanager.values.cyclic[0] = anexmanager.cyclic.readADC_SingleEnded(0);
  anexmanager.values.cyclic[1] = anexmanager.cyclic.readADC_SingleEnded(1);
  anexmanager.values.collective[0] = anexmanager.collective.readADC_SingleEnded(0);
  anexmanager.values.collective[1] = anexmanager.collective.readADC_SingleEnded(1);
  anexmanager.values.panel[0] = anexmanager.panel.readADC_SingleEnded(0);

  //read the digital boards, store the values in the array
  ioexmanager.values.cyclic = ioexmanager.cyclic.readGPIOAB();
  ioexmanager.values.collective = ioexmanager.collective.readGPIOAB();
  ioexmanager.values.panel1 = ioexmanager.panel1.readGPIOAB();
  //panel2 is encoders and thus doesn't need to be read until an encoder interrupt happens

  //store the lowest throttle value for the idle stop detection, throttle is reversed so max is used
  static int lowest_throttle = 0;
  lowest_throttle = max(lowest_throttle, anexmanager.values.collective[1]);

  //if the throttle is in detent
  if (anexmanager.values.collective[1] > (lowest_throttle * 0.9)) {
    anexmanager.values.collective[1] = lowest_throttle;

    //apply the idle stop
    bitWrite(
      ioexmanager.values.collective,
      6,  //idle stop
      0   //apply idle stop
    );
      
  } else {
    bitWrite(
      ioexmanager.values.collective,
      6,  //idle stop
      1   //remove idle stop
    );
  }

//apply the values in the array to the joystick axes
  joystick.setXAxis(anexmanager.values.cyclic[0]);
  joystick.setYAxis(anexmanager.values.cyclic[1]);
  joystick.setZAxis(anexmanager.values.collective[0]);
  joystick.setThrottle(anexmanager.values.collective[1]);
  joystick.setRudder(anexmanager.values.panel[0]);

//apply the cyclic momentary buttons to the joystick
  for (byte i = 0; i < 5; i++) {
    joystick.setButton(i, !bitRead(ioexmanager.values.cyclic, i));
  };
  joystick.setButton(5, !bitRead(ioexmanager.values.cyclic, 9));


//apply the cyclic hat inputs to the joystick hat
  int cyclic_hat_array[4] {};
  for (byte i = 0; i < 4; i++) {
    cyclic_hat_array[i] = !bitRead(ioexmanager.values.cyclic, (i + 5));
  }
//Serial.println(hat_direction(cyclic_hat_array));
  joystick.setHatSwitch(0, hat_direction(cyclic_hat_array));

//send the joystick data to the sim
  joystick.sendState();

  //send outgoing data to sim
  static unsigned long previous_time = 0;
  uint16_t switch_message_id = 1;
  uint16_t encoder_message_id = 2;

  uint32_t *encoder_payload;
  if (encoder_flag) { encoder_payload = handle_encoders() };

  //only send switch data every outgoing delay
  if (millis() > (previous_time + outgoing_delay)) {

    //build the payload
    uint8_t switch_payload[4] = {
      ioexmanager.values.collective, //low half (top cut off)
      (ioexmanager.values.collective >> 8), //high half
      ioexmanager.values.panel1,  //low half (top cut off)
      (ioexmanager.values.panel1 >> 8) //high half
    };

    //send the payload out
    messagePort->SendMessage(switch_message_id, switch_payload, 4); //TODO: ensure to update len
    messagePort->SendMessage(encoder_message_id, encoder_counts, 3);
    previous_time = millis();
  };

  //check for new payload from AM, run the callback function if new payload is ready
  messagePort->Tick();

  //debug to let us know the main loop is still running
  digitalWrite(17, millis()%1000>500);

}

