/mob/living/basic/spider/sand
	name = "sand spider"
	desc = "A spider adapted to life beneath the desert sands. You notice that its chelicerae and front legs have a slightly rounded, scoop-like shape. It is possible that it can use them to dig quite rapidly."
	icon = 'modular_bandastation/voyaker_events/icons/arachnoid.dmi'
	icon_state = "desert"
	maxHealth = 150
	health = 150
	poison_type = /datum/reagent/toxin/hunterspider
	poison_per_bite = 4
	melee_damage_lower = 10
	melee_damage_upper = 25
	melee_attack_cooldown = 2 SECONDS
	web_type = null
	ai_controller = /datum/ai_controller/basic_controller/spider/sand
	var/burrowed = FALSE
	var/burrow_steps = 0
	var/max_burrow_steps = 10
	var/mob/living/current_target
	var/next_burrow = 0
	var/burrow_cooldown = 10 SECONDS

/datum/movespeed_modifier/sand_walk
	multiplicative_slowdown = 0.45

/datum/movespeed_modifier/sand_burrow
	multiplicative_slowdown = -0.75

/mob/living/basic/spider/sand/Initialize(mapload)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/sand_walk)

/datum/ai_controller/basic_controller/spider/sand
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/sand_spider.bt.json"

/datum/bt_node/ai_behavior/sand_spider_logic
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key

/datum/bt_node/ai_behavior/sand_spider_logic/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/spider/sand/spider = controller.pawn
	if(!spider)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[hiding_location_key]
	if(!target)
		target = controller.blackboard[target_key]
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(spider.burrowed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < spider.next_burrow)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(spider, target) <= 3)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(spider, TYPE_PROC_REF(/mob/living/basic/spider/sand, start_burrow), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/mob/living/basic/spider/sand/proc/start_burrow(mob/living/target)
	if(burrowed)
		return
	current_target = target
	next_burrow = world.time + burrow_cooldown
	Shake(2, 1 SECONDS)
	visible_message(span_warning("[src] резко уходит под песок!"))
	addtimer(CALLBACK(src, PROC_REF(enter_burrow)), 1 SECONDS)

/mob/living/basic/spider/sand/proc/enter_burrow()
	if(QDELETED(src))
		return
	burrowed = TRUE
	burrow_steps = 0
	invisibility = INVISIBILITY_MAXIMUM
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags |= PASSMOB | PASSGRILLE | PASSMACHINE
	ADD_TRAIT(src, TRAIT_GODMODE, REF(src))
	remove_movespeed_modifier(/datum/movespeed_modifier/sand_walk)
	add_movespeed_modifier(/datum/movespeed_modifier/sand_burrow)
	playsound(src,'sound/effects/gravhit.ogg',60,TRUE)
	burrow_step()

/mob/living/basic/spider/sand/proc/burrow_step()
	if(!burrowed)
		return
	if(QDELETED(current_target))
		return finish_burrow()
	if(get_dist(src, current_target) <= 1)
		return finish_burrow()
	if(burrow_steps >= max_burrow_steps)
		return finish_burrow()
	step_towards(src, current_target)
	playsound(src,'sound/effects/bush/crunchybushwhack1.ogg',35,TRUE)
	burrow_steps++
	addtimer(CALLBACK(src, PROC_REF(burrow_step)), 2 DECISECONDS)

/mob/living/basic/spider/sand/proc/finish_burrow()
	if(!burrowed)
		return
	burrowed = FALSE
	invisibility = initial(invisibility)
	density = TRUE
	mouse_opacity = initial(mouse_opacity)
	pass_flags = initial(pass_flags)
	REMOVE_TRAIT(src, TRAIT_GODMODE, REF(src))
	remove_movespeed_modifier(/datum/movespeed_modifier/sand_burrow)
	add_movespeed_modifier(/datum/movespeed_modifier/sand_walk)
	playsound(src,'sound/effects/meteorimpact.ogg',70,TRUE)
	if(current_target && get_dist(src,current_target)<=1)
		current_target.Knockdown(2 SECONDS)
		current_target.apply_damage(15, BRUTE)
	current_target = null
	burrow_steps = 0
