/obj/effect/anomaly/pyro/pyro_zone
	name = "pyroclastic vortex"
	immortal = TRUE
	lifespan = INFINITY
	anomaly_core = null
	movement_type = FLOATING
	light_range = 4
	light_power = 2
	light_color = "#FF6633"

/obj/effect/anomaly/pyro/pyro_zone/detonate()
	return

/obj/effect/anomaly/pyro/pyro_zone/proc/move_to_zone()
	if(!length(GLOB.pyro_anomaly_points))
		return
	var/obj/effect/landmark/pyro_anomaly/L = pick(GLOB.pyro_anomaly_points)
	if(!L)
		return
	forceMove(get_turf(L))

/obj/effect/anomaly/pyro/pyro_zone/proc/relocate_within_zone()
	if(!length(GLOB.pyro_anomaly_points))
		return
	var/obj/effect/landmark/pyro_anomaly/L = pick(GLOB.pyro_anomaly_points)
	if(!L)
		return
	var/turf/target = get_turf(L)
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE)
	new /obj/effect/temp_visual/circle_wave/gravity(get_turf(src))
	forceMove(target)
	new /obj/effect/temp_visual/circle_wave/gravity(target)

/obj/effect/anomaly/pyro/pyro_zone/anomalyEffect(seconds_per_tick)
	ticks += seconds_per_tick
	if(ticks >= releasedelay)
		ticks -= releasedelay
		var/turf/open/T = get_turf(src)
		if(istype(T))
			T.atmos_spawn_air("[GAS_O2]=5;[GAS_PLASMA]=5;[TURF_TEMPERATURE(1000)]")
	if(!istype(get_area(src), /area/new_sydney/pyro_zone))
		move_to_zone()
	if(prob(10))
		relocate_within_zone()
	return TRUE

/obj/effect/anomaly/pyro/pyro_zone/Bumped(atom/movable/bumpee)
	. = ..()
	if(isliving(bumpee))
		var/mob/living/L = bumpee
		L.adjust_fire_loss(30)
		L.ignite_mob()
