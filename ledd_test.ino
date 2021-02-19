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

  uint16_t annunciator_data[3];

  if (message_id == 0) { //0, 1, and 2 should be annunciator data
    annunciator_data[message_id] = payload->data_int; //cast from uint_32 to uint_16 should chop off MSBs
    leddmanager.panel1.on_pattern(annunciator_data[message_id]); //actually put it on the annunciator
    leddmanager.panel1.off_pattern(~annunciator_data[message_id]);
    
  } else if (message_id == 1) {
    annunciator_data[message_id] = payload->data_int; //cast from uint_32 to uint_16 should chop off MSBs
    leddmanager.panel2.on_pattern(annunciator_data[message_id]); //actually put it on the annunciator
    leddmanager.panel2.off_pattern(~annunciator_data[message_id]);
    
  } else if (message_id == 2) {
    
    annunciator_data[message_id] = payload->data_int; //cast from uint_32 to uint_16 should chop off MSBs
    leddmanager.panel3.on_pattern(annunciator_data[message_id]); //actually put it on the annunciator
    leddmanager.panel3.off_pattern(~annunciator_data[message_id]);
  };
};


void setup() {

  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);

  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_LEONARDO,  //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );
  
};

void loop() {

  //I believe this will call the new_message_callback function on reciept of a new message
  messagePort->Tick();


  //TODO: AM Gauge creation
}
