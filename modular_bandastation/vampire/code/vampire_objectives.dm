/// Objectives that track the vampire datum rather than generic mob state.
/datum/objective/vampire
	abstract_type = /datum/objective/vampire

/datum/objective/vampire/blood
	name = "drink blood"

/datum/objective/vampire/blood/New()
	. = ..()
	target_amount = round(rand(150, 400) / 5) * 5

/datum/objective/vampire/blood/update_explanation_text()
	explanation_text = "Наберите в общей сложности не менее [target_amount] единиц крови."

/datum/objective/vampire/blood/check_completion()
	for(var/datum/mind/vampire_mind as anything in get_owners())
		var/datum/antagonist/vampire/vampire = vampire_mind.has_antag_datum(/datum/antagonist/vampire)
		if(vampire?.bloodtotal >= target_amount)
			return TRUE
	return FALSE

/datum/objective/vampire/specialization
	name = "vampire subclass"
	var/specialization_objective

/datum/objective/vampire/specialization/update_explanation_text()
	var/datum/antagonist/vampire/vampire = owner?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire?.subclass)
		explanation_text = "Накопите не менее 150 единиц крови и выберите специализацию, чтобы получить дальнейшие инструкции."
		return
	if(!specialization_objective)
		var/static/list/departments = list("security", "service", "research", "medical", "engineering", "supply")
		specialization_objective = replacetext(pick(vampire.subclass.unique_objectives), "%DEPARTMENT", pick(departments))
	explanation_text = specialization_objective

/datum/objective/vampire/specialization/check_completion()
	var/datum/antagonist/vampire/vampire = owner?.has_antag_datum(/datum/antagonist/vampire)
	return vampire?.subclass && vampire.bloodtotal >= 150

/datum/objective/vampire/lair
	name = "establish a lair"
	explanation_text = "Создайте логово, сделав гроб своим убежищем."

/datum/objective/vampire/lair/check_completion()
	for(var/datum/mind/vampire_mind as anything in get_owners())
		var/datum/antagonist/vampire/vampire = vampire_mind.has_antag_datum(/datum/antagonist/vampire)
		if(vampire?.has_lair)
			return TRUE
	return FALSE
