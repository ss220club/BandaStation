/datum/component/vampire_coffin_regeneration
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/vampire_coffin_regeneration/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/vampire_coffin_regeneration/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_STATUS_SLEEP_TICK, PROC_REF(regenerate_in_coffin))

/datum/component/vampire_coffin_regeneration/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_STATUS_SLEEP_TICK)

/datum/component/vampire_coffin_regeneration/proc/regenerate_in_coffin(mob/living/carbon/vampire, seconds_between_ticks)
	SIGNAL_HANDLER
	var/healing_multiplier = seconds_between_ticks / 2
	if(istype(vampire.loc, /obj/structure/closet/crate/coffin/vampire))
		var/obj/structure/closet/crate/coffin/vampire/coffin = vampire.loc
		if(coffin.get_vampire() != vampire)
			return
		vampire.adjust_brute_loss(-3 * healing_multiplier)
		vampire.adjust_fire_loss(-3 * healing_multiplier)
		vampire.adjust_tox_loss(-3 * healing_multiplier, forced = TRUE)
		vampire.adjust_oxy_loss(-3 * healing_multiplier)
		if(prob(25 * healing_multiplier))
			for(var/datum/disease/disease as anything in vampire.diseases)
				disease.cure()
		for(var/obj/item/bodypart/bodypart as anything in vampire.bodyparts)
			if(bodypart.brute_dam || bodypart.burn_dam)
				bodypart.heal_damage(3 * healing_multiplier, 3 * healing_multiplier)
				break
		for(var/obj/item/organ/organ as anything in vampire.organs)
			if(organ.damage)
				organ.apply_organ_damage(-2 * healing_multiplier)
				break
	else if(istype(vampire.loc, /obj/structure/closet/crate/coffin))
		vampire.adjust_brute_loss(-healing_multiplier)
		vampire.adjust_fire_loss(-healing_multiplier)
		vampire.adjust_tox_loss(-healing_multiplier, forced = TRUE)
		vampire.adjust_oxy_loss(-healing_multiplier)

/datum/status_effect/incapacitating/sleeping/tick(seconds_between_ticks)
	. = ..()
	SEND_SIGNAL(owner, COMSIG_LIVING_STATUS_SLEEP_TICK, seconds_between_ticks)
