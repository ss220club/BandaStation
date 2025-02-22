/datum/action/changeling/adrenaline
	name = "Repurposed Glands"
	desc = "Мы переносим почти всю доступную массу из рук в ноги, тем самым делая невозможным использование рук, но позволяет нам игнорировать оглушенияи на 20 секунд. Стоит 25 химикатов."
	helptext = "Отключает ваши руки и убирает био-оружие, но восстанавливает ваши ноги, ускоряя их и снимая все оглушения."
	button_icon_state = "adrenaline"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/adrenaline/can_sting(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT_FROM(user, TRAIT_PARALYSIS_L_ARM, CHANGELING_TRAIT) || HAS_TRAIT_FROM(user, TRAIT_PARALYSIS_R_ARM, CHANGELING_TRAIT))
		user.balloon_alert(user, "уже усилены!")
		return FALSE

	return .

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()
	to_chat(user, span_changeling("Наши руки слабы, но ноги - неостановимы!"))

	for(var/datum/action/changeling/weapon/weapon_ability in user.actions)
		weapon_ability.unequip_held(user)

	// Destroy legcuffs with our IMMENSE LEG STRENGTH.
	if(istype(user.legcuffed))
		user.visible_message(
			span_warning("Ноги [user.declent_ru(GENITIVE)] неожиданно разрывают [user.legcuffed.declent_ru(ACCUSATIVE)]!"),
			span_warning("Мы разрываем связывание на ногах!"),
		)
		qdel(user.legcuffed)

	// Regenerate our legs only.
	var/our_leg_zones = (GLOB.all_body_zones - GLOB.leg_zones)
	user.regenerate_limbs(excluded_zones = our_leg_zones) // why is this exclusive rather than inclusive

	user.add_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
	user.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

	// Revert above mob changes.
	addtimer(CALLBACK(src, PROC_REF(unsting_action), user), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	// Add fast reagents to go fast.
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds

	return TRUE

/datum/action/changeling/adrenaline/proc/unsting_action(mob/living/user)
	to_chat(user, span_changeling("Мускулы в наших конечностях возвращаются в норму."))
	user.remove_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
	user.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
