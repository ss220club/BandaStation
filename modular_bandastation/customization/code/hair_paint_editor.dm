/// Owns a single editor session for this preferences datum.
/datum/preference_middleware/hair_paint
	action_delegations = list("open_hair_paint" = PROC_REF(open_editor))
	/// Deleted when the slot, generic preferences, or owner are torn down.
	var/datum/hair_paint_editor/editor

/datum/preference_middleware/hair_paint/Destroy()
	QDEL_NULL(editor)
	return ..()

/datum/preference_middleware/hair_paint/on_new_character(mob/user)
	QDEL_NULL(editor)

/datum/preference_middleware/hair_paint/post_set_preference(mob/user, preference, value)
	QDEL_NULL(editor)

/// Create an owner-only session, publishing its reference before preview generation can yield.
/datum/preference_middleware/hair_paint/proc/open_editor(list/params, mob/user)
	if(user?.client != preferences.parent)
		return FALSE
	var/target = params["target"] || "hair"
	if(!(target in list("hair", "facial_hair")))
		return FALSE
	var/facial = target == "facial_hair"
	if(editor && editor.facial != facial)
		QDEL_NULL(editor)
	if(editor)
		editor.ui_interact(user)
		return TRUE
	editor = new(preferences, src, facial)
	var/datum/hair_paint_editor/opening = editor
	if(!opening.prepare() || QDELETED(opening) || editor != opening)
		if(editor == opening)
			QDEL_NULL(editor)
		return TRUE
	opening.ui_interact(user)
	return TRUE

