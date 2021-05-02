# 407sim
Resources for a two-seater home cockpit based around the Dreamfoil Bell 407 for X-Plane 11

## Current State of Things

**Last updated: 1 May 2021**

☑ Main frame constructed 
☑ Mainboard created 
☑ Power supply sourced and installed
☑ Cyclic assembly constructed 
☑ Instrument panel constructed
☑ Instrument panel expander board created 
☑ Power and data lines ran 
☑ Collective assembly constructed 
☑ Collective expander board constructed 
☑ Annunciator constructed 
☑ Annunciator expander board created 
☑ Annunciator output from sim to hardware annunciator
☑ Primary flight controls input from hardware to analog joystick inputs
☐ Overhead panel constructed
☐ Overhead panel expander board created
☐ GPS panel constructed
☐ GPS panel expander board created
☐ Digital hardware inputs into simulator

## Overview

The main frame of the cockpit is constructed from wood, with aluminum trim, plastic seats, and faux rivets. The instrument panel has a faux leather glareshield with a 3d printed and handwired annunciator panel of my own design. The seats are plastic fishing boat seats (upgrade to leather cushioned seats planned). The cyclics grips are 3d printed, and the conduit/tubing that connects them is 3/4" EMT. The conduit rides in 6702 bearings to interface with a stationary 1" PVC fitting, providing a smooth and sturdy axis on which to rotate. This setup is used for both axes of the cyclic, as well as the collective's movement. The collective head, throttle grip, and associated parts are 3d printed. The throttle has an idle stop detent. The collective's movement is dampened by a gas strut that has been depressurized. The anti-torque pedals are made of metal brackets and pipe over bolts, connected with linkages, and linked to custom 3d printed tees. The base that the pedals are mounted on is made of wood.

## Hardware

This project uses custom soldered breadboard-style protoboards designed to allow for easy replacement of components. If an input expander takes a crap, simply yank it out and drop another one in. The addresses, input/output terminals, etc are all hardwired onto the breadboards, so all of the expander's connections remain in place. This makes repair very easy.

The individual breadboards each have a section dedicated to connecting to and passing along the power and data busses. The input and output expanders communicate with the master board via I2C, which is a 2-wire protocol. +5v, +12v, and ground brings the total number of wires running around the cockpit to *five*, a massive improvement over my previous construction. The remote nature of the individual boards means that I/O expanders can be located very close to the hardware that they control, once again reducing the amount of wire required.


**Master board:**

Arduino Pro Micro

**Analog Input Expanders**

ADS1015

[Datasheet](https://www.ti.com/lit/ds/symlink/ads1015.pdf?ts=1612148121389&ref_url=https%253A%252F%252Fwww.startpage.com%252F)

[Library](https://github.com/adafruit/Adafruit_ADS1X15)

Initially I had planned to use the big brother of the 1015, the 1115. The 1115 provides 16 bits of precision (one being the sign bit, so 15 bits in each direction), but I got scammed by the amazon seller and ended up with the 1015 on an 1115's board. I will seek out true 1115s once the sim is complete and if the 1015s (12-bit precision) prove to be inadequate. As-is, they offer four times the resolution of the arduino's built-in ADC, though more is always better.


**Digital I/O Expanders**

MCP23017

[Datasheet](https://ww1.microchip.com/downloads/en/devicedoc/20001952c.pdf)

[Library](200~https://github.com/adafruit/Adafruit-MCP23017-Arduino-Library/blob/master/Adafruit_MCP23017.h)

These offer 16 digital general purpose I/O pins, including the ability to set pullup resistors. Therefore, I'm using them for the various buttons and switches throughout the cockpit. Currently six are planned, however I would need a total of 8 to cover every circuit breaker. Fortunately, there is enough I2C address space available in the MCP23017 to allow for that. Future expansion!

Since I could only find them in SSOP-28 packages, I hand soldered them to SSOP/TSSOP-28 breakout boards. This initially resulted in about a 50% success rate due mostly to bridged pins and burnt pads, but after upgrading to a temperature-controlled soldering iron, I was able to achieve a nearly perfect success rate. I only later found out that they're offered in DIP, though they're more expensive that way.


**LED Drivers**

TLC59116

[Datasheet](https://www.ti.com/lit/ds/symlink/tlc59116.pdf?ts=1611354508126&ref_url=https%253A%252F%252Fwww.google.com%252F)

[Library](https://github.com/2splat/arduino-TLC59116/blob/master/examples/basic_usage_single/basic_usage_single.ino)

Providing 16 PWM-capable constant current sinks, the 59116 is ideal for this project due to the requirement for many LEDs, especially for the annunciator. To allow for lower current requirements, and thus smaller wire gauges, a 12v rail is present to drive LEDs. This allows me to put four LEDs in series in each annunciator, providing the cells with even lighting. The same principle will be used for the overhead panel's backlighting. I am also able to take advantage of the 59116's ability to drive its own PWMs for each pin, freeing up much of the master board's processing time and enabling me to implement advanced features such as dimming all of the lights at once based on the simulator aircraft's bus voltage. 


**Power Supply**

12v industrial PLC power supply, 8A capacity, DIN rail mounted

I reclaimed this from the dumpster in perfect condition. I added an inline fuse holder and a 5A fuse (and I'll adjust if and when I need more amperage, it takes the automotive style fuses). The 12v powers all the LEDs in the annunciator and all the backlighting. This allows the current demands to stay down and and the wires to stay small (using AWG28 for most of the LED wires). Initially I was intending on powering the Pro Micro using the 12v, to keep the current demands on my computers USB ports to a minimum. However, the chinesium boards I got from Amazon ended up not being able to handle 12v on the RAW pin at the same time as being on USB power. They were fine on either one alone.


