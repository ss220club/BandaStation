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
	hud_icon = 'modular_bandastation/antagonists/icons/antag_hud.dmi'
	antag_hud_name = "shadowling"

	var/ling_role = SHADOWLING_ROLE_MAIN
	var/is_thrall = FALSE
	var/is_higher = FALSE

	var/datum/team/shadow_hive/shadow_team
	var/added_to_team = FALSE

/datum/antagonist/shadowling/can_be_owned(datum/mind/new_owner)
	if(new_owner?.has_antag_datum(type))
		return FALSE
	return ..()

/datum/antagonist/shadowling/on_gain()
	if(!owner)
		return

	shadow_team = get_shadow_hive()
	shadow_team.setup_objectives()

	if(!added_to_team && owner)
		shadow_team.add_member(owner)
		added_to_team = TRUE

	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		shadow_team.join_member(H, ling_role)

		if(!is_thrall)
			shadowling_grant_hatch(H)

	objectives |= shadow_team.get_objectives()

	owner.announce_objectives()
	var/mob/living/current = owner.current
	if(current)
		add_team_hud(current)

	if(H)
		shadow_team.sync_after_event(H)

	. = ..()

/datum/antagonist/shadowling/on_removal()
	var/mob/living/carbon/human/H = owner?.current
	if(istype(H))
		for(var/datum/action/cooldown/ability in H.actions)
			if(ability.type in typesof(/datum/action/cooldown/shadowling))
				ability.Remove(H)

		var/datum/team/shadow_hive/hive = get_shadow_hive()
		if(hive)
			hive.leave_member(H)

	if(shadow_team && owner)
		shadow_team.remove_member(owner)
	added_to_team = FALSE

	. = ..()

/datum/antagonist/shadowling/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current || mob_override
	if(current)
		add_team_hud(current)

/datum/antagonist/shadowling/proc/set_lesser()
	ling_role = SHADOWLING_ROLE_LESSER

/datum/antagonist/shadowling/proc/set_higher(state)
	is_higher = state
	var/mob/living/carbon/human/H = owner?.current
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(istype(H) && hive)
		hive.shadowling_set_ascended(H, state)

/datum/antagonist/shadow_thrall
	parent_type = /datum/antagonist/shadowling
	name = "Shadow Thrall"
	antagpanel_category = "Shadowlings"
	hud_icon = 'modular_bandastation/antagonists/icons/antag_hud.dmi'
	antag_hud_name = "shadowling_thrall"

	is_thrall = TRUE
	ling_role = SHADOWLING_ROLE_THRALL

/datum/antagonist/shadow_thrall/on_gain()
	. = ..()

	var/mob/living/carbon/human/H = owner?.current
	if(istype(H) && !H.get_organ_slot(ORGAN_SLOT_BRAIN_THRALL))
		var/obj/item/organ/brain/shadow/tumor_thrall/tumor = new
		tumor.Insert(H)

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
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return 0
	return hive.count_nt()

/datum/objective/shadowling/enslave_fraction/update_explanation_text()
	var/need = required_thralls()
	var/have = current_thralls()
	explanation_text = "Поработите не менее [need] членов экипажа. Сейчас: [have]/[need]."

/datum/objective/shadowling/enslave_fraction/check_completion()
	return current_thralls() >= required_thralls()

/datum/objective/shadowling/enslave_fraction/admin_edit(mob/admin)
	var/new_pct = input(admin, "Какой процент от стартового экипажа должен быть затраллен?", "Shadowling objective", percent) as num|null
	if(isnum(new_pct))
		percent = clamp(round(new_pct), 1, 100)
		update_explanation_text()

/datum/objective/shadowling/ascend
	name = "ascend"
	admin_grantable = TRUE

/datum/objective/shadowling/ascend/update_explanation_text()
	explanation_text = "Возвыситься, приняв высшую форму Тенелинга."

/datum/objective/shadowling/ascend/check_completion()
	if(!owner || !owner.current)
		return FALSE
	var/mob/living/carbon/human/H = owner.current
	return istype(H.dna?.species, /datum/species/shadow/shadowling/ascended)


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
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		var/alive_thralls = hive.count_nt()
		var/total_lings = 0
		var/alive_lings = 0
		for(var/mob/living/carbon/human/L in hive.lings)
			total_lings++
			if(!QDELETED(L) && L.stat != DEAD)
				alive_lings++
		report += "<span class='notice'>Слуг (живых): [alive_thralls]. Шадоулинги живы: [alive_lings]/[total_lings].</span>"
	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>[name] был успешен!</span>"
	else
		report += "<span class='redtext big'>[name] провалился!</span>"
	return report.Join("<br>")

/datum/antagonist/shadowling/get_team()
	return shadow_team

/datum/antagonist/shadow_thrall/get_team()
	return shadow_team

/proc/shadowling_grant_hatch(mob/living/carbon/human/H)
	if(!istype(H))
		return
	for(var/datum/action/cooldown/shadowling/hatch/X in H.actions)
		return
	var/datum/action/cooldown/shadowling/hatch/A = new
	A.Grant(H)

