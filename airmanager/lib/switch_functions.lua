--create nested array in logic.lua containing references to switch functions, which will be located in this file
--switch functions will be organized based on payload, payload array index, and input index
--switch functions named after hardware switch, alternate aircraft will keep these function names and only alter the logic within
--logic.lua will iterate over the payload, look for changes, and then call the correct function



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

headset_state = 0
function switch_overspeedtest(state)
  if state == 1 then headset_state = 1 - headset_state end
  print("heaset", headset_state)
  xpl_dataref_write(
    "B407/HeadPhone", "FLOAT",
    headset_state, 0
  )
end


--payload 1, panel1 high
function switch_cdi(state)
  command = "sim/GPS/g430n1_cdi"

  xpl_command(command, 1 - state)
end


function switch_fadec(state)
  command = "B407/systems/toggle/Fadec"

  xpl_command(command, 1 - state)
end


function switch_pedalstop(state)
end


function switch_oatvselect(state)
  command = "B407/Clock/efc_select"

  xpl_command(command, 1 - state)
end


function switch_clockselect(state)
  command = "B407/Clock/select"

  xpl_command(command, 1 - state)
end


function switch_clockcontrol(state)
  command = "B407/Clock/control"

  xpl_command(command, 1 - state)
end


function switch_1h7unused(state)
end


function switch_1h8unused(state)
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
end


function cb_fuelvalve(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/FUEL_VALVE",
    state, 0
  )
end

function cb_fuelqty(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/FUEL_QTY",
    state, 0
  )
end

function cb_fuelpressure(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/FUEL_PRESS",
    state, 0
  )
end

function cb_genreset(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/GEN_RESET",
    state, 0
  )
end

function cb_genfield(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/GEN_FIELD",
    state, 0
  )
end

function cb_xmsntemp(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/XMSN_TEMP",
    state, 0
  )
end

function cb_xmsnpress(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/XMSN_PRESS",
    state, 0
  )
end

function cb_engmgt(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_MGT",
    state, 0
  )
end

function cb_engtrq(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_TRQ",
    state, 0
  )
end

function cb_engng(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_NG",
    state, 0
  )
end

function cb_engnp(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_NP",
    state, 0
  )
end

function cb_engnr(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_NR",
    state, 0
  )
end

function cb_engoiltemp(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_TEMP",
    state, 0
  )
end

function cb_engoilpress(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ENG_PRESS",
    state, 0
  )
end

function cb_engantiice(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/ANTI_ICE",
    state, 0
  )
end

function cb_starter(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/START",
    state, 0
  )
end

function cb_igniter(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/IGNITER",
    state, 0
  )
end

function cb_fadec(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_fadec_0"
    output, 0
  )
end

function cb_hydsys(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/HYD_SYS",
    state, 0
  )
end

function cb_pedalstop(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/PEDAL_STOP",
    state, 0
  )
end

function cb_ldglights(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/LIGHT_PWR",
    state, 0
  )
end

function cb_ldglightscont(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/LIGHT_CONT",
    state, 0
  )
end

function cb_cautionlights(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/LIGHT_CAUT",
    state, 0
  )
end

function cb_oatv(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/OAT_V",
    state, 0
  )
end

function cb_amps(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/AMPS",
    state, 0
  )
end

function cb_navcom1(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_navcom1",
    output, 0
  )
end

function cb_com2(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_navcom2",
    output, 0
  )
end

function cb_xpndr(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_xpndr",
    output, 0
  )
end

function cb_gps1(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_gps",
    output, 0
  )
end

function cb_gps2(state)
  output = (1 - state) * 6
  xpl_dataref_write(
    "sim/operation/failures/rel_gps2",
    output, 0
  )
end

function cb_radalt(state)
  xpl_dataref_write(
    "B407/CircuitBreaker/RADAR_ALT",
    state, 0
  )
end

function cb_4h8unused(state)
end



switch_table = {
  [1] = {
    switch_fuelvalve,
    switch_annunciatortest,
    switch_hornmute,
    switch_instrumentcheck,
    switch_lcdtest,
    switch_fuelquantity,
    switch_fadechorntest,
    switch_overspeedtest
  },
  [2] = {
    switch_cdi,
    switch_fadec,
    switch_pedalstop,
    switch_oatvselect,
    switch_clockselect,
    switch_clockcontrol,
    switch_1h7unused,
    switch_1h8unused
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
    cb_fuelpressure,
    cb_genreset,
    cb_genfield,
    cb_xmsntemp,
    cb_xmsnpress,
    cb_engmgt
  },
  [6] = {
    cb_engtrq,
    cb_engng,
    cb_engnp,
    cb_engnr,
    cb_engoiltemp,
    cb_engoilpress,
    cb_engantiice,
    cb_starter
  },
  [7] = {
    cb_igniter,
    cb_fadec,
    cb_hydsys,
    cb_pedalstop,
    cb_ldglights,
    cb_ldglightscont,
    cb_cautionlights,
    cb_oatv
  },
  [8] = {
    cb_amps,
    cb_navcom1,
    cb_com2,
    cb_xpndr,
    cb_gps1,
    cb_gps2,
    cb_radalt,
    cb_4h8unused
  }
}
