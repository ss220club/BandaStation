/obj/item/construction/plumbing
	desc = "Устройство для быстрой постройки и разбора. Перезаряжается пластиком."
	matter = 0
	var/list/recharge_materials = list(
    	/obj/item/stack/sheet/plastic = 4,
	)

/obj/item/construction/plumbing/loaded
	matter = 200

/obj/item/construction/plumbing/service/loaded
	matter = 200

/obj/item/construction/plumbing/insert_matter(obj/item, mob/user)
	if(iscyborg(user))
		return FALSE

	var/loaded = FALSE

	if(isstack(item))
		loaded = loadwithsheets(item, user)
	if(loaded)
		update_appearance() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/plumbing/loadwithsheets(obj/item/stack/the_stack, mob/user)
	var/matter_value = recharge_materials[the_stack.type] || recharge_materials[the_stack.parent_type]
	if(!matter_value)
		balloon_alert(user, "неверный материал!")
		return FALSE

	var/maxsheets = floor((max_matter - matter) / matter_value)
	if(maxsheets > 0)
		var/amount_to_use = min(the_stack.amount, maxsheets)
		the_stack.use(amount_to_use)
		matter += matter_value * amount_to_use
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE

	balloon_alert(user, "хранилище заполнено!")
	return FALSE
