#define JOB_SLOT_RANDOMISED_SLOT -1
#define JOB_SLOT_CURRENT_SLOT 0
#define JOB_SLOT_RANDOMISED_TEXT "Случайное имя и внешность"
#define JOB_SLOT_CURRENT_TEXT "Текущий слот"
#define MAX_CHARACTER_SLOTS 8 // should be max_save_slots, but switch need static variable

/datum/preferences
	var/list/pref_job_slots = list()

/datum/preferences/proc/get_slot_options()
	var/list/slot_options = list(num2text(JOB_SLOT_CURRENT_SLOT) = JOB_SLOT_CURRENT_TEXT)
	for(var/index in 1 to max_save_slots)
		var/slot_name = (index == default_slot) \
			? read_preference(/datum/preference/name/real_name) \
			: savefile.get_entry("character[index]")?["real_name"]

		if(slot_name)
			slot_options[num2text(index)] = slot_name

	return slot_options += list(num2text(JOB_SLOT_RANDOMISED_SLOT) = JOB_SLOT_RANDOMISED_TEXT)

/datum/preferences/proc/reset_job_slots()
	pref_job_slots = list()
	save_preferences()

/// Loads appropriate character slot for the given job as assigned in preferences, returns true if random appearance
/datum/preferences/proc/set_assigned_slot(job_title, is_late_join = FALSE)
	if(is_late_join ? read_preference(/datum/preference/toggle/late_join_always_current_slot) : read_preference(/datum/preference/toggle/round_start_always_join_current_slot))
		return
	var/slot_for_job = pref_job_slots[job_title]
	switch(slot_for_job)
		if(JOB_SLOT_RANDOMISED_SLOT)
			return TRUE
		if(JOB_SLOT_CURRENT_SLOT)
			return // explicit
		if(1 to MAX_CHARACTER_SLOTS)
			switch_to_slot(slot_for_job)

///Whether joining at roundstart ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/round_start_always_join_current_slot
	savefile_key = "round_start_always_join_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

///Whether joining during the round ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/late_join_always_current_slot
	savefile_key = "late_join_always_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

#undef JOB_SLOT_RANDOMISED_TEXT
#undef JOB_SLOT_CURRENT_TEXT
#undef MAX_CHARACTER_SLOTS
