/obj/effect/anomaly/grav/high/big/radiation_lake
	name = "gravitational vortex"
	immortal = TRUE
	lifespan = INFINITY
	anomaly_core = null

/obj/effect/anomaly/grav/high/big/radiation_lake/detonate()
	return

/obj/effect/anomaly/grav/high/big/radiation_lake/anomalyEffect(seconds_per_tick)
	. = ..()
	if(!istype(get_area(src), /area/new_sydney/dark_forest/radiation_lake2))
		move_to_zone()
	if(prob(15))
		relocate_within_zone()

/obj/effect/anomaly/grav/high/big/radiation_lake/proc/move_to_zone()
	if(!length(GLOB.radiation_lake2_grav_points))
		return
	var/obj/effect/landmark/radiation_lake2_grav/L = pick(GLOB.radiation_lake2_grav_points)
	if(!L)
		return
	forceMove(get_turf(L))

/obj/effect/anomaly/grav/high/big/radiation_lake/proc/relocate_within_zone()
	if(!length(GLOB.radiation_lake2_grav_points))
		return
	var/obj/effect/landmark/radiation_lake2_grav/L = pick(GLOB.radiation_lake2_grav_points)
	if(!L)
		return
	var/turf/target = get_turf(L)
	new /obj/effect/temp_visual/circle_wave/gravity(get_turf(src))
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE)
	forceMove(target)
	new /obj/effect/temp_visual/circle_wave/gravity(target)
