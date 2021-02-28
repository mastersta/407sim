//ioex test only
#include <Wire.h>
#include <si_message_port.hpp>
#include <Adafruit_MCP23017.h>


#define i2c_speed 100000 //increase later after testing


//init messageport
SiMessagePort* messagePort;




//ioex = MCP23017 digital I/O expander
#define addr_ioex_cyclic 0x20
#define addr_ioex_collective 0x21
#define addr_ioex_panel1 0x22
#define addr_ioex_panel2 0x23
#define addr_ioex_panel3 0x24
#define addr_ioex_overhead1 0x25
#define addr_ioex_overhead2 0x26
#define addr_ioex_overhead3 0x27




struct ioex {
  Adafruit_MCP23017 cyclic;
  Adafruit_MCP23017 collective;
  Adafruit_MCP23017 panel1;
  Adafruit_MCP23017 panel2;
  Adafruit_MCP23017 panel3;
  Adafruit_MCP23017 overhead1;
  Adafruit_MCP23017 overhead2;
  Adafruit_MCP23017 overhead3;
  

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




void read_all_digitals() {  //invert due to pullups
  ioexmanager.values.cyclic =     ~ioexmanager.cyclic.readGPIOAB();
  ioexmanager.values.collective = ~ioexmanager.collective.readGPIOAB();
  ioexmanager.values.panel1 =     ~ioexmanager.panel1.readGPIOAB();
  ioexmanager.values.panel2 =     ~ioexmanager.panel2.readGPIOAB();
  ioexmanager.values.panel3 =     ~ioexmanager.panel3.readGPIOAB();
  ioexmanager.values.overhead1 =  ~ioexmanager.overhead1.readGPIOAB();
  ioexmanager.values.overhead2 =  ~ioexmanager.overhead2.readGPIOAB();
  ioexmanager.values.overhead3 =  ~ioexmanager.overhead3.readGPIOAB();
};




void setup() {


  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_MICRO,     //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );


  //ioex setup
  ioexmanager.cyclic.begin(addr_ioex_cyclic);
  ioexmanager.collective.begin(addr_ioex_collective);
  ioexmanager.panel1.begin(addr_ioex_panel1);
  ioexmanager.panel2.begin(addr_ioex_panel2);
  ioexmanager.panel3.begin(addr_ioex_panel3);
  ioexmanager.overhead1.begin(addr_ioex_overhead1);
  ioexmanager.overhead2.begin(addr_ioex_overhead2);
  ioexmanager.overhead3.begin(addr_ioex_overhead3);


}




void loop() {


  read_all_digitals();

  unsigned int payload[8] {
    ioexmanager.values.cyclic,
    ioexmanager.values.collective,
    ioexmanager.values.panel1,
    ioexmanager.values.panel2,
    ioexmanager.values.panel3,
    ioexmanager.values.overhead1,
    ioexmanager.values.overhead2,
    ioexmanager.values.overhead3
  }

  messageport->SendMessage(100, payload, 8);

  messagePort->Tick();

  delay(1);

}
