GLOBAL_LIST_EMPTY(ai_network_bridges)

/** Соединяет две физические подсети парной линией с наведением антенн. */
/obj/machinery/ai/network_bridge
	name = "neural network bridge"
	desc = "Мост нейросети (Neural Network Bridge). Направленный ретранслятор данных для удалённого оборудования ИИ. Проложите оптоволоконный кабель под обоими узлами. Мультитул связывает и калибрует узлы, ключ настраивает направление антенны. Кусачки снимают привязку."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1000
	circuit = /obj/item/circuitboard/machine/ai_network_bridge
	req_one_access = list(ACCESS_RD, ACCESS_TCOMMS)
	/// Физический мост второй стороны настроенной пары.
	var/obj/machinery/ai/network_bridge/partner
	/// Последнее состояние линии для обнаружения изменения топологии.
	var/cached_link = FALSE
	/// Разрешает работу линии без удаления настроенной пары.
	var/link_enabled = TRUE
	/// Угол антенны по часовой стрелке от севера, в градусах.
	var/antenna_heading = 0
	/// Слабая ссылка на сохранённую точку наведения, без слежения за недоступным партнёром.
	var/datum/weakref/target_turf_ref
	/// Последнее подтверждённое название помещения партнёра.
	var/last_remote_area

/obj/machinery/ai/network_bridge/Initialize(mapload)
	. = ..()
	GLOB.ai_network_bridges += src

/obj/machinery/ai/network_bridge/Destroy()
	disconnect()
	GLOB.ai_network_bridges -= src
	return ..()

/** Возвращает известную местную причину неготовности моста либо null. */
/obj/machinery/ai/network_bridge/proc/endpoint_status()
	if(!anchored)
		return "Крепёжные болты ослаблены"
	if(machine_stat & (BROKEN | EMPED))
		return "Оборудование ретранслятора недоступно"
	if(!has_power())
		return "Нет питания"
	if(!link_enabled)
		return "Ретранслятор отключён оператором"
	if(panel_open)
		return "Сервисная панель открыта"
	if(!isturf(loc) || !network_cable())
		return "Под ретранслятором не выбран подходящий оптоволоконный кабель"
	return null

/** Проверяет линию до партнёра, не раскрывая причину отказа недоступного удалённого узла. */
/obj/machinery/ai/network_bridge/proc/link_status()
	var/local_fault = endpoint_status()
	if(local_fault)
		return local_fault
	if(QDELETED(partner) || partner.partner != src)
		return "Не привязан"
	if(!ai_same_debug_environment(src, partner))
		return "Удалённый узел не отвечает; причина неизвестна"
	if(!configured_antenna_aligned())
		return "Местная антенна отклонена от цели"
	var/remote_fault = partner.endpoint_status()
	if(remote_fault || !antenna_aligned() || !partner.antenna_aligned())
		return "Удалённый узел не отвечает; причина неизвестна"
	return null

/** Возвращает направление в градусах на сохранённую точку настройки либо null. */
/obj/machinery/ai/network_bridge/proc/target_bearing()
	var/turf/target = target_turf_ref?.resolve()
	if(!target || !isturf(loc))
		return null
	return get_angle_raw(x, y, 0, 0, target.x, target.y, 0, 0)

/** Проверяет наведение на сохранённую точку, не считывая новое место недоступного партнёра. */
/obj/machinery/ai/network_bridge/proc/configured_antenna_aligned()
	var/bearing = target_bearing()
	return !isnull(bearing) && abs(closer_angle_difference(antenna_heading, bearing)) <= AI_BRIDGE_ALIGNMENT_TOLERANCE

/** Проверяет взаимное направление антенн физически существующей пары. */
/obj/machinery/ai/network_bridge/proc/antenna_aligned()
	if(QDELETED(partner) || !configured_antenna_aligned() || !isturf(loc) || !isturf(partner.loc))
		return FALSE
	var/bearing = get_angle_raw(x, y, 0, 0, partner.x, partner.y, 0, 0)
	return abs(closer_angle_difference(antenna_heading, bearing)) <= AI_BRIDGE_ALIGNMENT_TOLERANCE

/** Задаёт угол антенны в градусах от севера и обновляет топологию. */
/obj/machinery/ai/network_bridge/proc/set_antenna_heading(amount)
	if(!isnum(amount) || amount < 0 || amount > 360)
		return FALSE
	antenna_heading = SIMPLIFY_DEGREES(amount)
	SSai_networks.dirty = TRUE
	return TRUE

/** Проверяет физический доступ человека с мультитулом к настройке антенны. */
/obj/machinery/ai/network_bridge/proc/can_tune_antenna(mob/living/user, obj/item/tool)
	return ishuman(user) && !user.incapacitated && user.Adjacent(src) && tool?.loc == user && allowed(user)

