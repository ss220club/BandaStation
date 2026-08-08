/obj/effect/anomaly/bluespace/radiation_lake
	name = "unstable bluespace rift"
	immortal = TRUE
	lifespan = INFINITY
	anomaly_core = null

/obj/effect/anomaly/bluespace/radiation_lake/detonate()
	return

/obj/effect/anomaly/bluespace/radiation_lake/proc/move_to_lake()
	if(!length(GLOB.radiation_lake_anomaly_points))
		return
	var/obj/effect/landmark/radiation_lake_anomaly/L = pick(GLOB.radiation_lake_anomaly_points)
	if(!L)
		return
	forceMove(get_turf(L))

/obj/effect/anomaly/bluespace/radiation_lake/process()
	..()
	if(!istype(get_area(src), /area/new_sydney/dark_forest/radiation_lake))
		move_to_lake()

/obj/effect/anomaly/bluespace/radiation_lake/anomalyEffect()
	..()
	if(prob(10))
		relocate_within_lake()

/obj/effect/anomaly/bluespace/radiation_lake/proc/relocate_within_lake()
	if(!length(GLOB.radiation_lake_anomaly_points))
		return
	var/obj/effect/landmark/radiation_lake_anomaly/L = pick(GLOB.radiation_lake_anomaly_points)
	if(!L)
		return
	var/turf/target = get_turf(L)
	new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
	playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)
	forceMove(target)
	new /obj/effect/temp_visual/bluespace_fissure(target)

/obj/effect/anomaly/bluespace/radiation_lake/Bumped(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.adjust_tox_loss(5)
