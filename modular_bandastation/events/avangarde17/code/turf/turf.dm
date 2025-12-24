// MARK: Turf
// Турфы - не используются, может передумаем
/turf/open/misc/asteroid/moon/cold
	planetary_atmos = TRUE
	initial_gas_mix = COLD_ATMOS

/turf/open/misc/snow/avangarde
	slowdown = 1
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/closed/mineral/snowmountain/avangarde
	baseturfs = /turf/open/misc/asteroid/moon
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/misc/asteroid/moon
	defer_change = TRUE

/turf/closed/mineral/snowmountain/cavern/avangarde
	baseturfs = /turf/open/misc/asteroid/moon
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/misc/asteroid/moon
	defer_change = TRUE

/turf/closed/indestructible/rock/avangarde
	color = "#292929"
