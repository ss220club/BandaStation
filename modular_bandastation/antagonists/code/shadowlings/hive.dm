GLOBAL_VAR_INIT(shadowling_hive, null)

/datum/shadow_hive
	var/list/lings   = list()
	var/list/thralls = list()

/datum/shadow_hive/proc/join_ling(mob/living/carbon/human/H)
	if(!H || QDELETED(H))
		return
	if(!(H in lings))
		lings += H
	to_chat(H, span_notice("Вы ощущаете голоса улья в своей голове..."))
	refresh_languages(H)
	var/datum/action/cooldown/shadowling/hive_sync/sync_spell = new
	sync_spell.Grant(H)

/datum/shadow_hive/proc/join_thrall(mob/living/carbon/human/H)
	if(!H || QDELETED(H))
		return
	if(!(H in thralls))
		thralls += H
	to_chat(H, span_notice("Тьма захватывает ваш разум. Вы связаны с ульем."))
	refresh_languages(H)
	var/datum/action/cooldown/shadowling/hive_sync/sync_spell = new
	sync_spell.Grant(H)

/datum/shadow_hive/proc/leave(mob/living/carbon/human/H)
	if(!H) return
	lings -= H
	thralls -= H
	var/datum/language_holder/LH = H.get_language_holder()
	if(LH)
		LH.remove_language(/datum/language/shadow_hive)

/datum/shadow_hive/proc/count_nt()
	var/n = 0
	for(var/mob/living/carbon/human/T in thralls)
		if(QDELETED(T)) continue
		if(T.stat == DEAD) continue
		n++
	return n

/datum/shadow_hive/proc/refresh_languages(mob/living/carbon/human/H)
	if(!H) return
	var/datum/language_holder/LH = H.get_language_holder()
	LH.grant_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)

/proc/get_shadow_hive()
	if(!GLOB.shadowling_hive)
		GLOB.shadowling_hive = new /datum/shadow_hive
	return GLOB.shadowling_hive
