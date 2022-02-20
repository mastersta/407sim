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


--payload 1, panel1 low
function switch_fuelvalve(state)
  command0 = "sim/fuel/fuel_selector_all"
  command1 = "sim/fuel/fuel_selector_none"

  toggle_command(command0, command1, state)
end


function switch_annunciatortest(state)
  command = "sim/annunciator/test_all_annunciators"

  xpl_command(command, 1 - state)
end


function switch_hornmute(state)
  command = "B407/horn_mute"

  xpl_command(command, 1 - state)
end


function switch_instrumentcheck(state)
  command = "B407/instr_check"

  xpl_command(command, 1 - state)
end


function switch_lcdtest(state)
  command = "B407/lcd_test"

  xpl_command(command, 1 - state)
end


function switch_fuelquantity(state)
  command = "B407/fuelqty"

  xpl_command(command, 1 - state)
end


function switch_fadechorntest(state)
  command = "B407/fadec_horn"

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
  command = "B407/Clock/efc_select"
  print("oatv select")
  xpl_command(command, 1 - state)
end


function switch_clockselect(state)
  command = "B407/Clock/select"
  print("clock select")
  xpl_command(command, 1 - state)
end


function switch_clockcontrol(state)
  command = "B407/Clock/control"
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
  command = "RXP/GTN/HOME_2"
  print("gps 2 home")
  xpl_command(command, 1 - state)
end


function switch_gps2dto(state)
  command = "RXP/GTN/DTO_2"
  print("gps 2 direct-to")
  xpl_command(command, 1 - state)
end


function switch_gps2encpb(state)
  command = "RXP/GTN/FMS_PUSH_2"
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
  command0 = "B407/overhead/on/generator_1_reset"
  command1 = "B407/overhead/off/generator_1_off"

  toggle_command(command0, command1, state)
end


function switch_anticollisionlight(state)
  command0 = "B407/overhead/on/anticollision_lt"
  command1 = "B407/overhead/off/anticollision_lt"

  toggle_command(command0, command1, state)
end


function switch_hydraulics(state)
  command0 = "B407/overhead/on/hydr_sys"
  command1 = "B407/overhead/off/hydr_sys"

  toggle_command(command0, command1, state)
end


function switch_avionicsmaster(state)
  command0 = "B407/overhead/on/avionics_master"
  command1 = "B407/overhead/off/avionics_master"

  toggle_command(command0, command1, state)
end


function switch_engineantiice(state)
  command0 = "B407/overhead/on/eng_antiice"
  command1 = "B407/overhead/off/eng_antiice"

  toggle_command(command0, command1, state)
end


function switch_pitotheater(state)
  command0 = "B407/overhead/on/pitot_heater"
  command1 = "B407/overhead/off/pitot_heater"

  toggle_command(command0, command1, state)
end


--payload2, overhead1 high
function switch_positionlight(state)
  command0 = "B407/overhead/on/pos_lt"
  command1 = "B407/overhead/off/pos_lt"

  toggle_command(command0, command1, state)
end


function switch_cautionlightdim(state)
  output = (state / 2) + 0.5
  xpl_dataref_write(
    "sim/cockpit2/switches/panel_brightness_ratio", "FLOAT[4]",
    output, 0
  )
end


function switch_fuelpumpleft(state)
  command0 = "B407/overhead/on/boostxfr_left"
  command1 = "B407/overhead/off/boostxfr_left"

  toggle_command(command0, command1, state)
end


function switch_fuelpumpright(state)
  command0 = "B407/overhead/on/boostxfr_right"
  command1 = "B407/overhead/off/boostxfr_right"

  toggle_command(command0, command1, state)
end


function switch_instrumentdg(state)
  command0 = "B407/overhead/on/flightinstr_dg"
  command1 = "B407/overhead/off/flightinstr_dg"

  toggle_command(command0, command1, state)
end


function switch_instrumentatt(state)
  command0 = "B407/overhead/on/flightinstr_att"
  command1 = "B407/overhead/off/flightinstr_att"

  toggle_command(command0, command1, state)
end


function switch_instrumentturn(state)
  command0 = "B407/overhead/on/flightinstr_turn"
  command1 = "B407/overhead/off/flightinstr_turn"

  toggle_command(command0, command1, state)
end


function switch_2h8unused(state)
  print("unused input")
end


function cb_fuelvalve(state)
  dataref = "B407/CircuitBreaker/FUEL_VALVE"
  print("cb fuel valve")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_fuelqty(state)
  dataref = "B407/CircuitBreaker/FUEL_QTY"
  print("cb fuel qty")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_fuelpress(state)
  dataref = "B407/CircuitBreaker/FUEL_PRESS"
  print("cb fuel press")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_genreset(state)
  dataref = "B407/CircuitBreaker/GEN_RESET"
  print("cb gen reset")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_genfield(state)
  dataref = "B407/CircuitBreaker/GEN_FIELD"
  print("cb gen field")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_xmsnoiltemp(state)
  dataref = "B407/CircuitBreaker/XMSN_TEMP"
  print("cb xmsn oil temp")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_xmsnoilpress(state)
  dataref = "B407/CircuitBreaker/XMSN_PRESS"
  print("cb xmsn oil press")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_mgt(state)
  dataref = "B407/CircuitBreaker/ENG_MGT"
  print("cb mgt")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_trq(state)
  dataref = "B407/CircuitBreaker/ENG_TRQ"
  print("cb trq")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_ng(state)
  dataref = "B407/CircuitBreaker/ENG_NG"
  print("cb ng")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_np(state)
  dataref = "B407/CircuitBreaker/ENG_NP"
  print("cb np")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_nr(state)
  dataref = "B407/CircuitBreaker/ENG_NR"
  print("cb nr")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_engoiltemp(state)
  dataref = "B407/CircuitBreaker/ENG_TEMP"
  print("cb eng oil temp")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function cb_engoilpress(state)
  dataref = "B407/CircuitBreaker/ENG_PRESS"
  print("cb eng oil press")
  output = state
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
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
    switch_2h8unused
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
    switch_2h8unused,
    switch_2h8unused
  },
  [7] = {
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused
  },
  [8] = {
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused
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