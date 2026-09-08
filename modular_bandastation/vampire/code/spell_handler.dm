/// Shared vampire casting policy for native tg spell actions.
/datum/component/vampire_ability
	var/required_blood
	var/deduct_blood_on_cast

/datum/component/vampire_ability/Initialize(required_blood = 0, deduct_blood_on_cast = TRUE)
	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE
	src.required_blood = required_blood
	src.deduct_blood_on_cast = deduct_blood_on_cast
	RegisterSignal(parent, COMSIG_SPELL_CAN_CAST_CHECK, PROC_REF(can_cast))
	RegisterSignal(parent, COMSIG_SPELL_BEFORE_CAST, PROC_REF(before_cast))
	RegisterSignal(parent, COMSIG_SPELL_AFTER_CAST, PROC_REF(after_cast))

/datum/component/vampire_ability/proc/get_vampire(datum/action/cooldown/spell/spell)
	return spell.owner?.mind?.has_antag_datum(/datum/antagonist/vampire)

/datum/component/vampire_ability/proc/calculate_blood_cost(datum/antagonist/vampire/vampire)
	return round(required_blood * (1 + vampire.nullified / 100))

/datum/component/vampire_ability/proc/can_cast(datum/action/cooldown/spell/spell, feedback)
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/vampire = get_vampire(spell)
	if(!vampire)
		return SPELL_CANCEL_CAST
	if(spell.owner.stat >= DEAD)
		if(feedback)
			to_chat(spell.owner, span_warning("Not while you're dead!"))
		return SPELL_CANCEL_CAST
	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)
	if(vampire.nullified >= VAMPIRE_COMPLETE_NULLIFICATION && !fullpower)
		if(feedback)
			to_chat(spell.owner, span_warning("Something is blocking your powers!"))
		return SPELL_CANCEL_CAST
	var/blood_cost = calculate_blood_cost(vampire)
	if(vampire.bloodusable < blood_cost)
		if(feedback)
			to_chat(spell.owner, span_warning("You require at least [blood_cost] units of usable blood to do that!"))
		return SPELL_CANCEL_CAST
	if(istype(get_area(spell.owner), /area/station/service/chapel) && !fullpower)
		if(feedback)
			to_chat(spell.owner, span_warning("Your powers are useless on this holy ground."))
		return SPELL_CANCEL_CAST
	return NONE

/datum/component/vampire_ability/proc/before_cast(datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER
	if(!deduct_blood_on_cast || !required_blood)
		return
	var/datum/antagonist/vampire/vampire = get_vampire(spell)
	vampire?.subtract_usable_blood(calculate_blood_cost(vampire))

/datum/component/vampire_ability/proc/after_cast(datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER
	if(!required_blood)
		return
	var/datum/antagonist/vampire/vampire = get_vampire(spell)
	if(!vampire)
		return
	to_chat(spell.owner, span_boldnotice("You have [vampire.bloodusable] left to use."))
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell.type]")

/datum/action/cooldown/spell/proc/add_vampire_ability(required_blood = 0, deduct_blood_on_cast = TRUE)
	AddComponent(/datum/component/vampire_ability, required_blood, deduct_blood_on_cast)
