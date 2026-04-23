/datum/preference_middleware/body_modifications
	action_delegations = list(
		"apply_body_modification" = PROC_REF(apply_body_modification),
		"remove_body_modification" = PROC_REF(remove_body_modification),
		"set_body_modification_manufacturer" = PROC_REF(set_body_modification_manufacturer),
		"play_boot_sound" = PROC_REF(play_boot_sound),
		"play_boot_complete_sound" = PROC_REF(play_boot_complete_sound),
		"play_click_sound" = PROC_REF(play_click_sound),
		"play_install_sound" = PROC_REF(play_install_sound),
		"play_deselect_sound" = PROC_REF(play_deselect_sound),
		"start_hover_loop" = PROC_REF(start_hover_loop),
		"stop_hover_loop" = PROC_REF(stop_hover_loop),
	)

/datum/preference_middleware/body_modifications/get_ui_data(mob/user)
	var/list/data = list()
	data["applied_body_modifications"] = get_applied_body_modifications()
	data["incompatible_body_modifications"] = get_incompatible_body_modifications(user)
	data["manufacturers"] = get_prosthesis_manufacturers()
	data["selected_manufacturer"] = get_selected_manufacturers(user)
	return data

/datum/preference_middleware/body_modifications/get_constant_data(mob/user)
	var/list/data = list()
	for(var/body_modification_key in GLOB.body_modifications)
		var/datum/body_modification/body_modification = GLOB.body_modifications[body_modification_key]
		data += list(
			list(
				"key" = body_modification.key,
				"name" = body_modification.name,
				"description" = body_modification.get_description(),
				"cost" = body_modification.cost,
				"category" = body_modification.category
			)
		)

	return data

/datum/preference_middleware/body_modifications/proc/get_applied_body_modifications()
	PRIVATE_PROC(TRUE)

	var/list/applied_body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	var/list/modifications = list()
	for(var/body_modification_key in applied_body_modifications)
		modifications += body_modification_key

	return modifications

/datum/preference_middleware/body_modifications/proc/get_incompatible_body_modifications(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/incompatible_body_modifications = list()
	var/list/applied = preferences.read_preference(/datum/preference/body_modifications)

	for(var/body_modification_key in GLOB.body_modifications)
		var/datum/body_modification/M = GLOB.body_modifications[body_modification_key]
		if(!LAZYLEN(M.incompatible_body_modifications & applied))
			continue
		incompatible_body_modifications += body_modification_key

	return incompatible_body_modifications

/datum/preference_middleware/body_modifications/proc/get_prosthesis_manufacturers()
	PRIVATE_PROC(TRUE)

	var/list/manufacturers_map = list()
	for(var/key in GLOB.body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis = modification
		manufacturers_map[key] = prosthesis.manufacturers || list()

	return manufacturers_map

/datum/preference_middleware/body_modifications/proc/get_selected_manufacturers(mob/user)
	PRIVATE_PROC(TRUE)

	var/list/current_brands = list()
	var/list/player_modifications = preferences.read_preference(/datum/preference/body_modifications)

	for(var/key in GLOB.body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification, /datum/body_modification/bodypart_prosthesis))
			continue

		var/datum/body_modification/bodypart_prosthesis/prosthesis = modification
		current_brands[key] = player_modifications[key]?["selected_manufacturer"] || prosthesis.get_default_manufacturer()

	return current_brands

/// Принудительно пересоздаёт тело в превью персонажа.
/// При смене производителя/модификации гарантирует чистую
/// пересборку dummy-моба с последующим apply_prefs_to.
/datum/preference_middleware/body_modifications/proc/force_preview_rebuild()
	var/atom/movable/screen/map_view/char_preview/preview = preferences.character_preview_view
	if(!preview)
		return
	QDEL_NULL(preview.body)
	preview.update_body()

/datum/preference_middleware/body_modifications/proc/apply_body_modification(list/params, mob/user)
	var/key = params["body_modification_key"]
	if(!key)
		return FALSE

	var/datum/body_modification/modification = GLOB.body_modifications[key]
	if(!istype(modification) || !modification.can_be_applied(user))
		return FALSE

	var/list/updated_preference = preferences.read_preference(/datum/preference/body_modifications)
	if(!isnull(updated_preference[key]))
		return FALSE

	if(modification.ui_params_valid(params))
		updated_preference[key] = modification.handle_ui_params(params)
	else
		updated_preference[key] = modification.default_preference_value(params)

	if(!preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], updated_preference))
		return FALSE

	refresh_body_modification_on_user(modification, user, updated_preference[key])
	return TRUE

