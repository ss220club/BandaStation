/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "A tall rack for storing guns."
	icon = 'modular_bandastation/weapon/icons/gun_rack.dmi'
	icon_state = "gunrack"

/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	if(!mapload)
		return

/obj/structure/rack/gunrack/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// Special handling for guns
	if(istype(tool, /obj/item/gun))
		var/x_offset = 0
		var/y_offset = 2 // fixed visual shelf position, locked to the Y axis to match with the sprite

		// Only respect X axis, so players can manage the way the gun is hanging
		if(LAZYACCESS(modifiers, ICON_X))
			x_offset = clamp(text2num(modifiers[ICON_X]) - 16, -(ICON_SIZE_X * 0.5), ICON_SIZE_X * 0.5)

		if(user.transfer_item_to_turf(tool, get_turf(src), x_offset, y_offset, silent = FALSE))
			rotate_weapon(tool)
			tool.pixel_x = x_offset
			tool.pixel_y = y_offset
			return ITEM_INTERACT_SUCCESS

		return ITEM_INTERACT_BLOCKING

	// Default rack behavior otherwise (You can put other things on it if you want)
	return ..()

/obj/structure/rack/gunrack/proc/rotate_weapon(obj/item/incoming_weapon, being_removed = FALSE)
	var/matrix/new_matrix = matrix()
	if(!being_removed)
		new_matrix.Turn(-90)
		RegisterSignal(incoming_weapon, COMSIG_ITEM_EQUIPPED, PROC_REF(item_picked_up))
	else
		incoming_weapon.pixel_x = incoming_weapon.base_pixel_x
	incoming_weapon.transform = new_matrix

/// Checks when something is leaving our turf, if it's a gun then make sure to reset its transform so it's not permanently rotated
/obj/structure/rack/gunrack/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(!isgun(leaving))
		return
	var/obj/item/leaving_item = leaving
	rotate_weapon(leaving_item, being_removed = TRUE)

/// Handles the guns being picked up to unrotate them
/obj/structure/rack/gunrack/proc/item_picked_up(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	var/obj/item/leaving_item = source
	rotate_weapon(leaving_item, being_removed = TRUE)
	UnregisterSignal(leaving_item, COMSIG_ITEM_EQUIPPED)
