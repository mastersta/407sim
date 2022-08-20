--create nested array in logic.lua containing references to switch functions, which will be located in this file
--switch functions will be organized based on payload, payload array index, and input index
--switch functions named after hardware switch, alternate aircraft will keep these function names and only alter the logic within
--logic.lua will iterate over the payload, look for changes, and then call the correct function

function update_switches(payload)
  --print("switch payload in: ", payload)

  --iterate over the payload array
  for payload_index, value in ipairs(payload) do

    --check if the new bitfield is the same as the previous one
    if value ~= saved_switch_payload[payload_index] then

      --grab each bit and call the appropriate function
      for bit_index = 1,8 do

        switch_value = bitread(value,bit_index)
        previous_switch_value = bitread(saved_switch_payload[payload_index],bit_index)

        if switch_value ~= previous_switch_value then
          switch_table[payload_index][bit_index](switch_value)
          print("board #" .. payload_index .. " switch #" .. bit_index)
        end --if

      end --for
    end --if
  end --for

    --store the payload value
  for index, value in ipairs(payload) do
    saved_switch_payload[index] = value
  end --for

end --function

function toggle_command(command0, command1, state)
  command = (state == 0 and command0 or command1) --ternary

  xpl_command(command, 1)
  xpl_command(command, 0)
end

--initialize aircraft icao code, will get updated in logic script
icao = ""


--payload 1, panel1 low
function switch_fuelvalve(state)
  if icao == "B06" then
    output = 1 - state
    dataref = "206B3/fuel/valve"
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    command0 = "sim/fuel/fuel_selector_all"
    command1 = "sim/fuel/fuel_selector_none"
    toggle_command(command0, command1, state)
  end
end


function switch_annunciatortest(state)
  if icao == "B06" then
    command = "206B3/Buttons/cauttest_cmd"
  else
    command = "sim/annunciator/test_all_annunciators"
  end

  xpl_command(command, 1 - state)
end


function switch_hornmute(state)
  if icao == "B06" then
    command = "206B3/Buttons/mutehorn_cmd"
  else if icao == "B407" then
    command = "B407/horn_mute"
  else
    command = ""
  end
  --TODO: determine default

  xpl_command(command, 1 - state)
end


function switch_instrumentcheck(state)
  if icao == "B407" then
    command = "B407/instr_check"
  else
    command = ""
  end
  --TODO: determine default

  xpl_command(command, 1 - state)
end


function switch_lcdtest(state)
  if icao == "B407" then
    command = "B407/lcd_test"
  else
    command = ""
  end
  --TODO: determine default

  xpl_command(command, 1 - state)
end


function switch_fuelquantity(state)
  if icao == "B407" then
    command = "B407/fuelqty"
  else
    command = ""
  end
  --TODO: determine default

  xpl_command(command, 1 - state)
end


function switch_fadechorntest(state)
  if icao == "B407" then
    command = "B407/fadec_horn"
  else
    command = ""
  end
  --TODO: determine default

  xpl_command(command, 1 - state)
end


function switch_overspeedtest(state)
end


--payload 1, panel1 high
function switch_cdi(state)
--  command = "sim/GPS/g430n1_cdi"
  print("cdiselect")
--  xpl_command(command, 1 - state)
end


function switch_fadec(state)
--  command = "B407/systems/toggle/Fadec"
  print("fadectoggle")
--  xpl_command(command, 1 - state)
end


function switch_pedalstop(state)
  print("pedalstop")
end


function switch_oatvselect(state)
  if icao == "B407" then
    command = "B407/Clock/efc_select"
  else
    command = ""
  end
  --TODO: determine default

  print("oatv select")
  xpl_command(command, 1 - state)
end


function switch_clockselect(state)
  if icao == "B407" then
    command = "B407/Clock/select"
  else
    command = "sim/instruments/timer_mode"
    --TODO: test this
  end

  print("clock select")
  xpl_command(command, 1 - state)
end


