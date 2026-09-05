/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "A tall rack for storing guns."
	icon = 'modular_bandastation/weapon/icons/gun_rack.dmi'
	icon_state = "gunrack"
	pass_flags_self = NONE

/obj/structure/rack/gunrack/alt
	icon_state = "gunrack2"
	pass_flags_self = LETPASSTHROW

/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	if(!mapload)
		return

/obj/structure/rack/gunrack/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!user.combat_mode && istype(tool, /obj/item/gun))
		var/obj/item/gun/G = tool
		var/icon/gun_icon = icon(G.icon, G.icon_state)
		var/gun_width = gun_icon ? gun_icon.Width() : 32

		var/scale_factor = 1.0
		switch(gun_width)
			if(64)
				scale_factor = 0.65
			if(48)
				scale_factor = 0.75

		var/width_compensation = -round(((gun_width - 32) * 0.5) * scale_factor)
		var/player_x = 0
		if(LAZYACCESS(modifiers, ICON_X))
			var/raw_click_x = text2num(modifiers[ICON_X]) - 16
			player_x = clamp(raw_click_x, -9, 9)

		var/final_x_offset = player_x + width_compensation
		var/final_y_offset = 2

		if(user.transfer_item_to_turf(G, get_turf(src), final_x_offset, final_y_offset, silent = FALSE))
			rotate_weapon(G, being_removed = FALSE, scale_factor = scale_factor)
			G.pixel_x = final_x_offset
			G.pixel_y = final_y_offset
			return ITEM_INTERACT_SUCCESS

		return ITEM_INTERACT_BLOCKING

	return ..()

/obj/structure/rack/gunrack/proc/rotate_weapon(obj/item/incoming_weapon, being_removed = FALSE, scale_factor = 1.0)
	var/matrix/new_matrix = matrix()
	if(!being_removed)
		new_matrix.Scale(scale_factor, scale_factor)
		new_matrix.Turn(-90)
		incoming_weapon.transform = new_matrix
		RegisterSignal(incoming_weapon, COMSIG_ITEM_EQUIPPED, PROC_REF(item_picked_up))
	else
		UnregisterSignal(incoming_weapon, COMSIG_ITEM_EQUIPPED)
		incoming_weapon.transform = new_matrix
		incoming_weapon.pixel_x = incoming_weapon.base_pixel_x
		incoming_weapon.pixel_y = incoming_weapon.base_pixel_y

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

/obj/structure/rack/gunrack/Destroy()
	for(var/obj/item/gun/G in get_turf(src))
		UnregisterSignal(G, COMSIG_ITEM_EQUIPPED)
		rotate_weapon(G, being_removed = TRUE)

	return ..()

/obj/structure/rack/gunrack/alt/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

/obj/structure/rack/gunrack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return

/obj/item/rack_parts/gunrack
	name = "gun rack parts"
	desc = "Parts of a gun rack."

/obj/item/rack_parts/gunrack/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("Вы начинаете собирать оружейную стойку..."))
	if(do_after(user, 5 SECONDS, target = user))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/rack/R = new /obj/structure/rack/gunrack(get_turf(src))
		user.visible_message(span_notice("[user.declent_ru(NOMINATIVE)] собирает [R.declent_ru(ACCUSATIVE)]."), span_notice("Вы собираете [R.declent_ru(ACCUSATIVE)]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE

/obj/structure/rack/gunrack/atom_deconstruct(disassembled = TRUE)
	set_density(FALSE)
	var/obj/item/rack_parts/gunrack/newparts = new(loc)
	transfer_fingerprints_to(newparts)

/obj/effect/spawner/armory_spawn
	icon_state = "loot"
	icon = 'icons/effects/random_spawners.dmi'
	layer = OBJ_LAYER
	/// A list of possible guns to spawn.
	var/list/guns
	/// Do we fan out the items spawned for a natural effect?
	var/fan_out_items = FALSE
	/// How many mags per gun do we spawn, if it takes magazines.
	var/mags_to_spawn = 3
	/// Do we want to angle it so that it is horizontal?
	var/vertical_guns = TRUE

/obj/effect/spawner/armory_spawn/Initialize(mapload)
	. = ..()

	if(!guns)
		return

	var/obj/structure/rack/gunrack/rack_on_tile = locate(/obj/structure/rack/gunrack) in loc.contents

	var/gun_count = 0
	var/offset_percent = 20 / guns.len
	for(var/gun in guns) // 11/20/21: Gun spawners now spawn 1 of each gun in it's list no matter what, so as to reduce the RNG of the armory stock.
		var/obj/item/gun/spawned_gun = new gun(loc)

		if(vertical_guns && rack_on_tile)
			rack_on_tile.rotate_weapon(spawned_gun)
			spawned_gun.pixel_x = -10 + (offset_percent * gun_count) + spawned_gun.base_pixel_x
		else if (fan_out_items)
			spawned_gun.pixel_x = spawned_gun.pixel_y = ((!(gun_count%2)*gun_count/2)*-1)+((gun_count%2)*(gun_count+1)/2*1)

		gun_count++

/obj/effect/spawner/armory_spawn/shotguns
	guns = list(
		/obj/item/gun/ballistic/shotgun/riot,
		/obj/item/gun/ballistic/shotgun/riot,
		/obj/item/gun/ballistic/shotgun/riot,
	)

/obj/effect/spawner/armory_spawn/eguns
	guns = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/gun/energy/e_gun,
		/obj/item/gun/energy/e_gun,
	)

/obj/effect/spawner/armory_spawn/laser
	guns = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser,
	)

/obj/effect/spawner/armory_spawn/dragnets
	guns = list(
		/obj/item/gun/energy/e_gun/dragnet,
		/obj/item/gun/energy/e_gun/dragnet,
		/obj/item/gun/energy/e_gun/dragnet,
	)

/obj/effect/spawner/armory_spawn/disablers
	guns = list(
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/disabler,
	)

/obj/effect/spawner/armory_spawn/misc
	guns = list(
		/obj/item/gun/ballistic/automatic/battle_rifle,
		/obj/item/gun/energy/ionrifle,
		/obj/item/gun/energy/temperature/security,
	)
