#ifndef LIB407_IO_H
#define LIB407_IO_H

#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <Adafruit_MCP23017.h>
#include <Arduino.h>

//ADS1X15 analog input expander
#define addr_ads_cyclic     0x48
#define addr_ads_collective 0x49
#define addr_ads_panel      0x4A
#define addr_ads_overhead   0x4B

//MCP23017 digital I/O expander
#define addr_mcp_cyclic     0 //0x20
#define addr_mcp_collective 1 //0x21
#define addr_mcp_panel1     2 //0x22
#define addr_mcp_panel2     3 //0x23
#define addr_mcp_panel3     4 //0x24
#define addr_mcp_overhead1  5 //0x25
#define addr_mcp_overhead2  6 //0x26
#define addr_mcp_overhead3  7 //0x27


/*-------------------------------------------------------------

ANALOG EXPANDER CLASS
Defines the analog expander boards and provides storage for the
values it produces when read

-------------------------------------------------------------*/
class analog_expander {
  public:
    Adafruit_ADS1015 board;
    analog_expander (uint8_t);
    void init();
    void read_and_store(uint8_t);
    int16_t read_and_return(uint8_t);
    int16_t values[4] {};
};


/*-------------------------------------------------------------

DIGITAL EXPANDER CLASS
Defines the digital expander boards and provides storage for
the values it produces

-------------------------------------------------------------*/
class digital_expander {
  public:
    Adafruit_MCP23017 board;
    digital_expander (uint8_t);
    void init_as_switches();
    void init_as_encoders();
    void read_and_store();
    uint16_t read_and_return();
    uint16_t values;
    uint8_t address;

  private:
    void setup_input_pullups();
};

#endif