function switch_clockcontrol(state)
  if icao == "B407" then
    command = "B407/Clock/control"
  else
    command = "sim/instruments/timer_cycle"
    --TODO: test this
  end

  print("clock control")
  xpl_command(command, 1 - state)
end


function switch_gps1home(state)
  command = "RXP/GTN/HOME_1"
  print("gps 1 home")
  xpl_command(command, 1 - state)
end


function switch_gps1dto(state)
  command = "RXP/GTN/DTO_1"
  print("gps 1 direct-to")
  xpl_command(command, 1 - state)
end


function switch_gps1encpb(state)
  command = "RXP/GTN/FMS_PUSH_1"
  print("gps 1 encoder pb")
  xpl_command(command, 1 - state)
end


function switch_gps2home(state)
  if icao == "B407" then
    command = "RXP/GTN/HOME_2"
  else
    command = ""
  end
  --TODO: determine default

  print("gps 2 home")
  xpl_command(command, 1 - state)
end


function switch_gps2dto(state)
  if icao == "B407" then
    command = "RXP/GTN/DTO_2"
  else
    command = "sim/radios/com2_standy_flip"
  end

  print("gps 2 direct-to")
  xpl_command(command, 1 - state)
end


function switch_gps2encpb(state)
  if icao == "B407" then
    command = "RXP/GTN/FMS_PUSH_2"
  else
    command = ""
  end
  --TODO: determine default

  print("gps 2 encoder pb")
  xpl_command(command, 1 - state)
end


--payload1, overhead1 low
function switch_battery(state)
  command0 = "sim/electrical/battery_1_on"
  command1 = "sim/electrical/battery_1_off"

  toggle_command(command0, command1, state)
end


function switch_generator(state)
  command0 = "sim/electrical/generator_1_on"
  command1 = "sim/electrical/generator_1_off"

  toggle_command(command0, command1, state)
end


