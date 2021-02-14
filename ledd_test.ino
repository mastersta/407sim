//ledd test only
#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <si_base.h>
#include <si_network.h>
#include <si_circular_data.h>
#include <si_message_port.h>
#include <sim_extern_shared.h>
#include <sim_extern_client.h>
#include <si_input_buffer.h>
#include <si_message_port_driver.h>
#include <si_output_buffer.h>

//misc defines
#define i2c_speed 100000 //increase later after testing

//ledd = TLC59017 led driver
//#define addr_ledd_overhead1 0x60
//#define addr_ledd_overhead2 0x61
//#define addr_ledd_overhead3 0x62
#define addr_ledd_panel1 0
#define addr_ledd_panel2 1
#define addr_ledd_panel3 2

TLC59116Manager tlcmanager(Wire, i2c_speed);

SiMessagePort* messagePort;

static void new_message_callback(uint16_t message_id, struct SiMessagePortPayload* payload) {
  //message recieved
}

struct ledd {
  TLC59116 &panel1 = tlcmanager[addr_ledd_panel1];
  TLC59116 &panel2 = tlcmanager[addr_ledd_panel2];
  TLC59116 &panel3 = tlcmanager[addr_ledd_panel3];
};

struct ledd leddmanager;


void setup() {

  //ledd setup
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);

  //messageport setup
  messagePort = new SiMessagePort(SI_MESSAGE_PORT_DEVICE_ARDUINO_LEONARDO, SI_MESSAGE_PORT_CHANNEL_A, new_message_callback);
  
};

void loop() {
  //TODO: SI message port API integration
  messagePort->Tick();

  //super confused here

  //TODO: AM Gauge creation
}

