// MARK: BOBIK
// Машина ИзАда. Чат гпт не помог сделать блокер и фары, терпим.

/obj/vehicle/sealed/car/bobik
	name = "УАЗ 2558"
	desc = "Легендарный Бобик, произведенный в 2558 году по секретным чертежам НИИ СССПБМТУ-ФК. Под капотом, разумеется, плазменный двигатель."
	icon = 'modular_bandastation/events/avangarde17/icons/bobik.dmi'
	icon_state = "bobik"
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -32
	pixel_x = -32
	enter_delay = 1 SECONDS
	escape_time = 1 SECONDS
	vehicle_move_delay = 1.5
	key_type = /obj/item/key/bobik
	enter_sound = 'sound/vehicles/clown_car/door_close.ogg'
	exit_sound = 'sound/vehicles/clown_car/door_open.ogg'

	var/crash_all = FALSE
	headlights_toggle = FALSE

	var/obj/effect/bobik_headlight/headlight_left
	var/obj/effect/bobik_headlight/headlight_right

	var/obj/effect/bobik_blocker/front_blocker
	var/obj/effect/bobik_blocker/back_blocker

	var/datum/looping_sound/siren/weewooloop
	var/siren_is_on = FALSE

/obj/vehicle/sealed/car/bobik/Initialize(mapload)
	. = ..()
	create_headlights()
	create_blockers()
	update_headlight_positions()
	update_headlights()
	update_blockers()
	weewooloop = new(src, FALSE, FALSE)

/obj/vehicle/sealed/car/bobik/Destroy()
	QDEL_NULL(headlight_left)
	QDEL_NULL(headlight_right)
	QDEL_NULL(front_blocker)
	QDEL_NULL(back_blocker)
	QDEL_NULL(weewooloop)
	return ..()

// HEADLIGHTS

/obj/vehicle/sealed/car/bobik/proc/create_headlights()
	if(!headlight_left)
		headlight_left = new /obj/effect/bobik_headlight(src)
	if(!headlight_right)
		headlight_right = new /obj/effect/bobik_headlight(src)

/obj/vehicle/sealed/car/bobik/proc/update_headlight_positions()
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

/obj/vehicle/sealed/car/bobik/proc/update_headlights()
	if(!headlight_left || !headlight_right)
		return
	headlight_left.set_light_on(headlights_toggle)
	headlight_right.set_light_on(headlights_toggle)

// BLOCKERS

/obj/vehicle/sealed/car/bobik/proc/create_blockers()
	if(!front_blocker)
		front_blocker = new /obj/effect/bobik_blocker(src)
	if(!back_blocker)
		back_blocker = new /obj/effect/bobik_blocker(src)

/obj/vehicle/sealed/car/bobik/proc/update_blockers()
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

/obj/vehicle/sealed/car/bobik/setDir(newdir)
	. = ..()
	update_headlight_positions()
	update_blockers()

/obj/vehicle/sealed/car/bobik/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	update_headlight_positions()
	update_blockers()

// COLLISION

/obj/vehicle/sealed/car/bobik/Bump(atom/bumped)
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

/obj/vehicle/sealed/car/bobik/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/bobik_headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/lets_ride, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/bobik_siren, VEHICLE_CONTROL_DRIVE)

// KEY

/obj/item/key/bobik
	name = "ключи от Бобика"
	desc = "Береги их как зеницу ока."

// HEADLIGHT ATOM

/obj/effect/bobik_headlight
	anchored = FALSE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = FLOAT_LAYER
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 6
	light_power = 2
	light_color = LIGHT_COLOR_TUNGSTEN
	light_on = FALSE
	invisibility = INVISIBILITY_MAXIMUM

// BLOCKER ATOM

/obj/effect/bobik_blocker
	anchored = TRUE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = BELOW_MOB_LAYER
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/bobik_blocker/CanAllowThrough(atom/movable/mover, border_dir)
	if(mover == loc)
		return TRUE
	return ..()

// HEADLIGHT ACTION

/datum/action/vehicle/sealed/bobik_headlights
	name = "Toggle Headlights"
	desc = "Turn on your brights!"
	button_icon_state = "car_headlights"

/datum/action/vehicle/sealed/bobik_headlights/Trigger(mob/clicker, trigger_flags)
	var/obj/vehicle/sealed/car/bobik/B = vehicle_entered_target
	if(!istype(B))
		return
	B.headlights_toggle = !B.headlights_toggle
	B.update_headlights()
	B.update_appearance()
	playsound(owner, B.headlights_toggle ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 40, TRUE)

// MILITIA SIREN ACTION

/datum/action/vehicle/sealed/bobik_siren
	name = "Toggle Siren"
	desc = "Turn on your WEEEEOOO-WEEEEOOO!"
	button_icon = 'icons/obj/clothing/head/helmet.dmi'
	button_icon_state = "justice"

/datum/action/vehicle/sealed/bobik_siren/Trigger(mob/clicker, trigger_flags)
	var/obj/vehicle/sealed/car/bobik/B = vehicle_entered_target
	if(!istype(B))
		return
	if(B.siren_is_on)
		B.weewooloop.stop()
		B.icon_state = "bobik"
		B.siren_is_on = FALSE
	else
		B.weewooloop.start()
		B.icon_state = "bobik_siren"
		B.siren_is_on = TRUE
	B.update_appearance()
	playsound(owner, B.headlights_toggle ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 40, TRUE)

// LETS RIDE

/datum/action/vehicle/sealed/lets_ride
	name = "По коням!"
	desc = "Сообщить водителю о срочном выезде."
	button_icon = 'icons/obj/devices/voice.dmi'
	button_icon_state = "megaphone"
	COOLDOWN_DECLARE(lets_ride_cooldown)

/datum/action/vehicle/sealed/lets_ride/Trigger(mob/clicker, trigger_flags)
	if(!COOLDOWN_FINISHED(src, lets_ride_cooldown))
		return
	COOLDOWN_START(src, lets_ride_cooldown, 6 SECONDS)

	var/obj/vehicle/sealed/V = vehicle_entered_target
	var/list/drivers = V.return_drivers()
	if(!length(drivers))
		return

	var/mob/driver = pick(drivers)
	owner.say("[driver.name], у нас труп, возможно криминал. По коням!")

//SIREN
/datum/looping_sound/siren_high_volume
	mid_sounds = list('modular_bandastation/events/avangarde17/audio/angry_communist_speach.ogg' = 1)
	volume = 50