function switch_generatorreset(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/generator_1_reset"
    command1 = "B407/overhead/off/generator_1_off"
    toggle_command(command0, command1, state)
  else
    dataref = "sim/operation/failures/relgenera0"
    xpl_dataref_write(dataref, "INT", 6 - state, 0)
    --TODO: test this default
  end
end


function switch_anticollisionlight(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/anticollision_lt"
    command1 = "B407/overhead/off/anticollision_lt"
  else
    command0 = "sim/lights/beacon_lights_on"
    command1 = "sim/lights/beacon_lights_off"
  end

  toggle_command(command0, command1, state)
end


function switch_hydraulics(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/hydr_sys"
    command1 = "B407/overhead/off/hydr_sys"
    toggle_command(command0, command1, state)
  else if icao == "B06" then
    dataref = "206B3/hydraulics/onoff"
    xpl_dataref_write(dataref, "INT", 1 - state, 0)
  else
    command0 = "sim/electrical/generator_1_on"
    command1 = "sim/electrical/generator_1_off"
    toggle_command(command0, command1, state)
  end
end


function switch_avionicsmaster(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/avionics_master"
    command1 = "B407/overhead/off/avionics_master"
  else
    command0 = "sim/systems/avionics_on"
    command1 = "sim/systems/avionics_off"
  end

  toggle_command(command0, command1, state)
end


function switch_engineantiice(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/eng_antiice"
    command1 = "B407/overhead/off/eng_antiice"
  else
    command0 = "sim/ice/inlet_eai0_on"
    command1 = "sim/ice/inlet_eai0_off"
    --TODO: test with bell 206
  end

  toggle_command(command0, command1, state)
end


function switch_pitotheater(state)
  command0 = "sim/ice/pitot_heat0_on"
  command1 = "sim/ice/pitot_heat0_off"

  toggle_command(command0, command1, state)
end


--payload2, overhead1 high
function switch_positionlight(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/pos_lt"
    command1 = "B407/overhead/off/pos_lt"
  else
    command0 = "sim/lights/nav_lights_on"
    command1 = "sim/lights/nav_lights_off"
  end

  toggle_command(command0, command1, state)
end


function switch_cautionlightdim(state)
  output = (state / 2) + 0.5
  xpl_dataref_write("sim/cockpit2/switches/panel_brightness_ratio", "FLOAT[4]", output, 0)
end


function switch_fuelpumpleft(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/boostxfr_left"
    command1 = "B407/overhead/off/boostxfr_left"
    toggle_command(command0, command1, state)
  else if icao == "B06" then
    dataref = "206B3/fuel/boost/aft/br"
    xpl_dataref_write(dataref, "INT", state, 0)
  else
    command0 = "sim/fuel/fuel_tank_pump_1_on"
    command1 = "sim/fuel/fuel_tank_pump_1_off"
    toggle_command(command0, command1, state)
    command0 = "sim/fuel/left_xfr_on"
    command1 = "sim/fuel/left_xfr_off"
    toggle_command(command0, command1, state)
  end
end


function switch_fuelpumpright(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/boostxfr_right"
    command1 = "B407/overhead/off/boostxfr_right"
    toggle_command(command0, command1, state)
  else if icao == "B06" then
    dataref = "206B3/fuel/boost/fwd/br"
    xpl_dataref_write(dataref, "INT", state, 0)
  else
    command0 = "sim/fuel/fuel_tank_pump_2_on"
    command1 = "sim/fuel/fuel_tank_pump_2_off"
    toggle_command(command0, command1, state)
    command0 = "sim/fuel/right_xfr_on"
    command1 = "sim/fuel/right_xfr_off"
    toggle_command(command0, command1, state)
  end
end


function switch_instrumentdg(state)
  if icao == "B06" then
    dataref = "206B3/dg_att"
    output = 1 - state
  else
    dataref = "sim/operation/failures/rel_ss_dgy"
    output = state * 6
  end

  print("sw dg")
  xpl_dataref_write(dataref, "INT", output, 0)
end


function switch_instrumentatt(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/flightinstr_att"
    command1 = "B407/overhead/off/flightinstr_att"
    toggle_command(command0, command1, state)
  else
    dataref = "sim/operation/failures/rel_ss_ahz"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("sw att")
end


function switch_instrumentturn(state)
  if icao == "B407" then
    command0 = "B407/overhead/on/flightinstr_turn"
    command1 = "B407/overhead/off/flightinstr_turn"
    toggle_command(command0, command1, state)
  else
    dataref = "sim/operation/failures/rel_ss_tsi"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("sw turncoord")
end


function cb_fuelvalve(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/FUEL_VALVE"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  end

  print("cb fuel valve")
end


function cb_fuelqty(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/FUEL_QTY"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_fuel"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb fuel qty")
end


function cb_fuelpress(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/FUEL_PRESS"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_fp_ind_0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb fuel press")
end


function cb_genreset(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/GEN_RESET"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    --no generic alternative
  end
  
  print("cb gen reset")
end


function cb_genfield(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/GEN_FIELD"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_genera0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb gen field")
end


function cb_xmsnoiltemp(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/XMSN_TEMP"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    --no generic alternative
  end

  print("cb xmsn oil temp")
end


function cb_xmsnoilpress(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/XMSN_PRESS"
    output = state
    xpl_dataref_write( dataref, "FLOAT", output, 0)
  else
    --no generic alternative
  end

  print("cb xmsn oil press")
end


function cb_mgt(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_MGT"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_egt1"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb mgt")
end


function cb_trq(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_TRQ"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_TRQind0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb trq")
end


function cb_ng(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_NG"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_N1_ind0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb ng")
end


function cb_np(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_NP"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_N2_ind0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb np")
end


function cb_nr(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_NR"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_rpm1"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb nr")
end


function cb_engoiltemp(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_TEMP"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_oilt1"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb eng oil temp")
end


function cb_engoilpress(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ENG_PRESS"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_oilp1"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb eng oil press")
end

--breaker panel 2 start

function cb_antiice(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/ANTI_ICE"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_ice_inlet_heat"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb anti ice")
end


function cb_start(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/START"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_startr0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb start")
end


function cb_igntr(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/IGNITER"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_ignitr0"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb igntr")
end


function cb_fadec(state)
  dataref = "sim/operation/failures/rel_fadec_0"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb fadec")
end


function cb_hydsys(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/HYD_SYS"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_hydpmp"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb hyd sys")
end


function cb_pedalstop(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/PEDAL_STOP"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    --no generic alternative
  end
  print("cb pedal stop")
end


function cb_ldglightspwr(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/LIGHT_PWR"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_lites_land"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
    dataref = "sim/operation/failures/rel_lites_taxi"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb ldg lights pwr")
end


function cb_ldglightscont(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/LIGHT_CONT"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    --TODO: implement timer based landing light flash
  end

  print("cb ldg lights cont")
end


function cb_instrlights(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/LIGHT_INST"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_lites_ins"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb instr lights")
end


function cb_oatv(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/OAT_V"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_lites_ins"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb oatv")
end


function cb_amps(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/AMPS"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    dataref = "sim/operation/failures/rel_g_gen1"
    output = state * 6
    xpl_dataref_write(dataref, "INT", output, 0)
  end

  print("cb amps")
end


function cb_navcom1(state)
  dataref = "sim/operation/failures/rel_navcom1"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb navcom1")
end


function cb_com2(state)
  dataref = "sim/operation/failures/rel_navcom2"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb com2")
end


function cb_xpdr(state)
  dataref = "sim/operation/failures/rel_xpndr"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb xpdr")
end


function cb_gps1(state)
  dataref = "sim/operation/failures/rel_gps"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb gps1")
end


function cb_gps2(state)
  dataref = "sim/operation/failures/rel_gps2"
  output = (1 - state) * 6
  xpl_dataref_write(dataref, "INT", output, 0)

  print("cb gps2")
end


function cb_radaralt(state)
  if icao == "B407" then
    dataref = "B407/CircuitBreaker/RADAR_ALT"
    output = state
    xpl_dataref_write(dataref, "FLOAT", output, 0)
  else
    --no generic replacement
  end

  print("cb radar alt")
end


function switch_unused(state)
  print("unused input")
end




switch_table = {
  [1] = {
    switch_clockselect,
    switch_clockcontrol,
    switch_gps1home,
    switch_gps1dto,
    switch_gps1encpb,
    switch_gps2home,
    switch_gps2dto,
    switch_gps2encpb
  },
  [2] = {
    switch_fuelvalve,
    switch_annunciatortest,
    switch_hornmute,
    switch_instrumentcheck,
    switch_lcdtest,
    switch_fuelquantity,
    switch_fadechorntest,
    switch_oatvselect,
  },
  [3] = {
    switch_battery,
    switch_generator,
    switch_generatorreset,
    switch_anticollisionlight,
    switch_hydraulics,
    switch_avionicsmaster,
    switch_engineantiice,
    switch_pitotheater
  },
  [4] = {
    switch_positionlight,
    switch_cautionlightdim,
    switch_fuelpumpleft,
    switch_fuelpumpright,
    switch_instrumentdg,
    switch_instrumentatt,
    switch_instrumentturn,
    switch_unused
  },
  [5] = {
    cb_fuelvalve,
    cb_fuelqty,
    cb_fuelpress,
    cb_genreset,
    cb_genfield,
    cb_xmsnoiltemp,
    cb_xmsnoilpress,
    cb_mgt
  },
  [6] = {
    cb_trq,
    cb_ng,
    cb_np,
    cb_nr,
    cb_engoiltemp,
    cb_engoilpress,
    cb_antiice,
    cb_start
  },
  [7] = {
    cb_oatv,
    cb_instrlights,
    cb_ldglightscont,
    cb_ldglightspwr,
    cb_pedalstop,
    cb_hydsys,
    cb_fadec,
    cb_igntr
  },
  [8] = {
    cb_amps,
    cb_navcom1,
    cb_com2,
    cb_xpdr,
    cb_gps1,
    cb_gps2,
    cb_radaralt,
    switch_unused
  }
}


saved_switch_payload = {
  255,
  255,
  255,
  255,
  255,
  255,
  255,
  255
}
