GLOBAL_VAR_INIT(shadowling_hive, null)
GLOBAL_VAR_INIT(shadowling_vote, null)
GLOBAL_VAR_INIT(shadowling_engine_sabotage_used, FALSE)

#define SHADOWLING_ROLE_MAIN "shadowling_main"
#define SHADOWLING_ROLE_THRALL "shadowling_thrall"
#define SHADOWLING_ROLE_LESSER "shadowling_lesser"

/datum/shadow_hive
	var/list/lings   = list()
	var/list/thralls = list()

/datum/shadow_hive/Destroy()
	for(var/mob/living/L as anything in lings)
		if(!QDELETED(L))
			UnregisterSignal(L, COMSIG_QDELETING)
	for(var/mob/living/T as anything in thralls)
		if(!QDELETED(T))
			UnregisterSignal(T, COMSIG_QDELETING)
	lings.Cut()
	thralls.Cut()
	return ..()

/datum/shadow_hive/proc/join_ling(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(QDELETED(H))
		return
	if(H in lings)
		return

	lings += H
	RegisterSignal(H, COMSIG_QDELETING, PROC_REF(_on_member_qdel))

	to_chat(H, span_notice("Вы ощущаете голоса улья в своей голове..."))
	refresh_languages(H)
	grant_sync_action(H)

/datum/shadow_hive/proc/join_thrall(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(QDELETED(H))
		return
	if(H in thralls)
		return

	thralls += H
	RegisterSignal(H, COMSIG_QDELETING, PROC_REF(_on_member_qdel))

	to_chat(H, span_notice("Тьма захватывает ваш разум. Вы связаны с ульем."))
	refresh_languages(H)
	grant_sync_action(H)

/datum/shadow_hive/proc/leave(mob/living/carbon/human/H)
	if(!istype(H))
		return

	lings -= H
	thralls -= H
	UnregisterSignal(H, COMSIG_QDELETING)

	var/datum/language_holder/LH = H.get_language_holder()
	if(LH)
		LH.remove_language(/datum/language/shadow_hive)

/datum/shadow_hive/proc/_on_member_qdel(mob/living/source, force)
	SIGNAL_HANDLER
	lings -= source
	thralls -= source
	UnregisterSignal(source, COMSIG_QDELETING)

/datum/shadow_hive/proc/sanitize()
	for(var/i = length(lings) to 1 step -1)
		var/mob/living/L = lings[i]
		if(QDELETED(L) || !istype(L, /mob/living))
			lings.Cut(i, i + 1)

	for(var/i = length(thralls) to 1 step -1)
		var/mob/living/T = thralls[i]
		if(QDELETED(T) || !istype(T, /mob/living))
			thralls.Cut(i, i + 1)

/datum/shadow_hive/proc/count_nt()
	sanitize()
	var/n = 0
	for(var/mob/living/carbon/human/T in thralls)
		if(QDELETED(T))
			continue
		if(T.stat == DEAD)
			continue
		n++
	return n

/datum/shadow_hive/proc/refresh_languages(mob/living/carbon/human/H)
	if(!istype(H))
		return
	var/datum/language_holder/LH = H.get_language_holder()
	if(!LH)
		return
	LH.grant_language(/datum/language/shadow_hive, ALL, LANGUAGE_ATOM)

/datum/shadow_hive/proc/grant_sync_action(mob/living/carbon/human/H)
	if(!istype(H))
		return
	for(var/datum/action/cooldown/shadowling/hive_sync/existing in H.actions)
		return
	var/datum/action/cooldown/shadowling/hive_sync/A = new
	A.Grant(H)

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
