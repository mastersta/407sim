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

    for index, value in ipairs(payload) do   

      difference = encoder_table[index].previous - value
      new_value = encoder_table[index].simvalue + (difference * encoder_table[index].increment)

      if difference != 0 then
        xpl_dataref_write(
          encoder_table[index].dataref,
          encoder_table[index].type,
          new_value
        )

        encoder_table[index].previous = value
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




encoder_table{
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

xpl_dataref_subscribe(
  encoder_table[1].dataref, encoder_table[1].value,
  encoder_table[2].dataref, encoder_table[2].value,
  encoder_table[3].dataref, encoder_table[3].value,
  encoder_update_callback
)


