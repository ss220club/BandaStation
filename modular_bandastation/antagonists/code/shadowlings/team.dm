GLOBAL_VAR_INIT(shadowling_hive, null)

#define SHADOWLING_ROLE_MAIN "shadowling_main"
#define SHADOWLING_ROLE_THRALL "shadowling_thrall"
#define SHADOWLING_ROLE_LESSER "shadowling_lesser"

/datum/team/shadow_hive
	name = "\improper Shadow Hive"
	var/list/lings = list()
	var/list/thralls = list()
	var/list/ling_roles = list()
	var/mob/leader
	var/asc_thralls_needed = 0
	var/shadowling_vote
	var/is_shadowling_vote_finished
	var/is_shadowling_engine_sabotage_used

/datum/team/shadow_hive/New()
	. = ..()
	if(!GLOB.shadowling_hive)
		GLOB.shadowling_hive = src
	if(!(src in GLOB.antagonist_teams))
		GLOB.antagonist_teams += src
	_shadowling_dedupe_teams()

/datum/team/shadow_hive/Destroy()
	for(var/mob/living/L as anything in lings)
		if(!QDELETED(L))
			UnregisterSignal(L, COMSIG_QDELETING)
	for(var/mob/living/T as anything in thralls)
		if(!QDELETED(T))
			UnregisterSignal(T, COMSIG_QDELETING)
	lings.Cut()
	thralls.Cut()
	ling_roles.Cut()
	return ..()

/datum/team/shadow_hive/add_member(datum/mind/new_member)
	. = ..()
	if(!new_member)
		return
	if(is_unassigned_job(new_member.assigned_role))
		return
	if(!(new_member in members))
		members += new_member

/datum/team/shadow_hive/remove_member(datum/mind/old_member)
	. = ..()
	if(!old_member)
		return
	members -= old_member

/datum/team/shadow_hive/proc/join_member(mob/living/carbon/human/H, role = SHADOWLING_ROLE_THRALL)
	if(!istype(H))
		return
	if(QDELETED(H))
		return
	lings -= H
	thralls -= H
	ling_roles -= H
	UnregisterSignal(H, COMSIG_QDELETING)
	if(role == SHADOWLING_ROLE_THRALL)
		thralls += H
	else
		lings += H
		ling_roles[H] = role
	RegisterSignal(H, COMSIG_QDELETING, PROC_REF(_on_member_qdel))
	if(H.mind && !(H.mind in members))
		members += H.mind
	to_chat(H, span_notice("Вы ощущаете голоса роя в своей голове..."))
	grant_sync_action(H)
	grant_comm_action(H)

/datum/team/shadow_hive/proc/leave_member(mob/living/carbon/human/H)
	if(!istype(H))
		return
	lings -= H
	thralls -= H
	ling_roles -= H
	UnregisterSignal(H, COMSIG_QDELETING)
	if(H.mind && (H.mind in members))
		members -= H.mind

/datum/team/shadow_hive/proc/_on_member_qdel(mob/living/source)
	SIGNAL_HANDLER
	lings -= source
	thralls -= source
	ling_roles -= source
	UnregisterSignal(source, COMSIG_QDELETING)
	if(source?.mind && (source.mind in members))
		members -= source.mind

/datum/team/shadow_hive/proc/sanitize()
	for(var/i = length(lings) to 1 step -1)
		var/mob/living/L = lings[i]
		if(QDELETED(L) || !istype(L, /mob/living))
			lings.Cut(i, i + 1)
	for(var/i = length(thralls) to 1 step -1)
		var/mob/living/T = thralls[i]
		if(QDELETED(T) || !istype(T, /mob/living))
			thralls.Cut(i, i + 1)
	for(var/mob/M as anything in ling_roles)
		if(!(M in lings))
			ling_roles -= M
	var/list/keep = list()
	for(var/mob/living/carbon/human/K in lings + thralls)
		if(K?.mind)
			keep[K.mind] = TRUE
	for(var/datum/mind/mm as anything in members)
		if(!keep[mm])
			members -= mm

/datum/team/shadow_hive/proc/count_alive_thralls()
	sanitize()
	var/n = 0
	for(var/mob/living/carbon/human/T in thralls)
		if(QDELETED(T))
			continue
		if(T.stat == DEAD)
			continue
		n++
	return n

