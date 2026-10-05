/mob/living/silicon/proc/compose_open_door_href(atom/movable/speaker)
	var/mob/living/target = speaker.GetSource()

	if(!target || !isliving(target))
		return ""

	var/mob/living/silicon/ai/controller
	if(isAI(src))
		controller = src
	else if(iscyborg(src))
		var/mob/living/silicon/robot/bot = src
		if(bot.shell && bot.connected_ai)
			controller = bot.connected_ai

	return controller ? " <a href='byond://?src=[REF(controller)];open=[REF(target)]'>\[OPEN\]</a>" : ""

//Открытие шлюза рядом с целью для ИИ

/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target)
	if(!target)
		return

	var/mob/living/user = usr
	if(!user || !user.client)
		user = src

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/can_see_target = FALSE

	// ИИ в карте
	if(istype(loc, /obj/item/aicard))

		if(control_disabled)
			to_chat(user, span_warning("Беспроводная связь отключена."))
			return

		if(can_see(target))
			can_see_target = TRUE

	// ИИ в оболочке
	else if(deployed_shell && user == deployed_shell)

		if(!is_valid_z_level(get_turf(deployed_shell), target_turf))
			to_chat(user, span_warning("Ошибка: цель слишком далеко от вас."))
			return

		if(get_dist(deployed_shell, target) <= 7)
			can_see_target = TRUE

		else if(SScameras.is_visible_by_cameras(target_turf))
			// Имитируем все проверки зрения ИИ... да да...
			for(var/obj/machinery/camera/C in range(7, target))
				if(QDELETED(C)) continue
				if(!C.camera_enabled) continue
				if(C.machine_stat & BROKEN) continue
				if(C.emped) continue
				if(C.wires && (C.wires.is_cut(WIRE_CAMERA) || C.wires.is_cut(WIRE_POWER)))
					continue

				can_see_target = TRUE
				break

	// AI in core
	else
		if(!is_valid_z_level(get_turf(src), target_turf))
			to_chat(user, span_warning("Ошибка: цель слишком далеко от вас."))
			return

		if(can_see(target))
			can_see_target = TRUE

	if(!can_see_target)
		to_chat(user, span_warning("Цель вне зоны видимости."))
		return

	var/obj/machinery/door/airlock/A = null
	var/dist = -1

	for(var/obj/machinery/door/airlock/D in range(3, target))
		if(!D.density)
			continue

		var/curr_dist = get_dist(D, target)
		if(dist < 0 || curr_dist < dist)
			dist = curr_dist
			A = D

	if(A)

		if(A.hackProof)
			to_chat(user, span_warning("Ошибка: фаерволл [A] блокирует ваше управление."))
			return

		if(!A.hasPower())
			to_chat(user, span_warning("Ошибка: шлюз [A] отключен."))
			return

		if(A.locked)
			to_chat(user, span_warning("Ошибка: [A] болты подняты."))
			return

		if(A.welded)
			to_chat(user, span_warning("Ошибка: шлюз [A] не поддается."))
			return

		if(A.wires && A.wires.is_cut(WIRE_AI))
			to_chat(user, span_warning("Ошибка подключения: шлюз [A] не отвечает."))
			return

		var/confirm = tgui_alert(user, "Вы хотите открыть [A] для [target]?", "Открыть шлюз", list("Да", "Нет"))

		if(confirm == "Да")
			if(QDELETED(A) || !A.density || A.hackProof || !A.hasPower() || A.locked || (A.wires && A.wires.is_cut(WIRE_AI)))
				to_chat(user, span_warning("Действие сброшено: статус сменился"))
				return

			if(get_dist(A, target) > 5)
				to_chat(user, span_warning("Действие сброшено: цель переместилась."))
				return

			A.open()
			to_chat(user, span_notice("Вы открываете [A] для [target]."))
			log_silicon("opened [A] for [key_name(target)] via chat link at [AREACOORD(A)]")
	else
		to_chat(user, span_warning("Не удалось найти подходящий шлюз поблизости [target]."))
