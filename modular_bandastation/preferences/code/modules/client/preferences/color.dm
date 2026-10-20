/// The native modal/update operation resumes only for its original owner and character.
/datum/preferences/proc/is_color_preference_context_current(datum/preference/color/preference, editing_slot, datum/tgui/ui)
	if(QDELETED(ui) || ui.status != UI_INTERACTIVE || !ui.user?.client || ui.user.client != parent || parent.prefs != src)
		return FALSE
	return preference.savefile_identifier != PREFERENCE_CHARACTER || editing_slot == default_slot
