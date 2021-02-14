//anex only
#include <Wire.h>
#include <Adafruit_ADS1015.h>

//misc defines
#define i2c_speed 100000 //increase later after testing

//anex = ADS1015 analog input expander
#define addr_anex_cyclic 0x48
#define addr_anex_collective 0x49
#define addr_anex_panel 0x4A
#define addr_anex_overhead 0x4B




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




//init joystick
Joystick_ joystick(JOYSTICK_DEFAULT_REPORT_ID,JOYSTICK_TYPE_JOYSTICK,
  0, 0,              //button count, hat switch count
  true,true,false,    //X(roll), Y(pitch), Z
  false,false,false,  //Rx(dimmer), Ry(gtn1 vol), Rz(gtn2 vol)
  true,true,          //rudder(a/t), throttle(throttle)
  true,false,false  //accelerator(collective), brake(rotor brake), steering
  );




void setup() {

  //anex setup
  anexmanager.cyclic.begin();
  anexmanager.collective.begin();
  anexmanager.panel.begin();
  anexmanager.overhead.begin();

};


void loop() {
  //standard operations consisting of reading all analog and digital inputs, and sending them to the
  //sim as a joystick; followed by reading the air manager message port and using that data to
  //properly light up the annunciator

  read_all_analogs();

  joystick.setYAxis                   (anexmanager.values.cyclic[0]);
  joystick.setXAxis                   (anexmanager.values.cyclic[1]);
  joystick.setRudder                  (anexmanager.values.collective[0]);
  joystick.setThrottle                (anexmanager.values.collective[1]);
  joystick.setAccelerator             (anexmanager.values.panel[0]);


};
