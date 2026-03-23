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

/proc/get_bluespace_beacon_demonic_incursion_spawners()
	var/static/list/demon_spawners = list(
		/obj/structure/spawner/ice_moon/demonic_portal = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 3,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 2,
	)
	return demon_spawners

/obj/structure/spawner/bluespace_beacon_event
	name = "unstable bluespace portal"
	desc = "A violently fluctuating rift in reality."
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
	return ..()

/obj/structure/spawner/bluespace_beacon_event/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/effects/magic/lightning_chargeup.ogg', 80, TRUE)
	addtimer(CALLBACK(src, PROC_REF(collapse_portal)), lifetime)

/obj/structure/spawner/bluespace_beacon_event/proc/collapse_portal()
	if(QDELETED(src))
		return
	visible_message(span_warning("[src] destabilizes and collapses."))
	playsound(src, 'sound/effects/magic/lightningbolt.ogg', 70, TRUE)
	qdel(src)
