/obj/item/tank/internals/tactical
	name = "Тактический баллон"
	desc = "Улучшенный баллон с воздухом, оснащенный универсальным магнитным захватом повышенной мощности. Позволяет закрепить за спиной практически любой образец вооружения."
	icon = 'modular_bandastation/objects/icons/obj/items/tank_tactical.dmi'
	icon_state = "tank"

	volume = 120
	force = 12
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

	var/obj/item/stored_weapon = null

/obj/item/tank/internals/tactical/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air = return_air()
	if(air)
		air.assert_gas(/datum/gas/oxygen)
		air.gases[/datum/gas/oxygen][1] = (10 * 101.325) * volume / (8.31 * 293.15)

/obj/item/tank/internals/tactical/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/analyzer) || istype(W, /obj/item/wrench))
		return ..()

	if(stored_weapon)
		to_chat(user, span_warning("Магнитный захват уже занят [stored_weapon.name]!"))
		return

	if(istype(W, /obj/item/gun) || istype(W, /obj/item/melee))
		if(!user.transferItemToLoc(W, src))
			return

		stored_weapon = W
		to_chat(user, span_notice("Вы закрепили [W.name] на магнитном захвате баллона."))
		playsound(src, 'sound/items/weapons/magin.ogg', 40, TRUE)
		update_icon()
		return

	return ..()

/obj/item/tank/internals/tactical/click_alt(mob/user)
	if(!user.can_perform_action(src) || !user.Adjacent(src))
		return FALSE

	if(!stored_weapon)
		to_chat(user, span_warning("На захвате ничего не закреплено."))
		return FALSE

	eject_weapon(user)
	return TRUE

/obj/item/tank/internals/tactical/proc/eject_weapon(mob/user)
	if(!stored_weapon)
		return

	var/obj/item/W = stored_weapon
	stored_weapon = null

	to_chat(user, span_notice("Вы отсоединили [W.name] от баллона."))

	if(user && !user.put_in_hands(W))
		W.forceMove(get_turf(src))
	else if(!user)
		W.forceMove(get_turf(src))

	update_icon()

/obj/item/tank/internals/tactical/examine(mob/user)
	. = ..()
	if(stored_weapon)
		. += span_notice("К магнитному захвату прикреплен: <b>[stored_weapon.name]</b>.")
		. += span_info("Используйте <b>Alt+Клик</b>, чтобы быстро снять оружие.")
	else
		. += span_info("Магнитный захват пуст.")

/obj/item/tank/internals/tactical/Destroy()
	if(stored_weapon)
		stored_weapon.forceMove(get_turf(src))
		stored_weapon = null
	return ..()

/obj/item/tank/internals/tactical/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(AM == stored_weapon)
		stored_weapon = null
		update_icon()
