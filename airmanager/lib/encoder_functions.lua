function update_encoders(payload)
  print("encoder payload in: ", payload)

  for index, value in ipairs(encoder_table) do

    difference = encoder_table[index].previous - payload[index]
    new_value = encoder_table[index].simvalue + (difference * encoder_table[index].increment)

    if difference ~= 0 then
    
      if encoder_table[index].commandup == nil then
        xpl_dataref_write(
          encoder_table[index].dataref,
          encoder_table[index].type,
          new_value
        )
      else
        if difference > 0 then
          print("commanddown")
          xpl_command(encoder_table[index].commanddown, 1)
          xpl_command(encoder_table[index].commanddown, 0)
        end
        if difference < 0 then
          print("commandup")
          xpl_command(encoder_table[index].commandup, 1)
          xpl_command(encoder_table[index].commandup, 0)
        end
      end

      encoder_table[index].previous = payload[index]

    end
  end
end

function store_encoders(dataref1, dataref2, dataref3, dataref4,
                        dataref5, dataref6, dataref7, dataref8)
  encoder_table[1].simvalue = dataref1
  encoder_table[2].simvalue = dataref2
  encoder_table[3].simvalue = dataref3
  encoder_table[4].simvalue = dataref4
  encoder_table[5].simvalue = dataref5
  encoder_table[6].simvalue = dataref6
  encoder_table[7].simvalue = dataref7
  encoder_table[8].simvalue = dataref8
end


encoder_table = {
  [1] = {  --gps2 vol
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit2/radios/actuators/audio_volume_com2",
    ["commandup"] = "RXP/GTN/VOL_CCW_2",
    ["commanddown"] = "RXP/GTN/VOL_CW_2",
    ["type"] = "INT",
    ["increment"] = -100,
    ["previous"] = 0
  },
  [2] = {  --gps2 outer
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit/radios/com2_stdby_freq_hz",
    ["commandup"] = "RXP/GTN/FMS_OUTER_CW_2",
    ["commanddown"] = "RXP/GTN/FMS_OUTER_CCW_2",
    ["type"] = "INT",
    ["increment"] = -100,
    ["previous"] = 0
  },
  [3] = {  --gps2 inner
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit/radios/com2_stdby_freq_hz",
    ["commandup"] = "RXP/GTN/FMS_INNER_CCW_2",
    ["commanddown"] = "RXP/GTN/FMS_INNER_CW_2",
    ["type"] = "INT",
    ["increment"] = 2,
    ["previous"] = 0
  },
  [4] = {  --gps1 vol
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit2/radios/actuators/audio_volume_com1",
    ["commandup"] = "RXP/GTN/VOL_CW_1",
    ["commanddown"] = "RXP/GTN/VOL_CCW_1",
    ["type"] = "FLOAT",
    ["increment"] = -0.02,
    ["previous"] = 0
  },
  [5] = {  --baro
    ["simvalue"] = 29.92,
    ["dataref"] = "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",
    ["type"] = "FLOAT",
    ["increment"] = 0.01,
    ["previous"] = 0
  },
  [6] = {  --crs
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",
    ["type"] = "FLOAT",
    ["increment"] = 1,
    ["previous"] = 0
  },
  [7] = {  --gps1 inner
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit/radios/com1_stdby_freq_hz",
    ["commandup"] = "RXP/GTN/FMS_INNER_CCW_1",
    ["commanddown"] = "RXP/GTN/FMS_INNER_CW_1",
    ["type"] = "INT",
    ["increment"] = 2,
    ["previous"] = 0
  },
  [8] = {  --gps1 outer
    ["simvalue"] = 0,
    ["dataref"] = "sim/cockpit/radios/com1_stdby_freq_hz",
    ["commandup"] = "RXP/GTN/FMS_OUTER_CW_1",
    ["commanddown"] = "RXP/GTN/FMS_OUTER_CCW_1",
    ["type"] = "INT",
    ["increment"] = -100,
    ["previous"] = 0
  }
}


xpl_dataref_subscribe(
  encoder_table[1].dataref, encoder_table[1].type,
  encoder_table[2].dataref, encoder_table[2].type,
  encoder_table[3].dataref, encoder_table[3].type,
  encoder_table[4].dataref, encoder_table[4].type,
  encoder_table[5].dataref, encoder_table[5].type,
  encoder_table[6].dataref, encoder_table[6].type,
  encoder_table[7].dataref, encoder_table[7].type,
  encoder_table[8].dataref, encoder_table[8].type,
  store_encoders
)