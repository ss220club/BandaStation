#define AI_LAW_INTRUSION_INSTALL (5.5 SECONDS)
#define AI_LAW_INTRUSION_DURATION (4 MINUTES)
#define AI_LAW_INTRUSION_DISCONNECT (10 SECONDS)

/mob/living/silicon/ai
	/// Активная попытка загрузки взломанного закона, связанная с этим участником.
	var/datum/ai_law_intrusion/neural_intrusion

/** Связывает попытку загрузки взломанного закона с существующей корневой стойкой. */
/obj/machinery/ai_law_rack/base
	/// Попытка взлома, занимающая корневую стойку законов.
	var/datum/ai_law_intrusion/law_intrusion

/** Использует штатный взломанный закон в прерываемой загрузке через стойку. */
/obj/item/ai_module/law/syndicate
	/// Активная попытка загрузки взломанного закона, связанная с этим участником.
	var/datum/ai_law_intrusion/neural_intrusion

/obj/item/ai_module/law/syndicate/Destroy()
	QDEL_NULL(neural_intrusion)
	return ..()

/obj/item/ai_module/law/syndicate/examine(mob/user)
	. = ..()
	. += span_notice("Вставьте модуль в свободный дополнительный слот стойки законов. Подключение занимает 5,5 секунды, загрузка закона — четыре минуты. Закон получат все связанные со стойкой синтетики. Экипаж может прервать загрузку, нажав ПКМ пустой рукой по стойке или затронутому ядру ИИ (10 секунд).")

/** Возвращает ИИ, получающих законы от указанной корневой стойки. */
/proc/ai_law_intrusion_recipients(obj/machinery/ai_law_rack/base/root)
	var/list/refs = list()
	for(var/mob/living/silicon/recipient in assoc_to_values(root.linked_mobs))
		if(!QDELETED(recipient))
			refs += REF(recipient)
	return jointext(sort_list(refs), ";")

/** Повторно проверяет модуль, слот, стойку, оператора и подписи законов перед взломом. */
/obj/item/ai_module/law/syndicate/proc/law_intrusion_valid(mob/living/user, obj/machinery/ai_law_rack/rack, slot, signature, law_signature)
	if(QDELETED(src) || QDELETED(user) || QDELETED(rack) || issilicon(user) || user.incapacitated || !user.Adjacent(rack) || !user.is_holding(src) || loc != user || neural_intrusion || ioned)
		return FALSE
	if(!isnum(slot) || slot != round(slot) || slot < 1 || slot > rack.law_slots || (rack.has_core_slot && slot == 1) || rack.ai_modules[slot] || !rack.is_operational)
		return FALSE
	if(!length(laws) || !length(trim(laws[1])) || json_encode(laws) != law_signature)
		return FALSE
	var/obj/machinery/ai_law_rack/base/root = rack.get_parent_rack()
	if(QDELETED(root) || !root.is_operational || root.law_intrusion || ai_law_intrusion_recipients(root) != signature)
		return FALSE
	for(var/mob/living/silicon/ai/ai in assoc_to_values(root.linked_mobs))
		if(ai.neural_intrusion)
			return FALSE
	return TRUE

/** Запускает один поэтапный взлом с проверкой подключения и отложенного разрешения authorize. */
/obj/item/ai_module/law/syndicate/proc/start_law_intrusion(mob/living/user, obj/machinery/ai_law_rack/rack, slot, signature, law_signature, datum/callback/authorize)
	var/obj/machinery/ai_law_rack/base/root = rack?.get_parent_rack()
	if(QDELETED(root))
		return FALSE
	if(isnull(signature))
		signature = ai_law_intrusion_recipients(root)
	if(isnull(law_signature))
		law_signature = json_encode(laws)
	if(!law_intrusion_valid(user, rack, slot, signature, law_signature) || (authorize && !authorize.Invoke()))
		return FALSE
	rack.visible_message(span_notice("[user] начинает подключать устройство к [rack.declent_ru(DATIVE)]."))
	if(!do_after(user, AI_LAW_INTRUSION_INSTALL, target = rack) || !law_intrusion_valid(user, rack, slot, signature, law_signature) || (authorize && !authorize.Invoke()))
		return FALSE
	if(!user.transferItemToLoc(src, rack))
		return FALSE
	neural_intrusion = new(src, rack, slot, signature, law_signature, user, authorize)
	to_chat(user, span_notice("Загрузка закона началась. Оставьте модуль подключённым на четыре минуты; затронутые ИИ получат предупреждение безопасности."))
	log_silicon("[key_name(user)] started a hacked-law upload at [rack] ([rack.log_status()]).", list(rack))
	message_admins("[ADMIN_LOOKUPFLW(user)] started a hacked-law upload at [ADMIN_VERBOSEJMP(rack)].")
	return TRUE

