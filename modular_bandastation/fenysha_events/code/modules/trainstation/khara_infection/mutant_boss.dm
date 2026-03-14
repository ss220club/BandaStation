/mob/living/basic/khara_mutant/heat_of_infection
	name = "Сердце инфекции"
	desc = "Огромная мясная абоминация напоминающая что-то среднее между оторванной головой и бьющимся сердцем, \
			висит на потолке за складки сухожилий. Раззевает свой огромный рот выплевывая из него мерзкие остатки чего-то \
			живого. Это - ужасное создание."
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
		/datum/action/cooldown/mob_cooldown/throw_spider/strong = null,
	)

	var/list/mob/living/basic/khara_mutant/heat_of_infection_hand/hands = list()
	var/addictional_view_range = 7
	var/stage = 1

/mob/living/basic/khara_mutant/heat_of_infection/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 2)
		var/hand_type = (i % 2 == 1 ? /mob/living/basic/khara_mutant/heat_of_infection_hand/left : /mob/living/basic/khara_mutant/heat_of_infection_hand)
		hands += new hand_type(src)
	SSpoints_of_interest.make_point_of_interest(src)
	ADD_TRAIT(src, TRAIT_XRAY_VISION, INNATE_TRAIT)

	AddElement(/datum/element/simple_flying)
	notify_ghosts("Сердце инфекции только что появилось!", src, "Сердце инфекции")

	animate(src, pixel_y = -10, time = 2 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -30, time = 2 SECONDS, flags = ANIMATION_RELATIVE)

	addtimer(CALLBACK(src, PROC_REF(move_hands)), 1)
	update_sight()

/mob/living/basic/khara_mutant/heat_of_infection/Login()
	. = ..()
	client.view_size.setTo(addictional_view_range)

/mob/living/basic/khara_mutant/heat_of_infection/Logout()
	. = ..()
	client.view_size.resetToDefault()

/mob/living/basic/khara_mutant/heat_of_infection/Destroy()
	for(var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand as anything in hands)
		if(hand && !QDELETED(hand))
			qdel(hand)
	hands = null
	return ..()

/mob/living/basic/khara_mutant/heat_of_infection/proc/move_hands()
	if(!length(hands))
		return

	var/turf/boss_turf = get_turf(src)
	var/left_index = 1
	var/right_index = 1
	var/num_left = 0
	var/num_right = 0

	for(var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand as anything in hands)
		if(QDELETED(hand))
			continue
		if(istype(hand, /mob/living/basic/khara_mutant/heat_of_infection_hand/left))
			num_left++
		else
			num_right++

	var/spacing = 3
	var/min_dist = 1
	var/left_max_dist = max(7, min_dist + (num_left - 1) * spacing)
	var/right_max_dist = max(7, min_dist + (num_right - 1) * spacing)

	for(var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand as anything in hands)
		if(QDELETED(hand))
			continue

		var/is_left = istype(hand, /mob/living/basic/khara_mutant/heat_of_infection_hand/left)
		var/max_dist = is_left ? left_max_dist : right_max_dist
		var/index = is_left ? left_index : right_index
		var/dist = max_dist - (index - 1) * spacing
		var/dir = is_left ? WEST : EAST
		var/turf/hand_turf = boss_turf

		for(var/j in 1 to dist)
			hand_turf = get_step(hand_turf, dir)

		hand.forceMove(hand_turf)
		hand.home_turf = hand_turf

		hand.pixel_x = hand.base_pixel_x
		hand.pixel_y = hand.base_pixel_y

		if(is_left)
			left_index++
		else
			right_index++

/mob/living/basic/khara_mutant/heat_of_infection/proc/get_free_hand()
	var/list/available_hands = list()

	for(var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand as anything in hands)
		if(hand && !QDELETED(hand) && !hand.busy)
			available_hands += hand

	if(!length(available_hands))
		return null

	return pick(available_hands)

/mob/living/basic/khara_mutant/heat_of_infection/proc/add_new_hand()
	var/num_left = 0
	var/num_right = 0

	for(var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand as anything in hands)
		if(QDELETED(hand))
			continue
		if(istype(hand, /mob/living/basic/khara_mutant/heat_of_infection_hand/left))
			num_left++
		else
			num_right++

	var/left = (num_left <= num_right)
	var/hand_type = left ? /mob/living/basic/khara_mutant/heat_of_infection_hand/left : /mob/living/basic/khara_mutant/heat_of_infection_hand
	hands += new hand_type(src)
	move_hands()

/mob/living/basic/khara_mutant/heat_of_infection/proc/remove_hand()
	if(!length(hands))
		return
	var/mob/living/basic/khara_mutant/heat_of_infection_hand/hand = pick(hands)
	hands -= hand
	qdel(hand)
	move_hands()

/mob/living/basic/khara_mutant/heat_of_infection/proc/get_hands_count()
	return length(hands)

