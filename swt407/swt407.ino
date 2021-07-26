#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <si_message_port.hpp>

#include "lib407_io.h"
#include "lib407_interlock.h"

//tlc addresses
#define addr_tlc_panel1 0
#define addr_tlc_panel2 1
#define addr_tlc_panel3 2

//payload ids
#define switch_message_id 1
#define encoder_message_id 2

//interrupt handling
#define encoder_interrupt_pin 7
volatile bool encoder_flag = false;

//ISR for encoder interrupt
void encoder_interrupt() {
  encoder_flag = true;
}

//setup tlcmanager
#define i2c_speed 100000
TLC59116Manager tlcmanager(Wire, i2c_speed);

//init messageport
SiMessagePort* messagePort;

//init interlock
#define interlock_pin 6
interlock interlock(interlock_pin, 1000);




/*-------------------------------------------------------------

AIR MANAGER CALLBACK FUNCTION
When `Tick()` is called in the main loop, and a fresh payload
is ready from Air Manager, this function is called. It splits
the payload into ints (casting from the 32 bits recieved into
16 bits), applies the pwm value for brightness to each of them,
and then sends it to the LED drivers.

-------------------------------------------------------------*/
static void new_message_callback(
  uint16_t message_id,
  struct SiMessagePortPayload* payload) {

  //bus volts pwm value from instrument
  static int volts_pwm = 255;

  //binary annunciator light status
  static unsigned int annunciator_data[3] = {0, 0, 0};

  //above with pwm value applied
  static byte annunciator_pwm[3][16];


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
      interlock.engage();
      tlcmanager[i].set_outputs(annunciator_pwm[i]);
      interlock.disengage();
      
    };

  };

};




/*-------------------------------------------------------------

ANALOG EXPANDER SETUP
The collective idle stop requires knowing the throttle position

-------------------------------------------------------------*/
analog_expander ads_collective      (addr_ads_collective);




/*-------------------------------------------------------------

DIGITAL EXPANDER SETUP

-------------------------------------------------------------*/
//digital_expander mcp_cyclic         (addr_mcp_cyclic); //Not used here
digital_expander mcp_collective     (addr_mcp_collective);
digital_expander mcp_panel1         (addr_mcp_panel1);
digital_expander mcp_panel2         (addr_mcp_panel2);
//digital_expander mcp_overhead1      (addr_mcp_overhead1); //NYI
//digital_expander mcp_overhead2      (addr_mcp_overhead2); //NYI




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
void handle_encoders() {
  
  encoder_flag = false;

  static int32_t encoder_counts[8] = {};

  interlock.engage();

  uint8_t last_int_pin = mcp_panel2.board.getLastInterruptPin();
  uint8_t next_int_pin = last_int_pin + 1;
  uint8_t int_cap_val = mcp_panel2.board.getInterruptCaptureValue();
  uint8_t count_index = last_int_pin / 2;

  if (bitRead(int_cap_val, last_int_pin % 8) != 
      bitRead(int_cap_val, next_int_pin % 8)) {
    encoder_counts[count_index]++;
  } else {
    encoder_counts[count_index]--;
  };

  uint16_t throwaway = mcp_panel2.board.readGPIOAB();

  interlock.disengage();

  //send the current set of encoder counts to air manager
  messagePort->SendMessage(encoder_message_id,
                           encoder_counts, 8);

};




/*-------------------------------------------------------------

SETUP

-------------------------------------------------------------*/
void setup() {
  
  pinMode(17, OUTPUT);
  digitalWrite(17, LOW);

  attachInterrupt(digitalPinToInterrupt(encoder_interrupt_pin),
                  encoder_interrupt,
                  FALLING);

  //grab the I2C line
  interlock.engage();

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
  //ads_cyclic.init();  //Not used here
  ads_collective.init();
  //ads_panel.init();  //Not used here
  //ads_overhead.init();  //NYI

  //initialize the digital boards
  //mcp_cyclic.init_as_switches(); //Not used here
  mcp_collective.init_as_switches();
  mcp_panel1.init_as_switches();
  mcp_panel2.init_as_encoders();
  //mcp_overhead1.init_as_switches(); //NYI
  //mcp_overhead2.init_as_switches(); //NYI

  //release the I2C line
  interlock.disengage();
  
};




/*-------------------------------------------------------------

MAIN LOOP

-------------------------------------------------------------*/
void loop() {

  //Grab the I2C bus
  interlock.engage();

  //read the digital boards
  mcp_collective.read_and_store();
  mcp_panel1.read_and_store();
  mcp_panel2.read_and_store();
  //mcp_overhead1.read_and_store();
  //mcp_overhead2.read_and_store();

  //read the throttle
  ads_collective.read_and_store(1);

  //Release the I2C bus
  interlock.disengage();

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
    bitWrite(
      mcp_collective.values,
      6,  //idle stop
      0   //apply idle stop
    );
      
  } else {
    bitWrite(
      mcp_collective.values,
      6,  //idle stop
      1   //remove idle stop
    );
  }

  if (encoder_flag) { handle_encoders(); };

  //switch payload handling
  const byte sp_len = 4;  //TODO: ensure to update len
  static uint8_t previous_switch_payload[sp_len] = {};
  uint8_t switch_payload[sp_len] = {};

  //build the switch payload
  switch_payload[0] =  mcp_collective.values; //low half (top cut off)
  switch_payload[1] = (mcp_collective.values >> 8); //high half
  switch_payload[2] =  mcp_panel1.values;  //low half (top cut off)
  switch_payload[3] = (mcp_panel1.values >> 8); //high half
  //switch_payload[4] =  mcp_overhead1.values;  //low half (top cut off)
  //switch_payload[5] = (mcp_overhead1.values >> 8); //high half
  //switch_payload[6] =  mcp_overhead2.values;  //low half (top cut off)
  //switch_payload[7] = (mcp_overhead2.values >> 8); //high half
  
  //check if the payload has changed
  bool payload_changed = false;
  for (byte i = 0; i < sp_len; i++) {
    if (switch_payload[i] != previous_switch_payload[i]) { payload_changed = true; };
  };

  //send it out if so
  if (payload_changed) {
    messagePort->SendMessage(switch_message_id, switch_payload, sp_len);

    //save the new payload for later comparison
    for (byte i = 0; i < sp_len; i++) {
      previous_switch_payload[i] = switch_payload[i];
    };
  };

  //check for new payload from AM, run the callback function if
  //new payload is ready
  messagePort->Tick();

  //debug to let us know the main loop is still running
  digitalWrite(17, millis()%1000>500);

};
