///Bloodsuckers spawning a Guardian will get the Bloodsucker one instead.
/obj/item/guardian_creator/attack_self(mob/living/user, mob/dead/candidate)
	if(isguardian(user) && !allow_guardian)
		balloon_alert(user, "can't do that!")
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		balloon_alert(user, "already have one!")
		return
	if(IS_CHANGELING(user) && !allow_changeling)
		to_chat(user, ling_failure)
		return
	if(used)
		to_chat(user, used_message)
		return
	if(IS_BLOODSUCKER(user))
		//var/mob/living/basic/guardian/standard/timestop/guardian_path = new(user, GUARDIAN_THEME_MAGIC)
		var/mob/living/basic/guardian/guardian_path = /mob/living/basic/guardian/standard/timestop

		// START COPIED CODE FROM guardian_creator.dm
		used = TRUE
		to_chat(user, use_message)
		var/guardian_type_name = capitalize(initial(guardian_path.creator_name))
		var/mob/chosen_one = SSpolling.poll_ghost_candidates(
		"Do you want to play as [span_danger("[user.real_name]'s")] [span_notice("[guardian_type_name] [mob_name]")]?",
		check_jobban = ROLE_PAI,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_HOLOPARASITE,
		alert_pic = guardian_path,
		jump_target = src,
		role_name_text = guardian_type_name,
		amount_to_pick = 1,
	)
		if(chosen_one)
			spawn_guardian(user, chosen_one, guardian_path)
			used = TRUE
			SEND_SIGNAL(src, COMSIG_TRAITOR_ITEM_USED(type))
	else
		to_chat(user, failure_message)
		used = FALSE

	// Call parent to deal with everyone else
	return ..()
///Bloodsuckers spawning a Guardian will get the Bloodsucker one instead.

/obj/item/guardian_creator/spawn_guardian(mob/living/user, mob/dead/candidate)
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		balloon_alert(user, "already have one!")
		used = FALSE
		return
	if(IS_BLOODSUCKER(user))
		var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = new(user, GUARDIAN_THEME_MAGIC)

		bloodsucker_guardian.set_summoner(user, different_person = TRUE)
		bloodsucker_guardian.key = candidate.key
		user.log_message("has summoned [key_name(bloodsucker_guardian)], a [bloodsucker_guardian.creator_name] holoparasite.", LOG_GAME)
		bloodsucker_guardian.log_message("was summoned as a [bloodsucker_guardian.creator_name] holoparasite.", LOG_GAME)
		to_chat(user, "Голопаразит изменяется, благодаря чистой случайности или, возможно, судьбе, а может быть, даже из-за особенностей вашей собственной физиологии. Он становится манипулятором времени, стражом, достаточно могущественным, чтобы управлять МИРОМ!")
		to_chat(user, replacetext(success_message, "%GUARDIAN", mob_name))
		bloodsucker_guardian.client?.init_verbs()
		return

	// Call parent to deal with everyone else
	return ..()

/**
 * The Guardian itself
 */
/mob/living/basic/guardian/standard/timestop
	// Like Bloodsuckers do, you will take more damage to Burn and less to Brute
	damage_coeff = list(BRUTE = 0.5, BURN = 2.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	creator_name = "Timestop"
	creator_desc = "Разрушительные атаки в ближнем бою и высокая устойчивость к урону. Может пробивать не укреплённые стены и останавливать время."
	creator_icon = "timestop"
	playstyle_string = span_holoparasite("В качестве представителя типа <b>повелитель времени</b> вы обладаете способностью останавливать время. Вместо брони у вас имеется множитель урона, а также мощные атаки ближнего боя, способные разрушать стены.")

/mob/living/basic/guardian/standard/timestop/Initialize(mapload, theme)
	//Wizard Holoparasite theme, just to be more visibly stronger than regular ones
	theme = GLOB.guardian_themes[GUARDIAN_THEME_MAGIC]
	. = ..()
	var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = new()
	timestop_ability.Grant(src)

/mob/living/basic/guardian/standard/timestop/set_summoner(mob/living/to_who, different_person = FALSE)
	..()
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.grant_summoner_immunity()

/mob/living/basic/guardian/standard/timestop/cut_summoner(different_person = FALSE)
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.remove_summoner_immunity()
	..()

///Guardian Timestop ability
/datum/action/cooldown/spell/timestop/guardian
	name = "Guardian Timestop"
	desc = "Это заклинание останавливает время для всех, кроме вас и вашего хозяина, \
		позволяя вам свободно передвигаться, в то время как ваши враги и даже снаряды заморожены."
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/timestop/guardian/proc/grant_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = owner
	if(bloodsucker_guardian && istype(bloodsucker_guardian) && bloodsucker_guardian.summoner)
		ADD_TRAIT(bloodsucker_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/guardian/proc/remove_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = owner
	if(bloodsucker_guardian && istype(bloodsucker_guardian) && bloodsucker_guardian.summoner)
		REMOVE_TRAIT(bloodsucker_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))

// Магу можно, а остальным нельзя, потому баланса ради
/obj/item/guardian_creator/wizard
	allow_multiple = TRUE
	possible_guardians = list(
		/mob/living/basic/guardian/assassin,
		/mob/living/basic/guardian/charger,
		/mob/living/basic/guardian/dextrous,
		/mob/living/basic/guardian/explosive,
		/mob/living/basic/guardian/gaseous,
		/mob/living/basic/guardian/gravitokinetic,
		/mob/living/basic/guardian/lightning,
		/mob/living/basic/guardian/protector,
		/mob/living/basic/guardian/ranged,
		/mob/living/basic/guardian/standard,
		/mob/living/basic/guardian/standard/timestop,
	)
