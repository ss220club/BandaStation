/mob/living/basic/khara_mutant/heat_of_infection
	name = "Сердце инфекции"
	desc = "Огромная мерзость, напоминающая живое лёгкое. Извергает колоссальные объёмы заражённого миазмами Кхара тумана."
	cast = KHARA_CAST_ASSIMILATING
	icon = 'modular_bandastation/fenysha_events/icons/mob/256x256.dmi'
	icon_state = "screamer"
	icon_living = "screamer"
	icon_dead = "screamer"

	speed = 16
	maxHealth = 15000
	health = 15000

	anchored = TRUE
	regeneration_delay = 240 SECONDS
	health_regen_per_second = 30

	pixel_x = -100
	base_pixel_x = -100
	pixel_y = 0
	base_pixel_y = 0

	mob_size = MOB_SIZE_HUGE
	plane = MASSIVE_OBJ_PLANE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING

	ai_controller = null
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/boss_bone_shard = BB_MOB_ABILITY_BONESHARD,
		/datum/action/cooldown/mob_cooldown/throw_spider = BB_MOB_ABILITY_MEAT_BALL,
		/datum/action/cooldown/mob_cooldown/rumble = BB_MOB_ABILITY_RUMBLE,
	)

	var/mob/living/basic/khara_mutant/heat_of_infection_hand/left_hand = null
	var/mob/living/basic/khara_mutant/heat_of_infection_hand/right_hand = null

/mob/living/basic/khara_mutant/heat_of_infection/Initialize(mapload)
	. = ..()
	left_hand = new /mob/living/basic/khara_mutant/heat_of_infection_hand/left(src)
	right_hand = new /mob/living/basic/khara_mutant/heat_of_infection_hand(src)
	SSpoints_of_interest.make_point_of_interest(src)

	AddElement(/datum/element/simple_flying)
	notify_ghosts("Сердце инфекции только что появилось!", src, "Сердце инфекции")

	animate(src, pixel_y = -80, time = 2 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -100, time = 2 SECONDS, flags = ANIMATION_RELATIVE)

	addtimer(CALLBACK(src, PROC_REF(move_hands)), 1)

/mob/living/basic/khara_mutant/heat_of_infection/Destroy()
	if(left_hand && !QDELETED(left_hand))
		qdel(left_hand)
	if(right_hand && !QDELETED(right_hand))
		qdel(right_hand)
	return ..()

/mob/living/basic/khara_mutant/heat_of_infection/proc/move_hands()
	if(!left_hand || QDELETED(left_hand) || !right_hand || QDELETED(right_hand))
		return

	var/turf/boss_turf = get_turf(src)
	var/turf/left_turf = boss_turf
	var/turf/right_turf = boss_turf

	for(var/i in 1 to 7)
		left_turf = get_step(left_turf, WEST)
		right_turf = get_step(right_turf, EAST)

	left_hand.forceMove(left_turf)
	right_hand.forceMove(right_turf)

	left_hand.pixel_x = left_hand.base_pixel_x
	left_hand.pixel_y = left_hand.base_pixel_y
	right_hand.pixel_x = right_hand.base_pixel_x
	right_hand.pixel_y = right_hand.base_pixel_y


/mob/living/basic/khara_mutant/heat_of_infection/proc/get_free_hand()
	if(!left_hand || QDELETED(left_hand))
		left_hand = null
	if(!right_hand || QDELETED(right_hand))
		right_hand = null

	var/list/available_hands = list()
	if(left_hand && !left_hand.busy)
		available_hands += left_hand
	if(right_hand && !right_hand.busy)
		available_hands += right_hand

	if(!available_hands.len)
		return null

	return pick(available_hands)

/mob/living/basic/khara_mutant/heat_of_infection_hand
	name = "Конечность"
	desc = "Огромная мерзкая конечность еще больше существа."
	icon = 'modular_bandastation/fenysha_events/icons/mob/256x256.dmi'
	icon_state = "scream_hand_r"
	icon_living = "scream_hand_r"
	icon_dead = "scream_hand_r"

	speed = -1
	maxHealth = 5000
	health = 5000

	regeneration_delay = 240 SECONDS
	health_regen_per_second = 10

	pixel_x = -100
	base_pixel_x = -100
	pixel_y = -16
	base_pixel_y = -16

	mob_size = MOB_SIZE_HUGE
	plane = MASSIVE_OBJ_PLANE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING

	ai_controller = null

	var/datum/callback/attack_callback = null
	var/mob/living/basic/khara_mutant/heat_of_infection/owner
	var/busy = FALSE
	var/turf/home_turf

/mob/living/basic/khara_mutant/heat_of_infection_hand/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living/basic/khara_mutant/heat_of_infection))
		owner = loc
	AddElement(/datum/element/simple_flying)

/mob/living/basic/khara_mutant/heat_of_infection_hand/Destroy()
	if(owner && !QDELETED(owner))
		owner.take_damage(maxHealth, BRUTE)
	return ..()

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/prepare_for_attack()
	if(busy || QDELETED(src) || !owner)
		return FALSE

	busy = TRUE
	animate(src, pixel_y = base_pixel_y + 64, time = 10)
	return TRUE

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/finish_attack(cooldown_time = 10 SECONDS)
	animate(src, pixel_y = base_pixel_y, time = 10)
	addtimer(CALLBACK(src, PROC_REF(reset_busy)), cooldown_time)

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/reset_busy()
	busy = FALSE

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/move_to_target(turf/target_turf, reset = FALSE)
	if(busy || QDELETED(src) || !target_turf)
		return

	if(!prepare_for_attack())
		reset_busy()
		return
	home_turf = get_turf(src)
	var/distance = get_dist(home_turf, target_turf)
	for(var/i = 1 to distance)
		if(get_turf(src) == target_turf)
			break
		forceMove(get_step_towards(src, target_turf))
		sleep(0.5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(lower_to_turf), target_turf), 0.5 SECONDS)
	if(reset)
		reset_busy()
		home_turf = null

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/lower_to_turf(turf/target_turf)
	if(QDELETED(src) || get_turf(src) != target_turf)
		reset_busy()
		return
	if(attack_callback)
		attack_callback.Invoke(src, get_turf(src))
		attack_callback = null
	animate(src, pixel_y = base_pixel_y, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(return_to_home)), 5 SECONDS)

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/return_to_home()
	if(QDELETED(src) || !home_turf)
		reset_busy()
		return
	move_to_target(home_turf, TRUE)

/mob/living/basic/khara_mutant/heat_of_infection_hand/left
	icon_state = "scream_hand_l"
	icon_living = "scream_hand_l"
	icon_dead = "scream_hand_l"

