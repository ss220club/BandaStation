/datum/preference/choiced/height_scaling
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "height_scaling"
	savefile_identifier = PREFERENCE_CHARACTER

	var/static/list/height_scaling_strings = list(
		"[HUMAN_HEIGHT_SHORT]" = "Низкий",
		"[HUMAN_HEIGHT_MEDIUM]" = "Средний",
		"[HUMAN_HEIGHT_TALL]" = "Высокий"
	)

	var/static/list/incompatable_quirk_ids = list(
		"Spacer",
		"Settler"
	)

/datum/preference/choiced/height_scaling/init_possible_values()
	return list(HUMAN_HEIGHT_SHORT, HUMAN_HEIGHT_MEDIUM, HUMAN_HEIGHT_TALL)

/datum/preference/choiced/height_scaling/create_default_value()
	return HUMAN_HEIGHT_MEDIUM

/datum/preference/choiced/height_scaling/proc/has_incompatible_quirks(datum/preferences/preferences)
	if(!preferences?.all_quirks)
		return FALSE
	for(var/quirk_id as anything in preferences.all_quirks)
		if(quirk_id in incompatable_quirk_ids)
			return TRUE
	return FALSE

/datum/preference/choiced/height_scaling/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	return !has_incompatible_quirks(preferences)

/datum/preference/choiced/height_scaling/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(HAS_TRAIT(target, TRAIT_DWARF))
		return FALSE
	if(has_incompatible_quirks(preferences))
		return FALSE
	target.set_mob_height(value)

/datum/preference/choiced/height_scaling/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = height_scaling_strings
	return data

/mob/living/carbon/human/examine(mob/user)
    . = ..()
    var/height_pref = client?.prefs?.read_preference(/datum/preference/choiced/height_scaling)
    var/height_text = "неизвестной высоты"
    if(height_pref)
        switch(height_pref)
            if(HUMAN_HEIGHT_SHORT)
                height_text = "низкого роста"
            if(HUMAN_HEIGHT_MEDIUM)
                height_text = "среднего роста"
            if(HUMAN_HEIGHT_TALL)
                height_text = "высокого роста"
    . += "<span class='notice'>[src] [height_text].</span>"
