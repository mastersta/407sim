--407simV2 hardware communication instrument
--global variables
timer_delay = 10



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
