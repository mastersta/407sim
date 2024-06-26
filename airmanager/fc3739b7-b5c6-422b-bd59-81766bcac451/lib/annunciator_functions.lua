annunciator_payload = {0,0,0,255}

--initialize aircraft icao, will be updated in logic script 
icao = ""

function annunciator_write(payload, bit, value)
  if value == nil then
    print("ERROR - NIL VALUE FOUND AT ANN: " .. payload .. "/" .. bit)
    print(icao)
  else
    annunciator_payload[payload] = bitwrite(annunciator_payload[payload], bit, value)
  end
  generate_payload()
end

--annunciator functions
function af_float_test(input)
  --annunciator_write(1, 1, output)
  --no generic function
end

function af_engine_fire(input)
  output = input
  annunciator_write(1, 2, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/engine_fire",          "INT",  
  af_engine_fire
)

function af_engine_anti_ice(input1, input2)
  if icao == "B407" then
    output = input1
  elseif icao == "206B3" or icao == "206L3" then
    output = input2
  else
    output = input1
  end
  annunciator_write(1, 3, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/ice/ice_inlet_heat_on",                     "INT",    --B407
  "sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine",   "INT[8]", --206B3 
  af_engine_anti_ice
)

function af_float_arm(input1, input2, input3)
  if icao == "B407" then
    output = input1
  elseif icao == "206B3" then
    output = input2
  elseif icao == "206L3" then
    output = input3
  else
    output = 0 --no generic replacement
  end
  annunciator_write(1, 4, output)
end
xpl_dataref_subscribe(
  "B407/Float_Arm",                                 "FLOAT",  
  "206B3/acc/floats_active",                        "INT",  
  "206L3/acc/floats_active",                        "INT",  
  af_float_arm
)

--TODO: fix for 206's
function af_auto_relight(input1, input2, input3)
  if icao == "206B3" then
    output = 0 --disabled
  elseif icao == "206L3" then
    output = 0 --disabled
  else
    output = input3[1]
  end  
  annunciator_write(1, 5, output)
end
xpl_dataref_subscribe(
  "206B3/ignite",                                                "INT",
  "206L3/ignite",                                                "INT",
  "sim/cockpit2/annunciators/igniter_on",        "INT[8]",  
  af_auto_relight
)

function af_start(input)
  output = input[1]
  annunciator_write(1, 6, output)
end
xpl_dataref_subscribe(
  "sim/flightmodel2/engines/starter_is_running",    "INT[8]",  
  af_start
)

function af_baggage_door(input1, input2)
  if icao == "B407" then
    output = booltonum(input1 > 0.01)
  else
    output = input2
  end
  annunciator_write(1, 7, output)
end
xpl_dataref_subscribe(
  "B407/Baggage",                                   "FLOAT",
  "sim/cockpit2/cabin_door_open",                   "INT",
  af_baggage_door
)

function af_litter_door(input)
  if icao == "B407" then
    output = booltonum(input > 0.01)
  else
    output = 0 --no generic replacement
  end
  annunciator_write(1, 8, output)
end
xpl_dataref_subscribe(
  "B407/Door_4",                                   "FLOAT",
  af_litter_door
)

function af_heater_overtemp(input)
  output = 0
  annunciator_write(1, 9, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/hvac",               "INT",
  af_heater_overtemp
)

function af_lfuel_boost(input1, input2, input3, input4)
  if icao == "B407" then
    output = booltonum(input1[1] == 0)
  elseif icao == "206B3" then
    output = input2
  elseif icao == "206L3" then
    output = input3
  elseif icao == "J407" then
    output = 1 - input4[1]
  else
    output = booltonum(input1[1] == 0)
  end
  print("lfuel: " .. output)
  annunciator_write(1, 10, output)
  annunciator_write(1, 11, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/fuel/fuel_tank_pump_on",            "INT[8]",  
  "206B3/fuel/boost/aft/br",                        "INT",
  "206L3/fuel/boost/aft/br",                        "INT",
  "sim/cockpit/engine/fuel_pump_on",                "INT[16]",
  af_lfuel_boost
)

function af_lfuel_xfer(input)
  --assigned via lfuel_boost function
  --possibly sim/cockpit2/fuel_transfer[1]?
end

function af_fuel_filter(input1, input2, input3)
  output = booltonum((input1 > 0) or (input2 > 0)) 
  annunciator_write(1, 12, output)
end
xpl_dataref_subscribe(
  "sim/operation/failures/rel_fuel_block0",         "INT",
  "sim/operation/failures/rel_fuelfl0",                 "INT",
  "sim/cockpit2/annunciators/fuel_pressure",    "INT",
  af_fuel_filter
)

