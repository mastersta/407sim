//anex only
#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <Joystick.h>

//anex = ADS1015 analog input expander
#define addr_anex_cyclic 0x48
#define addr_anex_collective 0x49
#define addr_anex_panel 0x4A
#define addr_anex_overhead 0x4B

Joystick_ joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_JOYSTICK,
  0,  //buttons
  0,  //hats
  true, //x axis
  true, //y axis
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
);

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

struct anex anexmanager{  //initialize
};




void setup(void) 
{
  Serial.begin(9600);
  Serial.println("Hello!");
  
  Serial.println("Getting single-ended readings from AIN0..3");
  Serial.println("ADC Range: +/- 6.144V (1 bit = 3mV/ADS1015, 0.1875mV/ADS1115)");
  
  
  anexmanager.cyclic.begin();
  anexmanager.collective.begin();
  anexmanager.panel.begin();
  anexmanager.overhead.begin();

  anexmanager.cyclic.setGain(GAIN_ONE);
  anexmanager.collective.setGain(GAIN_ONE);
  anexmanager.panel.setGain(GAIN_ONE);
  anexmanager.overhead.setGain(GAIN_ONE);
  
  joystick.begin(true);
  
  joystick.setXAxisRange(0,2048);
  joystick.setYAxisRange(0,2048);
}

void loop(void) 
{
  int16_t adc0, adc1, adc2, adc3;

  adc0 = anexmanager.cyclic.readADC_SingleEnded(0);
  adc1 = anexmanager.cyclic.readADC_SingleEnded(1);
  Serial.print("AIN0: "); Serial.println(adc0);
  Serial.print("AIN1: "); Serial.println(adc1);
  Serial.println(" ");

  joystick.setXAxis(adc0);
  joystick.setYAxis(adc1);

  joystick.sendState();

  
}