/// Capture character state, including colour-picker updates that bypass middleware hooks.
/proc/hair_paint_character_state(datum/preferences/preferences)
	var/list/values = list("__quirks" = preferences.all_quirks)
	for(var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if(preference.savefile_identifier == PREFERENCE_CHARACTER)
			values[preference.savefile_key] = preferences.read_preference(preference.type)
	return json_encode(values)

/// Immutable server masks and an owner/slot snapshot; drawing history lives only in the browser.
/datum/hair_paint_editor
	/// Owner preferences; released on teardown.
	var/datum/preferences/preferences
	/// Middleware owning this session; released on teardown.
	var/datum/preference_middleware/hair_paint/middleware
	/// Slot captured when the session opens.
	var/slot
	/// Species type encoded for persistence.
	var/species
	/// Source hairstyle name.
	var/style
	/// Selects the facial-hair mask, style and persistence key.
	var/facial = FALSE
	/// Preference type owned by this session, never supplied by the browser on save.
	var/paint_preference = /datum/preference/hair_paint
	/// Snapshot checked after preview generation and before accepting a save.
	var/character_state
	/// Server-authoritative alpha silhouettes for all four directions.
	var/list/masks
	/// Padded body previews without top hair.
	var/list/backgrounds
	/// Original padded hair previews.
	var/list/frames
	/// Existing compatible saved edits, never modified during drawing.
	var/list/initial_paint
	/// Last validation error returned to the browser.
	var/error_message
	/// Changes on each submit so the browser can retry a rejected save.
	var/response_number = 0
	/// Blocks duplicate successful submissions.
	var/committed = FALSE
	/// Standard colour dialog owned by this editor and deleted with it.
	var/datum/tgui_color_picker/color_picker
	/// Last confirmed brush colour, never written to character preferences.
	var/brush_color
	/// Distinguishes confirmations of the same colour after a local palette change.
	var/brush_color_revision = 0

/datum/hair_paint_editor/New(datum/preferences/preferences, datum/preference_middleware/hair_paint/middleware, facial = FALSE)
	src.preferences = preferences
	src.middleware = middleware
	src.facial = facial
	paint_preference = facial ? /datum/preference/hair_paint/facial : /datum/preference/hair_paint
	slot = preferences.default_slot
	species = "[preferences.read_preference(/datum/preference/choiced/species)]"
	style = preferences.read_preference(facial ? /datum/preference/choiced/facial_hairstyle : /datum/preference/choiced/hairstyle)
	character_state = hair_paint_character_state(preferences)

/datum/hair_paint_editor/Destroy()
	QDEL_NULL(color_picker)
	if(middleware?.editor == src)
		middleware.editor = null
	preferences = null
	middleware = null
	masks = null
	backgrounds = null
	frames = null
	initial_paint = null
	return ..()

/// Generate exact native masks and previews once, then dispose of the temporary mannequin.
/datum/hair_paint_editor/proc/prepare()
	var/mob/living/carbon/human/dummy/mannequin = new
	preferences.apply_prefs_to(mannequin)
	if(QDELETED(src) || !preferences || preferences.default_slot != slot || hair_paint_character_state(preferences) != character_state)
		qdel(mannequin)
		return FALSE
	var/obj/item/bodypart/head/head = mannequin.get_bodypart(BODY_ZONE_HEAD)
	var/target_flag = facial ? HEAD_FACIAL_HAIR : HEAD_HAIR
	if(!head || !(head.head_flags & target_flag) || head.fixed_hair_color || head.override_hair_color)
		qdel(mannequin)
		to_chat(preferences.parent, span_warning("У этого персонажа нет доступных для редактирования волос."))
		return FALSE
	initial_paint = preferences.read_preference(paint_preference)
	if(initial_paint["style"] != style || initial_paint["species"] != species)
		initial_paint = list()
	if(facial)
		head.facial_hair_paint = null
	else
		head.hair_paint = null
	var/original_flags = head.head_flags
	head.head_flags = original_flags & ~(facial ? HEAD_HAIR : HEAD_FACIAL_HAIR)
	var/image/hair = hair_paint_canvas(head.get_hair_overlays())
	head.head_flags = original_flags & ~target_flag
	mannequin.update_hair()
	var/image/body_appearance = image(icon = null)
	body_appearance.appearance = mannequin.appearance
	var/image/body = hair_paint_canvas(list(body_appearance))
	body.plane = body_appearance.plane
	frames = list()
	backgrounds = list()
	masks = list()
	var/has_hair = FALSE
	for(var/direction in hair_paint_directions())
		var/icon/hair_icon = getFlatIcon(hair, defdir = text2num(direction), no_anim = TRUE)
		var/list/rows = hair_paint_icon_rows(hair_icon)
		frames[direction] = rows
		masks[direction] = rows
		for(var/list/row as anything in rows)
			for(var/pixel in row)
				if(copytext(pixel, 8) != "00")
					has_hair = TRUE
		var/icon/background = getFlatIcon(body, defdir = text2num(direction), no_anim = TRUE)
		backgrounds[direction] = hair_paint_icon_rows(background)
	qdel(mannequin)
	if(!has_hair)
		to_chat(preferences.parent, span_warning("Выбранная причёска не содержит доступных пикселей."))
	return has_hair

/datum/hair_paint_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/hair_paint_editor/ui_status(mob/user, datum/ui_state/state)
	if(!preferences || user?.client != preferences.parent || preferences.default_slot != slot)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/hair_paint_editor/ui_interact(mob/user, datum/tgui/ui)
	if(!frames || ui_status(user) != UI_INTERACTIVE)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HairPaint", facial ? "Редактор бороды" : "Редактор волос")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/hair_paint_editor/ui_static_data(mob/user)
	return list(
		"frames" = frames,
		"backgrounds" = backgrounds,
		"paint" = initial_paint["frames"],
		"style" = style,
		"facial" = facial,
		"large_buttons" = preferences.read_preference(/datum/preference/toggle/tgui_input_large),
		"swapped_buttons" = preferences.read_preference(/datum/preference/toggle/tgui_input_swapped),
	)

/datum/hair_paint_editor/ui_data(mob/user)
	return list(
		"error" = error_message,
		"response" = response_number,
		"color_picker_open" = !isnull(color_picker),
		"brush_color" = brush_color,
		"brush_color_revision" = brush_color_revision,
	)

/// Apply only a confirmed colour after revalidating the editor across the dialog wait.
/datum/hair_paint_editor/proc/wait_for_brush_color(mob/user, datum/tgui_color_picker/picker)
	if(QDELETED(src) || QDELETED(picker) || color_picker != picker)
		return
	picker.ui_interact(user)
	if(QDELETED(src) || QDELETED(picker) || color_picker != picker)
		return
	if(committed || ui_status(user) != UI_INTERACTIVE || hair_paint_character_state(preferences) != character_state)
		QDEL_NULL(color_picker)
		SStgui.update_uis(src)
		return
	picker.wait()
	if(QDELETED(src) || color_picker != picker)
		return
	var/new_color = picker.choice
	QDEL_NULL(color_picker)
	if(!committed && ui_status(user) == UI_INTERACTIVE && hair_paint_character_state(preferences) == character_state && new_color)
		brush_color = new_color
		brush_color_revision++
	SStgui.update_uis(src)

/datum/hair_paint_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	if(committed || ui_status(ui.user) != UI_INTERACTIVE)
		return FALSE
	if(action == "pick_color")
		if(color_picker || !istext(params["color"]) || hair_paint_character_state(preferences) != character_state)
			return FALSE
		if(length(params["color"]) != 7 || copytext(params["color"], 1, 2) != "#")
			return FALSE
		var/default_color = sanitize_hexcolor(params["color"], desired_format = 6, include_crunch = TRUE)
		if(default_color != lowertext(params["color"]))
			return FALSE
		color_picker = new(ui.user, null, "Цвет кисти", default_color, 0, TRUE, "ss220")
		INVOKE_ASYNC(src, PROC_REF(wait_for_brush_color), ui.user, color_picker)
		return TRUE
	if(action == "cancel")
		ui.close()
		return TRUE
	if(action != "save")
		return FALSE
	response_number++
	if(hair_paint_character_state(preferences) != character_state)
		to_chat(ui.user, span_warning("Персонаж изменился. Откройте редактор заново из настроек."))
		ui.close()
		return TRUE
	var/list/submitted_frames = hair_paint_unpack_frames(params["frames"], masks)
	if(!submitted_frames || !hair_paint_within_mask(submitted_frames, masks))
		error_message = "Некорректные цвета или попытка изменить пиксели вне волос."
		return TRUE
	var/list/paint = list("style" = style, "species" = species, "frames" = submitted_frames)
	if(!preferences.write_preference(GLOB.preference_entries[paint_preference], paint))
		error_message = "Не удалось сохранить рисунок."
		return TRUE
	committed = TRUE
	preferences.save_character()
	preferences.save_preferences()
	preferences.character_preview_view?.update_body()
	SStgui.update_uis(preferences)
	ui.close()
	return TRUE

/datum/hair_paint_editor/ui_close(mob/user)
	. = ..()
	QDEL_IN(src, 0)
