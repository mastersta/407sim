--407simV2 hardware communication instrument

id = hw_message_port_add("ARDUINO_MICRO_A", incoming_message_callback)




function incoming_message_callback()
  --incoming message will be array of ints (16 -> 32?)
  --iterate over array, compare to previous state
  --if change, send appropriate XP command
  
  --cyclic:
  --0/0 trigger (NYI) EXAMPLE OF MOMENTARY
  xpl_command("test/command/here", ((payload[0] >> 0) & 1) == 1)
  --0/1 left soft
  --0/2 right soft
  --0/3 force trim
  --0/4 pinky
  --0/5 hat up
  --0/6 hat right
  --0/7 hat left
  --0/8 hat down
  --0/9 hat push
  
  --collective:
  --1/0 starter eng EXAMPLE OF TOGGLE
  if has_changed(payload[0][0]) then
    xpl_command("sim/engines/engage_starters",1)
    timer_start(100, xpl_command("sim/engines/engage_starters",0))
  end
  --1/1 starter diseng
  --1/2 ldg light off
  --1/3 ldg light both [off state = ldg light on]
  --1/4 idle stop
  --1/5 hat up
  --1/6 hat right
  --1/7 hat left
  --1/8 hat down
  --1/9 hat push
end




function has_changed(ioex_num, input_num)

end




function annunciator_callback(
  float_test,     --\
  engine_fire,    --|
  engine_anti_ice,--|
  float_arm,      --|
  auto_relight,   --|
  start,          --|
  baggage_door,   --|----payload1
  lfuel_boost,    --|
  lfuel_xfer,     --|
  rfuel_boost,    --|
  rfuel_xfer,     --|
  fuel_valve,     --/
  fuel_low,        --\
  fadec_fail,      --|
  manual_fadec,    --|
  engine_chip,     --|
  tr_chip,         --|
  gen_fail,        --|
  xmsn_oil_press,  --|-----payload2
  exceedance_mgt,  --|
  exceedance_ng,   --|
  exceedance_trq,  --|
  battery_rly,     --|
  xmsn_oil_temp,   --|
  hydraulic_system,--/
  cyclic_pitch,   --\
  cyclic_roll,    --|
  on_ground,      --|
  n1_percent,     --|----payload3
  pedal_stop,     --|
  rpm,            --/
  annunciator_test,
  bus_volts,
  instr_brt
  )



  
  --message id = 0:ledd.panel1
  local payload1 = 0
  
  --fadec fault                                                        + 32768
  if fuel_valve == 1                          then payload1 = payload1 + 16384 end
  if rfuel_xfer == 0                          then payload1 = payload1 + 8192 end
  if rfuel_boost[2] == 0                      then payload1 = payload1 + 4096 end
  --fuel filter                                                        + 2048
  if lfuel_xfer == 0                          then payload1 = payload1 + 1024 end
  if lfuel_boost[1] == 0                      then payload1 = payload1 + 512 end
  --heater overtemp                                                    + 256
  --litter door                                                        + 128
  if baggage_door > 0.01                      then payload1 = payload1 + 64 end
  if start[1] == 1                            then payload1 = payload1 + 32 end
  if auto_relight == 1                        then payload1 = payload1 + 16 end
  if float_arm == 1                           then payload1 = payload1 + 8 end
  if engine_anti_ice == 1                     then payload1 = payload1 + 4 end
  if engine_fire == 1                         then payload1 = payload1 + 2 end
  if float_test == 1                          then payload1 = payload1 + 1 end




  --message id = 1: ledd.panel2
  local payload2 = 0

  --engine ovspd                                                       + 32768
  --battery hot                                                        + 16384
  if hydraulic_system < 650                   then payload2 = payload2 + 8192 end
  if xmsn_oil_temp > 11                       then payload2 = payload2 + 4096 end
  if battery_rly == 1                         then payload2 = payload2 + 2048 end
  if (
    exceedance_mgt +
    exceedance_ng +
    exceedance_trq > 0
  )                                           then payload2 = payload2 + 1024 end
  if xmsn_oil_press < 3.3                     then payload2 = payload2 + 512 end
  if gen_fail == 1                            then payload2 = payload2 + 256 end
  if tr_chip == 6                             then payload2 = payload2 + 128 end
  --xmsn chip                                                          + 64
  if engine_chip == 1                         then payload2 = payload2 + 32 end
  if manual_fadec == 0                        then payload2 = payload2 + 16 end
  --fadec degraded                                                     + 8
  if fadec_fail == 6                          then payload2 = payload2 + 4 end
  if fuel_low == 1                            then payload2 = payload2 + 2 end
  --restart fault                                                      + 1




  --message id = 2: ledd.panel3
  local payload3 = 0

  if ((math.abs(cyclic_pitch) > 0.042
    or math.abs(cyclic_roll) > 0.068)
    and (on_ground))                          then payload3 = payload3 + 1 end
  if n1_percent[1] < 55                       then payload3 = payload3 + 2 end
  if pedal_stop == 0                          then payload3 = payload3 + 4 end
  if (rpm[1] < 392 or rpm[1] > 442)           then payload3 = payload3 + 8 end




  --AND with annunciator test
  local ffff = 65535
  if annunciator_test == 1 then
    payload1 = ffff
    payload2 = ffff
    payload3 = 15
  end




  --convert bus volts to pwm byte value (28.4 is max expected)
  local bus_volts_map = {
    {0, 0},
    {100, 0},
    {284, 255}
  }
  local bus_volts_convert = math.floor(bus_volts[1] * 10)
  local annunciator_brt = math.floor(interpolate_linear(bus_volts_map, bus_volts_convert)) -- * instr_brt[11]))




  --send the payload to the arduino
  hw_message_port_send(id, 0, "INT[3]", {payload1, payload2, payload3})
  hw_message_port_send(id, 1, "INT", annunciator_brt)


