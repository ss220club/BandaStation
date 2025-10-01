GLOBAL_LIST_INIT(donor_shines, list(
	"Автоматически" = "auto",
	"Металлик" = "metal",
	"Светящийся" = "glowing",
))

/datum/preference/choiced/donor_chat_shine
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_chat_shine"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_chat_shine/init_possible_values()
	return assoc_to_keys(GLOB.donor_shines)

/datum/preference/choiced/donor_chat_shine/create_default_value()
	return GLOB.donor_shines[1]

/datum/preference/toggle/donor_public
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "donor_public"
	savefile_identifier = PREFERENCE_PLAYER
