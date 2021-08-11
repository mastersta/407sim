--helper functions
function numtobool(input)
  if input == 0 then return false
  else return true
  end
end

function booltonum(input)
  if input then return 1
  else return 0
  end
end

function bitread(value, bit)
  return ((value >> (bit - 1)) & 1)
end

function bitwrite(input, bit, write)
  if (write > 0) then
    return input | (1 << (bit - 1))
  else
    return input & ~(1 << (bit - 1))
  end
end

annunciator_payload = {}
annunciator_previous = {}

function annunciator_write(payload, bit, value)
  annunciator_payload[payload] = bitwrite(
    annunciator_payload[payload],
    bit,
    value
  )
end

--annunciator functions
function af_float_test(input)
  output = input
  annunciator_write(1, 1, output)
end
xpl_dataref_subscribe(
  "sim/test/test_float",                            "FLOAT",
  af_float_test
)

function af_engine_fire(input)
  output = input
  annunciator_write(1, 2, output)
end
xpl_dataref_subscribe(
  "sim/cockpit/warnings/annunciators/engine_fire",  "INT",  
  af_engine_fire
)

function af_engine_anti_ice(input)
  output = input
  annunciator_write(1, 3, output)
end
xpl_dataref_subscribe(
  "sim/cockpit/switches/anti_ice_inlet_heat",       "INT",  
  af_engine_anti_ice
)

function af_float_arm(input)
  output = input
  annunciator_write(1, 4, output)
end
xpl_dataref_subscribe(
  "B407/Float_Arm",                                 "FLOAT",  
  af_float_arm
)

function af_auto_relight(input)
  output = input
  annunciator_write(1, 5, output)
