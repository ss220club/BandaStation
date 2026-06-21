/obj/effect/bigot_tongue
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood"
	layer = ABOVE_MOB_LAYER

/obj/effect/bigot_tongue/Initialize(mapload)
	.=..()
	QDEL_IN(src, 0.5 SECONDS)

/mob/living/basic/bigot
	name = "изувер"
	desc = "Некогда человек. Теперь лишь воплощение боли."
	icon = 'modular_bandastation/voyaker_events/icons/bigot.dmi'
	icon_state = "bigot"
	maxHealth = 400
	health = 400
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	melee_damage_lower = 20
	melee_damage_upper = 40
	melee_attack_cooldown = 3 SECONDS
	obj_damage = 20
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

	ai_controller = /datum/ai_controller/basic_controller/bigot

/mob/living/basic/bigot/death(gibbed)
	. = ..()
	if(prob(65))
		new /obj/item/loot_mobs/bigot_claw(get_turf(src))
	new /obj/effect/gibspawner/generic(get_turf(src))
	qdel(src)

/datum/ai_controller/basic_controller/bigot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining/get_target_priority,
		BB_VISION_RANGE = 10,
		BB_TARGET_MINIMUM_STAT = CONSCIOUS,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/bigot_specials,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/target_retaliate
	)

/mob/living/basic/bigot/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/ai_retaliate)
	start_roaring()

/datum/ai_planning_subtree/bigot_specials

/datum/ai_planning_subtree/bigot_specials/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bigot/B = controller.pawn
	if(!B)
		return
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	if(B.stat != CONSCIOUS)
		return
	if(world.time >= B.next_tongue_attack || world.time >= B.next_charge_attack)
		B.use_specials(target)

/mob/living/basic/bigot/melee_attack(atom/target)
	. = ..()
	if(!isliving(target))
		return
	//if(iscarbon(target))
		//target.adjustBleedStacks(2)
	if(prob(20))
		new /obj/effect/decal/cleanable/blood(get_turf(src))

/mob/living/basic/bigot/proc/tongue_tentacle(mob/living/target)
	if(world.time < next_tongue_attack)
		return FALSE
	if(!target)
		return FALSE
	if(!can_see(src, target, 10))
		return FALSE
	next_tongue_attack = world.time + tongue_cooldown
	visible_message(span_warning("[src] выпускает длинную окровавленную руку-тентаклю!"))
	if(prob(35))
		visible_message(span_notice("[target] уклоняется от тентакли [src]!"))
		return FALSE
	Beam(target, icon_state = "blood", time = 10)
	target.Immobilize(3 SECONDS)
	while(get_dist(src, target) > 1)
		new /obj/effect/decal/cleanable/blood(get_turf(target))
		step_towards(target, src)
		sleep(2)
	target.apply_damage(35, BRUTE)
	//if(iscarbon(target))
		//target.adjustBleedStacks(8)
	return TRUE

/mob/living/basic/bigot/proc/charge_attack(mob/living/target)
	if(world.time < next_charge_attack)
		return FALSE
	if(!target)
		return FALSE
	next_charge_attack = world.time + charge_cooldown
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

/mob/living/basic/bigot/proc/use_specials(mob/living/target)
	var/dist = get_dist(src, target)
	if(dist >= 4 && dist <= 8)
		tongue_tentacle(target)
		return
	if(dist >= 5 && dist <= 10)
		charge_attack(target)
		return

/mob/living/basic/bigot/proc/start_roaring()
	addtimer(CALLBACK(src, PROC_REF(play_roar)), rand(min_roar_delay, max_roar_delay))

/mob/living/basic/bigot/proc/play_roar()
	if(QDELETED(src) || stat == DEAD)
		return
	if(prob(40))
		visible_message(span_warning("[src] издаёт жуткий рык!"))
	playsound(get_turf(src), roar_sound, 75, TRUE)
	start_roaring()

/mob/living/basic/bigot/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	var/mob/living/carbon/human/H = locate() in view(7, src)
	if(H)
		tongue_tentacle(H)
		charge_attack(H)
