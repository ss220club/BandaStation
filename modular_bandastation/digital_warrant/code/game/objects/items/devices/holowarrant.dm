/obj/item/device/holowarrant
	name = "warrant projector"
	desc = "The practical paperwork replacement for the officer on the go."
	icon = 'modular_bandastation/digital_warrant/icons/holowarrant.dmi'
	icon_state = "holowarrant"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	req_one_access = list(ACCESS_COMMAND, ACCESS_SECURITY)
	var/datum/digital_warrant/active

/obj/item/device/holowarrant/examine(mob/user)
	. = ..()
	if(active)
		. += "It's a holographic warrant for '[active.namewarrant]'."
	if(in_range(src, user))
		show_content(user)
	else
		. += span_notice("You have to be closer if you want to read it.")

/obj/item/device/holowarrant/GetAccess()
	. = list()
	if(!active || active.archived)
		return
	. |= active.access

/obj/item/device/holowarrant/attack_self(mob/living/user)
	active = null
	var/list/warrants = list()
	for(var/datum/digital_warrant/W in GLOB.all_warrants)
		if(!W.archived)
			warrants["[W.namewarrant] ([capitalize(W.arrestsearch)])"] = W
	if(!length(warrants))
		to_chat(user, span_notice("There are no warrants available"))
		update_appearance()
		return
	var/datum/digital_warrant/temp = input(user, "Which warrant would you like to load?") as null|anything in warrants
	if(!temp)
		update_appearance()
		return
	// Post-input context checks to mitigate input stalling exploits (see STANDARDS.md)
	if(QDELETED(src) || !user || !user.can_perform_action(src) || !in_range(src, user))
		update_appearance()
		return
	active = warrants[temp]
	update_appearance()

/obj/item/device/holowarrant/update_appearance()
	if(active && !active.archived)
		icon_state = "holowarrant_filled"
	else
		icon_state = "holowarrant"
	. = ..()

/obj/item/device/holowarrant/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		user.visible_message(
			span_notice("[user] holds up a warrant projector and shows the contents to [M]."),
			span_notice("You show the warrant to [M].")
		)
		M.examinate(src)
		return TRUE
	return ..()

/obj/item/device/holowarrant/proc/get_warrant_view(datum/digital_warrant/W)
	if(!W || W.archived)
		return null
	var/station = station_name()
	var/list/view = list(
		"title" = null,
		"subtitle" = "Выдан в юрисдикции станции [station]",
		"subject_label" = null,
		"subject" = W.namewarrant,
		"intro" = null,
		"fields" = list(),
		"notes" = list(),
		"type" = W.arrestsearch,
		"logo" = "ntlogo.png",
	)
	var/charges_text = W.charges ? trimtext(W.charges) : ""
	if(!length(charges_text))
		charges_text = "Не указано"
	var/auth_text = W.auth ? trimtext(W.auth) : ""
	if(!length(auth_text))
		auth_text = "Не указано"
	switch(W.arrestsearch)
		if("arrest")
			view["title"] = "Ордер на арест"
			view["subject_label"] = "Объект задержания"
			view["intro"] = "Настоящий документ разрешает задержание [W.namewarrant] за следующие нарушения:"
			view["fields"] += list(
				list("label" = "Нарушения", "value" = charges_text),
				list("label" = "Станция / объект", "value" = station),
				list("label" = "Санкционировал", "value" = auth_text, "hint" = "Лицо, санкционировавшее арест"),
			)
			view["notes"] = list(
				"Офицер(ы) службы безопасности уполномочены задержать указанное лицо и доставить его в изолятор для дальнейшего разбирательства. Допускается применение соразмерной силы.",
				"Задержанное лицо должно быть проинформировано о причине ареста и своих базовых правах: праве на медицинскую помощь, одном обращении по связи и возможности обжалования через командование или магистрата.",
				"Все предметы, потенциально связанные с нарушением, подлежат изъятию, документированию и передаче в помещение хранения улик.",
				"При попытке побега, активном сопротивлении или угрозе окружающим допускается временное усиление мер удержания до стабилизации ситуации.",
			)
		if("search")
			view["title"] = "Ордер на обыск"
			view["subject_label"] = "Подозреваемый / место"
			view["intro"] = "Настоящий документ разрешает проведение однократного законного обыска указанного лица, его имущества и/или помещения в рамках текущего расследования."
			view["fields"] += list(
				list("label" = "Основания", "value" = charges_text),
				list("label" = "Ордер выдал", "value" = auth_text),
				list("label" = "Станция / объект", "value" = station),
			)
			view["notes"] = list(
				"Офицер(ы) службы безопасности уполномочены изъять все предметы, связанные с предполагаемым нарушением, и оформить их как вещественные доказательства.",
				"От подозреваемого и причастного персонала ожидается полное содействие. В случае сопротивления допускается временное усиление мер удержания до стабилизации ситуации.",
				"Все изъятые предметы должны быть помещены в помещение хранения улик.",
			)
		else
			return null
	return view

/obj/item/device/holowarrant/proc/show_content(mob/user)
	if(!active || !user?.client)
		return
	ui_interact(user)

/obj/item/device/holowarrant/ui_interact(mob/user, datum/tgui/ui)
	if(!active)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/window_title = length(active.namewarrant) ? "[src] - [active.namewarrant]" : name
		ui = new(user, src, "HoloWarrant", window_title)
		ui.open()

/obj/item/device/holowarrant/ui_data(mob/user)
	var/list/data = list()
	data["warrant"] = get_warrant_view(active)
	return data

/obj/item/device/holowarrant/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/paper_logos),
	)
