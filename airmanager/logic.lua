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
store_alt = 0
store_hdg = 0
store_obs = 0




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
    print(payload[1])
    --altimeter
    --sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot [FLOAT]
    altimeter_setting = 29.92 + (payload[1] * -0.01)
    xpl_dataref_write(
      "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",
      "FLOAT",
      altimeter_setting
    )

    --heading bug
    --sim/cockpit/autopilot/heading [?] [FLOAT]
    heading_setting = store_hdg + (payload[2] * -1)
    xpl_dataref_write(
      "sim/cockpit/autopilot/heading",
      "FLOAT",
      heading_setting
    )

    --OBS
    --sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot [FLOAT]
    obs_setting = math.floor(payload[3] * -1)
    xpl_dataref_write(
      "sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",
      "FLOAT",
      obs_setting
    )
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

encoder_init = false

function encoder_update_callback(alt, hdg, obs)
  if not(encoder_init) then
    store_alt = alt
    store_hdg = hdg
    store_obs = obs
    encoder_init = true
  end
end

hw_id = hw_message_port_add("ARDUINO_LEONARDO_A", incoming_message_callback)


xpl_dataref_subscribe(
  "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot", "FLOAT",
  "sim/cockpit/autopilot/heading", "FLOAT",
  "sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", "FLOAT",
  encoder_update_callback
)
