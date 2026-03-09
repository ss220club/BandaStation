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
		/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/bones = null,
		/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/rumbling = null,
		/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave = null,
		/datum/action/cooldown/mob_cooldown/deadly_roar = null,
	)

	var/mob/living/basic/khara_mutant/heat_of_infection_hand/left_hand = null
	var/mob/living/basic/khara_mutant/heat_of_infection_hand/right_hand = null
	var/addictional_view_range = 7

/mob/living/basic/khara_mutant/heat_of_infection/Initialize(mapload)
	. = ..()
	left_hand = new /mob/living/basic/khara_mutant/heat_of_infection_hand/left(src)
	right_hand = new /mob/living/basic/khara_mutant/heat_of_infection_hand(src)
	SSpoints_of_interest.make_point_of_interest(src)
	ADD_TRAIT(src, TRAIT_XRAY_VISION, INNATE_TRAIT)

	AddElement(/datum/element/simple_flying)
	notify_ghosts("Сердце инфекции только что появилось!", src, "Сердце инфекции")

	animate(src, pixel_y = -80, time = 2 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -100, time = 2 SECONDS, flags = ANIMATION_RELATIVE)

	addtimer(CALLBACK(src, PROC_REF(move_hands)), 1)
	update_sight()

/mob/living/basic/khara_mutant/heat_of_infection/Login()
	. = ..()
	client.view_size.setTo(addictional_view_range)

/mob/living/basic/khara_mutant/heat_of_infection/Logout()
	. = ..()
	client.view_size.resetToDefault()

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
		sleep(0.3 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(lower_to_turf), target_turf), 0.2 SECONDS)
	if(reset)
		reset_busy()
		home_turf = null

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/lower_to_turf(turf/target_turf)
	if(QDELETED(src) || get_turf(src) != target_turf)
		reset_busy()
		return

	animate(src, pixel_y = base_pixel_y, time = 0.3 SECONDS)
	sleep(0.3 SECONDS)
	if(attack_callback)
		ASYNC
			attack_callback.Invoke(src, get_turf(src))
		attack_callback = null

	addtimer(CALLBACK(src, PROC_REF(return_to_home)), 3 SECONDS)

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/return_to_home()
	if(QDELETED(src) || !home_turf)
		reset_busy()
		return
	reset_busy()
	move_to_target(home_turf, TRUE)

/mob/living/basic/khara_mutant/heat_of_infection_hand/left
	icon_state = "scream_hand_l"
	icon_living = "scream_hand_l"
	icon_dead = "scream_hand_l"



/datum/action/cooldown/mob_cooldown/heat_of_infection
	name = "Атака настоящего босса"
	check_flags = NONE
	cooldown_time = 10 SECONDS
	text_cooldown = TRUE
	click_to_activate = TRUE
	shared_cooldown = NONE

	var/mob/living/basic/khara_mutant/heat_of_infection/boss_owner = null

/datum/action/cooldown/mob_cooldown/heat_of_infection/Grant(mob/granted_to)
	if(!istype(granted_to, /mob/living/basic/khara_mutant/heat_of_infection))
		qdel(src)
		return
	. = ..()
	boss_owner = owner

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack
	name = "Удар рукой"
	desc = "Использовать одну из своих рук, чтобы атаковать зону."
	cooldown_time = 1 SECONDS

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/IsAvailable(feedback)
	if(!boss_owner.get_free_hand())
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/Activate(atom/target)
	. = ..()
	var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand = boss_owner.get_free_hand()
	var/turf/target_turf = get_turf(target)
	if(!hand)
		to_chat(boss_owner, span_danger("Нет доступных рук!"))
		StartCooldown()
		return
	hand.attack_callback = CALLBACK(src, PROC_REF(on_attack))
	boss_owner.visible_message(span_danger("[boss_owner] заносит свою руку для атаки!"))
	for(var/turf/T in view(1, target_turf))
		new /obj/effect/temp_visual/telegraphing/boss_hit(T)
	ASYNC
		hand.move_to_target(target)
	CHECK_TICK

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/proc/on_attack(mob/living/basic/khara_mutant/heat_of_infection_hand/hand, turf/attacked_turf)
	if(!attacked_turf)
		return
	playsound(attacked_turf, 'sound/effects/bang.ogg', 70)
	for(var/turf/T in view(1, attacked_turf))
		for(var/mob/living/L in T.contents)
			if(L == boss_owner)
				continue
			L.Knockdown(2 SECONDS)
			L.take_overall_damage(rand(25, 50))
			if(prob(50))
				var/dir = pick(GLOB.cardinals)
				var/throw_dist = rand(1, 5)
				var/turf/target_turf = get_ranged_target_turf(L, dir, throw_dist)
				L.throw_at(target_turf, throw_dist, 1.6, boss_owner, spin = FALSE)
	CHECK_TICK


