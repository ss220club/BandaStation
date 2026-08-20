SUBSYSTEM_DEF(eftk_weather)
	name = "EFTK Weather"
	wait = 10 MINUTES

/datum/controller/subsystem/eftk_weather/fire(resumed)
	SSweather.run_weather(/datum/weather/rad_storm/eftk)
