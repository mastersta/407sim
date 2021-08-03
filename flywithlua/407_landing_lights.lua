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