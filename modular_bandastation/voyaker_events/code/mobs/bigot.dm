/obj/effect/bigot_tongue
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood"
	layer = ABOVE_MOB_LAYER

/obj/effect/bigot_tongue/Initialize(mapload)
	.=..()
	QDEL_IN(src, 0.5 SECONDS)

/datum/targeting_strategy/basic/not_zombies
	custom_faction_check = TRUE

/datum/targeting_strategy/basic/not_zombies/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return living_mob.has_faction(FACTION_CULT) && the_target.has_faction(FACTION_CULT)

/mob/living/basic/bigot
	name = "изувер"
	desc = "Некогда человек. Теперь лишь воплощение боли. Вместо правой руки - когти-лезвия. Вместо левой - окровавленная тентакля с шипами. У него ноги такой накаченной мускулатуры, словно он может прыгнуть даже на десятый этаж."
	icon = 'modular_bandastation/voyaker_events/icons/bigot.dmi'
	icon_state = "bigot"
	maxHealth = 400
	health = 400
	melee_damage_lower = 20
	melee_damage_upper = 40
	melee_attack_cooldown = 4 SECONDS
	obj_damage = 20
	speed = 2
	attack_verb_continuous = "разрывает"
	attack_verb_simple = "разрывает"
	attack_sound = 'sound/items/weapons/slice.ogg'
	var/next_tongue_attack = 0
	var/next_charge_attack = 0
	var/tongue_cooldown = 15 SECONDS
	var/charge_cooldown = 10 SECONDS
	var/roar_sound = 'modular_bandastation/voyaker_events/sounds/bigot_roar.ogg'
	var/min_roar_delay = 20 SECONDS
	var/max_roar_delay = 60 SECONDS
	var/max_steps = 12

	ai_controller = /datum/ai_controller/basic_controller/bigot

/mob/living/basic/bigot/death(gibbed)
	if(quest_killer && ishuman(quest_killer))
		check_trader_kill_quests(quest_killer, src)

	. = ..()

	if(prob(65))
		new /obj/item/loot_mobs/bigot_claw(get_turf(src))
	new /obj/effect/gibspawner/generic(get_turf(src))
	qdel(src)

/datum/ai_controller/basic_controller/bigot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_zombies,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/bigot.bt.json"

/datum/bt_node/ai_behavior/bigot_tongue
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key

/datum/bt_node/ai_behavior/bigot_tongue/setup(datum/ai_controller/controller)
	. = ..()
	if(!ispath(targeting_strategy))
		targeting_strategy = controller.blackboard[targeting_strategy]
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bigot_tongue/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bigot/bigot = controller.pawn
	if(!bigot)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[hiding_location_key]
	if(!target)
		target = controller.blackboard[target_key]
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(targeting_strategy)
	if(!strategy.is_valid_target(controller.pawn, target, controller = controller))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(IS_UNCONSCIOUS_OR_CRIT(bigot))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/dist = get_dist(bigot, target)
	if(dist < 4 || dist > 8)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < bigot.next_tongue_attack)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(bigot, TYPE_PROC_REF(/mob/living/basic/bigot, tongue_tentacle), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/bigot_charge
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key

/datum/bt_node/ai_behavior/bigot_charge/setup(datum/ai_controller/controller)
	. = ..()
	if(!ispath(targeting_strategy))
		targeting_strategy = controller.blackboard[targeting_strategy]
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bigot_charge/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bigot/bigot = controller.pawn
	if(!bigot)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[hiding_location_key]
	if(!target)
		target = controller.blackboard[target_key]
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(targeting_strategy)
	if(!strategy.is_valid_target(controller.pawn, target, controller = controller))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(IS_UNCONSCIOUS_OR_CRIT(bigot))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/dist = get_dist(bigot, target)
	if(dist < 5 || dist > 10)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < bigot.next_charge_attack)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(bigot, TYPE_PROC_REF(/mob/living/basic/bigot, charge_attack), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/bigot_roar

/datum/bt_node/ai_behavior/bigot_roar/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bigot/bigot = controller.pawn
	if(!bigot)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	bigot.play_roar()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/mob/living/basic/bigot/Initialize(mapload)
	. = ..()
	faction = list("cult")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/bigot/melee_attack(atom/target, ignore_cooldown)
	. = ..()
	if(!isliving(target))
		return
	if(prob(20))
		new /obj/effect/decal/cleanable/blood(get_turf(src))

/mob/living/basic/bigot/proc/tongue_tentacle(mob/living/target)
	if(!can_see(src, target, 10))
		return FALSE
	next_tongue_attack = world.time + tongue_cooldown
	visible_message(span_warning("[src] выпускает длинную окровавленную руку-тентаклю!"))
	if(prob(35))
		visible_message(span_notice("[target] уклоняется от тентакли [src]!"))
		return FALSE
	Beam(target, icon_state = "blood", time = 10)
	target.Immobilize(3 SECONDS)
	for(var/i in 1 to 12)
		if(QDELETED(src) || stat == DEAD)
			return FALSE
		if(QDELETED(target))
			return FALSE
		if(!can_see(src, target, 10))
			return FALSE
		var/turf/next = get_step_towards(target, src)
		if(!next)
			break
		if(isclosedturf(next))
			break
		for(var/obj/O in next)
			if(O.density)
				return FALSE
		new /obj/effect/decal/cleanable/blood(get_turf(target))
		target.forceMove(next)
		if(get_dist(src, target) <= 1)
			break
		sleep(2)
		target.apply_damage(10, BRUTE)

/mob/living/basic/bigot/proc/charge_attack(mob/living/target)
	next_charge_attack = world.time + charge_cooldown
	Shake(2, 2 SECONDS)
	visible_message(span_warning("[src] напрягается перед броском!"))
	sleep(2 SECONDS)
	var/dir_to_target = get_dir(src, target)
	for(var/i in 1 to 6)
		step(src, dir_to_target)
		playsound(get_turf(src), 'sound/effects/footstep/heavy1.ogg', 50, TRUE)
		if(get_dist(src, target) <= 1)
			target.Knockdown(2 SECONDS)
			target.apply_damage(20, BRUTE)
			return TRUE
		sleep(world.tick_lag)
	return TRUE

/mob/living/basic/bigot/proc/play_roar()
	if(QDELETED(src) || stat == DEAD)
		return
	if(prob(40))
		visible_message(span_warning("[src] издаёт жуткий рык!"))
	playsound(get_turf(src), roar_sound, 75, TRUE)
