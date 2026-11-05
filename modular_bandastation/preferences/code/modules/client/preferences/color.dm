/datum/preferences
	/// Changes on profile loads and edits, including replacing a character in the same slot.
	var/character_preferences_revision = 0

/datum/preferences/load_character(slot = default_slot)
	. = ..()
	character_preferences_revision++

/datum/preferences/update_preference(datum/preference/preference, preference_value)
	. = ..()
	if(. && preference.savefile_identifier == PREFERENCE_CHARACTER)
		character_preferences_revision++

/// The native modal/update operation resumes only for its original owner and character.
/datum/preferences/proc/is_color_preference_context_current(datum/preference/color/preference, character_revision, datum/tgui/ui)
	if(QDELETED(ui) || ui.status != UI_INTERACTIVE || !ui.user?.client || ui.user.client != parent || parent.prefs != src)
		return FALSE
	return preference.savefile_identifier != PREFERENCE_CHARACTER || character_revision == character_preferences_revision
