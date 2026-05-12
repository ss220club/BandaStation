/mob/living/carbon/human/proc/quick_accessory_draw()

	var/obj/item/clothing/under/U = w_uniform
	if(!U)
		to_chat(src, span_warning("На вас нет формы!"))
		return

	if(!LAZYLEN(U.attached_accessories))
		to_chat(src, span_warning("Нет аксессуаров!"))
		return

	var/obj/item/clothing/accessory/target_accessory = null

	for(var/obj/item/clothing/accessory/A in U.attached_accessories)
		if(A.atom_storage)
			target_accessory = A
			break

	if(!target_accessory)
		to_chat(src, span_warning("Нет аксессуара с хранилищем!"))
		return


	// =====================================================
	// ТАКТИЧЕСКАЯ КОБУРА
	// =====================================================

	if(istype(target_accessory, /obj/item/clothing/accessory/holster/tacticool))

		var/obj/item/gun/held_gun = null

		if(istype(get_active_held_item(), /obj/item/gun))
			held_gun = get_active_held_item()
		else if(istype(get_inactive_held_item(), /obj/item/gun))
			held_gun = get_inactive_held_item()

		var/obj/item/gun/first_gun = null
		var/obj/item/gun/second_gun = null

		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun))
				continue

			if(!first_gun)
				first_gun = I
				continue

			if(!second_gun)
				second_gun = I
				break

		//--------------------------------------------------
		// УБРАТЬ оружие
		//--------------------------------------------------

		if(held_gun)

			if(!first_gun)
				held_gun.forceMove(target_accessory)
				to_chat(src, span_notice("Вы убираете [held_gun] в первый слот кобуры."))
				return

			if(first_gun && !second_gun)
				held_gun.forceMove(target_accessory)
				to_chat(src, span_notice("Вы убираете [held_gun] во второй слот кобуры."))
				return

			to_chat(src, span_warning("Тактическая кобура заполнена!"))
			return

		//--------------------------------------------------
		// ДОСТАТЬ оружие
		//--------------------------------------------------

		if(!first_gun)
			to_chat(src, span_warning("В кобуре нет оружия!"))
			return

		first_gun.forceMove(src.loc)
		put_in_hands(first_gun)

		to_chat(src, span_notice("Вы быстро достаёте [first_gun]."))
		return


	// =====================================================
	// ОБЫЧНАЯ КОБУРА
	// =====================================================

	if(istype(target_accessory, /obj/item/clothing/accessory/holster))

		var/obj/item/gun/held_gun_normal = null

		if(istype(get_active_held_item(), /obj/item/gun))
			held_gun_normal = get_active_held_item()
		else if(istype(get_inactive_held_item(), /obj/item/gun))
			held_gun_normal = get_inactive_held_item()

		//--------------------------------------------------
		// УБРАТЬ оружие
		//--------------------------------------------------

		if(held_gun_normal)

			var/already_has_gun = FALSE

			for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
				if(istype(I, /obj/item/gun))
					already_has_gun = TRUE
					break

			if(already_has_gun)
				to_chat(src, span_warning("В кобуре уже есть оружие!"))
				return

			held_gun_normal.forceMove(target_accessory)

			to_chat(src, span_notice("Вы убираете [held_gun_normal] в кобуру."))
			return

		//--------------------------------------------------
		// ДОСТАТЬ оружие
		//--------------------------------------------------

		var/obj/item/gun/holstered_gun = null

		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(istype(I, /obj/item/gun))
				holstered_gun = I
				break

		if(!holstered_gun)
			to_chat(src, span_warning("В кобуре нет оружия!"))
			return

		holstered_gun.forceMove(src.loc)
		put_in_hands(holstered_gun)

		to_chat(src, span_notice("Вы быстро достаёте [holstered_gun]."))
		return

	// =====================================================
	// ЭНЕРГЕТИЧЕСКАЯ КОБУРА
	// =====================================================

	if(istype(target_accessory, /obj/item/clothing/accessory/holster/energy))

		var/list/guns = target_accessory:get_holstered_guns()

		var/obj/item/gun/energy/first_gun = null
		var/obj/item/gun/energy/second_gun = null

		if(guns.len >= 1)
			first_gun = guns[1]

		if(guns.len >= 2)
			second_gun = guns[2]

		var/obj/item/gun/energy/laser/thermal/held_energy = null

		if(istype(get_active_held_item(), /obj/item/gun/energy))
			held_energy = get_active_held_item()

		else if(istype(get_inactive_held_item(), /obj/item/gun/energy))
			held_energy = get_inactive_held_item()

		if(held_energy)

			if(!first_gun)
				held_thermal.forceMove(target_accessory)

				to_chat(src, span_notice("Вы убираете [held_energy] в первый слот кобуры."))

				return

			if(!second_gun)
				held_thermal.forceMove(target_accessory)

				to_chat(src, span_notice("Вы убираете [held_energy] во второй слот кобуры."))

				return

			to_chat(src, span_warning("Кобура заполнена!"))

			return

		var/active_item = get_active_held_item()
		var/inactive_item = get_inactive_held_item()

		var/use_inactive_hand = FALSE

		if(active_item && !inactive_item)
			use_inactive_hand = TRUE

		var/obj/item/gun/energy/target_gun = first_gun

		if(!target_gun)
			to_chat(src, span_warning("Кобура пуста!"))
			return

		target_gun.forceMove(src.loc)

		if(use_inactive_hand)
			put_in_inactive_hand(target_gun)
		else
			put_in_hands(target_gun)

		to_chat(src, span_notice("Вы быстро достаёте [target_gun]."))

		return

	// =====================================================
	// ОБЫЧНЫЕ АКСЕССУАРЫ
	// =====================================================

	var/obj/item/target_item = null

	for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
		target_item = I
		break

	if(!target_item)
		to_chat(src, span_warning("Аксессуар пуст!"))
		return

	target_item.forceMove(src.loc)
	put_in_hands(target_item)

	to_chat(src, span_notice("Вы достаёте [target_item]."))

/mob/living/carbon/human/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_KB_HUMAN_QUICK_ACCESSORY_DRAW_DOWN, PROC_REF(on_quick_accessory_draw))

/mob/living/carbon/human/proc/on_quick_accessory_draw()

	SIGNAL_HANDLER

	spawn()
		quick_accessory_draw()
