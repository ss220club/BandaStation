// MARK: Traps
// Ez-Briz изобрел трапов
#define IS_OPEN(parent) isgroundlessturf(parent)

/obj/structure/trap/punji
	name = ""
	desc = ""
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "spike_trap"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	time_between_triggers = 1 SECONDS
	var/damage_for_each_leg = 15

/obj/structure/trap/punji/trap_effect(mob/living/victim)
	to_chat(victim, span_bolddanger("Ловушка!"))
	victim.apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_L_LEG)
	victim.apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_R_LEG)
	victim.apply_damage(40, STAMINA)
	playsound(loc, 'modular_bandastation/events/avangarde17/audio/spike.ogg', 100)
	new /obj/structure/punji_sticks/steel(loc)

	QDEL_IN(src, 1 SECONDS)

/obj/structure/trap/punji/flare()
	return

/obj/structure/punji_sticks/steel
	name = "steel spikes"
	desc = "Don't step on this."
	icon = 'modular_bandastation/events/avangarde17/icons/obj.dmi'
	icon_state = "steel_punji"

// Trap door
/obj/structure/trap/trapdoor
	name = ""
	desc = ""
	icon_state = "trap-shock"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	time_between_triggers = 6 SECONDS
	alpha = 0
	var/disappear_time = 5 SECONDS
	var/trapdoor_baseturfs = list()
	var/trapdoor_turf_path

/obj/structure/trap/trapdoor/flare()
	return

/obj/structure/trap/trapdoor/Initialize(mapload)
	. = ..()
	src.trapdoor_turf_path = loc.type
	trapdoor_baseturfs += /turf/baseturf_skipover/trapdoor

/obj/structure/trap/trapdoor/trap_effect(mob/living/victim)
	to_chat(victim, span_bolddanger("Ловушка!"))
	toggle_trapdoor()
	//addtimer(CALLBACK(src, PROC_REF(toggle_trapdoor)), disappear_time) // Убрать если оставляем открытым
	QDEL_IN(src, 1 SECONDS) // Раскоментить, если хотим одноразку

/obj/structure/trap/trapdoor/proc/toggle_trapdoor()
	SIGNAL_HANDLER
	if(!IS_OPEN(loc))
		try_opening()
	else
		try_closing()

/obj/structure/trap/trapdoor/proc/try_opening()
	var/turf/open/trapdoor_turf = loc
	var/opening_depth = trapdoor_turf.depth_to_find_baseturf(/turf/baseturf_skipover/trapdoor)

	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_open.ogg', 50)
	trapdoor_baseturfs = trapdoor_turf.get_baseturfs_to_depth(opening_depth)
	trapdoor_turf.visible_message(span_warning("[trapdoor_turf] swings open!"))
	trapdoor_turf.ScrapeAway(opening_depth, flags = CHANGETURF_INHERIT_AIR | CHANGETURF_TRAPDOOR_INDUCED)

/obj/structure/trap/trapdoor/proc/try_closing()
	var/turf/open/trapdoor_turf = loc
	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_shut.ogg', 50)
	trapdoor_turf.visible_message(span_warning("The trapdoor mechanism in [trapdoor_turf] swings shut!"))
	var/list/new_baseturfs = list()
	new_baseturfs += trapdoor_turf.baseturfs
	new_baseturfs += trapdoor_turf.type

	new_baseturfs += trapdoor_baseturfs
	trapdoor_baseturfs = null
	trapdoor_turf.ChangeTurf(trapdoor_turf_path, new_baseturfs, flags = CHANGETURF_INHERIT_AIR | CHANGETURF_TRAPDOOR_INDUCED)

// Petya изобрел джокушки
/obj/structure/trap/projectile_trap
	name = ""
	desc = ""
	icon_state = "trap-shock"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	desc = "Джокушка"
	sparks = FALSE
	charges = 1
	alpha = 0

	var/projectile_origin_x = 0
	var/projectile_origin_y = 0
	var/projectile_origin_z = 0
	var/projectile_type = /obj/projectile/bullet/arrow
	var/projectile_fire_sound = 'sound/items/weapons/fwoosh.ogg'
	var/projectile_origin_radius = 1

/obj/structure/trap/projectile_trap/Initialize(mapload)
	. = ..()
	var/turf/origin_turf
	var/closest_dist = INFINITY

	for(var/turf/closed/S in range(projectile_origin_radius, src))
		if(S == src)
			continue
		var/turf/T = get_turf(S)
		if(!T)
			continue
		var/d = get_dist(src, S)
		if(d < closest_dist)
			closest_dist = d
			origin_turf = T

	if(origin_turf)
		projectile_origin_x = origin_turf.x
		projectile_origin_y = origin_turf.y
		projectile_origin_z = origin_turf.z

/obj/structure/trap/projectile_trap/trap_effect(mob/living/victim)
	var/turf/target = get_turf(src)
	if(!target)
		return

	if(!ispath(projectile_type, /obj/projectile))
		return

	var/turf/spawn_from = null
	// если при инициализации не найден закрытый турф в радиусе - спавним из рандомной точки в радиусе
	if(projectile_origin_x && projectile_origin_y)
		spawn_from = locate(projectile_origin_x, projectile_origin_y, projectile_origin_z || target.z)

	if(!spawn_from)
		var/list/candidates = list()
		for(var/turf/T in range(projectile_origin_radius, target))
			candidates += T
		if(candidates.len)
			spawn_from = pick(candidates)
		else
			spawn_from = target

	if(!spawn_from)
		return

	spawn_from.fire_projectile(projectile_type, target, projectile_fire_sound, src)

#undef IS_OPEN
