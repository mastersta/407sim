#ifndef LIB407_JOY_H
#define LIB407_JOY_H

#include <Arduino.h>


//takes in an array of the four hat switch states (up, right, down, left) (pullups)
//outputs the degrees that the joystick library expects for the hat position
int hat_direction(int input_array[4]);

#endif
