/datum/bloodsucker_clan/brujah
	name = CLAN_BRUJAH
	description =  "Бруджа стремятся к захвату власти прямыми (и, как правило, насильственными) средствами.\n\
		С возрастом они приобретают мощное телосложение и становятся способными уничтожить практически все голыми руками.\n\
		С ними следует быть острожонее, так как это ярые повстанцы, бунтовщики и анархисты, которые всегда пытаются подорвать авторитет местных властей. \n\
		Их любимый вассал получает частичку их необычайной физической силы в виде  the regular Brawn ability, а его кулаки становятся смертоносным оружием."
	clan_objective = /datum/objective/brujah_clan_objective
	join_icon_state = "Бруджа"
	join_description = "Вы получите улучшенную версию способности the brawn, которая позволит вам разрушать большинство сооружений (включая стены!) \
		Восстаньте против власти и попытайся ниспровергнуть её, но, в свою очредь, вы <b>немедленно прекратите маскарад присоединившиь к нам</b>  \
		и потеряете почти всю свою человечность."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY


/datum/bloodsucker_clan/brujah/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	owner_datum.special_vassals -= DISCORDANT_VASSAL //Removes Discordant Vassal, which is in the list by default.
	owner_datum.break_masquerade()
	owner_datum.AddHumanityLost(37.5) // Frenzy at 400
	bloodsuckerdatum.remove_nondefault_powers(return_levels = TRUE)
	// Copied over from 'clan_tremere.dm' with appropriate adjustment.
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if((initial(power.purchase_flags) & BRUJAH_DEFAULT_POWER))
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/brujah/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank, blood_cost)
	// Give them a quick warning about losing humanity on ranking up before actually ranking them up...
	var/mob/living/carbon/human/our_antag = source.owner.current
	var/warning_accepted = tgui_alert(our_antag, \
		"Поскольку вы являетесь частью клана Бруджа, повышение вашего ранга также уменьшит вашу человечность. \n\
		Это увеличит ваш текущий порог вхождения в  безумие с  [source.frenzy_threshold] до \
		[source.frenzy_threshold + 50]. Пожалуйста, убедитесь, что у вас достаточно крови, иначе вы рискуете впасть в безумие.", \
		"ИМЕЙТЕ ЭТО В ВИДУ", \
		list("Accept Warning", "Abort Ranking Up"))
	if(warning_accepted != "Accept Warning")
		return FALSE
	return ..()

/datum/bloodsucker_clan/brujah/finalize_spend_rank(datum/antagonist/bloodsucker/source, cost_rank, blood_cost)
	. = ..()
	source.AddHumanityLost(5) //Increases frenzy threshold by fifty

/// Raise the damage of both of their hands by four. Copied from 'finalize_spend_rank()' in '_clan.dm'
/datum/bloodsucker_clan/brujah/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	. = ..()
	var/mob/living/carbon/our_vassal = vassaldatum.owner.current
	var/obj/item/bodypart/vassal_left_hand = our_vassal.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/vassal_right_hand = our_vassal.get_bodypart(BODY_ZONE_R_ARM)
	vassal_left_hand.unarmed_damage_low += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_right_hand.unarmed_damage_low += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_left_hand.unarmed_damage_high += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_right_hand.unarmed_damage_high += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS

/**
 * Clan Objective
 * Brujah's Clan objective is to brainwash the highest ranking person on the station (if any.)
 * Made by referencing 'objective.dm'
 */
/datum/objective/brujah_clan_objective
	name = "brujahrevolution"
	martyr_compatible = TRUE

	/// Set to true when the target is turned into a Discordant Vassal.
	var/target_subverted = FALSE
	/// I have no idea what this actually does. It's on a lot of other assassination/similar objectives though...
	var/target_role_type = FALSE

/datum/objective/brujah_clan_objective/New(text)
	. = ..()
	get_target()
	update_explanation_text()

/datum/objective/brujah_clan_objective/check_completion()
	if(target_subverted)
		return TRUE
	return FALSE

/datum/objective/brujah_clan_objective/update_explanation_text()
	if(target?.current)
		explanation_text = "Подорвите авторитет [target.name] в роли [!target_role_type ? target.assigned_role.title : target.special_role] \
			превратив [target.p_them()] в Анархичного вассала на стойке для убеждения."
	else
		explanation_text = "Free objective."

/// Made after referencing '/datum/team/revolution/roundend_report()' in 'revolution.dm'
/datum/objective/brujah_clan_objective/get_target()
	var/list/target_options = SSjob.get_living_heads() //Look for heads...
	if(!target_options.len)
		target_options = SSjob.get_living_sec() //If no heads then look for security...
		if(!target_options.len)
			target_options = get_crewmember_minds() //If no security then look for ANY CREW MEMBER.

	if(target_options.len)
		target_options.Remove(owner)
	else
		update_explanation_text()
		return

	for(var/datum/mind/possible_target in target_options)
		if(!is_valid_target(possible_target))
			target_options.Remove(possible_target)

	target = pick(target_options)
	update_explanation_text()
