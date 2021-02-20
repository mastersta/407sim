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




//setup tlcmanager
TLC59116Manager tlcmanager(Wire, i2c_speed);

//init messageport
SiMessagePort* messagePort;




//Didn't play nice with SiMessagePort
  //struct ledd {
  //  TLC59116 &panel1 = tlcmanager[addr_ledd_panel1];
  //  TLC59116 &panel2 = tlcmanager[addr_ledd_panel2];
  //  TLC59116 &panel3 = tlcmanager[addr_ledd_panel3];
  //};
  //
  //struct ledd leddmanager;




//gets called when a new payload is recieved from the instrument
static void new_message_callback(uint16_t message_id, struct SiMessagePortPayload* payload) {




  static byte volts_pwm = 255;                          //bus volts pwm value from instrument
  static unsigned int annunciator_data[3] = {0, 0, 0};  //binary annunciator light status
  static byte annunciator_pwm[3][16];                   //above with pwm value applied


  
  
  //0 = annunciator light status data
  if (message_id == 0) {
    
    //iterate over each int32 in the payload
    for (byte i = 0; i < 3; i++) {
      
      //drop into annunciator data (uint16 casted automatically)
      annunciator_data[i] = payload->data_int[i];

      //iterate over each bit, apply current bus voltage pwm value
      for (byte j = 0; j < 16; j++) {
        annunciator_pwm[i][j] = (bitRead(annunciator_data[i], j) * volts_pwm);
      };

      //set the outputs according to the pwm data
      tlcmanager[i].set_outputs(annunciator_pwm[i]);
      
    };
     
  //1 = bus volts pwm data
  } else if (message_id == 1) {

    //grab from payload
    volts_pwm = payload->data_byte[0];

  };

};


void setup() {
  
  //tlc init 
  tlcmanager.init();
  tlcmanager.broadcast().set_milliamps(20, 1000);
  tlcmanager.broadcast().on_pattern(0xAAAA);  //checkerboard pattern

  //messageport setup
  messagePort = new SiMessagePort(
    SI_MESSAGE_PORT_DEVICE_ARDUINO_MICRO,     //board type
    SI_MESSAGE_PORT_CHANNEL_A,                //channel
    new_message_callback                      //function to call on message recieve
  );

  
};

void loop() {

  //call the new_message_callback function on reciept of a new message
  messagePort->Tick();
  delay(1);

}
