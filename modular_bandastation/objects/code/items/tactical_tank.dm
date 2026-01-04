/obj/item/tank/internals/tactical
	name = "tactical tank"
	desc = "Усовершенствованный воздушный баллон, оснащенный универсальным мощным магнитным зажимом. Позволяет закрепить практически любое оружие."
	icon = 'modular_bandastation/objects/icons/obj/items/tank_tactical.dmi'
	icon_state = "tank"

	worn_icon = 'modular_bandastation/objects/icons/obj/items/tank_tactical_back.dmi'
	worn_icon_state = "tank_back"

	slot_flags = ITEM_SLOT_BACK
	volume = 120
	force = 12
	w_class = WEIGHT_CLASS_BULKY

	var/obj/item/stored_weapon = null

/obj/item/tank/internals/tactical/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air = return_air()
	if(air)
		air.assert_gas(/datum/gas/oxygen)
		air.gases[/datum/gas/oxygen][MOLES] = (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

/obj/item/tank/internals/tactical/Destroy()
	if(stored_weapon)
		if(!QDELETED(stored_weapon))
			stored_weapon.forceMove(drop_location())
		stored_weapon = null
	return ..()

/obj/item/tank/internals/tactical/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(AM == stored_weapon)
		stored_weapon = null
		update_appearance()

/obj/item/tank/internals/tactical/examine(mob/user)
	. = ..()
	if(stored_weapon)
		. += span_notice("К магнитному захвату прикреплен: <b>[stored_weapon.name]</b>.")
		. += span_info("Используйте <b>Alt+Клик</b>, чтобы быстро снять оружие.")
	else
		. += span_info("Магнитный захват пуст.")

/obj/item/tank/internals/tactical/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/gun) || istype(W, /obj/item/melee))
		if(stored_weapon)
			to_chat(user, span_warning("Магнитный захват уже занят [stored_weapon.name]!"))
			return

		if(user.transferItemToLoc(W, src))
			stored_weapon = W
			to_chat(user, span_notice("Вы закрепили [W.name] на магнитном захвате баллона."))
			playsound(src, 'sound/items/weapons/magin.ogg', 40, TRUE)
			update_appearance()
			return
	return ..()

/obj/item/tank/internals/tactical/click_alt(mob/user)
	if(!user.can_perform_action(src) || !user.Adjacent(src))
		return FALSE
	if(!stored_weapon)
		return FALSE
	eject_weapon(user)
	return TRUE

/obj/item/tank/internals/tactical/proc/eject_weapon(mob/user)
	if(!stored_weapon)
		return
	var/obj/item/W = stored_weapon
	stored_weapon = null
	to_chat(user, span_notice("Вы отсоединили [W.name] от баллона."))
	if(!user || !user.put_in_hands(W))
		W.forceMove(drop_location())
	update_appearance()

/obj/item/tank/internals/tactical/update_overlays()
	. = ..()
	if(!stored_weapon)
		return

	var/mutable_appearance/weapon_overlay = mutable_appearance(stored_weapon.icon, stored_weapon.icon_state)
	var/matrix/M = matrix()
	M.Turn(90)
	M.Scale(0.6, 0.6)
	weapon_overlay.transform = M

	weapon_overlay.pixel_y = 2
	weapon_overlay.layer = FLOAT_LAYER
	weapon_overlay.color = stored_weapon.color
	. += weapon_overlay

/obj/item/tank/internals/tactical/worn_overlays(is_worn, slot)
	. = ..()
	if(!is_worn || slot != ITEM_SLOT_BACK || !stored_weapon)
		return

	var/mob/living/L = loc
	if(!istype(L))
		return

	if(L.dir == SOUTH)
		return

	var/mutable_appearance/weapon_worn = mutable_appearance(stored_weapon.icon, stored_weapon.icon_state)
	var/matrix/M = matrix()
	M.Turn(90)
	M.Scale(0.5, 0.5)

	if(L.dir == NORTH)
		weapon_worn.pixel_x = 0
		weapon_worn.pixel_y = 1
	else
		weapon_worn.pixel_x = (L.dir == EAST) ? -2 : 2
		weapon_worn.pixel_y = 1

	weapon_worn.transform = M
	weapon_worn.layer = FLOAT_LAYER + 0.01
	weapon_worn.color = stored_weapon.color

	. += weapon_worn

/obj/item/tank/internals/tactical/update_appearance()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_appearance()
