--[[==========DATAREF FINDS==========]]
--Dreamfoil 407 datarefs
  --FIXME this fails for some reason... maybe since the aircraft wasn't loaded? How to check first...?
  --dataref("df407_landing_lights_dataref",     "B407/Collective/LandingLight",               "writable")

--JRX 407 datarefs
  dataref("jrx407_starter_engage_dataref",    "jrxDR/407/collective/switches/starter",      "writable")
  dataref("jrx407_landing_lights_dataref",    "jrxDR/407/panels/switches/landing_lights",   "writable")
  dataref("jrx407_floats_arm_dataref",        "jrxDR/407/overhead/switches/floats_armed",   "writable")
  dataref("jrx407_floats_cover_dataref",      "jrxDR/407/overhead/switches/floats_cover",   "writable")
  dataref("jrx407_floats_inflate_dataref",    "jrxDR/407/overhead/switches/floats_inflate", "writable")

--Cowan 206B3 datarefs
  --TODO

--Cowan 206L3 datarefs
  --TODO
  --landing lights: 1 is forward, 2 is down
  --	g206landinglightDataRef = XPLMFindDataRef("206L3/ldglts/sw")
  --	ll_1_off_com = "sim/lights/landing_01_light_off"
  --	ll_1_on_com = "sim/lights/landing_01_light_on"
  --	ll_2_off_com = "sim/lights/landing_02_light_off"
  --	ll_2_on_com = "sim/lights/landing_02_light_on"

  --floats: arm = 1, blow floats = 0
  --	g206floatArmDataRef = XPLMFindDataRef("206L3/acc/floats_active")
  --	g206floatBlowDataRef = XPLMFindDataRef("206L3/acc/floats_blown")



--[[==========CUSTOM COMMANDS==========]]
--6: Idle Stop
function _407simv2_idle_stop()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    command_once("407/Switches/Controls/idle_stop_button")

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/idle_stop",
                "Idle Stop",
                "",
                "_407simv2_idle_stop()",
                "")


--7: Starter Engage
function _407simv2_starter_engage()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_starter_engage_dataref = 1

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
function _407simv2_starter_off()
  if (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_starter_engage_dataref = 0
  end
end
create_command( "FlyWithLua/407simv2/starter_engage",
                "Starter Engage",
                "",
                "_407simv2_starter_engage()",
                "_407simv2_starter_off()")


--8: Starter Disengage
function _407simv2_starter_disengage()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    --Not supported by JRX 407

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO
  end

end
create_command( "FlyWithLua/407simv2/starter_disengage",
                "Starter Disengage",
                "",
                "_407simv2_starter_disengage()",
                "")


--9: Landing Lights Both
function _407simv2_landing_lights_both()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_landing_lights_dataref = 2

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/landing_lights_both",
                "Landing Lights Both",
                "",
                "_407simv2_landing_lights_both()",
                "")


--10: Landing Lights Off
function _407simv2_landing_lights_off()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_landing_lights_dataref = 0

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/landing_lights_off",
                "Landing Lights Off",
                "",
                "_407simv2_landing_lights_off()",
                "")


--11: Floats Inflate
function _407simv2_floats_inflate()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_floats_inflate_dataref = 1

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/floats_inflate",
                "Floats Inflate",
                "",
                "_407simv2_floats_inflate()",
                "")


--12: Floats Arm
function _407simv2_floats_arm()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_floats_cover_dataref = 1
    jrx407_floats_arm_dataref = 1

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/floats_arm",
                "Floats Arm",
                "",
                "_407simv2_floats_arm()",
                "")


--13: Landing Lights Fwd
function _407simv2_landing_lights_fwd()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_landing_lights_dataref = 1

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/landing_lights_fwd",
                "Landing Lights Fwd",
                "",
                "_407simv2_landing_lights_fwd()",
                "")


--14: Floats Disarm
function _407simv2_floats_disarm()

  if (PLANE_AUTHOR == "Dreamfoil Creations") then
    --TODO

  elseif (PLANE_AUTHOR == "JRX Design Studio") then
    jrx407_floats_cover_dataref = 0
    jrx407_floats_arm_dataref = 0

  elseif (PLANE_ICAO == "206B3") then
    --TODO

  elseif (PLANE_ICAO == "206L3") then
    --TODO

  end

end
create_command( "FlyWithLua/407simv2/floats_disarm",
                "Floats Disarm",
                "",
                "_407simv2_floats_disarm()",
                "")
=======
b206landinglightDataRef     =   "206L3/ldglts/sw"
ll_1_off_command            =   "sim/lights/landing_01_light_off"
ll_1_on_command             =   "sim/lights/landing_01_light_on"
ll_2_off_command            =   "sim/lights/landing_02_light_off"
ll_2_on_command             =   "sim/lights/landing_02_light_on"

function set206landinglight(position)
    if position == 0 then
        --set("b206landinglightDataRef", 0)
        command_once(ll_1_off_command)
        command_once(ll_2_off_command)

    elseif position == 1 then
        --set("b206landinglightDataRef", 1)
        command_once(ll_1_on_command)
        command_once(ll_2_off_command)

    elseif position == 2 then
        --set("b206landinglightDataRef", 2)
        command_once(ll_1_on_command)
        command_once(ll_2_on_command)

    end
end

create_command( "FlyWithLua/206/landing_lights_off",    "Landing Lights Off",       "set206landinglight(0)", "", "")
create_command( "FlyWithLua/206/landing_lights_fwd",    "Landing Lights Forward",   "set206landinglight(1)", "", "")
create_command( "FlyWithLua/206/landing_lights_both",   "Landing Lights Both",      "set206landinglight(2)", "", "")