end
xpl_dataref_subscribe(
  "sim/cockpit/warnings/annunciators/auto_ignition","INT",  
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

function af_baggage_door(input)
  output = booltonum(input > 0.01)
  annunciator_write(1, 7, output)
end
xpl_dataref_subscribe(
  "B407/Baggage",                                   "FLOAT",
  af_baggage_door
)

function af_litter_door()
  output = 0
  annunciator_write(1, 8, output)
end
--NYI

function af_heater_overtemp()
  output = 0
  annunciator_write(1, 9, output)
end
--NYI

function af_lfuel_boost(input)
  output = booltonum(not(input[2]))
  annunciator_write(1, 10, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/fuel/fuel_tank_pump_on",            "INT[8]",  
  af_lfuel_boost
)

function af_lfuel_xfer(input)
  output = booltonum(not(input))
  annunciator_write(1, 11, output)
end
xpl_dataref_subscribe(
  "B407/Overhead/Swt_BoostXFR_Left",                "FLOAT",  
  af_lfuel_xfer
)

function af_fuel_filter(input)
  output = 0
  annunciator_write(1, 12, output)
end
--NYI

function af_rfuel_boost(input)
  output = input[2]
  annunciator_write(1, 13, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/fuel/fuel_tank_pump_on",            "INT[8]",  
  af_rfuel_boost
)

function af_rfuel_xfer(input)
  output = not(input)
  annunciator_write(1, 14, output)
end
xpl_dataref_subscribe(
  "B407/Overhead/Swt_BoostXFR_Right",               "FLOAT",  
  af_rfuel_xfer
)

function af_fuel_valve(input)
  output = input
  annunciator_write(1, 15, output)
end
xpl_dataref_subscribe(
  "B407/FuelValveMoving",                           "FLOAT",  
  af_fuel_valve
)

function af_restart_fault(input)
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

function af_fadec_degraded(input)
  output = 0
  annunciator_write(2, 4, output)
end
--NYI

function af_manual_fadec(input)
  output = not(input)
  annunciator_write(2, 5, output)
end
xpl_dataref_subscribe(
  "B407/Fadec",                                     "FLOAT",
  af_manual_fadec
)

function af_engine_chip(input)
  output = input
  annunciator_write(2, 6, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/annunciators/chip_detect",          "INT",
  af_engine_chip
)

function af_xmsn_chip(input)
  output = 0
  annunciator_write(2, 7, output)
end
--NYI

function af_tr_chip(input)
  output = booltonum(input == 6)
  annunciator_write(2, 8, output)
end
xpl_dataref_subscribe(
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

function af_xmsn_oil_press(input)
  output = booltonum(input < 3.3)
  annunciator_write(2, 10, output)
end
xpl_dataref_subscribe(
  "B407/Panel/XMsn_Oil_Psi",                        "FLOAT",
  af_xmsn_oil_press
)

function af_instr_check(input1, input2, input3)
  output = booltonum(
    input1 + input2 + input3 > 0
  )
  annunciator_write(2, 11, output)
end
xpl_dataref_subscribe(
  "B407/Panel/Exceedance/MGT",                      "FLOAT",
  "B407/Panel/Exceedance/NG",                       "FLOAT",
  "B407/Panel/Exceedance/TRQ",                      "FLOAT",
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

function af_xmsn_oil_temp(input)
  output = booltonum(input > 11)
  annunciator_write(2, 13, output)
end
xpl_dataref_subscribe(
  "B407/Panel/XMsn_Oil_C",                          "FLOAT",
  af_xmsn_oil_temp
)

function af_hyd_sys(input)
  output = booltonum(input < 650)
  annunciator_write(2, 14, output)
end
xpl_dataref_subscribe(
  "sim/operation/failures/hydraulic_pressure_ratio","FLOAT",
  af_hyd_sys
)

function af_battery_hot(input)
  output = 0
  annunciator_write(2, 15, output)
end
--NYI

function af_engine_ovspd(input)
  output = 0
  annunciator_write(2, 16, output)
end
--NYI

--========3========

function af_cyclic_centering(input1, input2, input3)
  output = booltonum(
    input1 and
    (math.abs(input2) > 0.042 or math.abs(input3) > 0.068)
  )
  annunciator_write(3, 1, output)
end
xpl_dataref_subscribe(
  "B407/Controls/Pitch",                            "FLOAT",
  "B407/Controls/Roll",                             "FLOAT",
  "sim/flightmodel/failures/onground_all",          "INT",
  af_cyclic_centering
)

function af_engine_out(input)
  output = booltonum(input[1] < 55)
  annunciator_write(3, 2, output)
end
xpl_dataref_subscribe(
  "sim/flightmodel2/engines/N1_percent",         "FLOAT[8]",
  af_engine_out
)

function af_pedal_stop(input)
  output = not(input)
  annunciator_write(3, 3, output)
end
xpl_dataref_subscribe(
  "B407/PedalStop",                                 "FLOAT",  
  af_pedal_stop
)

function af_rpm(input)
  output = booltonum(input[1] < 392 or input[1] > 442)
  annunciator_write(3, 4, output)
end
xpl_dataref_subscribe(
  "sim/cockpit2/engine/indicators/prop_speed_rpm","FLOAT[8]",
  af_rpm
)




function generate_payload(test_button, bus_volts, instr_brt)

  --Set brightness
  annunciator_payload[4] = math.floor(instr_brt[11] * 255)

  --Apply test button
  if test_button == 1 then
    annunciator_payload[1] = 65535
    annunciator_payload[2] = 65535
    annunciator_payload[3] = 15
  end

  if not array_compare(annunciator_payload, annunciator_previous) then
    if hw_connected("ARDUINO_LEONARDO_A") then
      hw_message_port_send(hw_id, 0, "INT[4]", annunciator_payload)
      annunciator_previous = annunciator_payload
    end
  end

end

xpl_dataref_subscribe(
  --annunciator test
    "sim/cockpit/warnings/annunciator_test_pressed",  "INT",

  --bus volts
    "sim/cockpit2/electrical/bus_volts",              "FLOAT[8]",

  --instr brt
    "sim/cockpit2/switches/instrument_brightness_ratio","FLOAT[32]", 

  generate_payload
)
