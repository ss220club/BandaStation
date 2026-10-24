// Preview recycling transfers the inserted item to the wardrobe before deleting the PDA.
/obj/item/modular_computer/pda/Exited(atom/movable/gone, direction)
	if(inserted_item == gone)
		inserted_item = null
	return ..()