/mob/living/basic/khara_mutant/heat_of_infection/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	if(health <= 10000 && stage == 1)
		stage++
		for(var/i = get_hands_count() to 4)
			add_new_hand()
		for(var/datum/action/cooldown/ability in actions)
			ability.cooldown_time *= 0.5

	if(health <= 3000 && stage == 2)
		stage++
		for(var/i = get_hands_count() to 6)
			add_new_hand()

/mob/living/basic/khara_mutant/heat_of_infection_hand
	name = "Конечность"
	desc = "Огромная мерзкая конечность еще больше существа."
	icon = 'modular_bandastation/fenysha_events/icons/mob/256x256.dmi'
	icon_state = "scream_hand_r"
	icon_living = "scream_hand_r"
	icon_dead = "scream_hand_r"

	speed = -5
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
	var/maximum_distance = 40

/mob/living/basic/khara_mutant/heat_of_infection_hand/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living/basic/khara_mutant/heat_of_infection))
		owner = loc
	AddElement(/datum/element/simple_flying)

/mob/living/basic/khara_mutant/heat_of_infection_hand/Destroy()
	if(owner && !QDELETED(owner))
		owner.take_damage(1000, BRUTE)
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

	var/safety = maximum_distance
	while(get_turf(src) != target_turf && safety > 0)
		safety--
		forceMove(get_step_towards(src, target_turf))
		sleep(0.2 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(lower_to_turf), target_turf), 0.2 SECONDS)
	if(reset)
		reset_busy()

/mob/living/basic/khara_mutant/heat_of_infection_hand/proc/lower_to_turf(turf/target_turf)
	if(QDELETED(src))
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
		hand.move_to_target(target_turf)
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
	var/shards_per_turf = 1
	var/shard_waves = 3
	var/wave_delay = 1 SECONDS

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
	for(var/i = 1 to shard_waves)
		for(var/turf/T in target_turfs)
			for(var/j = 1 to shards_per_turf)
				owner_turf.fire_projectile(/obj/projectile/bullet/pellet/bone_fragment, T, firer = owner)
		sleep(wave_delay)
	CHECK_TICK

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
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "the_traps"

	cooldown_time = 30 SECONDS
	var/max_dist = 60

/datum/action/cooldown/mob_cooldown/deadly_roar/Activate(atom/target)
	for(var/mob/living/player in GLOB.alive_player_list)
		if(get_dist(owner, player) > max_dist)
			continue
		flash_color(player, flash_color = "#FF0000", flash_time = 50)
		shake_camera(player, 2 SECONDS, 1)
		to_chat(player, span_userdanger("[owner] истошно рычит, погружая вас в отчаянье!"))
		player.Shake(duration = 1 SECONDS)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/throw_spider/strong
	name = "Мясной шар"
	desc = "Выпускает мясной шар с существом внутри"

	projectile_type = /obj/projectile/meat_ball/huge
	cooldown_time = 7 SECONDS

/datum/action/cooldown/mob_cooldown/throw_spider/strong/Activate(atom/target)
	mob_type = pick(/mob/living/basic/khara_mutant/reaper, /mob/living/basic/khara_mutant/arachnid)
	. = ..()

GLOBAL_LIST_EMPTY(infection_lasers)

/obj/machinery/infection_laser
	name = "S-Jok лазер"
	desc = "Специальный лазер, предназначенный для борьбы с сердцем инфекции. Активируйте его, чтобы подготовить к атаке."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "explosive_compressor"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	uses_integrity = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	var/active = FALSE
	var/datum/beam/current_beam = null
	var/cooldown_time = 0

/obj/machinery/infection_laser/Initialize(mapload)
	. = ..()
	GLOB.infection_lasers += src
	update_visuals()

/obj/machinery/infection_laser/Destroy()
	GLOB.infection_lasers -= src
	qdel(current_beam)
	return ..()

/obj/machinery/infection_laser/proc/update_visuals()
	update_icon_state()
	if(!active)
		add_filter("story_outline", 2, list("type" = "outline", "color" = "#fa3b3b", "size" = 1))
	else
		remove_filter("story_outline")

/obj/machinery/infection_laser/update_icon_state()
	. = ..()
	icon_state = active ? "explosive_compressor-off" : "explosive_compressor"

/obj/machinery/infection_laser/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(active)
		to_chat(user, span_notice("Лазер уже активирован."))
		return
	if(world.time < cooldown_time)
		to_chat(user, span_warning("Лазер на перезарядке! Осталось [round((cooldown_time - world.time) / 10)] секунд."))
		return
	active = TRUE
	update_visuals()
	to_chat(user, span_notice("Вы активируете [src]."))
	check_all_active()

/obj/machinery/infection_laser/proc/check_all_active()
	for(var/obj/machinery/infection_laser/laser as anything in GLOB.infection_lasers)
		if(!laser.active)
			return FALSE
	activate_attack()
	return TRUE

/obj/machinery/infection_laser/proc/activate_attack()
	for(var/obj/machinery/infection_laser/laser as anything in GLOB.infection_lasers)
		laser.perform_attack()

