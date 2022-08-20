--create nested array in logic.lua containing references to switch functions, which will be located in this file
--switch functions will be organized based on payload, payload array index, and input index
--switch functions named after hardware switch, alternate aircraft will keep these function names and only alter the logic within
--logic.lua will iterate over the payload, look for changes, and then call the correct function

function update_switches(payload)
  print("switch payload in: ", payload)

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
  output = 1 - state
  dataref = "206B3/fuel/valve"
  xpl_dataref_write(
    dataref, "FLOAT",
    output, 0
  )
end


function switch_annunciatortest(state)
  command = "206B3/Buttons/cauttest_cmd"

  xpl_command(command, 1 - state)
end


function switch_hornmute(state)
  command = "206B3/Buttons/mutehorn_cmd"

  xpl_command(command, 1 - state)
end


function switch_instrumentcheck(state)

end


function switch_lcdtest(state)

end


function switch_fuelquantity(state)

end


function switch_fadechorntest(state)

end

headset_state = 0
function switch_overspeedtest(state)
  if state == 1 then headset_state = 1 - headset_state end
  xpl_dataref_write(
    "206B3/headset/right", "int",
    headset_state, 0
  )
end


--payload 1, panel1 high
function switch_cdi(state)
--  command = "sim/GPS/g430n1_cdi"
--  xpl_command(command, 1 - state)
end


function switch_fadec(state)
--  command = "B407/systems/toggle/Fadec"
--  xpl_command(command, 1 - state)
end


function switch_pedalstop(state)

end

--oatv_state = 0
function switch_oatvselect(state)
--  dataref = "laminar/c172/knob_OAT"
--  if state = 1 then
--    oatv_state = oatv_state + 1
--  end
--  output = oatv_state % 4
--  print(output)
--  xpl_dataref_write(
--    dataref, "INT",
--    output, 0
--  )
end


function switch_clockselect(state)

end


function switch_clockcontrol(state)

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
  command = "sim/radios/com2_standy_flip"
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

end


function switch_anticollisionlight(state)
  command0 = "sim/lights/beacon_lights_on"
  command1 = "sim/lights/beacon_lights_off"

  toggle_command(command0, command1, state)
end


function switch_hydraulics(state)
  dataref = "206B3/hydraulics/onoff"

  xpl_dataref_write(
    dataref, "INT",
    1 - state, 0
  )
end


function switch_avionicsmaster(state)
  command0 = "sim/systems/avionics_on"
  command1 = "sim/systems/avionics_off"

  toggle_command(command0, command1, state)
end


function switch_engineantiice(state)
  dataref = "sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine"

  xpl_dataref_write(
    dataref, "INT[8]",
    1 - state, 0
  )
end


function switch_pitotheater(state)
  command0 = "sim/ice/pitot_heat0_on"
  command1 = "sim/ice/pitot_heat0_off"

  toggle_command(command0, command1, state)
end


--payload2, overhead1 high
function switch_positionlight(state)
  command0 = "sim/lights/nav_lights_on"
  command1 = "sim/lights/nav_lights_off"

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
  dataref = "206B3/fuel/boost/aft/br"

  xpl_dataref_write(
    dataref, "INT",
    state, 0
  )
end


function switch_fuelpumpright(state)
  dataref = "206B3/fuel/boost/fwd/br"

  xpl_dataref_write(
    dataref, "INT",
    state, 0
  )
end


function switch_instrumentdg(state)
  dataref = "206B3/dg_att"

  xpl_dataref_write(
    dataref, "INT",
    1 - state, 0
  )
end


function switch_instrumentatt(state)

end


function switch_instrumentturn(state)

end


function switch_2h8unused(state)
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
    switch_2h8unused
  },
  [5] = {
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused
  },
  [6] = {
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
    switch_2h8unused,
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