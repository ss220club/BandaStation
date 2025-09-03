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
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	if(GLOB.shadowling_vote)
		to_chat(H, span_warning("Голосование уже идёт."))
		return FALSE

	if(length(hive.lings) <= 0)
		to_chat(H, span_warning("Некому голосовать."))
		return FALSE

	var/datum/shadow_vote/V = new
	GLOB.shadowling_vote = V
	V.start(hive)
	to_chat(H, span_notice("Вы запускаете голосование за лидера улья."))
	return TRUE

/// ==== Датум голосования ====
/datum/shadow_vote
	var/active = FALSE
	var/duration = 30 SECONDS
	var/list/candidates
	var/list/votes // [voter] = candidate

/datum/shadow_vote/proc/start(datum/shadow_hive/hive)
	if(active)
		return
	active = TRUE
	candidates = list()
	votes = list()
	for(var/mob/living/carbon/human/L in hive.lings)
		if(!QDELETED(L))
			candidates += L
	if(!length(candidates))
		finalize(hive)
		return

	for(var/mob/living/carbon/human/L in hive.lings)
		if(QDELETED(L))
			continue
		spawn(0)
			prompt_one(hive, L)

	addtimer(CALLBACK(src, PROC_REF(finalize), hive), duration)

/datum/shadow_vote/proc/prompt_one(datum/shadow_hive/hive, mob/living/carbon/human/voter)
	if(!active || QDELETED(voter))
		return
	if(!(voter in hive.lings))
		return
	var/list/choices = list()
	for(var/mob/living/carbon/human/C in candidates)
		choices["[C.real_name]"] = C
	var/ans = input(voter, "Выберите лидера улья:", "Голосование") as null|anything in choices
	if(!active)
		return
	if(ans && (voter in hive.lings))
		votes[voter] = choices[ans]
		to_chat(voter, span_notice("Ваш голос учтён."))

/datum/shadow_vote/proc/finalize(datum/shadow_hive/hive)
	if(!active)
		return
	active = FALSE

	// Подсчёт голосов
	var/list/tally = list()
	for(var/mob/living/carbon/human/C in candidates)
		tally[C] = 0
	for(var/mob/living/carbon/human/Voter in votes)
		var/mob/living/carbon/human/Choice = votes[Voter]
		if(Choice && (Choice in tally))
			tally[Choice]++

	// Если никто не проголосовал — случайный кандидат
	var/list/winners = list()
	var/best = -1
	for(var/mob/living/carbon/human/C in tally)
		var/cnt = tally[C]
		if(cnt > best)
			winners = list(C)
			best = cnt
		else if(cnt == best)
			winners += C
	if(!length(winners))
		winners = candidates.Copy()

	var/mob/living/carbon/human/leader = pick(winners)

	// Выдать саботаж лидеру
	if(leader && !QDELETED(leader))
		var/datum/action/cooldown/shadowling/engine_sabotage/S = new
		S.Grant(leader)
		for(var/mob/living/carbon/human/L in hive.lings)
			if(QDELETED(L)) continue
			to_chat(L, span_boldnotice("Лидером улья выбран: [leader.real_name]. Ему дарован «Саботаж двигателей»."))
	// Снять «Голос лидера» со всех
	remove_vote_action_from_all(hive)

	// Очистить глобал
	if(GLOB.shadowling_vote == src)
		GLOB.shadowling_vote = null

/datum/shadow_vote/proc/remove_vote_action_from_all(datum/shadow_hive/hive)
	for(var/mob/living/carbon/human/M in (hive.lings + hive.thralls))
		for(var/datum/action/cooldown/shadowling/election/A in M.actions)
			A.Remove(M)
			qdel(A)
