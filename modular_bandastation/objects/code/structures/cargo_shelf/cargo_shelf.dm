#define CARGO_SHELF_CAPACITY 3
#define CARGO_SHELF_VERTICAL_OFFSET 10
#define CARGO_SHELF_USE_DELAY (1 SECONDS)

/datum/armor/structure_cargo_shelf
	melee = 20
	bullet = 10
	laser = 10
	bomb = 10
	fire = 70
	acid = 60

/obj/structure/cargo_shelf
	name = "crate shelf"
	desc = "Полка для хранения ящиков."
	icon = 'modular_bandastation/aesthetics/rack/icons/rack.dmi'
	icon_state = "rack"
	density = TRUE
	anchored = TRUE
	gender = FEMALE
	armor_type = /datum/armor/structure_cargo_shelf

	VAR_FINAL/capacity = CARGO_SHELF_CAPACITY
	var/use_delay = CARGO_SHELF_USE_DELAY
	var/list/crates_stored

/obj/structure/cargo_shelf/Initialize(mapload)
	. = ..()

	crates_stored = new /list(capacity)

/obj/structure/cargo_shelf/Destroy()
	for(var/slot in 1 to length(crates_stored))
		var/obj/structure/closet/crate/crate = crates_stored[slot]
		if(crate)
			crate.forceMove(drop_location())

	return ..()

/obj/structure/cargo_shelf/proc/crate_count()
	var/count = 0

	for(var/crate in crates_stored)
		if(crate)
			count++

	return count

/obj/structure/cargo_shelf/proc/get_shelf_slot(y_offset)
	if(y_offset <= 12)
		return 1

	if(y_offset <= 21)
		return 2

	return 3

/obj/structure/cargo_shelf/proc/can_load(obj/structure/closet/crate/crate, mob/user, y_offset)
	if(crate_count() >= capacity)
		balloon_alert(user, "полка забита под завязку!")
		return FALSE

	var/slot = get_shelf_slot(y_offset)

	if(crates_stored[slot])
		balloon_alert(user, "эта полка занята!")
		return FALSE

	return TRUE

/obj/structure/cargo_shelf/proc/load_crate(obj/structure/closet/crate/crate, mob/user, y_offset)
	if(!can_load(crate, user, y_offset))
		return FALSE

	if(!do_after(user, use_delay, target = crate))
		return FALSE

	if(!can_load(crate, user, y_offset))
		return FALSE

	if(crate.opened)
		if(!crate.close())
			return FALSE

	var/slot = get_shelf_slot(y_offset)

	switch(slot)
		if(1)
			crate.pixel_y = CARGO_SHELF_VERTICAL_OFFSET * 0
			crate.layer = BELOW_OBJ_LAYER
		if(2)
			crate.pixel_y = CARGO_SHELF_VERTICAL_OFFSET * 1
			crate.layer = BELOW_OBJ_LAYER + 0.01
		if(3)
			crate.pixel_y = CARGO_SHELF_VERTICAL_OFFSET * 2
			crate.layer = ABOVE_MOB_LAYER + 0.02

	crates_stored[slot] = crate

	crate.interaction_flags_atom |= INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT

	crate.forceMove(src)
	vis_contents += crate
	crate.mouse_opacity = MOUSE_OPACITY_OPAQUE

	crate.add_fingerprint(user)

	return TRUE

/obj/structure/cargo_shelf/mouse_drop_receive(atom/dropped, mob/user, params)
	if(!istype(dropped, /obj/structure/closet/crate))
		return

	var/obj/structure/closet/crate/crate = dropped

	var/list/drop_params = params2list(params)
	var/y_offset = text2num(LAZYACCESS(drop_params, "icon-y"))

	if(!y_offset)
		return

	load_crate(crate, user, y_offset)

/obj/structure/closet/crate/mouse_drop_receive(atom/dropped, mob/user, params)
	var/obj/structure/cargo_shelf/shelf = loc
	if(!istype(shelf))
		return ..()

	shelf.mouse_drop_receive(dropped, user, params)

/obj/structure/cargo_shelf/proc/remove_crate(obj/structure/closet/crate/crate)
	PROTECTED_PROC(TRUE)

	for(var/slot in 1 to length(crates_stored))
		if(crates_stored[slot] != crate)
			continue

		crates_stored[slot] = null

		crate.layer = initial(crate.layer)
		crate.pixel_y = initial(crate.pixel_y)
		crate.mouse_opacity = initial(crate.mouse_opacity)
		crate.interaction_flags_atom &= ~INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT

		vis_contents -= crate

		return TRUE

	return FALSE

/obj/structure/cargo_shelf/Exited(atom/movable/gone, direction)
	if(istype(gone, /obj/structure/closet/crate))
		remove_crate(gone)

	return ..()

/obj/structure/closet/crate/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	. = ..()

	var/obj/structure/cargo_shelf/shelf = loc
	if(!istype(shelf))
		return

	if(istype(over, /obj/structure/closet/crate))
		over = shelf

	if(!isturf(over) && !istype(over, /obj/structure/cargo_shelf))
		return

	if(!shelf.remove_crate(src))
		return

	if(isturf(over))
		forceMove(over)

/obj/structure/cargo_shelf/examine(mob/user)
	. = ..()

	if(crate_count() < capacity)
		. += span_notice("Вы можете перетащить ящик на полку.")

	if(crate_count())
		. += span_notice("Вы можете снять ящик с полки.")

/obj/structure/cargo_shelf/wrench_act(mob/living/user, obj/item/tool)
	set_anchored(!anchored)

	user.visible_message(
		span_notice("[user] [anchored ? "закрепляет" : "открепляет"] полку для ящиков."),
		span_notice("Вы [anchored ? "закрепляете" : "открепляете"] полку для ящиков.")
	)

	tool.play_tool_sound(src, 75)

	return ITEM_INTERACT_SUCCESS

/obj/structure/cargo_shelf/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "сначала открутите полку!")
		return ITEM_INTERACT_BLOCKING

	if(crate_count())
		balloon_alert(user, "сначала уберите ящики с полки!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.use_tool(src, user, 2 SECONDS))
		return ITEM_INTERACT_BLOCKING

	deconstruct(TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/structure/cargo_shelf/atom_deconstruct(disassembled)
	if(disassembled)
		new /obj/item/cargo_shelf_parts(drop_location())

#undef CARGO_SHELF_CAPACITY
#undef CARGO_SHELF_VERTICAL_OFFSET
#undef CARGO_SHELF_USE_DELAY
