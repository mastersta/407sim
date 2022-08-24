--407simV2 hardware communication instrument
--global variables
timer_delay = 10
 
icao = "" --initialize aircraft icao
function update_icao(input)
  icao = input
end
xpl_dataref_subscribe(
  "sim/aircraft/view/acf_ICAO", "STRING", update_icao)

function don_headset(input)
  don_headset = booltonum(input[1] > 40)
  if icao == "B407" then
    xpl_dataref_write("B407/HeadPhone", "FLOAT", don_headset, 0)
  end
end
xpl_dataref_subscribe(
  "sim/cockpit2/engine/indicators/N2_percent", "FLOAT[8]", don_headset)


--switches that are ON are 0 due to the pullups
function incoming_message_callback(id, payload)
  --print("payload in", payload)

  if id == 1 then
    update_switches(payload)
  end

  if id == 2 then
    update_encoders(payload)
  end

  if id == 3 then
    print("analog payload in: ", payload)

    output = 1 - math.max(0, math.min(1, (payload/1800)))
    if output == 0 then output = 1 end
    xpl_dataref_write(
      "sim/cockpit/electrical/instrument_brightness",
      "FLOAT",
      output,
      0)
  end

end --function end


hw_id = hw_message_port_add("ARDUINO_LEONARDO_A", incoming_message_callback)
