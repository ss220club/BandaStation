/obj/effect/dark_guardian_beam_target
	name = "dark beam endpoint"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT

/mob/living/basic/mining/dark_guardian
	name = "dark guardian"
	desc = "A creature formed from living darkness. Its presence seems to distort the air around it."
	icon = 'modular_bandastation/mobs/icons/dark_guardian.dmi'
	icon_state = "dark_guardian"
	icon_living = "dark_guardian"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON

	basic_mob_flags = DEL_ON_DEATH
	mob_biotypes = MOB_ORGANIC|MOB_MINERAL|MOB_MINING

	speed = 0.5
	maxHealth = 200
	health = 200

	obj_damage = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH

	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	ai_controller = /datum/ai_controller/basic_controller/dark_guardian

	death_message = "collapses into a pool of living darkness."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	var/stealth_active = FALSE

/datum/ai_controller/basic_controller/dark_guardian
	behavior_tree_json = "code/modules/mob/living/basic/icemoon/ice_demon/dark_guardian.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7,
		BB_LIST_SCARY_ITEMS = list(
			/obj/item/weldingtool,
			/obj/item/flashlight,
		),
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/mob/living/basic/mining/dark_guardian/Initialize(mapload)
	. = ..()

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/dark_guardian_beam = BB_DARK_GUARDIAN_BEAM_ABILITY,
		/datum/action/cooldown/mob_cooldown/dark_guardian_teleport = BB_DARK_GUARDIAN_TELEPORT_ABILITY,
	)
	grant_actions_by_list(innate_actions)
	AddElement(/datum/element/simple_flying)

/mob/living/basic/mining/dark_guardian/proc/get_teleport_target()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return
	var/list/possible_targets = list()
	for(var/turf/open/target_turf in range(10, current_turf))
		if(target_turf == current_turf)
			continue
		if(target_turf.density)
			continue
		if(locate(/mob/living) in target_turf)
			continue
		possible_targets += target_turf
	if(!length(possible_targets))
		return
	return pick(possible_targets)

/mob/living/basic/mining/dark_guardian/proc/enter_stealth(duration)
	if(stealth_active)
		return
	stealth_active = TRUE
	apply_wibbly_filters(src)
	animate(src, alpha = 0, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(exit_stealth)), duration, TIMER_UNIQUE)

/mob/living/basic/mining/dark_guardian/proc/exit_stealth()
	if(!stealth_active)
		return
	stealth_active = FALSE
	remove_wibbly_filters(src)
	animate(src, alpha = initial(alpha), time = 0.5 SECONDS)

/mob/living/basic/mining/dark_guardian/proc/get_beam_direction(atom/target)
	var/turf/guardian_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!guardian_turf || !target_turf)
		return
	var/dx = target_turf.x - guardian_turf.x
	var/dy = target_turf.y - guardian_turf.y
	if(abs(dx) > abs(dy))
		return dx > 0 ? EAST : WEST
	if(abs(dy) > abs(dx))
		return dy > 0 ? NORTH : SOUTH
	if(dx)
		return dx > 0 ? EAST : WEST
	return dy > 0 ? NORTH : SOUTH

/mob/living/basic/mining/dark_guardian/proc/get_beam_target(direction)
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return
	for(var/i in 1 to 10)
		var/turf/next_turf = get_step(current_turf, direction)
		if(!next_turf)
			return current_turf
		if(IS_OPAQUE_TURF(next_turf))
			return current_turf
		current_turf = next_turf
	return current_turf

/mob/living/basic/mining/dark_guardian/proc/get_beam_turfs(direction)
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return
	var/list/beam_turfs = list()
	for(var/i in 1 to 10)
		var/turf/next_turf = get_step(current_turf, direction)
		if(!next_turf)
			break
		if(IS_OPAQUE_TURF(next_turf))
			break
		beam_turfs += next_turf
		current_turf = next_turf
	return beam_turfs

/datum/action/cooldown/mob_cooldown/dark_guardian_beam/proc/fire_beam(mob/living/basic/mining/dark_guardian/guardian, beam_direction)
	if(!guardian || QDELETED(guardian))
		return
	var/turf/beam_start = get_turf(guardian)
	if(!beam_start)
		return
	var/turf/beam_target = guardian.get_beam_target(beam_direction)
	if(!beam_target || beam_target == beam_start)
		return
	var/obj/effect/dark_guardian_beam_target/beam_end = new(beam_target)
	guardian.Beam(beam_end, beam_effect, time = 1 SECONDS)
	var/list/beam_turfs = guardian.get_beam_turfs(beam_direction)
	var/list/hit_targets = list()
	for(var/turf/T in beam_turfs)
		for(var/mob/living/M in T.contents)
			if(M == guardian || M in hit_targets)
				continue
			hit_targets += M
			guardian.apply_beam_effect(M)
	addtimer(CALLBACK(src, PROC_REF(cleanup_beam), beam_end), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/dark_guardian_beam/proc/cleanup_beam(obj/effect/dark_guardian_beam_target/beam_end)
	if(beam_end)
		qdel(beam_end)

/mob/living/basic/mining/dark_guardian/proc/apply_beam_effect(mob/living/target)
	if(!target)
		return
	target.Knockdown(3 SECONDS)
	target.set_temp_blindness(3 SECONDS)

/datum/action/cooldown/mob_cooldown/dark_guardian_teleport
	name = "Shadow Teleport"
	desc = "Teleport to a random location and disappear into darkness."
	cooldown_time = 15 SECONDS

/datum/action/cooldown/mob_cooldown/dark_guardian_teleport/Activate()
	. = ..()
	var/mob/living/basic/mining/dark_guardian/guardian = owner
	if(!guardian)
		return
	var/turf/old_turf = get_turf(guardian)
	var/turf/target_turf = guardian.get_teleport_target()
	if(!target_turf)
		return
	new /obj/effect/temp_visual/bluespace_fissure(old_turf)
	playsound(old_turf, 'sound/effects/phasein.ogg', 75, TRUE)
	guardian.forceMove(target_turf)
	new /obj/effect/temp_visual/bluespace_fissure(target_turf)
	playsound(target_turf, 'sound/effects/phasein.ogg', 75, TRUE)
	guardian.enter_stealth(10 SECONDS)

/datum/action/cooldown/mob_cooldown/dark_guardian_beam
	name = "Dark Beam"
	desc = "Prepare and fire a beam of darkness."
	cooldown_time = 10 SECONDS
	var/beam_effect = "drain_life"

/datum/action/cooldown/mob_cooldown/dark_guardian_beam/Activate()
	. = ..()
	var/mob/living/basic/mining/dark_guardian/guardian = owner
	if(!guardian)
		return
	var/mob/living/target = BB_CURRENT_TARGET
	if(!target)
		return
	var/beam_direction = guardian.get_beam_direction(target)
	if(!beam_direction)
		return
	guardian.dir = beam_direction
	guardian.Shake(1, 1, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fire_beam), guardian, beam_direction), 3 SECONDS)
