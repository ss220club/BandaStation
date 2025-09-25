/obj/item/device/holowarrant
	name = "warrant projector"
	desc = "The practical paperwork replacement for the officer on the go."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "remote"
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

/obj/item/device/holowarrant/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	var/obj/item/card/id/id = tool.GetID()
	if(!id)
		return ..()
	if(!active)
		to_chat(user, span_warning("\\The [src] has no warrant to authorize."))
		return TRUE
	if(!check_access(id))
		to_chat(user, span_warning("Access denied."))
		return TRUE
	var/choice = tgui_alert(user, "Would you like to authorize this warrant?", "\\The [src] - Authorization", list("Yes", "No"))
	if(choice != "Yes" || !user.can_perform_action(src))
		return TRUE
	active.auth = "[id.registered_name] - [id.assignment ? id.assignment : "(Unknown)"]"
	user.visible_message(
		span_notice("[user] scans [tool] with [src]."),
		span_notice("You authorize [src]'s warrant with [id.registered_name].")
	)
	return TRUE

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

/obj/item/device/holowarrant/proc/warrant_html_header(section_title, station_enc)
	return "<HTML><HEAD><TITLE>[section_title]</TITLE></HEAD>\n<BODY bgcolor='#ffffff'>\n<table width='100%' cellspacing='0' cellpadding='0'><tr><td align='left' valign='top' style='width:64px;'>\n<img src='ntlogo.png' alt='NanoTrasen' width='64' height='64'>\n</td><td align='center' valign='middle'>\n<large><b>Система отслеживания ордеров SCG SFP</b></large></br>\n</td></tr></table>\n</br>\nВыдан в юрисдикции станции</br>\n[station_enc]</br>\n</br>\n"

/obj/item/device/holowarrant/proc/warrant_html_footer()
	return "</BODY></HTML>"

/obj/item/device/holowarrant/proc/build_warrant_html(datum/digital_warrant/W)
	if(!W)
		return list("html" = null, "title" = null)
	var/name_enc = html_encode(W.namewarrant)
	var/charges_enc = html_encode(W.charges)
	var/auth_enc = html_encode(W.auth)
	var/station_enc = html_encode(station_name())
	var/title
	var/list/body_lines = list()

	if(W.arrestsearch == "arrest")

		title = "Ордер на арест: [name_enc]"
		body_lines += warrant_html_header(name_enc, station_enc)
		body_lines += list(
			"<b>ОРДЕР НА АРЕСТ</b></center></br>",
			"<hr>",
			"Настоящий документ является разрешением и уведомлением на арест _<u>[name_enc]</u>____ по следующ(ему/им) нарушени(ю/ям):</br>[charges_enc]</br>",
			"</br>",
			"Станция / объект: _<u>[station_enc]</u>____</br>",
			"</br>_<u>[auth_enc]</u>____</br>",
			"<small>Лицо, санкционировавшее арест</small></br>",
			"</br>",
			"<center><small><i>Офицер(ы) службы безопасности уполномочены задержать указанное лицо и доставить его в изолятор для дальнейшего разбирательства. Допускается применение соразмерной силы.</br>",
			"</br>",
			"Задержанное лицо должно быть проинформировано о причине ареста и своих базовых правах: праве на медицинскую помощь, одном обращении по связи и возможности обжалования через командование или магистратуру.</br>",
			"</br>",
			"Все предметы, потенциально связанные с нарушением, подлежат изъятию, документированию и передаче в помещение хранения улик.</br>",
			"</br>",
			"При попытке побега, активном сопротивлении или угрозе окружающим допускается временное усиление мер удержания до стабилизации ситуации.</i></small></center></br>"
		)
		body_lines += warrant_html_footer()
	else if(W.arrestsearch == "search")
		title = "Ордер на обыск: [name_enc]"
		body_lines += warrant_html_header("Ордер на обыск: [name_enc]", station_enc)
		body_lines += list(
			"<b>ОРДЕР НА ОБЫСК</b></center></br>",
			"</br>",
			"<b>Имя подозреваемого / место: </b>[name_enc]</br>",
			"</br>",
			"<b>Основания: </b> [charges_enc]</br>",
			"</br>",
			"<b>Ордер выдал: </b> [auth_enc]</br>",
			"</br>",
			"Станция / объект: _<u>[station_enc]</u>____</br>",
			"</br>",
			"<center><small><i>Офицер(ы) службы безопасности, предъявляющие данный ордер, уполномочены произвести однократный законный обыск личности подозреваемого, его вещей, помещений и/или отдела в целях изъятия любых предметов и материалов, которые могут быть связаны с предполагаемым преступлением, указанным ниже, в рамках текущего расследования.</br>",
			"</br>",
			"Офицер(ы) обязаны изъять все такие предметы у подозреваемого и/или из отдела и оформить их как вещественные доказательства.</br>",
			"</br>",
			"От подозреваемого / персонала отдела ожидается полное содействие.</br>",
			"</br>",
			"В случае сопротивления, попыток воспрепятствовать обыску или побега — допускается временное усиление мер удержания до стабилизации ситуации.</br>",
			"</br>",
			"Все изъятые предметы должны быть помещены в помещение хранения улик!</small></i></center></br>"
		)
		body_lines += warrant_html_footer()
	else
		return list("html" = null, "title" = null)

	var/html = jointext(body_lines, "\n")
	return list("html" = html, "title" = title)

/obj/item/device/holowarrant/proc/show_content(mob/user)
	if(!active)
		return
	var/list/render = build_warrant_html(active)
	if(!render || !render["html"])
		return
	user << browse(HTML_SKELETON(render["html"]), "window=[render["title"]]")
