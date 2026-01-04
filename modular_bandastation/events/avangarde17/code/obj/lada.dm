// MARK: BOBIK
// Машина ИзАда. Чат гпт не помог сделать блокер и фары, терпим.

/obj/vehicle/sealed/car/lada
	name = "ВАЗ-220107"
	desc = "Легендарный автомобиль, перевыпущенный в новом корпусе, с новой краской и всё той же начинкой."
	icon = 'modular_bandastation/events/avangarde17/icons/lada.dmi'
	icon_state = "car"
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -32
	pixel_x = -32
	enter_delay = 1 SECONDS
	escape_time = 1 SECONDS
	vehicle_move_delay = 1
	key_type = /obj/item/key/lada
	enter_sound = 'sound/vehicles/clown_car/door_close.ogg'
	exit_sound = 'sound/vehicles/clown_car/door_open.ogg'

	var/crash_all = FALSE
	headlights_toggle = FALSE

	var/obj/effect/bobik_headlight/headlight_left
	var/obj/effect/bobik_headlight/headlight_right

	var/obj/effect/bobik_blocker/front_blocker
	var/obj/effect/bobik_blocker/back_blocker

/obj/vehicle/sealed/car/lada/Initialize(mapload)
	. = ..()
	create_headlights()
	create_blockers()
	update_headlight_positions()
	update_headlights()
	update_blockers()

/obj/vehicle/sealed/car/lada/Destroy()
	QDEL_NULL(headlight_left)
	QDEL_NULL(headlight_right)
	QDEL_NULL(front_blocker)
	QDEL_NULL(back_blocker)
	return ..()

// HEADLIGHTS

/obj/vehicle/sealed/car/lada/proc/create_headlights()
	if(!headlight_left)
		headlight_left = new /obj/effect/bobik_headlight(src)
	if(!headlight_right)
		headlight_right = new /obj/effect/bobik_headlight(src)

/obj/vehicle/sealed/car/lada/proc/update_headlight_positions()
	if(!headlight_left || !headlight_right)
		return

	headlight_left.loc = src
	headlight_right.loc = src

	switch(dir)
		if(NORTH)
			headlight_left.pixel_x = -22
			headlight_left.pixel_y = 36
			headlight_right.pixel_x = 22
			headlight_right.pixel_y = 36
		if(SOUTH)
			headlight_left.pixel_x = -22
			headlight_left.pixel_y = -36
			headlight_right.pixel_x = 22
			headlight_right.pixel_y = -36
		if(EAST)
			headlight_left.pixel_x = 36
			headlight_left.pixel_y = 22
			headlight_right.pixel_x = 36
			headlight_right.pixel_y = -22
		if(WEST)
			headlight_left.pixel_x = -36
			headlight_left.pixel_y = 22
			headlight_right.pixel_x = -36
			headlight_right.pixel_y = -22

/obj/vehicle/sealed/car/lada/proc/update_headlights()
	if(!headlight_left || !headlight_right)
		return
	headlight_left.set_light_on(headlights_toggle)
	headlight_right.set_light_on(headlights_toggle)

// BLOCKERS

/obj/vehicle/sealed/car/lada/proc/create_blockers()
	if(!front_blocker)
		front_blocker = new /obj/effect/bobik_blocker(src)
	if(!back_blocker)
		back_blocker = new /obj/effect/bobik_blocker(src)

/obj/vehicle/sealed/car/lada/proc/update_blockers()
	if(!front_blocker || !back_blocker)
		return

	front_blocker.loc = src
	back_blocker.loc = src

	front_blocker.pixel_x = 0
	front_blocker.pixel_y = 0
	back_blocker.pixel_x = 0
	back_blocker.pixel_y = 0

	switch(dir)
		if(EAST)
			front_blocker.pixel_x = 48
			back_blocker.pixel_x = -48
		if(WEST)
			front_blocker.pixel_x = -48
			back_blocker.pixel_x = 48
		else
			front_blocker.invisibility = INVISIBILITY_MAXIMUM
			back_blocker.invisibility = INVISIBILITY_MAXIMUM
			return

	front_blocker.invisibility = 0
	back_blocker.invisibility = 0

// MOVEMENT HOOKS

/obj/vehicle/sealed/car/lada/setDir(newdir)
	. = ..()
	update_headlight_positions()
	update_blockers()

/obj/vehicle/sealed/car/lada/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	update_headlight_positions()
	update_blockers()

// COLLISION

/obj/vehicle/sealed/car/lada/Bump(atom/bumped)
	. = ..()
	if(!bumped || !bumped.density || occupant_amount() == 0)
		return

	if(crash_all && ismovable(bumped))
		var/atom/movable/M = bumped
		M.throw_at(get_edge_target_turf(bumped, dir), 4, 3)

	if(!ishuman(bumped))
		return

	var/mob/living/carbon/human/H = bumped
	H.Paralyze(100)
	H.adjust_stamina_loss(30)
	H.apply_damage(rand(20,35), BRUTE)
	H.throw_at(get_edge_target_turf(bumped, dir), 4, 3)

// ACTIONS

/obj/vehicle/sealed/car/lada/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/bobik_headlights, VEHICLE_CONTROL_DRIVE)

// KEY

/obj/item/key/lada
	name = "ключи от Лады"
	desc = "Не вишнёвая семёрка, но тоже порядок."
