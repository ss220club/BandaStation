/obj/item/organ/monster_core/regenerative_core/on_triggered_internal()
	if(!owner)
		return
	apply_to(owner)
	qdel(src)