function af_rfuel_boost(input1, input2, input3, input4)
  if icao == "B407" then
    output = booltonum(input1[2] == 0)
  elseif icao == "206B3" then
    output = input2
  elseif icao == "206L3" then
    output = input3
  elseif icao == "J407" then
    output = 1 - input4[2]
  else
    output = booltonum(input1[2] == 0)
  end
  print("rfuel: " .. output)
  annunciator_write(1, 13, output)
  annunciator_write(1, 14, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/fuel/fuel_tank_pump_on",            "INT[8]",  
  "206B3/fuel/boost/fwd/br",                        "INT",  
  "206L3/fuel/boost/fwd/br",                        "INT",
  "sim/cockpit/engine/fuel_pump_on",                "INT[16]",  
  af_rfuel_boost
)

function af_rfuel_xfer(input)
  --assigned via rfuel_boost function
  --possibly sim/cockpit2/fuel_transfer[2]?
end

function af_fuel_valve(input1, input2, input3, input4, input5)
  if icao == "B407" then
    output = input1
  elseif icao == "206B3" then
    output = 1 - input2
  elseif icao == "206L3" then
    output = 1 - input3
  elseif icao == "J407" then
    output = input5
  else
    output = booltonum(input4 == 0)
  end
  annunciator_write(1, 15, output)
end
xpl_dataref_subscribe(
  "B407/FuelValveMoving",                           "FLOAT",  
  "206B3/fuel/valve",                               "FLOAT",  
  "206L3/fuel/valve",                               "FLOAT",  
  "sim/cockpit2/fuel/fuel_tank_selector",           "INT",
  "sim/cockpit2/fuel/firewall_closed_left",         "INT",
  af_fuel_valve
)

function af_fadec_fault(input)
  output = 0
  annunciator_write(1, 16, output)
end
--NYI

--========2========

function af_restart_fault(input)
  output = 0
  annunciator_write(2, 1, output)
end
--NYI

function af_fuel_low(input)
  output = input
  annunciator_write(2, 2, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/fuel_quantity",        "INT",
  af_fuel_low
)

function af_fadec_fail(input)
  output = booltonum(input == 6)
  annunciator_write(2, 3, output)
end
xpl_dataref_subscribe(
  "sim/operation/failures/rel_fadec_0",             "INT",
  af_fadec_fail
)

lowfps_counter = 0
function af_fadec_degraded(input)
  if input > 0.05 then
    lowfps_counter = lowfps_counter + 1
  else
    lowfps_counter = 0
  end
  output = booltonum(lowfps_counter > 20)
  annunciator_write(2, 4, output)
end
xpl_dataref_subscribe(
  "sim/time/framerate_period",                      "FLOAT",
  af_fadec_degraded
)

function af_manual_fadec(input1, input2)
  if icao == "B407" then
    output = 1 - input1
  else
    output = 1 - input2[1]
  end
  annunciator_write(2, 5, output)
end
xpl_dataref_subscribe(
  "B407/Fadec",                                     "FLOAT",
  "sim/cockpit2/engine/actuators/fadec_on",         "INT[8]",
  af_manual_fadec
)

function af_engine_chip(input1, input2, input3)
  if icao == "206B3" then
    output = input1
  elseif icao == "206L3" then
    output = input2
  else
    output = input3
  end
  annunciator_write(2, 6, output)
end
xpl_dataref_subscribe(
  "206B3/caut/ENG_chip",                            "INT",
  "206L3/caut/ENG_chip",                            "INT",
  "sim/cockpit2/annunciators/chip_detect",          "INT",
  af_engine_chip
)

function af_xmsn_chip(input1, input2)
  if icao == "206B3" then
    output = input1
  elseif icao == "206L3" then
    output = input2
  else
    output = 0 --no generic replacement
  end
  annunciator_write(2, 7, output)
end
xpl_dataref_subscribe(
  "206B3/caut/MR_chip",                             "INT",
  "206L3/caut/MR_chip",                             "INT",
  af_xmsn_chip
)

function af_tr_chip(input1, input2, input3)
  if icao == "206B3" then
    output = input1
  elseif icao == "206L3" then
    output = input2
  else
    output = booltonum(input3 == 6)
  end
  annunciator_write(2, 8, output)
end
xpl_dataref_subscribe(
  "206B3/caut/TR_chip",                             "INT",
  "206L3/caut/TR_chip",                             "INT",
  "sim/operation/failures/rel_trotor",              "INT",
  af_tr_chip
)

function af_gen_fail(input)
  output = input
  annunciator_write(2, 9, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/generator",            "INT",
  af_gen_fail
)

function af_xmsn_oil_press(input1, input2, input3)
  if icao == "B407" then
    output = booltonum(input1 < 3.3)
  elseif icao == "206B3" then
    output = input2
  elseif icao == "206L3" then
    output = input3
  else
    output = 0 --no generic replacement
  end
  annunciator_write(2, 10, output)
