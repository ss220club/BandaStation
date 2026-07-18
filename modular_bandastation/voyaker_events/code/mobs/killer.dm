/datum/targeting_strategy/basic/not_kamilla_friends

/datum/targeting_strategy/basic/not_kamilla_friends/can_attack(mob/living/living_mob, atom/target, vision_range)
	if(!..())
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if((H.trader_rep[TRADER_KAMILLA] || 0) >= 50)
			return FALSE
	return TRUE

/mob/living/basic/killer
	name = "убийца"
	desc = "Выглядит как профессиональный наёмник. Одёт в тёмный прорезиненный комбинезон с кевларовыми подкладками. Его глаза ужасающе светятся красным сквозь баллистическую маску - видимо, это очки термального зрения. На поясе находятся дымовые и осколочные гранаты, в руке - сжимает УЗИ с глушителем, за спиной - верная катана. На кого работает - неизвестно."
	icon = 'modular_bandastation/voyaker_events/icons/assasin.dmi'
	icon_state = "s-ninja"
	maxHealth = 200
	health = 200
	melee_damage_lower = 20
	melee_damage_upper = 35
	melee_attack_cooldown = 1.5 SECONDS
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	move_force = MOVE_FORCE_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_WEAK
	ai_controller = /datum/ai_controller/basic_controller/killer
	var/uzi_burst = 3
	var/next_uzi = 0
	var/uzi_cooldown = 3 SECONDS
	var/next_smoke = 0
	var/smoke_cooldown = 12 SECONDS
	var/next_grenade = 0
	var/grenade_cooldown = 30 SECONDS
	var/retreating = FALSE
	var/heal_amount = 15
	var/heal_interval = 1 SECONDS
	var/heal_duration = 10
	var/healing = FALSE

/datum/ai_controller/basic_controller/killer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_kamilla_friends,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining/get_target_priority,
		BB_VISION_RANGE = 15,
		BB_TARGET_MINIMUM_STAT = CONSCIOUS,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/killer_logic,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/target_retaliate
	)

/datum/ai_planning_subtree/killer_logic

/datum/ai_planning_subtree/killer_logic/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/killer/killer = controller.pawn
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	var/dist = get_dist(killer, target)
	if(killer.health <= 75)
		if(world.time >= killer.next_grenade)
			killer.next_grenade = world.time + killer.grenade_cooldown
			killer.release_grenade(target)
			killer.begin_retreat(target)
			return
	if(dist > 3 && dist <= 10)
		if(world.time >= killer.next_uzi)
			killer.next_uzi = world.time + killer.uzi_cooldown
			killer.fire_uzi(target)
			return
	if(dist <= 3)
		if(world.time >= killer.next_smoke)
			killer.next_smoke = world.time + killer.smoke_cooldown
			killer.release_smoke()

/datum/movespeed_modifier/killer_fast
    multiplicative_slowdown = -0.5

/mob/living/basic/killer/Initialize(mapload)
	. = ..()
	faction = list("Syndicate")
	add_movespeed_modifier(/datum/movespeed_modifier/killer_fast)

/mob/living/basic/killer/proc/shoot_single(atom/target)
	face_atom(target)
	fire_projectile(/obj/projectile/bullet, target, 'sound/items/weapons/gun/smg/shot_suppressed.ogg')

/mob/living/basic/killer/proc/fire_uzi(atom/target)
	if(QDELETED(target))
		return
	visible_message(span_warning("[src] открывает огонь!"))
	fire_uzi_burst(target, uzi_burst)

/mob/living/basic/killer/proc/fire_uzi_burst(atom/target, shots_left)
	if(QDELETED(src) || QDELETED(target))
		return
	if(shots_left <= 0)
		return
	shoot_single(target)
	addtimer(
		CALLBACK(src, PROC_REF(fire_uzi_burst), target, shots_left - 1), 2 DECISECONDS)

/mob/living/basic/killer/proc/release_smoke()
	if(QDELETED(src))
		return
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_smoke(4, src, get_turf(src), smoke_type = /datum/effect_system/fluid_spread/smoke/bad)

/mob/living/basic/killer/proc/release_grenade(mob/living/target)
	if(QDELETED(target))
		return
	var/turf/T = get_step_towards(get_turf(src), get_turf(target))
	if(!T)
		return
	var/obj/item/grenade/G = new /obj/item/grenade/frag(T)
	G.arm_grenade(src)
	visible_message(span_warning("[src] бросает гранату!"))
	G.throw_at(T, 5, 1)

/mob/living/basic/killer/proc/begin_retreat(mob/living/target)
	if(retreating)
		return
	retreating = TRUE
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_smoke(4, src, get_turf(src), smoke_type = /datum/effect_system/fluid_spread/smoke/bad)
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	retreat_step(target, 30)
	addtimer(CALLBACK(src, PROC_REF(begin_healing)), 5 SECONDS)

/mob/living/basic/killer/proc/retreat_step(mob/living/target, steps_left)
	if(!retreating)
		return
	if(QDELETED(src))
		return
	if(QDELETED(target))
		return
	if(steps_left <= 0)
		retreating = FALSE
		return
	var/turf/T = get_step_away(src, target)
	if(T)
		Move(T)
	addtimer(CALLBACK(src, PROC_REF(retreat_step), target, steps_left - 1), 2)

/mob/living/basic/killer/proc/begin_healing()
	if(QDELETED(src))
		return
	if(health >= maxHealth)
		return
	if(healing)
		return
	healing = TRUE
	heal_tick(heal_duration)

/mob/living/basic/killer/proc/heal_tick(remaining)
	if(QDELETED(src))
		return
	if(!healing)
		return
	if(remaining <= 0)
		healing = FALSE
		return
	if(health < maxHealth)
		heal_overall_damage(min(maxHealth, health + heal_amount))
	addtimer(CALLBACK(src, PROC_REF(heal_tick), remaining - 1), heal_interval)
