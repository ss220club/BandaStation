GLOBAL_VAR_INIT(shadowling_hive, null)
GLOBAL_VAR_INIT(shadowling_vote, null)
GLOBAL_VAR_INIT(shadowling_engine_sabotage_used, FALSE)

#define SHADOWLING_ROLE_MAIN "shadowling_main"
#define SHADOWLING_ROLE_THRALL "shadowling_thrall"
#define SHADOWLING_ROLE_LESSER "shadowling_lesser"

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

/datum/shadow_hive/proc/apply_evac_delay(delay_time = 10 MINUTES)
	if(!SSshuttle || !SSshuttle.emergency)
		return FALSE

	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		return FALSE

	var/security_num = SSsecurity_level.get_current_level_as_number()
	var/set_coefficient = 1
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			set_coefficient = 2
		if(SEC_LEVEL_BLUE)
			set_coefficient = 1
		else
			set_coefficient = 0.5

	var/new_timer = SSshuttle.emergency.timeLeft(1) + delay_time
	SSshuttle.emergency.setTimer(new_timer)

	var/surplus = new_timer - (SSshuttle.emergency_call_time * set_coefficient)
	if(surplus > 0)
		SSshuttle.block_recall(surplus)

	var/mins = round(delay_time / (1 MINUTES))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Зафиксирован спад мощности в реакторном контуре. Время прибытия эвакуационного шаттла увеличено на [mins] минут.", "Приоритетное оповещение", 'sound/announcer/announcement/announce_syndi.ogg', null, "Центральное Командование: Транспортный Департамент Нанотрейзен"), rand(2 SECONDS, 6 SECONDS))

	return TRUE
