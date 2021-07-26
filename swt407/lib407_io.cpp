#include "lib407_io.h"

//Constructor to allow initialization with address
analog_expander::analog_expander (uint8_t address) {
  board = Adafruit_ADS1015(address);
};

//To be called in the arduino Setup() function
void analog_expander::init() {
  board.begin();
  board.setGain(GAIN_ONE);
};

//Reads the input number and stores in the values array
void analog_expander::read_and_store(uint8_t input) {
  values[input] = board.readADC_SingleEnded(input);
};

//Reads the input number and stores in the values array, then
//returns the array
int16_t analog_expander::read_and_return(uint8_t input) {
  read_and_store(input);
  return values[input];
};


//=============================================================


//Constructor to allow initialization with address
digital_expander::digital_expander(uint8_t init_address) {
  address = init_address;
};

//Sets all pins on the board as input pullups
void digital_expander::setup_input_pullups() {
  for (byte i = 0; i < 16; i++) {
    board.pinMode(i, INPUT);
    board.pullUp(i, HIGH);
  };
};

//Initializes the board for switches/buttons
//To be called in arduino setup() function
void digital_expander::init_as_switches() {

  if (address == 0) {
    board.begin(); //if address zero, do not pass into begin()
  } else {
    board.begin(address);
  };

  setup_input_pullups();
};

//Initializes the board for encoders
//To be called in arduino setup() function
void digital_expander::init_as_encoders() {

  init_as_switches();

  board.setupInterrupts(true, false, LOW);
  for (byte i = 0; i < 16; i+=2) {
    board.setupInterruptPin(i, CHANGE);
  };
};

//Reads all inputs and stores in values variable
void digital_expander::read_and_store() {
  values = board.readGPIOAB();
};

//Reads all inputs and stores in values variable, then returns
//the values
uint16_t digital_expander::read_and_return() {
  read_and_store();
  return values;
};

