/mob/living/carbon/human/proc/in_raid()
	return istype(get_area(src), /area/station/hallway/primary/central)

/mob/living/carbon/human/death(gibbed)
	if(in_raid())
		extract_from_raid()
		return TRUE

	return ..()

/mob/living/carbon/human/proc/extract_from_raid()
	var/turf/death_turf = get_turf(src)
	var/list/items_to_drop = list(
		head,
		wear_mask,
		glasses,
		ears,
		gloves,
		shoes,
		belt,
		back,
		s_store,
		l_store,
		r_store,
		wear_suit,
		get_active_held_item(),
		get_inactive_held_item(),
		wear_neck
	)

	for(var/obj/item/I as anything in items_to_drop)
		if(I)
			dropItemToGround(I, TRUE)
	if(w_uniform?.atom_storage)
		for(var/obj/item/I in w_uniform.atom_storage.real_location.contents.Copy())
			w_uniform.atom_storage.attempt_remove(I, death_turf)
	visible_message(
		span_danger("[src] рассыпается в пепел!")
	)

	new /obj/effect/decal/cleanable/ash(death_turf)
	forceMove(locate(100, 50, 3))
	fully_heal()
	regenerate_icons()
