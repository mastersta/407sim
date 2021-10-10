--407simV2 hardware communication instrument
--global variables
timer_delay = 10
saved_switch_payload = {
  255,
  255,
  255,
  255,
  255,
  255
}




--switches that are ON are 0 due to the pullups
function incoming_message_callback(id, payload)

  if id == 1 then

    --iterate over the payload array
    for payload_index, value in ipairs(payload) do

      --check if the new bitfield is the same as the previous one
      if value != previous_payload_in[payload_index] then

        --grab each bit and call the appropriate function
        for bit_index = 1,8 in value do
          switch_value = bitread(value,bit_index)
          switch_table[payload_index..""][bit_index..""](switch_value)
        end

      end

    --store the payload value
    for index, value in ipairs(payload) do
      saved_switch_payload[index] = value
    end

  end

  if id == 2 then

    for index, value in ipairs(encoder_table) do

      difference = encoder_table[index].previous - payload[index]
      new_value = encoder_table[index].simvalue + (difference * encoder_table[index].increment)

      if difference ~= 0 then
        xpl_dataref_write(
          encoder_table[index].dataref,
          encoder_table[index].type,
          new_value
        )

        encoder_table[index].previous = payload[index]
      end
    end
  end

  if id == 3 then
    print("analog: " .. payload)

    output = 1 - math.max(0, math.min(1, (payload/1700)))
    xpl_dataref_write(
      --"sim/cockpit/electrical/instrument_brightness",
      "B407/Overhead/Swt_Instrument_Brt",
      "FLOAT",
      output,
      0)
  end

end --function end




encoder_table = {
  [1] = {
    ["simvalue"] = 29.92,
    ["dataref"] = "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",
    ["type"] = "FLOAT",
    ["increment"] = 0.01,
    ["previous"] = 0
  },
  [2] = {
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit/autopilot/heading",
    ["type"] = "FLOAT",
    ["increment"] = 1,
    ["previous"] = 0
  },
  [3] = {
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",
    ["type"] = "FLOAT",
    ["increment"] = 1,
    ["previous"] = 0
  }
}

function encoder_update(dataref1, dataref2, dataref3)
  encoder_table[1].simvalue = dataref1
  encoder_table[2].simvalue = dataref2
  encoder_table[3].simvalue = dataref3
end

hw_id = hw_message_port_add("ARDUINO_LEONARDO_A", incoming_message_callback)

xpl_dataref_subscribe(
  encoder_table[1].dataref, encoder_table[1].type,
  encoder_table[2].dataref, encoder_table[2].type,
  encoder_table[3].dataref, encoder_table[3].type,
  encoder_update
)
