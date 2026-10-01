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
			to_chat(user, span_warning("Ошибка: Фаерволл [A] блокирует ваше управление."))
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
				to_chat(user, span_warning("Действие сброшено: Цель переместилась."))
				return

			A.open()
			to_chat(user, span_notice("Вы открываете [A] для [target]."))
			log_silicon("opened [A] for [key_name(target)] via chat link at [AREACOORD(A)]")
	else
		to_chat(user, span_warning("Не удалось найти подходящий шлюз поблизости [target]."))



/mob/living/silicon/ai/proc/fulfill_door_request(mob/living/requester, obj/machinery/door/airlock/door, action)
	if(!istype(requester) || !istype(door))
		return

	var/mob/living/user = usr
	if(!user || !user.client)
		user = src

	if(istype(loc, /obj/item/aicard))
		to_chat(user, span_warning("Ошибка: ИИ находится в интеллкарте. Управление шлюзами недоступно."))
		return

	if(QDELETED(door))
		to_chat(user, span_warning("Соединение потеряно! Шлюз не отвечает."))
		return

	var/turf/requester_turf = get_turf(requester)
	var/turf/door_turf = get_turf(door)
	if(!requester_turf || !door_turf)
		return

	var/can_see_requester = FALSE
	var/can_see_door = FALSE

	// AI в оболочке (клик из оболочки)
	if(deployed_shell && user == deployed_shell)
		if(!is_valid_z_level(get_turf(deployed_shell), requester_turf) || !is_valid_z_level(get_turf(deployed_shell), door_turf))
			to_chat(user, span_warning("Ошибка: цель слишком далеко от вас."))
			return

		if(get_dist(deployed_shell, requester) <= 7)
			can_see_requester = TRUE
		else if(SScameras.is_visible_by_cameras(requester_turf))
			for(var/obj/machinery/camera/camera in range(7, requester))
				if(QDELETED(camera)) continue
				if(!camera.camera_enabled) continue
				if(camera.machine_stat & BROKEN) continue
				if(camera.emped) continue
				if(camera.wires && (camera.wires.is_cut(WIRE_CAMERA) || camera.wires.is_cut(WIRE_POWER)))
					continue
				can_see_requester = TRUE
				break

		if(get_dist(deployed_shell, door) <= 7)
			can_see_door = TRUE
		else if(SScameras.is_visible_by_cameras(door_turf))
			for(var/obj/machinery/camera/camera in range(7, door))
				if(QDELETED(camera)) continue
				if(!camera.camera_enabled) continue
				if(camera.machine_stat & BROKEN) continue
				if(camera.emped) continue
				if(camera.wires && (camera.wires.is_cut(WIRE_CAMERA) || camera.wires.is_cut(WIRE_POWER)))
					continue
				can_see_door = TRUE
				break

	else
		if(!is_valid_z_level(get_turf(src), requester_turf) || !is_valid_z_level(get_turf(src), door_turf))
			to_chat(user, span_warning("Ошибка: цель слишком далеко от вас."))
			return

		if(can_see(requester))
			can_see_requester = TRUE
		if(can_see(door))
			can_see_door = TRUE

	if(!can_see_requester)
		to_chat(user, span_warning("Цель вне зоны видимости."))
		return
	if(!can_see_door)
		to_chat(user, span_warning("Шлюз вне зоны видимости."))
		return

	// Проверки шлюза
	if(door.hackProof)
		to_chat(user, span_warning("Ошибка: Фаерволл [door] блокирует ваше управление."))
		return
	if(!door.hasPower())
		to_chat(user, span_warning("Ошибка: шлюз [door] отключен."))
		return
	if(!door.canAIControl())
		to_chat(user, span_notice("Ошибка: вы не чувствуете шлюз."))
		return
	if(door.obj_flags & EMAGGED)
		to_chat(user, span_warning("Ошибка: шлюз не отвечает."))
		return
	if(door.wires && door.wires.is_cut(WIRE_AI))
		to_chat(user, span_warning("Ошибка подключения: шлюз [door] не отвечает."))
		return

	if(!COOLDOWN_FINISHED(door, answer_cd))
		to_chat(user, span_warning("Вы уже ответили на запрос."))
		return

	COOLDOWN_START(door, answer_cd, 10 SECONDS)

	switch(action)
		if("open")
			if(door.welded)
				to_chat(user, span_warning("Ошибка: шлюз [door] не поддается."))
				return
			if(door.locked)
				door.unbolt()
			door.open()
			to_chat(user, span_notice("Вы открываете [door] для [requester]."))
			door.visible_message(span_notice("Шлюз пищит: [src] одобряет доступ."), vision_distance = COMBAT_MESSAGE_RANGE)
			door.requesters -= "[requester.ckey]_[REF(door)]"

		if("bolt")
			if(door.locked)
				door.unbolt()
				door.visible_message(span_notice("Шлюз щёлкает: [src] поднимает болты."), vision_distance = COMBAT_MESSAGE_RANGE)
			else
				door.bolt()
				door.visible_message(span_danger("Шлюз щёлкает: [src] опускает болты."), vision_distance = COMBAT_MESSAGE_RANGE)

		if("deny")
			playsound(door, 'sound/machines/buzz/buzz-sigh.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
			door.visible_message(span_danger("Шлюз жужжит: [src] отклоняет запрос."), vision_distance = COMBAT_MESSAGE_RANGE)
			to_chat(user, span_notice("Вы отклоняете запрос [requester]."))