/obj/machinery/ai/network_bridge/wrench_act(mob/living/user, obj/item/tool)
	if(!can_tune_antenna(user, tool))
		balloon_alert(user, "доступ запрещён!")
		return ITEM_INTERACT_BLOCKING
	var/bearing = target_bearing()
	var/heading = tgui_input_number(user, "Задайте направление по часовой стрелке от севера. Направление на целевой узел: [isnull(bearing) ? "нет привязки" : "[round(bearing, 0.1)]°"]. Допустимое отклонение: [AI_BRIDGE_ALIGNMENT_TOLERANCE]°.", "Антенна ретранслятора", antenna_heading, 360, 0, round_value = FALSE)
	if(isnull(heading))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || !can_tune_antenna(user, tool) || !set_antenna_heading(heading))
		return ITEM_INTERACT_BLOCKING
	SSai_networks.rebuild()
	balloon_alert(user, antenna_aligned() ? "антенна направлена на цель" : "антенна настроена")
	return ITEM_INTERACT_SUCCESS

/** Проверяет линию и обновляет последнее известное место партнёра только при рабочей связи. */
/obj/machinery/ai/network_bridge/proc/link_available()
	. = !link_status()
	if(.)
		last_remote_area = ai_localized_area(partner)

/** Возвращает подтверждённое либо последнее известное место партнёра с признаком потери связи. */
/obj/machinery/ai/network_bridge/proc/remote_area()
	if(QDELETED(partner))
		return "Не привязан"
	if(link_available())
		return last_remote_area
	return last_remote_area ? "[last_remote_area] (последнее известное место; нет связи)" : "Местоположение неизвестно"

/** Связывает два физических моста одной среды, сохраняя точки для наведения антенн. */
/obj/machinery/ai/network_bridge/proc/connect_to(obj/machinery/ai/network_bridge/target)
	if(QDELETED(target) || target == src || partner || target.partner || !isturf(loc) || !isturf(target.loc) || !ai_same_debug_environment(src, target))
		return FALSE
	partner = target
	target.partner = src
	target_turf_ref = WEAKREF(get_turf(target))
	target.target_turf_ref = WEAKREF(get_turf(src))
	last_remote_area = ai_localized_area(target)
	target.last_remote_area = ai_localized_area(src)
	set_antenna_heading(target_bearing())
	target.set_antenna_heading(target.target_bearing())
	SSai_networks.dirty = TRUE
	return TRUE

/** Разрывает пару с обеих сторон и удаляет сохранённые сведения о партнёрах. */
/obj/machinery/ai/network_bridge/proc/disconnect()
	if(!QDELETED(partner) && partner.partner == src)
		partner.target_turf_ref = null
		partner.last_remote_area = null
		partner.partner = null
	partner = null
	target_turf_ref = null
	last_remote_area = null
	SSai_networks.dirty = TRUE

/obj/machinery/ai/network_bridge/multitool_act(mob/living/user, obj/item/tool)
	if(!allowed(user) || !istype(tool, /obj/item/multitool))
		balloon_alert(user, "доступ запрещён!")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/multitool/multitool = tool
	if(!istype(multitool.buffer, /obj/machinery/ai/network_bridge))
		multitool.set_buffer(src)
		balloon_alert(user, "узел сохранён")
		return ITEM_INTERACT_SUCCESS
	var/obj/machinery/ai/network_bridge/target = multitool.buffer
	if(!target.allowed(user) || !connect_to(target))
		balloon_alert(user, "невозможно связать узлы!")
		return ITEM_INTERACT_BLOCKING
	multitool.set_buffer(null)
	to_chat(user, span_notice("Ретранслятор связан с [partner.declent_ru(INSTRUMENTAL)] в [ai_localized_area(partner, PREPOSITIONAL)]. [link_status() || "Связь установлена"]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/network_bridge/wirecutter_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 1 SECONDS))
		return ITEM_INTERACT_BLOCKING
	disconnect()
	balloon_alert(user, "ретранслятор отвязан")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/network_bridge/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai/network_bridge/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai/network_bridge/examine(mob/user)
	. = ..()
	. += span_notice("[link_status() || "Связь установлена"].")
	if(!QDELETED(partner))
		. += span_notice("Связанный узел: [remote_area()].")

	. += span_notice("Направление антенны: [round(antenna_heading, 0.1)]° по часовой стрелке от севера. Настройте ключом на месте.")
	var/bearing = target_bearing()
	if(!isnull(bearing))
		. += span_notice("Направление на целевой узел: [round(bearing, 0.1)]°; допуск: [AI_BRIDGE_ALIGNMENT_TOLERANCE]°.")
