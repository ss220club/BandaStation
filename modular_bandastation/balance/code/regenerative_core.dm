#define INTERNAL_CORE_HEALING -50

/obj/item/organ/monster_core/regenerative_core/on_triggered_internal()
	if(!owner)
		return
	owner.adjust_brute_loss(INTERNAL_CORE_HEALING)
	owner.adjust_fire_loss(INTERNAL_CORE_HEALING)
	apply_to(owner, owner)
	qdel(src)

#undef INTERNAL_CORE_HEALING