end
xpl_dataref_subscribe(
  "B407/Panel/XMsn_Oil_Psi",                        "FLOAT",
  "206B3/caut/x_oil_press",                         "INT",
  "206L3/caut/x_oil_press",                         "INT",
  af_xmsn_oil_press
)

function af_instr_check(input1, input2, input3, input4, input5, input6)
  if icao == "B407" then
    output = booltonum(
      ((input1 + input2 + input3) > 0)
      or
      (input4[1] > 12000)
      or
      (input5[1] > 920)
      or
      (input6[1] > 105)
    )
  else
    output = 0 --no generic replacement
  end
  annunciator_write(2, 11, output)
end
xpl_dataref_subscribe(
  "B407/Panel/Exceedance/MGT",                      "FLOAT",
  "B407/Panel/Exceedance/NG",                       "FLOAT",
  "B407/Panel/Exceedance/TRQ",                      "FLOAT",
  "sim/cockpit2/engine/indicators/torque_n_mtr",    "FLOAT[8]",
  "sim/cockpit2/engine/indicators/EGT_deg_C",       "FLOAT[8]",
  "sim/cockpit2/engine/indicators/N1_percent",      "FLOAT[8]",
  af_instr_check
)

function af_battery_rly(input)
  output = input
  annunciator_write(2, 12, output)
end
xpl_dataref_subscribe(
  "sim/cockpit/electrical/gpu_on",                  "INT",
  af_battery_rly
)

function af_xmsn_oil_temp(input1, input2, input3)
  if icao == "B407" then
    output = booltonum(input1 > 11)
  elseif icao == "206B3" then
    output = input2
  elseif icao == "206L3" then
    output = input3
  else
    output = 0 --no generic replacement
  end
  annunciator_write(2, 13, output)
end
xpl_dataref_subscribe(
  "B407/Panel/XMsn_Oil_C",                          "FLOAT",
  "206B3/caut/x_oil_temp",                          "INT",
  "206L3/caut/x_oil_temp",                          "INT",
  af_xmsn_oil_temp
)

function af_hyd_sys(input1, input2)
  if icao == "B407" then
    output = booltonum(input1 < 650)
  else
    output = input2
  end
  annunciator_write(2, 14, output)
end
xpl_dataref_subscribe(
  "sim/operation/failures/hydraulic_pressure_ratio","FLOAT",
  "sim/cockpit2/annunciators/hydraulic_pressure",   "INT",
  af_hyd_sys
)

--TODO: activate after certain time on
function af_battery_hot(input)
  output = input
  annunciator_write(2, 15, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/battery_charge_hi",    "INT",    --preheat condition, not actual temperature... close enough
  af_battery_hot
)

function af_engine_ovspd(input)
  output = booltonum(input[1] > 102.1)
  annunciator_write(2, 16, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/engine/indicators/N2_percent",              "FLOAT[8]",
  af_engine_ovspd
)

--========3========

function af_cyclic_centering(input1, input2, input3)
  if icao == "B407" then
    output = booltonum(
      (input3 == 1) and
      (math.abs(input1) > 0.042 or math.abs(input2) > 0.068)
    )
  else
    output = 0 --no generic replacement
  end
  annunciator_write(3, 1, output)
end
xpl_dataref_subscribe(
  "B407/Controls/Pitch",                            "FLOAT",
  "B407/Controls/Roll",                             "FLOAT",
  "sim/flightmodel/failures/onground_all",          "INT",
  af_cyclic_centering
)

--TODO: fix 407 acf for N1 low
function af_engine_out(input)
  output = booltonum(input[1] < 55)
  --output = input[1]
  annunciator_write(3, 2, output)
end
xpl_dataref_subscribe(
  "sim/flightmodel2/engines/N1_percent",         "FLOAT[8]",
  --"sim/cockpit2/annunciators/N1_low",               "INT[8]",
  af_engine_out
)

function af_pedal_stop(input)
  if icao == "B407" then
    output = booltonum(input == 0)
  else
    output = 0 --no generic replacement
  end
  annunciator_write(3, 3, output)
end
xpl_dataref_subscribe(
  "B407/PedalStop",                                 "FLOAT",  
  af_pedal_stop
)

--TODO: fix 407 acf for NR low
function af_rpm(input1, input2)
  if icao == "B407" then
    output = booltonum(input1[1] < 392 or input1[1] > 442)
  elseif icao == "206B3" then
    output = booltonum(input1[1] < 355)
  elseif icao == "206L3" then
    output = booltonum(input1[1] < 355)
  else
    output = input2
  end
  annunciator_write(3, 4, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/engine/indicators/prop_speed_rpm","FLOAT[8]",
  "sim/cockpit2/annunciators/low_rotor",                   "INT",
  af_rpm
)