/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/bones
	name = "Костяной удар"
	desc = "Ударить рукой по зоне, чтобы вызвать удар костями"

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/bones/on_attack(mob/living/basic/khara_mutant/heat_of_infection_hand/hand, turf/attacked_turf)
	. = ..()
	for(var/dir in GLOB.cardinals.Copy())
		var/turf/attack_direction = get_ranged_target_turf(hand, dir, 1)
		if(attack_direction)
			for(var/i = 1 to 3)
				attack_direction.fire_projectile(/obj/projectile/bullet/pellet/bone_fragment, attack_direction, firer = boss_owner)
	CHECK_TICK

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/rumbling
	name = "Силовой удар"
	desc = "Ударить рукой по зоне, чтобы вызвать ударную волну"

/datum/action/cooldown/mob_cooldown/heat_of_infection/hand_attack/rumbling/on_attack(mob/living/basic/khara_mutant/heat_of_infection_hand/hand, turf/attacked_turf)
	. = ..()
	for(var/current_radius in 1 to 4)
		sleep(1.5 + (current_radius * 0.8))
		var/list/ring_turfs = list()
		for(var/turf/T in range(current_radius, attacked_turf))
			if(get_dist(attacked_turf, T) == current_radius)
				ring_turfs += T
		if(!length(ring_turfs))
			continue
		for(var/turf/T in ring_turfs)
			animate(T, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 3, loop = 2, easing = JUMP_EASING)
			animate(pixel_x = 0, pixel_y = 0, time = 4)
		CHECK_TICK
		var/volume = clamp(90 - (current_radius * 12), 30, 90)
		playsound(attacked_turf, 'sound/effects/bang.ogg', volume, TRUE, frequency = 0.7 + (current_radius * 0.04))
		for(var/mob/living/L in range(current_radius + 1, attacked_turf))
			if(L == boss_owner)
				continue
			if(L.incorporeal_move)
				continue
			var/dist = get_dist(attacked_turf, L)
			if(dist < current_radius - 1 || dist > current_radius + 1.5)
				continue
			var/strength = clamp((4 - dist + 1), 1, 4)
			L.apply_damage(5 + strength * 2.5, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
			L.Knockdown(2 SECONDS + strength * 1.2)
			L.Paralyze(0.4 SECONDS)
		CHECK_TICK
		for(var/mob/M in range(5, attacked_turf))
			if(current_radius <= 3)
				shake_camera(M, 4, 1.5 + (current_radius * 0.4))
			else
				shake_camera(M, 3, 1)



/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave
	name = "Костяная волна"
	desc = "Выпускает косяную волну в указанном направлении."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_turret"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	click_to_activate = TRUE
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	var/max_range = 15
	var/shard_delay = 3 SECONDS
	var/shard_sound = 'sound/effects/splat.ogg'
	var/wave_width = 11
	var/shards_per_turf = 3

/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave/PreActivate(atom/target)
	target = get_turf(target)
	if (get_dist(owner, target) > max_range)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave/Activate(atom/target)
	INVOKE_ASYNC(src, PROC_REF(do_hurl_wave), get_turf(target))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave/proc/do_hurl_wave(turf/target)
	owner.visible_message(span_danger("[owner] ГОТОВИТЬСЯ ВЫПУСТИТЬ ВОЛНУ СНАРЯДОВ!"))
	var/turf/start = get_turf(owner)
	var/list/target_turfs = get_wave_turfs(start, target, wave_width)
	for(var/turf/T in target_turfs)
		new /obj/effect/temp_visual/telegraphing/boss_hit(T)
	sleep(shard_delay)
	owner.visible_message(span_danger("[owner] ВЫПУСКАЕТ ВОЛНУ СНАРЯДОВ!"))
	if(shard_sound)
		playsound(owner, shard_sound, 50, TRUE)
	var/turf/owner_turf = get_turf(owner)
	for(var/turf/T in target_turfs)
		for(var/i = 1 to shards_per_turf)
			owner_turf.fire_projectile(/obj/projectile/bullet/pellet/bone_fragment, T, firer = owner)
			sleep(0.1 SECONDS)

/datum/action/cooldown/mob_cooldown/boss_bone_shard_wave/proc/get_wave_turfs(turf/start, turf/target, width)
	var/list/turfs = list()
	var/dir = get_dir(start, target)
	var/perp_dir1 = turn(dir, 90)
	var/perp_dir2 = turn(dir, -90)

	turfs += target

	var/turf/current = target
	for(var/i = 1 to (width - 1) / 2)
		current = get_step(current, perp_dir1)
		if(current && get_dist(start, current) <= max_range)
			turfs += current

	current = target
	for(var/i = 1 to (width - 1) / 2)
		current = get_step(current, perp_dir2)
		if(current && get_dist(start, current) <= max_range)
			turfs += current
	return turfs


/datum/action/cooldown/mob_cooldown/deadly_roar
	name = "Смертоносный крик"
	desc = "Испустить истошный крик!"
