//ledd test only
#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <si_message_port.hpp>

//misc defines
#define i2c_speed 100000 //increase later after testing

//ledd = TLC59017 led driver
#define addr_ledd_panel1 0
#define addr_ledd_panel2 1
#define addr_ledd_panel3 2

TLC59116Manager tlcmanager(Wire, i2c_speed);

struct ledd {
  TLC59116 &panel1 = tlcmanager[addr_ledd_panel1];
  TLC59116 &panel2 = tlcmanager[addr_ledd_panel2];
  TLC59116 &panel3 = tlcmanager[addr_ledd_panel3];
};

struct ledd leddmanager;

SiMessagePort* messagePort;

static void new_message_callback(uint16_t message_id, struct SiMessagePortPayload* payload) {
  //message recieved
  static byte volts_pwm = 255;
  static unsigned int annunciator_data[3] = {0, 0, 0};
  static byte annunciator_pwm[3][16];
  
  
  if (message_id == 0) {
    
    for (byte i = 0; i < 3; i++) {
      annunciator_data[i] = payload->data_int[i];
//      messagePort->DebugMessage(SI_MESSAGE_PORT_LOG_LEVEL_INFO, (String)annunciator_data[i]);
//      tlcmanager[i].on_pattern(annunciator_data[i]);
//      tlcmanager[i].off_pattern(~annunciator_data[i]);

      for (byte j = 0; j < 16; j++) {
        byte holder = bitRead(annunciator_data[i], j);
        annunciator_pwm[i][j] = (holder * volts_pwm);
      };

      tlcmanager[i].set_outputs(annunciator_pwm[i]);
      
    };
    
  } else if (message_id == 1) {
    volts_pwm = payload->data_byte[0];
  };

};


void setup() {
  
  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  tlcmanager.broadcast().on_pattern(0xAAAA);

  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_MICRO,  //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );

  
};

void loop() {

  //I believe this will call the new_message_callback function on reciept of a new message
  messagePort->Tick();
  delay(1);

}
