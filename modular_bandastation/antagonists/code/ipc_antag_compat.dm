// ============================================
// ИПС: СОВМЕСТИМОСТЬ С АНТАГОНИСТАМИ
// ============================================
// КПБ — роботы. Ряд антагонистских механик несовместим с ними физически.
//
// Чейнджлинг: ИПС не может стать чейнджлингом (нет ДНК для поглощения).
// Культ: ИПС может быть завербован в культ, но не может чертить руны
//        (нет крови для ритуала, масло не является жертвенной субстанцией).

// ============================================
// ЧЕЙНДЖЛИНГ: ИПС — недопустимый кандидат
// ============================================

/datum/dynamic_ruleset/roundstart/changeling/is_valid_candidate(mob/living/candidate, client/candidate_client)
	if(!..())
		return FALSE
	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	if(istype(species, /datum/species/ipc))
		return FALSE
	return TRUE

// ============================================
// КУЛЬТ: ИПС не может чертить руны кровью
// ============================================

/datum/component/cult_ritual_item/do_scribe_rune(obj/item/tool, mob/living/cultist)
	if(istype(cultist.dna?.species, /datum/species/ipc))
		to_chat(cultist, span_warning("Масло КПБ не является жертвенной субстанцией — руна не может быть начертана."))
		return FALSE
	return ..()
