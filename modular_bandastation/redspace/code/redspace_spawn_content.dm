/// A direct fireball projectile used by the ranged demon. It has no explosion.
/obj/projectile/magic/lesser_fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 20
	damage_type = BURN
	/// Chance to ignite a living target on hit.
	var/ignite_chance = 30
	/// Fire stacks applied when the ignition roll succeeds.
	var/fire_stacks = 2

/obj/projectile/magic/lesser_fireball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target) || !prob(ignite_chance))
		return
	var/mob/living/living_target = target
	living_target.adjust_fire_stacks(fire_stacks)
	living_target.ignite_mob()

/// A lesser demon that can survive only while its redspace energy is supplied.
/mob/living/basic/demon/redspace
	icon = 'modular_bandastation/redspace/icons/mob/demonic/lesser_demons.dmi'
	icon_state = "demon_melee"
	icon_living = "demon_melee"
	speed = 0.5
	maxHealth = 150
	health = 150
	melee_damage_lower = 12
	melee_damage_upper = 18
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile

/mob/living/basic/demon/redspace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/redspace_energy, 100, 100, 10, 10, 5, 5, 3, -0.2, 0.5, REDSPACE_DISTURBANCE_ENTER_VALUE)

/mob/living/basic/demon/redspace/ranged
	name = "ranged demon"
	real_name = "ranged demon"
	unique_name = FALSE
	desc = "A lesser redspace demon that hurls weakened fireballs from a distance."
	icon_state = "demon_ranged"
	icon_living = "demon_ranged"
	maxHealth = 100
	health = 100
	melee_damage_lower = 6
	melee_damage_upper = 10
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_ranged

/mob/living/basic/demon/redspace/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/magic/lesser_fireball,\
		projectile_sound = 'sound/effects/magic/fireball.ogg',\
		cooldown_time = 3 SECONDS,\
	)

/mob/living/basic/demon/redspace/soldier
	name = "demon soldier"
	real_name = "demon soldier"
	unique_name = FALSE
	desc = "A heavily built redspace demon bred for close combat."
	icon_state = "demon_soldier"
	icon_living = "demon_soldier"
	maxHealth = 240
	health = 240
	melee_damage_lower = 20
	melee_damage_upper = 28

/// A persistent redspace manifestation used to verify object spawn events.
/obj/structure/redspace/demonic_crystal
	name = "demonic redspace crystal"
	desc = "A crimson crystal that seems to draw its glow from the space around it."
	icon = 'modular_bandastation/redspace/icons/obj/demon_objs.dmi'
	icon_state = "demonic_crystal"
	anchored = TRUE
	density = FALSE
	var/redspace_deletion_threshold = REDSPACE_DISTURBANCE_ENTER_VALUE

/obj/structure/redspace/demonic_crystal/Initialize(mapload)
	. = ..()
	set_light(3, 1, "#ff0000")
	AddElement(/datum/element/redspace_threshold/delete_below, redspace_deletion_threshold)
	return .

/// Spawns one demonic crystal and keeps the event reserved until the crystal disappears.
/datum/redspace_event/spawn/object/demonic_crystal
	event_id = "demonic_crystal"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 1
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_crystal"

/datum/redspace_event/spawn/object/demonic_crystal/can_start(turf/target)
	if(!..())
		return FALSE
	for(var/obj/structure/redspace/demonic_crystal/crystal in target)
		return FALSE
	return TRUE

/datum/redspace_event/spawn/object/demonic_crystal/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	var/obj/structure/redspace/demonic_crystal/crystal = new(target)
	if(!crystal || QDELETED(crystal))
		return FALSE
	if(!register_spawned_atom(crystal))
		qdel(crystal)
		return FALSE

	target.visible_message(span_warning("В пространстве формируется демонический кристалл."))
	return TRUE

/// Replaces one turf with a necropolis floor and restores it below the disturbance range.
/datum/redspace_event/spawn/turf/demonic_necropolis
	event_id = "demonic_necropolis"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 2
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_necropolis"

/datum/redspace_event/spawn/turf/demonic_necropolis/can_start(turf/target)
	if(!..())
		return FALSE
	return !istype(target, /turf/open/indestructible/necropolis)

/datum/redspace_event/spawn/turf/demonic_necropolis/start(client/admin, turf/target)
	if(!can_start(target))
		return FALSE

	var/restore_turf_type = target.type
	var/list/restore_baseturfs = islist(target.baseturfs) ? target.baseturfs.Copy() : target.baseturfs ? list(target.baseturfs) : list()
	var/turf/necropolis_turf = target.ChangeTurf(/turf/open/indestructible/necropolis, null, CHANGETURF_FORCEOP)
	if(!necropolis_turf || QDELETED(necropolis_turf))
		return FALSE

	event_target = necropolis_turf
	if(!register_spawned_atom(necropolis_turf))
		necropolis_turf.ChangeTurf(restore_turf_type, restore_baseturfs.Copy(), CHANGETURF_FORCEOP)
		return FALSE
	necropolis_turf.AddElement(/datum/element/redspace_threshold/revert_turf_below, REDSPACE_DISTURBANCE_ENTER_VALUE, restore_turf_type, restore_baseturfs)
	if(QDELETED(src) || !(src in SSredspace.active_events))
		return FALSE

	necropolis_turf.visible_message(span_warning("Пол покрывается камнем демонического некрополя."))
	return TRUE

/// Spawns a lesser demon and keeps the event reserved until the demon is removed.
/datum/redspace_event/spawn/mob/demonic_lesser_demon
	event_id = "demonic_lesser_demon"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 2
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_lesser_demon"
	spawn_type = /mob/living/basic/demon/redspace
	spawn_message = "В редспейсе материализуется малый демон."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/can_start(turf/target)
	if(!..())
		return FALSE
	for(var/mob/living/basic/demon/redspace/demon in target)
		return FALSE
	return TRUE

/datum/redspace_event/spawn/mob/demonic_lesser_demon/ranged
	event_id = "demonic_ranged_demon"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 2
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_ranged_demon"
	spawn_type = /mob/living/basic/demon/redspace/ranged
	spawn_message = "В редспейсе материализуется демон-стрелок."

/datum/redspace_event/spawn/mob/demonic_lesser_demon/soldier
	event_id = "demonic_soldier"
	profile_id = REDSPACE_PROFILE_DEMONIC
	min_value = REDSPACE_STORM_ENTER_VALUE
	max_value = REDSPACE_MAX_NORMAL_VALUE
	cooldown = 60 SECONDS
	automatic = TRUE
	weight = 1
	spawn_count = 1
	spawn_budget_cost = 1
	spawn_policy_id = "demonic_soldier"
	spawn_type = /mob/living/basic/demon/redspace/soldier
	spawn_message = "В редспейсе материализуется демонический солдат."
