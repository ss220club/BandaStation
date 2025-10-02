/obj/item/rcd_ammo/plumbing/large
	ammoamt = 160

/obj/item/construction/plumbing
	matter = 0

/obj/item/construction/plumbing/loaded
	matter = 200

/obj/item/construction/plumbing/service/loaded
	matter = 200

/obj/item/stack/sheet/plastic
	var/plastic_matter_amount = 4

/obj/item/rcd_ammo/plumbing
	name = "RPLD matter cartridge"
	desc = "Highly compressed matter for the RPLD."

/obj/item/construction/plumbing/insert_matter(obj/item, mob/user)
	if(iscyborg(user))
		return FALSE

	var/loaded = FALSE
	if(istype(item, /obj/item/rcd_ammo/plumbing))
		var/obj/item/rcd_ammo/plumbing/ammo = item
		var/load = min(ammo.ammoamt, max_matter - matter)
		if(load <= 0)
			balloon_alert(user, "storage full!")
			return FALSE
		ammo.ammoamt -= load
		if(ammo.ammoamt <= 0)
			qdel(ammo)
		matter += load
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(isstack(item))
		loaded = loadwithsheets(item, user)
	if(loaded)
		update_appearance() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/plumbing/loadwithsheets(obj/item/stack/the_stack, mob/user)
	if(!istype(the_stack, /obj/item/stack/sheet/plastic))
		balloon_alert(user, "invalid sheets!")
		return FALSE
	var/obj/item/stack/sheet/plastic/plastic_stack = the_stack
	var/maxsheets = round((max_matter-matter) / plastic_stack.plastic_matter_amount) //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(plastic_stack.amount, maxsheets)
		plastic_stack.use(amount_to_use)
		matter += plastic_stack.plastic_matter_amount * amount_to_use
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		return TRUE
	balloon_alert(user, "storage full!")
	return FALSE
