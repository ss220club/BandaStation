/datum/action/cooldown/shadowling/election
	name = "Голос лидера"
	desc = "Запустить голосование за лидера улья среди шадоулингов. Победитель получит одноразовый «Саботаж двигателей»."
	button_icon_state = "shadow_vote"
	cooldown_time = 0
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/election/DoEffect(mob/living/carbon/human/H, atom/_)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	if(!(H in hive.lings))
		to_chat(H, span_warning("Только тенелинги могут начать голосование."))
		return FALSE

	if(GLOB.shadowling_vote_finished)
		to_chat(H, span_warning("Голосование уже завершено."))
		remove_vote_action_from(H)
		return FALSE

	var/datum/shadow_vote/V = GLOB.shadowling_vote

	if(isnull(V))
		if(length(hive.lings) <= 0)
			to_chat(H, span_warning("Некому голосовать."))
			return FALSE

		V = new
		V.hive = hive
		GLOB.shadowling_vote = V
		V.start()
		to_chat(H, span_notice("Вы запускаете голосование за лидера улья."))
		return TRUE

	if(!V.active)
		to_chat(H, span_warning("Голосование уже завершено."))
		remove_vote_action_from(H)
		return FALSE

	if(H in V.votes)
		to_chat(H, span_notice("Ваш голос уже учтён."))
		remove_vote_action_from(H)
		return FALSE

	V.prompt_one(H)
	return TRUE

/datum/action/cooldown/shadowling/election/proc/remove_vote_action_from(mob/living/carbon/human/M)
	if(!istype(M))
		return
	for(var/datum/action/cooldown/shadowling/election/A in M.actions)
		A.Remove(M)
		qdel(A)



/datum/shadow_vote
	var/active = FALSE
	var/duration = 30 SECONDS
	var/list/candidates
	var/list/votes
	var/datum/team/shadow_hive/hive

/datum/shadow_vote/proc/start()
	if(active)
		return
	if(!hive)
		finalize()
		return

	active = TRUE
	candidates = list()
	votes = list()

	for(var/mob/living/carbon/human/L in hive.lings)
		if(QDELETED(L))
			continue
		if(L.stat == DEAD)
			continue
		candidates += L

	if(!length(candidates))
		finalize()
		return

	for(var/mob/living/carbon/human/L in hive.lings)
		if(QDELETED(L) || !L.client || L.stat == DEAD)
			continue
		addtimer(CALLBACK(src, PROC_REF(prompt_one), L), 0)

	addtimer(CALLBACK(src, PROC_REF(finalize)), duration, TIMER_STOPPABLE)

/datum/shadow_vote/proc/prompt_one(mob/living/carbon/human/voter)
	if(!active)
		return
	if(QDELETED(voter))
		return
	if(!(voter in hive.lings))
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/C in candidates)
		choices["[C.real_name]"] = C

	var/ans = tgui_input_list(voter, "Выберите лидера улья:", "Голосование", choices)
	if(!active)
		return

	if(ans)
		if(voter in hive.lings)
			votes[voter] = choices[ans]
			to_chat(voter, span_notice("Ваш голос учтён."))
			// скрыть кнопку у проголосовавшего
			for(var/datum/action/cooldown/shadowling/election/A in voter.actions)
				A.Remove(voter)
				qdel(A)

/datum/shadow_vote/proc/finalize()
	if(!active)
		return
	active = FALSE

	var/list/tally = list()
	for(var/mob/living/carbon/human/C in candidates)
		tally[C] = 0
	for(var/mob/living/carbon/human/Voter in votes)
		var/mob/living/carbon/human/Choice = votes[Voter]
		if(Choice && (Choice in tally))
			tally[Choice]++

	var/list/winners = list()
	var/best = -1
	for(var/mob/living/carbon/human/C in tally)
		var/cnt = tally[C]
		if(cnt > best)
			winners = list(C); best = cnt
		else if(cnt == best)
			winners += C
	if(!length(winners))
		winners = candidates.Copy()

	var/mob/living/carbon/human/leader = pick(winners)

	if(leader && !QDELETED(leader))
		if(!GLOB.shadowling_engine_sabotage_used)
			var/datum/action/cooldown/shadowling/engine_sabotage/S = new
			S.Grant(leader)
			GLOB.shadowling_engine_sabotage_used = TRUE

		for(var/mob/living/carbon/human/L in hive.lings)
			if(QDELETED(L))
				continue
			to_chat(L, span_boldnotice("Лидером улья выбран: [leader.real_name].[GLOB.shadowling_engine_sabotage_used ? " Ему дарован «Саботаж двигателей»." : ""]"))

	remove_vote_action_from_all()

	GLOB.shadowling_vote_finished = TRUE

	if(GLOB.shadowling_vote == src)
		GLOB.shadowling_vote = null

	qdel(src)

/datum/shadow_vote/proc/remove_vote_action_from_all()
	if(!hive)
		return
	for(var/mob/living/carbon/human/M in (hive.lings + hive.thralls))
		for(var/datum/action/cooldown/shadowling/election/A in M.actions)
			A.Remove(M)
			qdel(A)
