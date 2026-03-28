/datum/preference/numeric/los_alpha
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "los_alpha"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 50
	maximum = 100
	step = 1

/datum/preference/numeric/los_alpha/create_default_value()
	return 90

/datum/preference/numeric/los_alpha/apply_to_client(client/client, value)
	los_refresh_cascade_client_prefs(client)

/datum/preference/numeric/los_blur
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "los_blur"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 2
	maximum = 6
	step = 1

/datum/preference/numeric/los_blur/create_default_value()
	return 2

/datum/preference/numeric/los_blur/apply_to_client(client/client, value)
	los_refresh_cascade_client_prefs(client)
