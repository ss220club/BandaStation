/mob/living/basic/spider/sand
	name = "sand spider"
	desc = "A spider adapted to life beneath the desert sands."
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
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		targeting_strategy = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/sand_spider_logic,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_planning_subtree/sand_spider_logic

/datum/ai_planning_subtree/sand_spider_logic/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/spider/sand/spider = controller.pawn
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	if(spider.burrowed)
		return
	if(world.time < spider.next_burrow)
		return
	if(get_dist(spider,target) <= 3)
		return
	spider.current_target = target
	spider.visible_message(span_warning("[spider] резко начинает уходить под песок!"))
	addtimer(CALLBACK(spider, TYPE_PROC_REF(/mob/living/basic/spider/sand, enter_burrow)), 1 SECONDS)

/mob/living/basic/spider/sand/proc/enter_burrow()
	if(burrowed)
		return
	burrowed = TRUE
	next_burrow = world.time + burrow_cooldown
	burrow_steps = 0
	invisibility = INVISIBILITY_MAXIMUM
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags |= PASSMOB|PASSGRILLE|PASSMACHINE
	ADD_TRAIT(src, TRAIT_GODMODE, REF(src))
	remove_movespeed_modifier(/datum/movespeed_modifier/sand_walk)
	add_movespeed_modifier(/datum/movespeed_modifier/sand_burrow)
	playsound(src,'sound/effects/gravhit.ogg',60,TRUE)
	burrow_tick()

/mob/living/basic/spider/sand/proc/burrow_tick()
	if(!burrowed)
		return
	if(QDELETED(current_target))
		return leave_burrow()
	if(get_dist(src,current_target)<=1)
		return leave_burrow()
	if(burrow_steps>=max_burrow_steps)
		return leave_burrow()
	var/turf/T=get_step_towards(src,current_target)
	if(T)
		Move(T)
		playsound( src, 'sound/effects/bush/crunchybushwhack1.ogg', 35, TRUE)
	burrow_steps++
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/basic/spider/sand, burrow_tick)), 2)

/mob/living/basic/spider/sand/proc/leave_burrow()
	if(!burrowed)
		return
	burrowed=FALSE
	invisibility=0
	density=TRUE
	mouse_opacity=initial(mouse_opacity)
	pass_flags=initial(pass_flags)
	REMOVE_TRAIT(src,TRAIT_GODMODE,REF(src))
	remove_movespeed_modifier(/datum/movespeed_modifier/sand_burrow)
	add_movespeed_modifier(/datum/movespeed_modifier/sand_walk)
	playsound(src,'sound/effects/meteorimpact.ogg',70,TRUE)
	current_target=null
	burrow_steps=0
