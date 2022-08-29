if (PLANE_ICAO == "B407") then
	g407landinglightDataRef = XPLMFindDataRef("B407/Collective/LandingLight")

	create_command( "FlyWithLua/407/landing_lights_off", "Landing Lights Off",
                "",
                "XPLMSetDataf(g407landinglightDataRef, 0)",
                "")

	create_command( "FlyWithLua/407/landing_lights_fwd", "Landing Lights Forward",
                "",
                "XPLMSetDataf(g407landinglightDataRef, 1)",
                "")

	create_command( "FlyWithLua/407/landing_lights_both", "Landing Lights Both",
                "",
                "XPLMSetDataf(g407landinglightDataRef, 2)",
                "")

	g407floatDataRef = XPLMFindDataRef("B407/Float_Arm")

	create_command( "FlyWithLua/407/float_disarm", "Float Disarm",
                "",
                "XPLMSetDataf(g407floatDataRef, 0)",
                "")
end

if (PLANE_ICAO == "206L3") then
	g206landinglightDataRef = XPLMFindDataRef("206L3/ldglts/sw")
	ll_1_off_com = "sim/lights/landing_01_light_off"
	ll_1_on_com = "sim/lights/landing_01_light_on"
	ll_2_off_com = "sim/lights/landing_02_light_off"
	ll_2_on_com = "sim/lights/landing_02_light_on"

	create_command( "FlyWithLua/206/landing_lights_off", "Landing Lights Off",
                "",
		"XPLMSetDatai(g206landinglightDataRef, 0); command_once(ll_1_off_com); command_once(ll_2_off_com)",
                "")

	create_command( "FlyWithLua/206/landing_lights_fwd", "Landing Lights Forward",
                "",
		"XPLMSetDatai(g206landinglightDataRef, 1); command_once(ll_1_on_com); command_once(ll_2_off_com)",
                "")

	create_command( "FlyWithLua/206/landing_lights_both", "Landing Lights Both",
                "",
		"XPLMSetDatai(g206landinglightDataRef, 2); command_once(ll_1_on_com); command_once(ll_2_on_com)",
                "")

	g206floatArmDataRef = XPLMFindDataRef("206L3/acc/floats_active")

	create_command( "FlyWithLua/206/float_disarm", "Float Disarm",
                "",
                "XPLMSetDatai(g206floatArmDataRef, 0)",
                "")

	create_command( "FlyWithLua/206/float_arm", "Float Arm",
                "",
                "XPLMSetDatai(g206floatArmDataRef, 1)",
                "")

	g206floatBlowDataRef = XPLMFindDataRef("206L3/acc/floats_blown")

	create_command( "FlyWithLua/206/float_blow", "Float Blow",
                "",
                "XPLMSetDatai(g206floatBlowDataRef, 0)",
                "")
end