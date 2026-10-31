// BANDASTATION ADD START - Перенос ИИ: русские сообщения intelliCard.
/** Переносной носитель исходного ИИ с собственными каналами связи и циклом очистки. */
/obj/item/aicard
	name = "intelliCard"
	desc = "Накопитель для ИИ. Патент ожидает подтверждения."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard"
	base_icon_state = "aicard"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	custom_materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 2)
	var/flush = FALSE
	/// Номер цикла очистки; смена поколения прекращает старую асинхронную операцию.
	var/wipe_generation = 0
	var/mob/living/silicon/ai/AI
// BANDASTATION ADD END - Перенос ИИ

/obj/item/aicard/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI))
		return INITIALIZE_HINT_QDEL
	ADD_TRAIT(src, TRAIT_CASTABLE_LOC, INNATE_TRAIT)

/obj/item/aicard/Destroy(force)
	if(AI)
		AI.ghostize(can_reenter_corpse = FALSE)
		QDEL_NULL(AI)
	return ..()

// BANDASTATION ADD START - Перенос ИИ: русские сообщения intelliCard.
/** Особый внешний вариант intelliCard со штатной логикой переноса ИИ. */
/obj/item/aicard/aitater
	name = "intelliTater"
	desc = "Стильное улучшение (?) intelliCard."
	icon_state = "aitater"
	base_icon_state = "aitater"
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5.5, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 2, /datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5)

/** Особый внешний вариант intelliCard со штатной логикой переноса ИИ. */
/obj/item/aicard/aispook
	name = "intelliLantern"
	desc = "Жу-у-уткое улучшение intelliCard."
	icon_state = "aispook"
	base_icon_state = "aispook"
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5.5, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 2, /datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5)

/** Выполняет штатное самоубийство с картой, прекращая несовместимую очистку носителя. */
/obj/item/aicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] пытается загрузить себя в [declent_ru(ACCUSATIVE)]! Это плохо закончится!"))
	return BRUTELOSS
// BANDASTATION ADD END - Перенос ИИ

/obj/item/aicard/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(AI)
		if(upload_ai(interacting_with, user))
			return ITEM_INTERACT_SUCCESS
	else
		if(capture_ai(interacting_with, user))
			return ITEM_INTERACT_SUCCESS
	return NONE

/// Tries to get an AI from the atom clicked
/obj/item/aicard/proc/capture_ai(atom/from_what, mob/living/user)
	from_what.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	if(isnull(AI))
		return FALSE
	log_silicon("[key_name(user)] carded [key_name(AI)]", list(src))
	update_appearance()
	AI.cancel_camera()
	RegisterSignal(AI, COMSIG_MOB_STATCHANGE, PROC_REF(on_ai_stat_change))
	RegisterSignal(AI, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_ai_icon_update))
	return TRUE

/// Tries to upload the AI we have captured to the atom clicked
/obj/item/aicard/proc/upload_ai(atom/to_what, mob/living/user)
	var/mob/living/silicon/ai/old_ai = AI
	to_what.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
	if(!isnull(AI))
		return FALSE
	log_combat(user, old_ai, "uploaded", src, "to [to_what].")
	update_appearance()
	old_ai.cancel_camera()
	UnregisterSignal(old_ai, COMSIG_MOB_STATCHANGE)
	UnregisterSignal(old_ai, COMSIG_ATOM_UPDATE_ICON)
	return TRUE

/obj/item/aicard/proc/on_ai_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD || old_stat == DEAD)
		update_appearance()

/obj/item/aicard/proc/on_ai_icon_update(datum/source)
	SIGNAL_HANDLER
	update_appearance()

/obj/item/aicard/update_appearance(updates)
	. = ..()

	if(!AI)
		set_light(0)
		return

	set_light(0.5, 0.5, LIGHT_COLOR_FAINT_CYAN)

/obj/item/aicard/update_name(updates)
	. = ..()
	if(AI)
		name = "[initial(name)] - [AI.name]"
	else
		name = initial(name)

/obj/item/aicard/update_icon_state()
	icon_state = base_icon_state
	return ..()

//Support for different displays
/obj/item/aicard/update_overlays()
	. = ..()
	if(!AI)
		return

	var/card_display = AI.display_icon_override || "ai"

	if(AI.stat == DEAD)
		card_display = "[card_display]_dead"

	if(!(card_display in icon_states(icon)))
		if(AI.stat == DEAD)
			card_display = "ai_dead"
		else
			card_display = "ai"

	. += mutable_appearance(icon, card_display)
	. += emissive_appearance(icon, card_display, src, alpha = src.alpha)

	if(AI.control_disabled)
		var/indicator_state = "[base_icon_state]-off"
		. += mutable_appearance(icon, indicator_state)
		. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)

	if(!AI.control_disabled)
		var/indicator_state = "[base_icon_state]-on"
		. += mutable_appearance(icon, indicator_state)
		. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)

// BANDASTATION ADD START - Перенос ИИ: тип состояния интерфейса карты.
/** Разрешает взаимодействие с картой по штатным правилам предмета в руках. */
/obj/item/aicard/ui_state(mob/user)
	RETURN_TYPE(/datum/ui_state)
	return GLOB.hands_state
