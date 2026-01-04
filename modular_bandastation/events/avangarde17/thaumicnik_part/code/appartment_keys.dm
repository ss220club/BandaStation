/obj/item/key/appartment
	name = "Ключ для квартиры"
	desc = "Кликните им по шлюзу не закрытому на болты, чтобы привязать ключ к нему. После этого вы сможете ставить и убирать шлюз с болтов."
	var/obj/machinery/door/airlock/linked_airlock = null

/obj/item/key/appartment/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(user))
		return ITEM_INTERACT_BLOCKING

	if(!istype(interacting_with, /obj/machinery/door/airlock))
		return ITEM_INTERACT_BLOCKING

	var/obj/machinery/door/airlock/airlock = interacting_with
	if(!do_after(user, 5 SECONDS))
		return ITEM_INTERACT_BLOCKING
	if(linked_airlock)
		if(!linked_airlock.opacity)
			return ITEM_INTERACT_BLOCKING
		if(linked_airlock.locked)
			linked_airlock.locked = FALSE
			linked_airlock.update_appearance()
		else
			linked_airlock.secure_close()
	else
		if(airlock.locked)
			return ITEM_INTERACT_BLOCKING
		linked_airlock = airlock
		name = "Ключ от [linked_airlock.name]"
		desc = "Этим ключом можно открывать и закрывать [linked_airlock.name]"

	return ITEM_INTERACT_SUCCESS
