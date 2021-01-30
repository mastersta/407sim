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
  
}

void loop() {

}
