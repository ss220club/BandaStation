// MARK: Turf
// Турфы - не используются, может передумаем
/turf/open/misc/asteroid/moon/cold
	planetary_atmos = TRUE
	initial_gas_mix = COLD_ATMOS

/turf/open/misc/snow/avangarde
	slowdown = 1
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/asteroid/moon

/turf/open/misc/snow/avangarde/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return TRUE

/turf/closed/mineral/snowmountain/avangarde
	baseturfs = /turf/open/misc/asteroid/moon
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/misc/asteroid/moon
	defer_change = TRUE

/turf/open/floor/asphalt/avangarde
	baseturfs = /turf/open/misc/asteroid/moon
	footstep = FOOTSTEP_SAND

/turf/open/floor/asphalt/avangarde/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return TRUE

/turf/closed/mineral/snowmountain/cavern/avangarde
	baseturfs = /turf/open/misc/asteroid/moon
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/misc/asteroid/moon
	defer_change = TRUE

/turf/closed/indestructible/rock/avangarde
	color = "#292929"

/turf/open/floor/plating/temple
	name = "temple floor"
	icon_state = "cult"
	color = "#4b4b4b"
