--407simV2 hardware communication instrument
--global variables
timer_delay = 10
previous_payload_in = {
  255,
  255,
  255,
  255,
  255,
  255
}
command_table = static_data_load("command_table.json")
store_alt = 0
store_hdg = 0
store_obs = 0

--helper functions
--function array_compare(array1, array2)
--  for i,v in pairs(array1) do
--    if v ~= array2[i] then
--      return false
--    end
--  end
--  return true
--end

--compare each payload to previous iteration; if a bit is different than its previous iteration,
--run the approprate command through a timer depending on which direction it changed as
--switches that are ON are 0 due to the pullups
function incoming_message_callback(id, payload)

  if id == 1 then
    
    --iterate over payloads
    for iter_payload, val_payload in ipairs(payload) do

      --iterate over inputs
      for i = 1, 8 do
        local current_value = bitread(payload[iter_payload], i)
        local previous_value = bitread(previous_payload_in[iter_payload], i)
        if command_table[iter_payload .. ""][i .. ""]["type"] == "momentary" then
        
          if current_value ~= previous_value then

            xpl_command(
              command_table[iter_payload .. ""][i .. ""][0 .. ""],
              1 - current_value
            )
            print("momentary - " .. iter_payload .. ":" .. i)

          end

        elseif command_table[iter_payload .. ""][i .. ""]["type"] == "toggle" then

        --if input is different than previous
          if current_value ~= previous_value then

          --use input value as index, check if "dataref" = nil
            if command_table[iter_payload .. ""][i .. ""][current_value .. ""]["dataref"] ~= nil then

            --if not, write "dataref" with "value"
              xpl_dataref_write(
                command_table[iter_payload .. ""][i .. ""][current_value .. ""]["dataref"],
                command_table[iter_payload .. ""][i .. ""][current_value .. ""]["type"],
                command_table[iter_payload .. ""][i .. ""][current_value .. ""]["value"]
              )
              print("toggle dataref - " .. iter_payload .. ":" .. i)

          --if is, send command with timer to end command
            else
          

              xpl_command(
                command_table[iter_payload .. ""][i .. ""][current_value .. ""],
                1
              )
              print("toggle command - " .. iter_payload .. ":" .. i)

              function timer_callback()
                xpl_command(
                  command_table[iter_payload .. ""][i .. ""][current_value .. ""],
                  0
                )
              end

              timer_start(
                timer_delay,
                timer_callback
              )
            end
          end
        end
      end
    end

    --assign most recent payload to previous payload
    for index, value in ipairs(payload) do
      previous_payload_in[index] = payload[index]
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