encoder_type = "TYPE_1_DETENT_PER_PULSE"

function gps1_inner(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/FMS_INNER_CW_1")
  else
    xpl_command("RXP/GTN/FMS_INNER_CCW_1")
  end
end

dial_gps1_inner = hw_dial_add("GPS1 INNER", encoder_type, 2, gps1_inner) 

function gps1_outer(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/FMS_OUTER_CW_1")
  else
    xpl_command("RXP/GTN/FMS_OUTER_CCW_1")
  end
end

dial_gps1_outer = hw_dial_add("GPS1 OUTER", encoder_type, 2, gps1_outer) 

function gps1_vol(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/VOL_CW_1")
  else
    xpl_command("RXP/GTN/VOL_CCW_1")
  end
end

dial_gps1_vol = hw_dial_add("GPS1 VOL", encoder_type, 2, gps1_vol) 

function gps2_inner(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/FMS_INNER_CW_2")
  else
    xpl_command("RXP/GTN/FMS_INNER_CCW_2")
  end
end

dial_gps2_inner = hw_dial_add("GPS2 INNER", encoder_type, 2, gps2_inner) 

function gps2_outer(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/FMS_OUTER_CW_2")
  else
    xpl_command("RXP/GTN/FMS_OUTER_CCW_2")
  end
end

dial_gps2_outer = hw_dial_add("GPS2 OUTER", encoder_type, 2, gps2_outer) 

function gps2_vol(direction)
  if direction == 1 then
    xpl_command("RXP/GTN/VOL_CW_2")
  else
    xpl_command("RXP/GTN/VOL_CCW_2")
  end
end

dial_gps2_vol = hw_dial_add("GPS2 VOL", encoder_type, 2, gps2_vol) 

function alt_adj(direction)
  if direction == 1 then
    xpl_command("sim/instruments/barometer_up")
  else
    xpl_command("sim/instruments/barometer_down")
  end
end

dial_alt_adj = hw_dial_add("ALT ADJ", encoder_type, 2, alt_adj) 

function hdg_bug(direction)
  if direction == 1 then
    xpl_command("sim/autopilot/heading_up")
  else
    xpl_command("sim/autopilot/heading_down")
  end
end

dial_hdg_bug = hw_dial_add("HDG BUG", encoder_type, 2, hdg_bug) 

function obs_adj(direction)
  if direction == 1 then
    xpl_command("sim/radios/obs1_up")
  else
    xpl_command("sim/radios/obs1_down")
  end
end

dial_obs_adj = hw_dial_add("OBS ADJ", encoder_type, 2, obs_adj) 

