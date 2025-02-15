/datum/status_effect/neck_slice/on_remove()
	. = ..()
	owner.remove_traits(list(TRAIT_MUTE), REF(src))

/datum/status_effect/neck_slice/on_apply()
	if (!..())
		return
	owner.add_traits(list(TRAIT_MUTE), REF(src))
	. = ..()
