/proc/get_bluespace_beacon_portal_factions()
	var/static/list/factions = list(
		"Lavaland fauna" = list(
			"weight" = 5,
			"portal_name" = "lavaland fauna rift",
			"spawn_time" = 20 SECONDS,
			"max_mobs" = 6,
			"mob_types" = list(
				/mob/living/basic/mining/goldgrub,
				/mob/living/basic/mining/goliath/ancient,
				/mob/living/basic/mining/hivelord,
				/mob/living/basic/mining/basilisk,
			),
			"faction" = list(FACTION_MINING),
			"lifetime" = 3 MINUTES,
		),
		"Netherworld" = list(
			"weight" = 3,
			"portal_name" = "netherworld breach",
			"spawn_time" = 18 SECONDS,
			"max_mobs" = 6,
			"mob_types" = list(
				/mob/living/basic/blankbody,
				/mob/living/basic/creature,
				/mob/living/basic/migo,
			),
			"faction" = list(FACTION_NETHER),
			"lifetime" = 3 MINUTES,
		),
		"Carp migration" = list(
			"weight" = 4,
			"portal_name" = "carp rift",
			"spawn_time" = 15 SECONDS,
			"max_mobs" = 7,
			"mob_types" = list(
				/mob/living/basic/carp,
				/mob/living/basic/carp,
				/mob/living/basic/carp,
				/mob/living/basic/carp/magic,
				/mob/living/basic/carp/mega,
			),
			"faction" = list(FACTION_CARP),
			"lifetime" = 3 MINUTES,
		),
	)
	return factions

/obj/structure/spawner
	/// Weakref to owning bluespace beacon for beacon-origin portals.
	var/datum/weakref/bluespace_beacon_owner_ref
	/// Scatter radius for spawned mobs from beacon-origin portals.
	var/bluespace_beacon_spawn_radius = 2

/proc/get_bluespace_beacon_demonic_incursion_spawners()
	var/static/list/demon_spawners = list(
		/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/ice_whelp = 3,
		/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/snowlegion = 2,
	)
	return demon_spawners

/proc/get_bluespace_beacon_portal_spawn_turf(atom/source, radius = 2)
	var/list/possible_turfs = list()
	for(var/turf/target_turf as anything in RANGE_TURFS(radius, source))
		if(target_turf == get_turf(source))
			continue
		if(target_turf.density || isspaceturf(target_turf))
			continue
		if(target_turf.is_blocked_turf_ignore_climbable())
			continue
		possible_turfs += target_turf
	if(!length(possible_turfs))
		return null
	return pick(possible_turfs)

/obj/structure/spawner/proc/bluespace_beacon_scatter_spawned_mob(atom/created_atom, radius = 2)
	if(!isliving(created_atom))
		return
	var/mob/living/spawned_mob = created_atom
	var/turf/new_turf = get_bluespace_beacon_portal_spawn_turf(src, radius)
	if(new_turf)
		spawned_mob.forceMove(new_turf)

/obj/structure/spawner/proc/bluespace_beacon_set_owner(obj/machinery/power/bluespace_beacon/beacon_owner)
	if(beacon_owner)
		bluespace_beacon_owner_ref = WEAKREF(beacon_owner)

/obj/structure/spawner/proc/bluespace_beacon_register_owner_portal()
	var/obj/machinery/power/bluespace_beacon/beacon_owner = bluespace_beacon_owner_ref?.resolve()
	beacon_owner?.register_active_portal(src)

/obj/structure/spawner/proc/bluespace_beacon_unregister_owner_portal()
	var/obj/machinery/power/bluespace_beacon/beacon_owner = bluespace_beacon_owner_ref?.resolve()
	beacon_owner?.unregister_active_portal(src)

/obj/structure/spawner/bluespace_beacon_event
	name = "unstable bluespace portal"
	desc = "Яростно флуктуирующий разрыв в реальности."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "nether"
	max_integrity = 100
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE
	faction = list(FACTION_HOSTILE)
	max_mobs = 5
	spawn_time = 20 SECONDS
	mob_types = list(/mob/living/basic/carp)
	spawn_text = "steps through"
	/// Auto-collapse timer.
	var/lifetime = 3 MINUTES

/obj/structure/spawner/bluespace_beacon_event/New(
	loc,
	portal_name = null,
	list/portal_mob_types = null,
	portal_spawn_time = null,
	portal_max_mobs = null,
	list/portal_faction = null,
	portal_lifetime = null,
	obj/machinery/power/bluespace_beacon/beacon_owner = null,
)
	if(portal_name)
		name = portal_name
	if(islist(portal_mob_types) && length(portal_mob_types))
		mob_types = portal_mob_types.Copy()
	if(isnum(portal_spawn_time) && portal_spawn_time > 0)
		spawn_time = portal_spawn_time
	if(isnum(portal_max_mobs) && portal_max_mobs > 0)
		max_mobs = portal_max_mobs
	if(islist(portal_faction) && length(portal_faction))
		faction = portal_faction.Copy()
	if(isnum(portal_lifetime) && portal_lifetime > 0)
		lifetime = portal_lifetime
	bluespace_beacon_set_owner(beacon_owner)
	return ..()

/obj/structure/spawner/bluespace_beacon_event/Initialize(mapload)
	. = ..()
	bluespace_beacon_register_owner_portal()
	playsound(src, 'sound/effects/magic/lightning_chargeup.ogg', 80, TRUE)
	addtimer(CALLBACK(src, PROC_REF(collapse_portal)), lifetime)

/obj/structure/spawner/bluespace_beacon_event/Destroy()
	bluespace_beacon_unregister_owner_portal()
	return ..()

/obj/structure/spawner/bluespace_beacon_event/on_mob_spawn(atom/created_atom)
	. = ..()
	bluespace_beacon_scatter_spawned_mob(created_atom, bluespace_beacon_spawn_radius)

/obj/structure/spawner/bluespace_beacon_event/proc/collapse_portal()
	if(QDELETED(src))
		return
	visible_message(span_warning("[src] дестабилизируется и коллапсирует."))
	playsound(src, 'sound/effects/magic/lightningbolt.ogg', 70, TRUE)
	qdel(src)

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/New(loc, obj/machinery/power/bluespace_beacon/beacon_owner = null)
	bluespace_beacon_set_owner(beacon_owner)
	return ..()

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/Initialize(mapload)
	. = ..()
	bluespace_beacon_register_owner_portal()

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/Destroy()
	bluespace_beacon_unregister_owner_portal()
	return ..()

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/on_mob_spawn(atom/created_atom)
	. = ..()
	bluespace_beacon_scatter_spawned_mob(created_atom, bluespace_beacon_spawn_radius)

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/ice_whelp
	mob_types = list(/mob/living/basic/mining/ice_whelp)

/obj/structure/spawner/ice_moon/demonic_portal/bluespace_beacon_event/snowlegion
	mob_types = list(/mob/living/basic/mining/legion/snow/spawner_made)
