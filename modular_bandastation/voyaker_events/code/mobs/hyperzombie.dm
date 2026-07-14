/mob/living/basic/hyperzombie
	name = "гиперзомби"
	desc = "Его плоть светится ядовито-зелёным светом."
	icon = 'modular_bandastation/voyaker_events/icons/hyperzombie.dmi'
	icon_state = "hyperzombie"
	maxHealth = 270
	health = 270
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	attack_sound = 'sound/items/weapons/bite.ogg'
	light_color = COLOR_GREEN
	light_power = 1.4
	light_range = 2
	var/next_spit = 0
	var/spit_cooldown = 10 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/hyperzombie

/datum/ai_controller/basic_controller/hyperzombie
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
    	/datum/ai_planning_subtree/hyper_spit,
    	/datum/ai_planning_subtree/basic_melee_attack_subtree,
    	/datum/ai_planning_subtree/attack_obstacle_in_path,
    	/datum/ai_planning_subtree/target_retaliate
	)

/datum/ai_planning_subtree/hyper_spit

/datum/ai_planning_subtree/hyper_spit/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/hyperzombie/zombie = controller.pawn
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	if(world.time < zombie.next_spit)
		return
	var/dist = get_dist(zombie, target)
	if(dist <= 1)
		return
	if(dist > 5)
		return
	zombie.next_spit = world.time + zombie.spit_cooldown
	zombie.visible_message(span_warning("[zombie] извергает поток радиоактивной желчи!"))
	addtimer(CALLBACK(zombie, TYPE_PROC_REF(/mob/living/basic/hyperzombie, do_spit)), 5)


/mob/living/basic/hyperzombie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	addtimer(CALLBACK(src, PROC_REF(radiation_aura)), 1 SECONDS)

/mob/living/basic/hyperzombie/proc/radiation_aura()
	if(QDELETED(src))
		return
	radiation_pulse(src, max_range = 1, threshold = 0.1, chance = 80)
	addtimer(CALLBACK(src, PROC_REF(radiation_aura)), 1 SECONDS)

/mob/living/basic/hyperzombie/proc/do_spit()
	var/atom/target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	var/dir = get_dir(src, target)
	spit_step(get_turf(src), dir, 8)

/mob/living/basic/hyperzombie/proc/spit_step(turf/current, dir, remaining)
	if(remaining <= 0)
		return
	current = get_step(current, dir)
	if(!current)
		return
	for(var/obj/O in current)
		if(O.density)
			return
	var/obj/effect/decal/cleanable/greenglow/radioactive/puddle = new(current)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), puddle), 3 SECONDS)
	playsound(current, 'sound/effects/splat.ogg', 50)
	for(var/mob/living/L in current)
		L.Knockdown(2 SECONDS)
		L.apply_damage(20, BURN)
		radiation_pulse(L, max_range = 1, threshold = 0.1, chance = 60)
		break
	addtimer(CALLBACK(src, PROC_REF(spit_step), current, dir, remaining - 1), 1 DECISECONDS)