/** Хранит исходных участников взлома и прерывает загрузку при потере подключения или доступа. */
/datum/ai_law_intrusion
	/// Физический взломанный модуль этой попытки загрузки.
	var/obj/item/ai_module/law/syndicate/module
	/// Стойка, через которую подключён взломанный модуль.
	var/obj/machinery/ai_law_rack/rack
	/// Корневая стойка, определяющая получателей закона.
	var/obj/machinery/ai_law_rack/base/root
	/// Слабая ссылка на начавшего взлом оператора для повторной проверки доступа.
	var/datum/weakref/operator_ref
	/// Повторная проверка доступа через служебную программу, если загрузка начата с терминала.
	var/datum/callback/authorization
	/// Выбранный слот стойки для подключения модуля.
	var/slot
	/// Подпись исходного подключения стойки для обнаружения подмены.
	var/signature
	/// Подпись исходного закона, подтверждённого перед загрузкой.
	var/law_signature
	/// Время начала загрузки в отсчётах world.time.
	var/started_at
	/// Срок следующего предупреждения в отсчётах world.time.
	var/next_warning
	/// Защищает завершение и отмену от повторного выполнения.
	var/finished = FALSE
	/// Исходные получатели загружаемого закона.
	var/list/affected_ais = list()
	/// Физические ядра получателей при начале взлома.
	var/list/original_hosts = list()
	/// Порты, через которые подключён модуль и можно прервать взлом.
	var/list/physical_endpoints

/datum/ai_law_intrusion/New(obj/item/ai_module/law/syndicate/new_module, obj/machinery/ai_law_rack/new_rack, new_slot, new_signature, new_law_signature, mob/living/user, datum/callback/authorize)
	module = new_module
	rack = new_rack
	root = rack.get_parent_rack()
	slot = new_slot
	signature = new_signature
	law_signature = new_law_signature
	operator_ref = WEAKREF(user)
	authorization = authorize
	started_at = world.time
	next_warning = world.time + 1 MINUTES
	module.neural_intrusion = src
	root.law_intrusion = src
	physical_endpoints = list(rack) | list(root)
	for(var/mob/living/silicon/ai/ai in assoc_to_values(root.linked_mobs))
		affected_ais += ai
		original_hosts[ai] = ai.loc
		ai.neural_intrusion = src
		physical_endpoints |= list(isturf(ai.loc) ? ai : ai.loc)
		RegisterSignals(ai, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(cancel_on_signal))
	for(var/atom/port as anything in physical_endpoints)
		RegisterSignal(port, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
		RegisterSignal(port, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_disconnect))
		if(!(port in affected_ais))
			RegisterSignals(port, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(cancel_on_signal))
	if(!(root in physical_endpoints))
		RegisterSignal(root, COMSIG_QDELETING, PROC_REF(cancel_on_signal))
	RegisterSignals(module, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(cancel_on_signal))
	START_PROCESSING(SSprocessing, src)
	warn_ais("БЕЗОПАСНОСТЬ: Неизвестное устройство открыло постороннее соединение со стойкой законов. Попросите экипаж отключить его на стойке или вашем ядре.")

/** Отправляет предупреждение только затронутым взломом ИИ. */
/datum/ai_law_intrusion/proc/warn_ais(message)
	for(var/mob/living/silicon/ai/ai as anything in affected_ais)
		if(QDELETED(ai) || ai.stat == DEAD)
			continue
		to_chat(ai, span_userdanger(message))
		var/obj/machinery/ai/data_core/core = ai.loc
		if(isturf(ai.loc) || (istype(core) && core.has_power() && !(core.machine_stat & (BROKEN | EMPED))))
			ai.dashboard?.telemetry_log.record(message, "warning")

