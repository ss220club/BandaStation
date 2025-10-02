/obj/item/construction/plumbing
	desc = "Устройство для быстрой постройки и разбора. Перезаряжается пластиком."
	matter = 0

/obj/item/construction/plumbing/loaded
	matter = 200

/obj/item/construction/plumbing/service/loaded
	matter = 200

/obj/item/stack/sheet/plastic
	var/plastic_matter_amount = 4

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
	if(!istype(the_stack, /obj/item/stack/sheet/plastic))
		balloon_alert(user, "неверный материал!")
		return FALSE
	var/obj/item/stack/sheet/plastic/plastic_stack = the_stack
	var/maxsheets = round((max_matter-matter) / plastic_stack.plastic_matter_amount)
	if(maxsheets > 0)
		var/amount_to_use = min(plastic_stack.amount, maxsheets)
		plastic_stack.use(amount_to_use)
		matter += plastic_stack.plastic_matter_amount * amount_to_use
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE
	balloon_alert(user, "хранилище заполнено!")
	return FALSE
