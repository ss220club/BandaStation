/// Shared vampire casting policy for native tg spell actions.
/datum/component/vampire_ability
	var/required_blood
	var/deduct_blood_on_cast

/datum/component/vampire_ability/Initialize(required_blood = 0, deduct_blood_on_cast = TRUE)
	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE
	var/datum/action/cooldown/spell/spell = parent
	spell.spell_requirements = NONE
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
			to_chat(spell.owner, span_warning("Не в состоянии смерти!"))
		return SPELL_CANCEL_CAST
	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)
	if(vampire.nullified >= VAMPIRE_COMPLETE_NULLIFICATION && !fullpower)
		if(feedback)
			to_chat(spell.owner, span_warning("Что-то блокирует ваши силы!"))
		return SPELL_CANCEL_CAST
	var/blood_cost = calculate_blood_cost(vampire)
	if(vampire.bloodusable < blood_cost)
		if(feedback)
			to_chat(spell.owner, span_warning("Для этого требуется как минимум [blood_cost] единиц доступной крови!"))
		return SPELL_CANCEL_CAST
	if(istype(get_area(spell.owner), /area/station/service/chapel) && !fullpower)
		if(feedback)
			to_chat(spell.owner, span_warning("На этой святой земле ваши силы бесполезны."))
		return SPELL_CANCEL_CAST
	return NONE

/datum/component/vampire_ability/proc/before_cast(datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER
	if(deduct_blood_on_cast)
		deduct_blood(spell)

/datum/component/vampire_ability/proc/deduct_blood(datum/action/cooldown/spell/spell)
	if(!required_blood)
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
	to_chat(spell.owner, span_boldnotice("У вас осталось [vampire.bloodusable] единиц доступной крови."))
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell.type]")

/datum/action/cooldown/spell/proc/add_vampire_ability(required_blood = 0, deduct_blood_on_cast = TRUE)
	if(required_blood)
		name += " ([required_blood])"
	background_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	overlay_icon_state = "bg_vampire_border"
	AddComponent(/datum/component/vampire_ability, required_blood, deduct_blood_on_cast)