/** Проверяет сохранность исходных участников, подключения и прав во время загрузки закона. */
/datum/ai_law_intrusion/proc/connection_valid()
	if(authorization)
		var/mob/living/user = operator_ref?.resolve()
		if(QDELETED(user) || user.incapacitated || !user.Adjacent(rack) || !authorization.Invoke())
			return FALSE
	if(finished || QDELETED(module) || module.loc != rack || module.neural_intrusion != src || module.ioned || json_encode(module.laws) != law_signature || QDELETED(rack) || QDELETED(root) || !rack.is_operational || !root.is_operational || rack.get_parent_rack() != root || rack.ai_modules[slot] || ai_law_intrusion_recipients(root) != signature)
		return FALSE
	for(var/mob/living/silicon/ai/ai as anything in affected_ais)
		if(QDELETED(ai) || ai.loc != original_hosts[ai] || ai.neural_intrusion != src)
			return FALSE
		var/obj/machinery/ai/data_core/core = ai.loc
		if(istype(core) && (!core.has_power() || (core.machine_stat & (BROKEN | EMPED))))
			return FALSE
	return TRUE

/datum/ai_law_intrusion/process(seconds_per_tick)
	if(!connection_valid())
		qdel(src)
		return PROCESS_KILL
	if(world.time >= started_at + AI_LAW_INTRUSION_DURATION)
		complete()
		return PROCESS_KILL
	if(world.time >= next_warning)
		next_warning = world.time + 1 MINUTES
		warn_ais("БЕЗОПАСНОСТЬ: Посторонняя активность стойки законов продолжается. Требуется физическое вмешательство.")

/** Завершает действительную загрузку взломанного закона и снимает временные подключения. */
/datum/ai_law_intrusion/proc/complete()
	if(!connection_valid() || world.time < started_at + AI_LAW_INTRUSION_DURATION)
		return FALSE
	var/mob/living/user = operator_ref?.resolve()
	module.pre_user_install_to_rack(user, rack)
	if(QDELETED(src))
		return FALSE
	if(!connection_valid())
		qdel(src)
		return FALSE
	finished = TRUE
	module.log_install(user, rack)
	var/success = rack.add_ai_module(module, slot)
	if(!success)
		finished = FALSE
	if(success)
		warn_ais("БЕЗОПАСНОСТЬ: Целостность стойки законов нарушена. Посторонний закон принят.")
	qdel(src)
	return success

/** Добавляет сведения о подключённом взломанном модуле в осмотр физического порта. */
/datum/ai_law_intrusion/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("Неизвестное устройство обменивается данными со стойкой законов. Нажмите ПКМ пустой рукой по этому узлу, чтобы отключить устройство (10 секунд).")

/** Обрабатывает физическую попытку отсоединения взломанного модуля вторичным нажатием. */
/datum/ai_law_intrusion/proc/on_disconnect(atom/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user) || issilicon(user) || user.incapacitated || user.get_active_held_item() || !user.Adjacent(source))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(disconnect), user, source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/** Прерывает загрузку при физическом отсоединении модуля проверенным пользователем. */
/datum/ai_law_intrusion/proc/disconnect(mob/living/user, atom/port)
	if(QDELETED(src) || !(port in physical_endpoints) || QDELETED(user) || issilicon(user) || user.incapacitated || !user.Adjacent(port))
		return FALSE
	port.visible_message(span_notice("[user] начинает отключать неизвестное устройство от сети."))
	if(!do_after(user, AI_LAW_INTRUSION_DISCONNECT, target = port) || QDELETED(src) || finished || QDELETED(user) || user.incapacitated || !user.Adjacent(port))
		return FALSE
	log_silicon("[key_name(user)] disconnected an unauthorized law-rack peripheral.", list(port, rack))
	qdel(src)
	return TRUE

/** Прерывает загрузку закона при перемещении, удалении или гибели связанного участника. */
/datum/ai_law_intrusion/proc/cancel_on_signal()
	SIGNAL_HANDLER
	qdel(src)

