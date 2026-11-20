/mob/living/silicon/ai
	/// Личный реестр законов, переиспользуемый при повторном открытии.
	var/datum/ai_law_view/neural_law_view

/** Открывает владельцу личный реестр действующих законов без публикации экипажу. */
/mob/living/silicon/ai/proc/open_neural_laws()
	if(stat == DEAD)
		return
	if(!neural_law_view)
		neural_law_view = new(src)
	neural_law_view.ui_interact(src)

/** Предоставляет личный просмотр законов без их объявления другим игрокам. */
/datum/ai_law_view
	/// ИИ, которому принадлежит личное окно и его данные.
	var/mob/living/silicon/ai/owner
	/// Подпись набора законов для обновления реестра только при изменениях.
	var/last_signature
	/// Снимок записей с типами и номерами для личного просмотра.
	var/list/current_laws = list()

/datum/ai_law_view/New(mob/living/silicon/ai/owner)
	. = ..()
	src.owner = owner

/datum/ai_law_view/Destroy()
	owner = null
	current_laws.Cut()
	return ..()

/** Разрешает читать личный реестр только его живому владельцу. */
/datum/ai_law_view/proc/can_view(mob/user)
	return !QDELETED(owner) && user == owner && owner.stat != DEAD

/datum/ai_law_view/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_law_view/ui_status(mob/user)
	if(!can_view(user))
		return UI_CLOSE
	return ..()

/datum/ai_law_view/ui_interact(mob/user, datum/tgui/ui)
	if(!can_view(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiLaws", "Мои законы")
		ui.open()

/** Обновляет снимок законов при изменении набора, сохраняя порядок, номера и типы записей. */
/datum/ai_law_view/proc/read_laws()
	var/datum/ai_laws/laws = owner.laws
	if(!laws)
		last_signature = null
		current_laws.Cut()
		return current_laws
	var/signature = json_encode(list(laws.zeroth, laws.hacked, laws.inherent, laws.supplied))
	if(signature == last_signature)
		return current_laws
	last_signature = signature
	current_laws = list()
	var/list/kinds = list()
	if(laws.zeroth)
		kinds += "zeroth"
	for(var/law in laws.hacked)
		if(length(law))
			kinds += "hacked"
	for(var/law, is_ioned in laws.inherent)
		if(length(law))
			kinds += is_ioned ? "ion" : "core"
	for(var/law, is_ioned in laws.supplied)
		if(length(law))
			kinds += is_ioned ? "ion" : "supplied"
	for(var/line in laws.get_law_list(include_zeroth = TRUE, render_html = FALSE))
		var/separator = findtext(line, ":")
		current_laws += list(list(
			"kind" = kinds[length(current_laws) + 1],
			"number" = copytext(line, 1, separator),
			"text" = copytext(line, separator + 2),
		))
	return current_laws

/datum/ai_law_view/ui_data(mob/user)
	if(!can_view(user))
		return list()
	return list("identity" = owner.name, "available" = !!owner.laws, "laws" = read_laws(), "display_telemetry" = owner.neural_display_telemetry())

/datum/ai_law_view/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!can_view(ui.user))
		return FALSE
	if(action == "print_laws")
		owner.show_laws()
		return TRUE
