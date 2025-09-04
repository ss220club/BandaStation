/datum/mood_event/shadowling
	description = "Холодная тьма внутри шепчет о власти."
	mood_change = 12
	hidden = TRUE

/datum/antagonist/shadowling
	name = "Shadowlings"
	antagpanel_category = "Shadowlings"
	show_in_antagpanel = TRUE
	preview_outfit = null
	pref_flag = ROLE_SHADOWLING
	stinger_sound = 'modular_bandastation/antagonists/sound/shadowlings/shadowling_gain.ogg'
	antag_moodlet = /datum/mood_event/shadowling

/datum/antagonist/shadowling/greet(mob/user, tell_objectives = TRUE)
	..()

/datum/antagonist/shadowling/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner?.current
	if(istype(H))
		var/datum/action/cooldown/shadowling/hatch/A = new
		A.Grant(H)

	forge_objectives()
	owner?.announce_objectives()
	greet(H)

/datum/antagonist/shadowling/forge_objectives()
	if(length(objectives))
		return

	var/datum/objective/shadowling/enslave_fraction/ens = new
	ens.owner = owner
	objectives += ens

	var/datum/objective/survive/surv = new
	surv.owner = owner
	objectives += surv

/datum/antagonist/shadowling/get_preview_icon(mob/user)
	return ..()

/proc/shadowling_grant_hatch(mob/living/carbon/human/H)
	if(!istype(H)) return
	for(var/datum/action/cooldown/shadowling/hatch/X in H.actions)
		return
	var/datum/action/cooldown/shadowling/hatch/A = new
	A.Grant(H)

/datum/objective/shadowling/enslave_fraction
	name = "subjugate crew"
	admin_grantable = TRUE

	var/percent = 25
	var/baseline_population = 0

/datum/objective/shadowling/enslave_fraction/New(pct = null)
	if(isnum(pct))
		percent = clamp(round(pct), 1, 100)
	capture_baseline_population()
	update_explanation_text()
	return ..()

/datum/objective/shadowling/enslave_fraction/proc/capture_baseline_population()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY)
			baseline_population++
	if(!baseline_population)
		baseline_population = length(get_crewmember_minds())
	if(baseline_population <= 0)
		baseline_population = 1

/datum/objective/shadowling/enslave_fraction/proc/required_thralls()
	var/need_exact = (baseline_population * percent) / 100
	var/need = round(need_exact)
	if(need < need_exact)
		need++
	return max(1, need)

/datum/objective/shadowling/enslave_fraction/proc/current_thralls()
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return 0
	return hive.count_nt()

/datum/objective/shadowling/enslave_fraction/update_explanation_text()
	var/need = required_thralls()
	var/have = current_thralls()
	explanation_text = "Подчините улью не менее [need] членов экипажа ([percent]% от стартового состава). Сейчас: [have]/[need]."

/datum/objective/shadowling/enslave_fraction/check_completion()
	return current_thralls() >= required_thralls()

/datum/objective/shadowling/enslave_fraction/admin_edit(mob/admin)
	var/new_pct = input(admin, "Какой процент от стартового экипажа должен быть затраллен?", "Shadowling objective", percent) as num|null
	if(isnum(new_pct))
		percent = clamp(round(new_pct), 1, 100)
		update_explanation_text()

/datum/antagonist/shadowling/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("Antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/O in objectives)
			if(!O.check_completion())
				objectives_complete = FALSE
				break

	// Сводка по улью
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(hive)
		// живые траллы уже считаются через count_nt()
		var/alive_thralls = hive.count_nt()

		var/total_lings = 0
		var/alive_lings = 0
		for(var/mob/living/carbon/human/L in hive.lings)
			total_lings++
			if(!QDELETED(L) && L.stat != DEAD)
				alive_lings++

		report += "<span class='notice'>Слуг (живых): [alive_thralls]. Шадоулинги живы: [alive_lings]/[total_lings].</span>"

	// Итог «успех/провал»
	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>[name] был успешен!</span>"
	else
		report += "<span class='redtext big'>[name] провалился!</span>"

	return report.Join("<br>")