end




xpl_dataref_subscribe(
  "sim/test/test_float",                                "FLOAT",    --float test
  "sim/cockpit/warnings/annunciators/engine_fire",      "INT",      --engine fire
  "sim/cockpit/switches/anti_ice_inlet_heat",           "INT",      --engine anti-ice
  "B407/Float_Arm",                                     "FLOAT",    --float arm
  "sim/cockpit/warnings/annunciators/auto_ignition",    "INT",      --auto relight
  "sim/flightmodel2/engines/starter_is_running",        "INT[8]",   --start
  "B407/Baggage",                                       "FLOAT",    --baggage door (>0 = on)
  "sim/cockpit2/fuel/fuel_tank_pump_on",                "INT[8]",   --lfuel boost
  "B407/Overhead/Swt_BoostXFR_Left",                    "FLOAT",    --lfuel xfer
  "sim/cockpit2/fuel/fuel_tank_pump_on",                "INT[8]",   --rfuel boost
  "B407/Overhead/Swt_BoostXFR_Right",                   "FLOAT",    --rfuel xfer
  "B407/FuelValveMoving",                               "FLOAT",    --fuel valve
  "sim/cockpit2/annunciators/fuel_quantity",            "INT",      --fuel low
  "sim/operation/failures/rel_fadec_0",                 "INT",      --fadec fail (6=fail)
  "B407/Fadec",                                         "FLOAT",    --manual fadec (0=manual = on)
  "sim/cockpit2/annunciators/chip_detect",              "INT",      --engine chip
  "sim/operation/failures/rel_trotor",                  "INT",      --t/r chip (6=fail)
  "sim/cockpit2/annunciators/generator",                "INT",      --gen fail
  "B407/Panel/XMsn_Oil_Psi",                            "FLOAT",    --xmsn oil press (<3.3 = fail)
  "B407/Panel/Exceedance/MGT",                          "FLOAT",    --check instr...
  "B407/Panel/Exceedance/NG",                           "FLOAT",    --...(any of these three...
  "B407/Panel/Exceedance/TRQ",                          "FLOAT",    --...>0 = fail)
  "sim/cockpit/electrical/gpu_on",                      "INT",      --battery rly
  "B407/Panel/XMsn_Oil_C",                              "FLOAT",    --xmsn oil temp (>11 = fail)
  "sim/operation/failures/hydraulic_pressure_ratio",    "FLOAT",    --hydraulic system (<650 = fail)
  "B407/Controls/Pitch",                                "FLOAT",    --cyclic centering (<.042 AND...
  "B407/Controls/Roll",                                 "FLOAT",    --...<.068 = on)...
  "sim/flightmodel/failures/onground_any",              "INT",      --...AND is on the ground
  "sim/flightmodel2/engines/N1_percent",                "FLOAT[8]", --engine out (<55 = fail)
  "B407/PedalStop",                                     "FLOAT",    --pedal stop (0 = fail)
  "sim/cockpit2/engine/indicators/prop_speed_rpm",      "FLOAT[8]", --rpm (392<x<442)
  "sim/cockpit/warnings/annunciator_test_pressed",      "INT",      --annunciator test
  "sim/cockpit2/electrical/bus_volts",                  "FLOAT[8]", --bus volts
  "sim/cockpit2/switches/instrument_brightness_ratio",  "FLOAT[32]",--instr brt
  annunciator_callback
)