/obj/machinery/infection_laser/proc/perform_attack()
	var/mob/living/basic/khara_mutant/heat_of_infection/target = null
	var/min_dist = INFINITY
	for(var/mob/living/basic/khara_mutant/heat_of_infection/heart in GLOB.mob_living_list)
		if(!istype(heart))
			continue
		var/dist = get_dist(src, heart)
		if(dist < min_dist)
			min_dist = dist
			target = heart
	if(!target)
		return
	playsound(src, 'sound/effects/magic/lightning_chargeup.ogg', 100)
	current_beam = Beam(get_turf(target), icon_state = "blood_beam", time = 11 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(deal_damage), target), 11 SECONDS)

/obj/machinery/infection_laser/proc/deal_damage(mob/living/basic/khara_mutant/heat_of_infection/target)
	if(QDELETED(target) || !target)
		return
	target.take_damage(100, BRUTE, "laser")
	qdel(current_beam)
	current_beam = null
	active = FALSE
	cooldown_time = world.time + 2 MINUTES
	addtimer(CALLBACK(src, PROC_REF(cooldown_end)), 2 MINUTES)
	for(var/obj/machinery/infection_laser/laser as anything in GLOB.infection_lasers)
		laser.after_shoot()

/obj/machinery/infection_laser/proc/cooldown_end()
	update_visuals()

/obj/machinery/infection_laser/proc/after_shoot()
	playsound(src, 'sound/items/weapons/beam_sniper.ogg', 100)


/obj/item/gun/energy/anti_khara
	name = "Анти-Кхара винтовка"
	desc = "Продвинутая энергетическая винтовка испускающую пучки энергии колебающиеся на особой частоте. \
			Тонкая настройка позволяет им атаковать исключительно абоминации Кхары - игнорируя другие живые цели."
	icon_state = "instagibgreen"
	inhand_icon_state = "instagibgreen"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(
		/obj/item/ammo_casing/energy/anti_khara,
		/obj/item/ammo_casing/energy/anti_khara/smart,
	)
	cell_type = /obj/item/stock_parts/power_store/cell/high
	clumsy_check = FALSE
	selfcharge = TRUE
	self_charge_amount = 1000
	automatic_charge_overlays = FALSE


/obj/item/gun/energy/anti_khara/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/energy/anti_khara/update_icon_state()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot, /obj/item/ammo_casing/energy/anti_khara/smart))
		inhand_icon_state = "instagibblue"
		icon_state = "instagibblue"
	else
		inhand_icon_state = "instagibgreen"
		icon_state = "instagibgreen"

/obj/item/gun/energy/anti_khara/examine(mob/user)
	. = ..()
	. += span_hypnophrase("Это невероятное оружие. \n")

	if(selfcharge)
		. += span_boldnicegreen("Ядро оружие автоматически восстанавливает энергию в нем.")
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot, /obj/item/ammo_casing/energy/anti_khara/smart))
		. += span_boldnotice("Включен умный режим стрельбы с доводкой по цели.")
	else
		. += span_boldnotice("Включен усиленный режим стрельбы с повышенным уроном.")



/obj/item/ammo_casing/energy/anti_khara
	projectile_type = /obj/projectile/energy/anti_khara
	select_name = "anti-khara"
	e_cost = LASER_SHOTS(100, STANDARD_CELL_CHARGE * 10)

/obj/item/ammo_casing/energy/anti_khara/smart
	projectile_type = /obj/projectile/energy/anti_khara/smart
	e_cost = LASER_SHOTS(30, STANDARD_CELL_CHARGE * 10)
	select_name = "smart anti-khara"

/obj/item/ammo_casing/energy/anti_khara/smart/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(is_khara_creature(target))
		loaded_projectile.set_homing_target(target)
		new /obj/effect/temp_visual/smartgun_target(get_turf(target))
	return ..()



/obj/projectile/energy/anti_khara
	name = "anti-khara bolt"
	icon_state = "spell"
	damage = 0
	damage_type = BRUTE
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara

	var/smart = FALSE
	var/khara_damage = 45

/obj/projectile/energy/anti_khara/Initialize(mapload)
	. = ..()
	if(!smart)
		var/matrix/big = matrix()
		big.Scale(2, 2,)
		animate(src, transform = big, time = 3 SECONDS)

/obj/effect/temp_visual/impact_effect/anti_khara
	icon_state = "mech_toxin"
	duration = 5

/obj/effect/temp_visual/impact_effect/anti_khara/smart
	icon_state = "shieldsparkles"

/obj/projectile/energy/anti_khara/smart
	name = "anti-khara smart bolt"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/anti_khara/smart
	smart = TRUE
	khara_damage = 25
	range = 10
	homing_turn_speed = 10
	homing_inaccuracy_min = 1
	homing_inaccuracy_max = 1

/obj/projectile/energy/anti_khara/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return BULLET_ACT_FORCE_PIERCE
		else
			L.take_overall_damage(khara_damage)
	return ..()

/obj/projectile/energy/anti_khara/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	if(isliving(target))
		var/mob/living/L = target
		if(!is_khara_creature(L))
			return FALSE
	return ..()

/obj/projectile/energy/anti_khara/Bump(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!is_khara_creature(L))
			return FALSE
	return ..()