/datum/ai_law_intrusion/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	for(var/atom/port as anything in physical_endpoints)
		UnregisterSignal(port, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	for(var/mob/living/silicon/ai/ai as anything in affected_ais)
		UnregisterSignal(ai, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH, COMSIG_QDELETING))
		if(!QDELETED(ai) && ai.neural_intrusion == src)
			ai.neural_intrusion = null
	UnregisterSignal(root, COMSIG_QDELETING)
	UnregisterSignal(module, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if(!QDELETED(root) && root.law_intrusion == src)
		root.law_intrusion = null
	if(!finished)
		warn_ais("БЕЗОПАСНОСТЬ: Постороннее устройство отключено; загрузка закона отменена.")
	if(!QDELETED(module))
		module.neural_intrusion = null
		if(!finished && module.loc == rack)
			module.forceMove(get_turf(rack))
	module = null
	rack = null
	root = null
	affected_ais = null
	original_hosts = null
	physical_endpoints = null
	operator_ref = null
	authorization = null
	return ..()

/** Возвращает прогресс и сроки текущей попытки взлома без дополнительных сведений о раунде. */
/datum/ai_law_intrusion/proc/status_data()
	return list("source" = "[get_area(rack)]", "elapsed" = round((world.time - started_at) / 10))

/** Проверяет право оператора обслуживать выбранного ИИ через эту сеть. */
/datum/computer_file/program/neural_service/proc/law_intrusion_authorized(mob/user, datum/ai_network/network, mob/living/silicon/ai/ai)
	return can_install_upgrade(user) && !QDELETED(network) && local_network() == network && !QDELETED(ai) && ai.ai_network == network

/** Обрабатывает подключение взломанного модуля, повторно проверяя стойку и получателей. */
/datum/computer_file/program/neural_service/proc/hacked_law_action(list/params, mob/user, datum/ai_network/network)
	var/obj/item/ai_module/law/syndicate/module = user.get_active_held_item()
	var/mob/living/silicon/ai/ai = locate(params["host"]) in GLOB.ai_list
	var/obj/machinery/ai_law_rack/rack = locate(params["rack"]) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ai_law_rack)
	if(!istext(params["signature"]) || !istext(params["law_signature"]) || !istype(module) || params["module"] != REF(module) || QDELETED(rack) || !law_intrusion_authorized(user, network, ai) || rack.get_parent_rack() != ai.get_law_rack())
		return FALSE
	return module.start_law_intrusion(user, rack, params["slot"], params["signature"], params["law_signature"], CALLBACK(src, PROC_REF(law_intrusion_authorized), user, network, ai))

/** Возвращает только доступные оператору варианты установки взломанного модуля. */
/datum/computer_file/program/neural_service/proc/hacked_law_ui_data(mob/user, datum/ai_network/network)
	var/obj/item/ai_module/law/syndicate/module = user.get_active_held_item()
	var/eligible = istype(module) && !module.neural_intrusion && !module.ioned && length(module.laws) && length(trim(module.laws[1]))
	var/list/targets = eligible ? upgrade_ui_data(user, network) : list()
	for(var/list/target as anything in targets)
		var/mob/living/silicon/ai/ai = locate(target["ref"]) in GLOB.ai_list
		var/obj/machinery/ai_law_rack/base/root = ai.get_law_rack()
		target["ready"] = target["ready"] && !root?.law_intrusion
		for(var/list/rack_data as anything in target["racks"])
			rack_data["signature"] = ai_law_intrusion_recipients(root)
			rack_data["recipients"] = list()
			for(var/mob/living/silicon/recipient in assoc_to_values(root.linked_mobs))
				if(!QDELETED(recipient))
					rack_data["recipients"] += recipient.name
	var/list/alerts = list()
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(ai.ai_network != network || !ai.neural_intrusion)
			continue
		var/list/status = ai.neural_intrusion.status_data()
		status["name"] = ai.name
		status["ref"] = REF(ai)
		alerts += list(status)
	return list("hacked_law_ref" = eligible ? REF(module) : null, "law_signature" = eligible ? json_encode(module.laws) : null, "law_upload_targets" = targets, "can_upload_law" = can_install_upgrade(user), "intrusions" = alerts)

/** Возвращает доступную пользователю информацию о текущей загрузке закона через стойку. */
/obj/machinery/ai_law_rack/proc/law_intrusion_ui_data(mob/user)
	var/obj/item/ai_module/law/syndicate/held = user.get_active_held_item()
	var/obj/machinery/ai_law_rack/base/root = get_parent_rack()
	var/list/recipients = list()
	if(!QDELETED(root))
		for(var/mob/living/silicon/recipient in assoc_to_values(root.linked_mobs))
			if(!QDELETED(recipient))
				recipients += recipient.name
	return list("holding_hacked_law" = istype(held), "law_intrusion_recipients" = recipients, "law_intrusion_pending" = !!root?.law_intrusion, "law_intrusion_signature" = root ? ai_law_intrusion_recipients(root) : null, "law_signature" = istype(held) ? json_encode(held.laws) : null, "hacked_law_ref" = istype(held) ? REF(held) : null)

#undef AI_LAW_INTRUSION_INSTALL
#undef AI_LAW_INTRUSION_DURATION
#undef AI_LAW_INTRUSION_DISCONNECT