/datum/preference_middleware/body_modifications/proc/remove_body_modification(list/params, mob/user)
	var/body_modification_key = params["body_modification_key"]
	if(!body_modification_key)
		return FALSE

	var/list/body_modifications = preferences.read_preference(/datum/preference/body_modifications)
	if(isnull(body_modifications[body_modification_key]))
		return FALSE

	body_modifications -= body_modification_key
	if(!preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], body_modifications))
		return FALSE

	return TRUE

/datum/preference_middleware/body_modifications/proc/set_body_modification_manufacturer(list/params, mob/user)
	var/key = params["body_modification_key"]
	if(!key)
		return FALSE

	var/list/updated_preference = preferences.read_preference(/datum/preference/body_modifications)
	if(!islist(updated_preference[key]))
		return FALSE

	var/datum/body_modification/modification = GLOB.body_modifications[key]
	if(!istype(modification, /datum/body_modification/bodypart_prosthesis))
		return FALSE

	if(!modification.ui_params_valid(params))
		return FALSE

	updated_preference[key] = modification.handle_ui_params(params)
	if(!preferences.update_preference(GLOB.preference_entries[/datum/preference/body_modifications], updated_preference))
		return FALSE

	refresh_body_modification_on_user(modification, user, updated_preference[key])
	return TRUE

/// Проигрывает звук загрузки при открытии интерфейса RipperDoc.
/datum/preference_middleware/body_modifications/proc/play_boot_sound(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/loading.ogg')
	S.volume = 50
	S.wait = FALSE
	user.client << S
	return FALSE

/// Проигрывает джингл по завершении загрузочной анимации RipperDoc.
/datum/preference_middleware/body_modifications/proc/play_boot_complete_sound(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/Launch2.ogg')
	S.volume = 55
	S.wait = FALSE
	user.client << S
	return FALSE

/// Проигрывает звук нажатия кнопки в обычном меню модификаций.
/datum/preference_middleware/body_modifications/proc/play_click_sound(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/Select2.ogg')
	S.volume = 40
	S.wait = FALSE
	user.client << S
	return FALSE

/// Проигрывает звук подтверждения выбора/установки модификации.
/datum/preference_middleware/body_modifications/proc/play_install_sound(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/Select1.ogg')
	S.volume = 40
	S.wait = FALSE
	user.client << S
	return FALSE

/// Проигрывает звук удаления модификации (кнопка "Удалить").
/datum/preference_middleware/body_modifications/proc/play_deselect_sound(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/deselect1.ogg')
	S.volume = 40
	S.wait = FALSE
	user.client << S
	return FALSE

/// Запускает зацикленный звук при наведении на кнопку "Сообщить об ошибке" в меню КПБ.
/datum/preference_middleware/body_modifications/proc/start_hover_loop(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound('modular_bandastation/augmentation_preferences/sound/ui_mm_alert.ogg')
	S.volume = 45
	S.wait = FALSE
	S.repeat = TRUE
	S.channel = 500
	user.client << S
	return FALSE

/// Останавливает зацикленный звук кнопки "Сообщить об ошибке".
/datum/preference_middleware/body_modifications/proc/stop_hover_loop(list/params, mob/user)
	if(!user?.client)
		return FALSE
	var/sound/S = sound(null)
	S.channel = 500
	user.client << S
	return FALSE
/datum/preference_middleware/body_modifications/proc/refresh_body_modification_on_user(datum/body_modification/modification, mob/user, list/modification_params)
	PRIVATE_PROC(TRUE)

	if(!istype(user, /mob/living/carbon/human))
		return FALSE

	var/mob/living/carbon/human/human_user = user
	if(QDELETED(human_user) || !human_user.client)
		return FALSE

	return modification.apply_to_human(human_user, modification_params)
