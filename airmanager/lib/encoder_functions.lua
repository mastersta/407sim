encoder_type = "TYPE_2_DETENT_PER_PULSE"

--initialize aircraft icao, will be updated in logic script 
icao = ""


function gps1_inner(direction)
  print("gps1_inner  " .. direction)
  
  if icao == "B407" then
    if direction == 1 then    xpl_command("RXP/GTN/FMS_INNER_CW_1")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_1")
    end
    
  elseif icao == "206B3" then
    if direction == 1 then    xpl_command("sim/radios/stby_com1_fine_up")
    else                      xpl_command("sim/radios/stby_com1_fine_down")
    end
    
  elseif icao == "206L3" then
    if direction == 1 then    xpl_command("RXP/GTN/FMS_INNER_CW_1")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_1")
    end
    
  else
    if direction == 1 then    xpl_command("RXP/GTN/FMS_INNER_CW_2")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_2")
    end
    
  end
end

dial_gps1_inner = hw_dial_add("GPS1 INNER", encoder_type, 1, gps1_inner) 


function gps1_outer(direction)
  print("gps1_outer  " .. direction)
  
  if icao == "B407" then
    if direction == -1 then   xpl_command("RXP/GTN/FMS_OUTER_CW_1")
    else                      xpl_command("RXP/GTN/FMS_OUTER_CCW_1")
    end
    
  elseif icao == "206B3" then
    if direction == -1 then   xpl_command("sim/radios/stby_com1_coarse_up")
    else                      xpl_command("sim/radios/stby_com1_coarse_down")
    end
    
  elseif icao == "206L3" then
    if direction == -1 then   xpl_command("RXP/GTN/FMS_INNER_CW_1")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_1")
    end
    
  else
    if direction == -1 then   xpl_command("RXP/GTN/FMS_INNER_CW_2")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_2")
    end
    
  end
end

dial_gps1_outer = hw_dial_add("GPS1 OUTER", encoder_type, 1, gps1_outer) 


function gps1_vol(direction)
  print("gps1_vol  " .. direction)
  
  if direction == -1 then     xpl_command("RXP/GTN/VOL_CW_1")
  else                        xpl_command("RXP/GTN/VOL_CCW_1")
  end
end

dial_gps1_vol = hw_dial_add("GPS1 VOL", encoder_type, 4, gps1_vol) 


function gps2_inner(direction)
  print("gps2_inner  " .. direction)
  
  if icao == "B407" then
    if direction == -1 then   xpl_command("RXP/GTN/FMS_INNER_CW_2")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_2")
    end
    
  elseif icao == "206B3" then
    if direction == -1 then   xpl_command("RXP/GTN/FMS_INNER_CW_2")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_2")
    end
    
  elseif icao == "206L3" then
    if direction == -1 then   xpl_command("sim/radios/stby_com2_fine_up")
    else                      xpl_command("sim/radios/stby_com2_fine_down")
    end
    
  else
    if direction == -1 then   xpl_command("RXP/GTN/FMS_INNER_CW_2")
    else                      xpl_command("RXP/GTN/FMS_INNER_CCW_2")
    end
    
  end
end

dial_gps2_inner = hw_dial_add("GPS2 INNER", encoder_type, 1, gps2_inner) 


function gps2_outer(direction)
  print("gps2_outer  " .. direction)
  
  if icao == "B407" then
    if direction == 1 then   xpl_command("RXP/GTN/FMS_OUTER_CW_2")
    else                     xpl_command("RXP/GTN/FMS_OUTER_CCW_2")
    end
    
  elseif icao == "206B3" then
    if direction == 1 then   xpl_command("RXP/GTN/FMS_OUTER_CW_2")
    else                     xpl_command("RXP/GTN/FMS_OUTER_CCW_2")
    end
    
  elseif icao == "206L3" then
    if direction == 1 then   xpl_command("sim/radios/stby_com2_coarse_up")
    else                     xpl_command("sim/radios/stby_com2_coarse_down")
    end
    
  else
    if direction == 1 then   xpl_command("RXP/GTN/FMS_OUTER_CW_2")
    else                     xpl_command("RXP/GTN/FMS_OUTER_CCW_2")
    end
    
  end
end

dial_gps2_outer = hw_dial_add("GPS2 OUTER", encoder_type, 1, gps2_outer) 


function gps2_vol(direction)
  print("gps2_vol  " .. direction)
  if direction == -1 then    xpl_command("RXP/GTN/VOL_CW_2")
  else                       xpl_command("RXP/GTN/VOL_CCW_2")
  end
end

dial_gps2_vol = hw_dial_add("GPS2 VOL", encoder_type, 4, gps2_vol) 


function alt_adj(direction)
  print("alt  " .. direction)
  if direction == 1 then     xpl_command("sim/instruments/barometer_up")
  else                       xpl_command("sim/instruments/barometer_down")
  end
end

dial_alt_adj = hw_dial_add("ALT ADJ", encoder_type, 1, alt_adj) 


function hdg_bug(direction)
  print("hdg  " .. direction)
  if direction == 1 then     xpl_command("sim/autopilot/heading_up")
  else                       xpl_command("sim/autopilot/heading_down")
  end
end

dial_hdg_bug = hw_dial_add("HDG BUG", encoder_type, 2, hdg_bug) 


function obs_adj(direction)
  print("obs  " .. direction)

  if icao == "B407" then
    if direction == 1 then   xpl_command("sim/radios/obs1_up")
    else                     xpl_command("sim/radios/obs1_down")
    end
    
  elseif icao == "206B3" then
    if direction == 1 then   xpl_command("sim/instruments/DG_sync_up")
    else                     xpl_command("sim/instruments/DG_sync_down")
    end
    
  elseif icao == "206L3" then
    if direction == 1 then   xpl_command("sim/instruments/DG_sync_up")
    else                     xpl_command("sim/instruments/DG_sync_down")
    end
    
  else
    if direction == 1 then   xpl_command("sim/radios/obs1_up")
    else                     xpl_command("sim/radios/obs1_down")
    end
  end
end

dial_obs_adj = hw_dial_add("OBS ADJ", encoder_type, 2, obs_adj) 

