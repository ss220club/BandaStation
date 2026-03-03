// ============================================
// ИПС: БЛОКИРОВКА КВИРКОВ
// ============================================
// КПБ — это роботы. Механики квирков (болезни, зависимости,
// физиологические особенности) не применимы к машинам.
// Все квирки для ИПС отключены.

/datum/quirk/is_species_appropriate(datum/species/mob_species)
	. = ..()
	if(!.)
		return FALSE
	if(istype(GLOB.species_prototypes[mob_species], /datum/species/ipc))
		return FALSE
	return TRUE
