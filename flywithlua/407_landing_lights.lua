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
