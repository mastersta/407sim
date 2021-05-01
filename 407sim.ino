//ledd test only
#include <Wire.h>
#include <TLC59116_Unmanaged.h>
#include <TLC59116.h>
#include <si_message_port.hpp>
#include <Adafruit_ADS1015.h>
#include <Joystick.h>
#include <avr/wdt.h>

//misc defines
#define i2c_speed 100000 //increase later after testing

//ledd = TLC59017 led driver
#define addr_ledd_panel1 0
#define addr_ledd_panel2 1
#define addr_ledd_panel3 2

//anex = ADS1X15 analog input expander
#define addr_anex_cyclic 0x48
#define addr_anex_collective 0x49
#define addr_anex_panel 0x4A
#define addr_anex_overhead 0x4B



//setup tlcmanager
TLC59116Manager tlcmanager(Wire, i2c_speed);

//init messageport
SiMessagePort* messagePort;


void watchdogSetup(void) {
  cli();
  wdt_reset();
  WDTCSR |= (1<<WDCE) | (1<<WDE);
  WDTCSR = 0b01011100;
  sei();
}

ISR(WDT_vect) {
  digitalWrite(17, HIGH);
  digitalWrite(30, HIGH);

  pinMode(3, OUTPUT);

  for (byte i = 0; i < 10; i++) {
    digitalWrite(3,LOW);
    digitalWrite(3,HIGH);
  };
}

//gets called when a new payload is recieved from the instrument
static void new_message_callback(uint16_t message_id, struct SiMessagePortPayload* payload) {

  static int volts_pwm = 255;                          //bus volts pwm value from instrument
  static unsigned int annunciator_data[3] = {0, 0, 0};  //binary annunciator light status
  static byte annunciator_pwm[3][16];                   //above with pwm value applied
  static byte counter = 0;

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

  counter++;
  if (counter == 3) { counter = 0; };

};




Joystick_ joystick(
  JOYSTICK_DEFAULT_REPORT_ID,
  JOYSTICK_TYPE_JOYSTICK,
  0,  //buttons
  0,  //hats
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




void setup() {

  watchdogSetup();
  
  pinMode(17, OUTPUT);
  pinMode(30, OUTPUT);
  digitalWrite(17, HIGH);
  digitalWrite(30, HIGH);

  //tlc init 
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  tlcmanager.broadcast().on_pattern(0xAAAA);  //checkerboard pattern
  //tlcmanager.broadcast().on_pattern(0xFFFF);  //all lit

  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_LEONARDO,     //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );

  anexmanager.cyclic.begin();
  anexmanager.cyclic.setGain(GAIN_ONE);
  
  anexmanager.collective.begin();
  anexmanager.collective.setGain(GAIN_ONE);
  
  anexmanager.panel.begin();
  anexmanager.panel.setGain(GAIN_ONE);
  
  joystick.begin(false);

  joystick.setXAxisRange(0,2048);
  joystick.setYAxisRange(0,2048);
  joystick.setZAxisRange(0,2048);
  joystick.setThrottleRange(0,2048);
  joystick.setRudderRange(0,2048);
  
};

void loop() {

  wdt_reset();

  anexmanager.values.cyclic[0] = anexmanager.cyclic.readADC_SingleEnded(0);
  anexmanager.values.cyclic[1] = anexmanager.cyclic.readADC_SingleEnded(1);
  anexmanager.values.collective[0] = anexmanager.collective.readADC_SingleEnded(0);
  anexmanager.values.collective[1] = anexmanager.collective.readADC_SingleEnded(1);
  anexmanager.values.panel[0] = anexmanager.panel.readADC_SingleEnded(0);

  joystick.setXAxis(anexmanager.values.cyclic[0]);
  joystick.setYAxis(anexmanager.values.cyclic[1]);
  joystick.setZAxis(anexmanager.values.collective[0]);
  joystick.setThrottle(anexmanager.values.collective[1]);
  joystick.setRudder(anexmanager.values.panel[0]);
  
  joystick.sendState();

  messagePort->Tick();

}
