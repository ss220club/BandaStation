/datum/personality/department
	groups = list(PERSONALITY_GROUP_DEPARTMENT)
	/// List of areas this personality applies to
	var/list/applicable_areas

/datum/personality/department/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE), PROC_REF(update_effect))
	// Unfortunate side effect here in that IC job changes, IE HoP are missed
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area, applicable_areas & who.mind?.get_work_areas())

/datum/personality/department/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE))
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area)

/// Signal handler to update our status effect when our job changes
/datum/personality/department/proc/update_effect(mob/living/source, ...)
	SIGNAL_HANDLER

	source.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area)
	source.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/enjoying_department_area, applicable_areas & source.mind.get_work_areas())

/datum/personality/department/analytical
	savefile_key = "analytical"
	name = "Аналитический"
	desc = "Когда дело доходит до принятия решений, я склонен быть более беспристрастным."
	neut_gameplay_desc = "Предпочитает работать в системных средах, таких как инженерия, исследования или медицина"
	applicable_areas = list(
		/datum/job_department/engineering::primary_work_area,
		/datum/job_department/science::primary_work_area,
		/datum/job_department/medical::primary_work_area,
	)

/datum/personality/department/impulsive
	savefile_key = "impulsive"
	name = "Импульсивный"
	desc = "Мне лучше действовать по ситуации."
	neut_gameplay_desc = "Предпочитает работать в социальных средах, таких как снабжение, командование, безопасность или сервис"
	applicable_areas = list(
		/datum/job_department/cargo::primary_work_area,
		/datum/job_department/command::primary_work_area,
		/datum/job_department/security::primary_work_area,
		/datum/job_department/service::primary_work_area,
	)
