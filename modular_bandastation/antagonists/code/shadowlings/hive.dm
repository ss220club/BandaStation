GLOBAL_VAR_INIT(shadowling_hive, null)

/datum/shadow_hive
	var/list/lings   = list()   // все шадоулинги (мобы)
	var/list/thralls = list()   // все траллы (мобы)

	var/current_tier = TIER_T0  // активный тир
	var/highest_unlocked_tier = TIER_T0

/datum/shadow_hive/proc/join_ling(mob/living/carbon/human/H)
	if(!H || QDELETED(H)) return
	if(!(H in lings))
		lings += H
	to_chat(H, span_notice("Вы ощущаете голоса улья в своей голове..."))
	refresh_languages(H)

/datum/shadow_hive/proc/join_thrall(mob/living/carbon/human/H)
	if(!H || QDELETED(H)) return
	if(!(H in thralls))
		thralls += H
	to_chat(H, span_notice("Тьма захватывает ваш разум. Вы связаны с ульем."))
	refresh_languages(H)

/datum/shadow_hive/proc/leave(mob/living/carbon/human/H)
	if(!H) return
	lings -= H
	thralls -= H
	var/datum/language_holder/lang_holder = H.get_language_holder()
	if(lang_holder)
		lang_holder.remove_language(/datum/language/shadow_hive)

/datum/shadow_hive/proc/count_nt()
	return length(thralls)

/datum/shadow_hive/proc/refresh_languages(mob/living/carbon/human/H)
	if(!H)
		return
	var/datum/language_holder/lang_holder = H.get_language_holder()
	if(lang_holder)
		return
	lang_holder.grant_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)

/proc/get_shadow_hive()
	if(!GLOB.shadowling_hive)
		GLOB.shadowling_hive = new /datum/shadow_hive
	return GLOB.shadowling_hive
