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

	// Tacticool holster
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

			var/obj/item/gun/G = I
			if(!first_gun)
				first_gun = G
				continue
			if(!second_gun)
				second_gun = G
				break

		if(held_gun)
			if(!first_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_gun, src))
					to_chat(src, span_warning("[held_gun] не помещается в кобуру!"))
					return

				return
			if(!second_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_gun, src))
					to_chat(src, span_warning("[held_gun] не помещается в кобуру!"))
					return

				return
			to_chat(src, span_warning("Тактическая кобура заполнена!"))
			return

		var/obj/item/gun/target_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun))
				continue
			target_gun = I
			break
		if(!target_gun)
			to_chat(src, span_warning("В кобуре нет оружия!"))
			return
		if(!target_accessory.atom_storage.attempt_remove(target_gun, src.loc))
			return
		put_in_hands(target_gun)
		to_chat(src, span_notice("Вы быстро достаёте [target_gun]."))
		return

	// Standart holster
	if(target_accessory.type == /obj/item/clothing/accessory/holster)
		var/obj/item/gun/held_gun_normal = null
		if(istype(get_active_held_item(), /obj/item/gun))
			held_gun_normal = get_active_held_item()
		else if(istype(get_inactive_held_item(), /obj/item/gun))
			held_gun_normal = get_inactive_held_item()
		if(held_gun_normal)
			var/already_has_gun = FALSE
			for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
				if(istype(I, /obj/item/gun))
					already_has_gun = TRUE
					break
			if(already_has_gun)
				to_chat(src, span_warning("В кобуре уже есть оружие!"))
				return
			if(!target_accessory.atom_storage.attempt_insert(held_gun_normal, src))
				to_chat(src, span_warning("[held_gun_normal] не помещается в кобуру!"))
			return

		var/obj/item/gun/holstered_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(istype(I, /obj/item/gun))
				holstered_gun = I
				break
		if(!holstered_gun)
			to_chat(src, span_warning("В кобуре нет оружия!"))
			return
		if(!target_accessory.atom_storage.attempt_remove(holstered_gun, src.loc))
			return
		put_in_hands(holstered_gun)
		to_chat(src, span_notice("Вы быстро достаёте [holstered_gun]."))
		return

	// Energy holster
	if(istype(target_accessory, /obj/item/clothing/accessory/holster/energy))
		var/obj/item/gun/energy/first_gun = null
		var/obj/item/gun/energy/second_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun/energy))
				continue

			var/obj/item/gun/energy/G = I
			if(!first_gun)
				first_gun = G
				continue
			if(!second_gun)
				second_gun = G
				break

		var/obj/item/gun/energy/held_energy = null
		if(istype(get_active_held_item(), /obj/item/gun/energy))
			held_energy = get_active_held_item()
		else if(istype(get_inactive_held_item(), /obj/item/gun/energy))
			held_energy = get_inactive_held_item()
		if(held_energy)
			if(!first_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_energy, src))
					to_chat(src, span_warning("[held_energy] не помещается в кобуру!"))
				return
			if(!second_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_energy, src))
					to_chat(src, span_warning("[held_energy] не помещается в кобуру!"))
				return
			to_chat(src, span_warning("Кобура заполнена!"))
			return

		var/active_item = get_active_held_item()
		var/inactive_item = get_inactive_held_item()
		var/use_inactive_hand = FALSE
		if(active_item && !inactive_item)
			use_inactive_hand = TRUE

		var/obj/item/gun/energy/target_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun/energy))
				continue
			target_gun = I
			break
		if(!target_gun)
			to_chat(src, span_warning("Кобура пуста!"))
			return
		if(!target_accessory.atom_storage.attempt_remove(target_gun, src.loc))
			return
		if(use_inactive_hand)
			put_in_inactive_hand(target_gun)
		else
			put_in_hands(target_gun)
			to_chat(src, span_notice("Вы быстро достаёте [target_gun]."))
		return

	// Standard accessories
	var/obj/item/held_item = get_active_held_item()
	if(held_item)
		if(!target_accessory.atom_storage.attempt_insert(held_item, src))
			to_chat(src, span_warning("Не удалось убрать [held_item] в карман!"))
			return

		return

	var/obj/item/target_item = null
	for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
		target_item = I
		break
	if(!target_item)
		to_chat(src, span_warning("Карман пуст!"))
		return
	if(!target_accessory.atom_storage.attempt_remove(target_item, src.loc))
		return
	put_in_hands(target_item)
	to_chat(src, span_notice("Вы достаёте [target_item]."))

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_KB_HUMAN_QUICK_ACCESSORY_DRAW_DOWN, PROC_REF(on_quick_accessory_draw))

/mob/living/carbon/human/proc/on_quick_accessory_draw()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(quick_accessory_draw))