function af_overhead_lights(input)
  output = booltonum(input[1] > 0)
  if input[1] == 1 then output = 0 end
  annunciator_write(3, 5, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/electrical/instrument_brightness_ratio_manual","FLOAT[32]", 
  af_overhead_lights
)

function af_ks_navgps(input1, input2)
  output = booltonum(input1 == 0 and input2 == 1)
  output2 = booltonum(input1 == 2 and input2 == 1)
  annunciator_write(3, 9, output)
  annunciator_write(3, 10, output2)
end
xpl_dataref_subscribe(
  "sim/cockpit2/radios/actuators/HSI_source_select_pilot", "INT",
  "sim/cockpit2/switches/avionics_power_on", "INT",
  af_ks_navgps
)

function af_ks_sason(input1, input2)
  output1 = booltonum(input2 == 1)
  output2 = booltonum(input1 >= 0.5 and input2 == 1)
  annunciator_write(3, 11, output1)
  annunciator_write(3, 12, output2)
end
xpl_dataref_subscribe(
  "Helisas/info/ANN_SAS", "FLOAT",
  "sim/cockpit2/switches/avionics_power_on", "INT",
  af_ks_sason
)

function af_ks_fadecautoman(input1)
  output1 = booltonum(input1 == 1)
  annunciator_write(3, 13, output1)
  annunciator_write(3, 14, 1 - output1)
end
xpl_dataref_subscribe(
  "B407/Fadec", "FLOAT",
  af_ks_fadecautoman
)

test_button = 0
bus_volts = 0
instr_brt = 1
dimmer = 1
brt_swt = 1

function update_annunciator_misc(a,b,c,d,e)   --TODO: Clean up
  test_button = a
  bus_volts = b[1]
  instr_brt = c[11]
  dimmer = math.max(d, 0.1)
  brt_swt = e[1]
end

previous_payload = {0,0,0,255}
standby_payload = {1,0,32,255}

function generate_payload()
  --Set brightness
  bus_volts_adjusted = math.min(1,math.max((bus_volts - 5) / 23, 0))
  annunciator_payload[4] = math.floor(bus_volts_adjusted * dimmer * brt_swt * 255)
  --if annunciator_payload[4] > 0 then annunciator_payload[4] = 255 end

  payload_final = table.clone(annunciator_payload)

  --Apply test button
  if test_button == 1 then
    payload_final[1] = payload_final[1] | 65535
    payload_final[2] = payload_final[2] | 65535
    payload_final[3] = payload_final[3] | 15
    --payload_final[4] = 255
  end
 

  if not array_compare(payload_final, previous_payload) then
  
    if hw_connected("ARDUINO_LEONARDO_A") then
      hw_message_port_send(hw_id, 0, "INT[4]", payload_final)
      print("payload out")
    end
  
    previous_payload = table.clone(payload_final)
  end

end

annun_reset = true
function check_xpl_connection()

  if not xpl_connected() and not fs2020_connected() then

    if hw_connected("ARDUINO_LEONARDO_A") then
      hw_message_port_send(hw_id, 0, "INT[4]", standby_payload)
      print("hardware connected, waiting for sim")

    else print("waiting on hardware") end
  
  else

    if hw_connected("ARDUINO_LEONARDO_A") then

      if annun_reset then
        annun_reset = false
        xpl_command("sim/annunciator/test_all_annunciators", 0)
      end

      hw_message_port_send(hw_id, 0, "INT[4]", payload_final)
      print("heartbeat")

    else
      print("sim connected, waiting on hardware")
      annun_reset = true
    end

  end
end

connection_timer = timer_start(0, 1000, check_xpl_connection)

xpl_dataref_subscribe(
  --annunciator test
    "sim/cockpit/warnings/annunciator_test_pressed",  "INT",

  --bus volts
    "sim/cockpit2/electrical/bus_volts",              "FLOAT[8]",

  --instr brt
    "sim/cockpit2/switches/instrument_brightness_ratio","FLOAT[32]",

  --dimmer pot
    "sim/cockpit/electrical/instrument_brightness","FLOAT",

  --dimmer switch
    "sim/cockpit2/switches/panel_brightness_ratio","FLOAT[4]",

  update_annunciator_misc
)

ENGOUT_horn = sound_add("b407ENGOUThorn.wav", 1)
NR_horn = sound_add("b407NRhorn.wav", 1)
function update_horns(engout_horn, hinr_horn, lonr_horn)
  if engout_horn == 1 then
    sound_loop(ENGOUT_horn)
  else
    sound_stop(ENGOUT_horn)
  end

  if (hinr_horn == 1) or (lonr_horn == 1) then
    sound_loop(NR_horn)
  else
    sound_stop(NR_horn)
  end
end
xpl_dataref_subscribe(
  "B407/EngOut_Horn",  "FLOAT",
  "B407/HiNR_Horn",  "FLOAT",
  "B407/LoNR_Horn",  "FLOAT",
  update_horns)
