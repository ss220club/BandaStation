/datum/preference/numeric/fov_alpha
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "fov_alpha"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/fov_alpha/create_default_value()
	return 20

/datum/preference/numeric/fov_alpha/apply_to_client(client/client, value)
	client.fov_alpha = value / 100
	fov_update_client_matrix(client)
	fov_refresh_client_plane(client)

/datum/preference/color/fov_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "fov_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/fov_color/create_default_value()
	return "#000000"

/datum/preference/color/fov_color/apply_to_client(client/client, value)
	client.fov_color = value
	fov_update_client_matrix(client)
	fov_refresh_client_plane(client)