/datum/team/shadow_hive/proc/grant_sync_action(mob/living/carbon/human/H)
	if(!istype(H))
		return
	var/check_thralls = (H in thralls)
	var/check_lings = (H in lings)
	if(!((isshadowling(H) && check_lings) || check_thralls))
		return
	for(var/datum/action/cooldown/shadowling/hive_sync/existing in H.actions)
		return
	var/datum/action/cooldown/shadowling/hive_sync/A = new
	A.Grant(H)

/datum/team/shadow_hive/proc/grant_comm_action(mob/living/carbon/human/H)
	if(!istype(H))
		return
	for(var/datum/action/cooldown/shadowling/commune/existing in H.actions)
		return
	var/datum/action/cooldown/shadowling/commune/A = new
	A.Grant(H)

/datum/team/shadow_hive/proc/get_ling_role(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	if(!(H in lings))
		return null
	return ling_roles[H]

/datum/team/shadow_hive/proc/apply_evac_delay(delay_time = 10 MINUTES)
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

/datum/team/shadow_hive/proc/shadowling_set_ascended(mob/living/carbon/human/H, ascended = TRUE)
	if(!istype(H))
		return
	if(ascended)
		H.set_species(/datum/species/shadow/shadowling/ascended)
	else
		H.set_species(/datum/species/shadow/shadowling)

/proc/_shadowling_dedupe_teams()
	var/datum/team/shadow_hive/main = get_shadow_hive()
	if(!main)
		return

	var/list/dupes = list()
	for(var/datum/team/shadow_hive/T in GLOB.antagonist_teams)
		if(T != main)
			dupes += T

	for(var/datum/team/shadow_hive/T in dupes)
		for(var/datum/mind/M in T.members)
			if(M && !(M in main.members))
				main.members += M
		GLOB.antagonist_teams -= T
		qdel(T)

/datum/team/shadow_hive/proc/setup_objectives()
	if(length(objectives))
		return

	add_objective(new /datum/objective/shadowling/enslave_fraction)
	add_objective(new /datum/objective/shadowling/ascend)

	refresh_ascension_thralls_needed()

/datum/team/shadow_hive/proc/get_objectives()
	return objectives

/datum/team/shadow_hive/proc/sync_after_event(mob/living/carbon/human/actor)
	for(var/datum/action/cooldown/shadowling/hive_sync/A in actor.actions)
		if(A)
			A.DoEffect(actor)

/proc/get_shadow_hive()
	if(GLOB.shadowling_hive)
		return GLOB.shadowling_hive

	var/datum/team/shadow_hive/T = new /datum/team/shadow_hive
	GLOB.shadowling_hive = T
	if(!(T in GLOB.antagonist_teams))
		GLOB.antagonist_teams += T
	_shadowling_dedupe_teams()
	return T

/datum/team/shadow_hive/proc/shadowling_grant_hatch(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	for(var/datum/action/cooldown/shadowling/hatch/X in H.actions)
		return X
	var/datum/action/cooldown/shadowling/hatch/A = new
	A.Grant(H)

/datum/team/shadow_hive/proc/shadowling_grant_nightvision(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	for(var/datum/action/cooldown/shadowling/toggle_night_vision/X in H.actions)
		return X
	var/datum/action/cooldown/shadowling/toggle_night_vision/A = new
	A.Grant(H)
	return A

/datum/team/shadow_hive/proc/get_ascension_thralls_needed()
	if(asc_thralls_needed > 0)
		return asc_thralls_needed

	return refresh_ascension_thralls_needed()

/datum/team/shadow_hive/proc/refresh_ascension_thralls_needed()
	var/datum/objective/shadowling/enslave_fraction/obj = null
	if(islist(objectives))
		obj = (locate(/datum/objective/shadowling/enslave_fraction) in objectives)

	if(obj)
		asc_thralls_needed = max(1, obj.required_thralls())
		return asc_thralls_needed

	var/baseline = 0
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY)
			baseline++

	if(!baseline)
		baseline = length(get_crewmember_minds())
	if(baseline <= 0)
		baseline = 1

	asc_thralls_needed = max(1, floor((baseline * SHADOWLING_ASCEND_DEFAULT_PERCENT) / 100))
	return asc_thralls_needed