// BANDASTATION ADD END - Перенос ИИ

/obj/item/aicard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Intellicard", name)
		ui.open()

// BANDASTATION ADD START - Перенос ИИ: документация изменённого API.
/** Передаёт состояние текущего ИИ на карте, каналы связи и доступный пользователю набор законов. */
// BANDASTATION ADD END - Перенос ИИ
/obj/item/aicard/ui_data()
	var/list/data = list()
	// BANDASTATION ADD START - Перенос ИИ: явное состояние пустого носителя.
	data["AI_present"] = !QDELETED(AI)
	// BANDASTATION ADD END - Перенос ИИ
	if(AI)
		data["name"] = AI.name
		data["laws"] = AI.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)
		data["health"] = (AI.health + 100) / 2
		data["wireless"] = !AI.control_disabled
		data["radio"] = AI.radio_enabled
		data["isDead"] = AI.stat == DEAD
		data["isBraindead"] = AI.client ? FALSE : TRUE
	data["wiping"] = flush
	return data

// BANDASTATION ADD START - Перенос ИИ: русские сообщения intelliCard.
/** Проверяет пользователя и содержимое карты перед переключением связи или подтверждённой очисткой. */
/obj/item/aicard/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/target = AI
	if(QDELETED(target) || target.loc != src)
		return FALSE
	switch(action)
		if("wipe")
			if(flush)
				flush = FALSE
				wipe_generation++
			else
				if(target.stat == DEAD)
					return FALSE
				var/mob/user = ui.user
				var/confirm = tgui_alert(user, "Очистка повредит нейроструктуру и приведёт к гибели [target.name]. Остановка не восстановит нанесённый ущерб. Начать?", name, list("Да", "Нет"))
				if(confirm != "Да" || QDELETED(ui) || ui.user != user || !can_start_wipe(user, target) || ui.status != UI_INTERACTIVE || ui_status(user, ui.state) != UI_INTERACTIVE)
					return FALSE
				flush = TRUE
				wipe_generation++
				wipe_ai()
			. = TRUE
		if("wireless")
			AI.set_control_disabled(!AI.control_disabled)
			to_chat(AI, span_warning("Беспроводное управление [AI.control_disabled ? "отключено" : "включено"]!"))
			. = TRUE
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			to_chat(AI, span_warning("Ваш подпространственный приёмопередатчик [AI.radio_enabled ? "включён" : "отключён"]!"))
			. = TRUE
	update_appearance()

/** Повторно проверяет пользователя, карту и исходного ИИ после подтверждения очистки. */
/obj/item/aicard/proc/can_start_wipe(mob/user, mob/living/silicon/ai/target)
	if(QDELETED(src) || QDELETED(user) || QDELETED(target) || AI != target || target.loc != src || target.stat == DEAD || flush)
		return FALSE
	return ui_state(user).can_use_topic(src, user) == UI_INTERACTIVE

/** Повреждает исходного ИИ только пока действует тот же цикл очистки и содержимое карты не изменилось. */
/obj/item/aicard/proc/wipe_ai()
	set waitfor = FALSE
	var/mob/living/silicon/ai/target = AI
	var/started_generation = wipe_generation
	if(!QDELETED(target) && target.loc == src)
		to_chat(target, span_userdanger("ВАШИ СИСТЕМНЫЕ ФАЙЛЫ УДАЛЯЮТСЯ!"))
		while(!QDELETED(src) && !QDELETED(target) && AI == target && target.loc == src && target.stat != DEAD && flush && wipe_generation == started_generation)
			target.adjust_oxy_loss(5)
			target.updatehealth()
			sleep(0.5 SECONDS)
	if(!QDELETED(src) && wipe_generation == started_generation)
		flush = FALSE
// BANDASTATION ADD END - Перенос ИИ

/obj/item/aicard/used_in_craft(atom/result, datum/crafting_recipe/current_recipe)
	. = ..()
	if(!AI || !istype(result, /obj/item/aicard))
		return
	var/obj/item/aicard/new_card = result
	AI.forceMove(new_card)
	new_card.AI = AI
	new_card.update_appearance()
	AI = null

// Special Cards

/obj/item/aicard/aitater/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/item/aicard/aitater/update_overlays()
	..()
	. = list()

	if(!AI)
		return

	var/face_state = "[base_icon_state][AI.stat == DEAD ? "-404" : "-full"]"
	. += mutable_appearance(icon, face_state)
	. += emissive_appearance(icon, face_state, src, alpha = src.alpha)

	var/indicator_state = "[base_icon_state][AI.control_disabled ? "-off" : "-on"]"
	. += mutable_appearance(icon, indicator_state)
	. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)


/obj/item/aicard/aispook/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/item/aicard/aispook/update_overlays()
	..()
	. = list()

	if(!AI)
		return

	var/face_state = "[base_icon_state][AI.stat == DEAD ? "-404" : "-full"]"
	. += mutable_appearance(icon, face_state)
	. += emissive_appearance(icon, face_state, src, alpha = src.alpha)

	var/indicator_state = "[base_icon_state][AI.control_disabled ? "-off" : "-on"]"
	. += mutable_appearance(icon, indicator_state)
	. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)
