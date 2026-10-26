#define COMMS_INTERCEPT_PROB 15
#define COMMS_INTERCEPT_MIN_CREW 15
#define COMMS_INTERCEPT_MESSAGES_PER_CREW 2
#define COMMS_INTERCEPT_MIN_MESSAGES 40
#define COMMS_INTERCEPT_MAX_MESSAGES 100
/// Per-speaker cooldown, so one person can't fill the packet alone
#define COMMS_INTERCEPT_SPEAKER_COOLDOWN (30 SECONDS)
#define COMMS_INTERCEPT_UPLOAD_TIME (3 MINUTES)
#define COMMS_INTERCEPT_LOGS_PERCENT 25
#define COMMS_INTERCEPT_ECHO_PERCENT 50
#define COMMS_INTERCEPT_ECHO_PROB 5
#define COMMS_INTERCEPT_ECHO_COOLDOWN (10 MINUTES)
#define COMMS_INTERCEPT_DIRECTION_PERCENT 75
/// Add a corrupt log entry every N packets
#define COMMS_INTERCEPT_LOG_EVERY 3
/// Repeat the bearing every N packets so it follows a moved receiver
#define COMMS_INTERCEPT_DIRECTION_EVERY 5
#define COMMS_INTERCEPT_TAP_EMP_TIME (2 MINUTES)
#define COMMS_INTERCEPT_RECEIVER_EMP_TIME (60 SECONDS)
#define COMMS_INTERCEPT_MAX_LOG_ENTRIES 400

#define COMMS_RECEIVER_OFF 0
#define COMMS_RECEIVER_ONLINE 1
#define COMMS_RECEIVER_UPLOADING 2
#define COMMS_RECEIVER_DONE 3

#define COMMS_TAP_STAGE_NONE 0
#define COMMS_TAP_STAGE_PORT_FOUND 1
#define COMMS_TAP_STAGE_CONTACTS_STRIPPED 2

/// One per round. Items are spawned by path, so they look the objective up here
GLOBAL_DATUM(comms_intercept, /datum/objective/comms_intercept)
GLOBAL_VAR_INIT(comms_intercept_assigned, FALSE)

/proc/comms_intercept_threshold(crew)
	return clamp(crew * COMMS_INTERCEPT_MESSAGES_PER_CREW, COMMS_INTERCEPT_MIN_MESSAGES, COMMS_INTERCEPT_MAX_MESSAGES)

/// Common is unencrypted, only department channels count
/proc/comms_intercept_frequencies()
	var/static/list/frequencies = list(
		FREQ_COMMAND,
		FREQ_ENGINEERING,
		FREQ_JUSTICE,
		FREQ_MEDICAL,
		FREQ_SCIENCE,
		FREQ_SECURITY,
		FREQ_SERVICE,
		FREQ_SUPPLY,
	)
	return frequencies

/proc/comms_intercept_living_crew()
	. = 0
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		if(crew_mind.current && crew_mind.current.stat != DEAD)
			.++

/proc/comms_intercept_direction_text(turf/source_turf, turf/target_turf)
	var/static/list/direction_names = list(
		"[NORTH]" = "на север",
		"[SOUTH]" = "на юг",
		"[EAST]" = "на восток",
		"[WEST]" = "на запад",
		"[NORTHEAST]" = "на северо-восток",
		"[NORTHWEST]" = "на северо-запад",
		"[SOUTHEAST]" = "на юго-восток",
		"[SOUTHWEST]" = "на юго-запад",
	)
	// get_dir() mixes in UP/DOWN across z-levels, the level is reported separately
	. = direction_names["[get_dir(source_turf, target_turf) & ~(UP|DOWN)]"] || "в пределах узла"
	if(target_turf.z > source_turf.z)
		. += ", уровнем выше"
	else if(target_turf.z < source_turf.z)
		. += ", уровнем ниже"

/// Names of the department channels going through this machine
/proc/comms_intercept_channel_names(obj/machinery/telecomms/machine)
	. = list()
	for(var/channel_name in GLOB.default_radio_channels)
		var/frequency = GLOB.default_radio_channels[channel_name]
		if(!(frequency in comms_intercept_frequencies()))
			continue
		if(!length(machine.freq_listening) || (frequency in machine.freq_listening))
			. += channel_name

/proc/is_comms_tappable(atom/target)
	var/static/list/tappable_machines = typecacheof(list(
		/obj/machinery/telecomms/bus,
		/obj/machinery/telecomms/hub,
		/obj/machinery/telecomms/receiver,
		/obj/machinery/telecomms/server,
	))
	return is_type_in_typecache(target, tappable_machines)

/// Needs something to tap and a log console, otherwise the first hint has nowhere to show up
/proc/comms_intercept_station_equipped()
	var/has_tappable_machine = FALSE
	for(var/obj/machinery/telecomms/machine as anything in GLOB.telecomm_machines)
		if(is_comms_tappable(machine) && is_station_level(machine.z))
			has_tappable_machine = TRUE
			break
	if(!has_tappable_machine)
		return FALSE
	for(var/obj/machinery/computer/telecomms/server/console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/telecomms/server))
		if(is_station_level(console.z))
			return TRUE
	return FALSE

/datum/antagonist/traitor/proc/try_forge_comms_intercept()
	if(GLOB.comms_intercept_assigned || !prob(COMMS_INTERCEPT_PROB))
		return null
	var/crew = comms_intercept_living_crew()
	if(crew < COMMS_INTERCEPT_MIN_CREW)
		return null
	if(!comms_intercept_station_equipped())
		return null
	var/datum/objective/comms_intercept/objective = new
	objective.owner = owner
	objective.setup(crew)
	return objective

/datum/objective/comms_intercept
	name = "encryption key theft"
	admin_grantable = TRUE
	var/messages_collected = 0
	/// Kept here so moving the receiver doesn't reset the upload
	var/upload_progress = 0
	var/upload_announced = FALSE
	var/upload_done = FALSE
	/// Key dump pulled out of the receiver after the upload
	var/datum/weakref/disk_ref
	/// Receiver was destroyed before the dump was taken out
	var/failed = FALSE
	var/last_direction_report = 0
	/// Each receiver copies the signal, so we dedupe on the root one
	var/last_signal_key
	/// REF(speaker) = world.time of their last counted packet
	var/list/speaker_last_packet = list()
	/// REF(speaker) = world.time of their last echo
	var/list/speaker_last_echo = list()
	var/datum/weakref/receiver_ref
	var/list/obj/item/comms_tap/active_taps = list()

/datum/objective/comms_intercept/Destroy()
	if(GLOB.comms_intercept == src)
		GLOB.comms_intercept = null
	active_taps.Cut()
	receiver_ref = null
	disk_ref = null
	return ..()

/datum/objective/comms_intercept/proc/setup(crew)
	target_amount = comms_intercept_threshold(crew)
	GLOB.comms_intercept = src
	GLOB.comms_intercept_assigned = TRUE
	update_explanation_text()
	give_special_equipment(list(/obj/item/storage/box/syndie_kit/comms_intercept))
	var/datum/antagonist/traitor/traitor = owner?.has_antag_datum(/datum/antagonist/traitor)
	traitor?.uplink_handler?.extra_purchasable += new /datum/uplink_item/special_equipment/comms_tap

/datum/objective/comms_intercept/admin_edit(mob/admin)
	if(GLOB.comms_intercept)
		to_chat(admin, span_warning("В раунде уже есть активная цель перехвата эфира, эта цель не будет работать."))
		return
	setup(comms_intercept_living_crew())

/datum/objective/comms_intercept/update_explanation_text()
	explanation_text = "Украдите ключи шифрования станции: подключите сетевой жучок к телекоммуникациям, соберите приёмником [target_amount] пакетов из каналов отделов, дождитесь окончания выгрузки, заберите дамп ключей шифрования из приёмника и вывезите его со станции. Инструкция приложена к оборудованию."

/datum/objective/comms_intercept/check_completion()
	if(completed)
		return TRUE
	var/obj/item/disk/comms_intercept/disk = disk_ref?.resolve()
	if(!disk || !considered_escaped(owner))
		return FALSE
	return disk in owner.current.get_all_contents()

/datum/objective/comms_intercept/proc/on_intercepted_message(datum/signal/subspace/vocal/signal)
	if(upload_done || failed || messages_collected >= target_amount)
		return
	var/datum/signal/subspace/root = signal
	while(root.original)
		root = root.original
	// world.time in the key in case a deleted signal's ref gets reused
	var/signal_key = "[REF(root)]-[world.time]"
	if(signal_key == last_signal_key)
		return
	last_signal_key = signal_key
	var/atom/movable/speaker = signal.virt?.source
	if(!speaker)
		return
	if(ismob(speaker))
		var/mob/speaking_mob = speaker
		if(speaking_mob.mind == owner)
			return
	var/speaker_key = REF(speaker)
	if(world.time < speaker_last_packet[speaker_key] + COMMS_INTERCEPT_SPEAKER_COOLDOWN)
		return
	var/obj/item/comms_intercept_receiver/receiver = receiver_ref?.resolve()
	if(!receiver?.can_receive())
		return
	speaker_last_packet[speaker_key] = world.time
	messages_collected++
	give_hints(receiver, speaker)
	if(messages_collected >= target_amount)
		receiver.start_upload()
	receiver.update_status()

/datum/objective/comms_intercept/proc/is_echo_active()
	return !upload_done && !failed && messages_collected * 100 / target_amount >= COMMS_INTERCEPT_ECHO_PERCENT

/datum/objective/comms_intercept/proc/give_hints(obj/item/comms_intercept_receiver/receiver, atom/movable/speaker)
	var/percent = messages_collected * 100 / target_amount
	if(percent >= COMMS_INTERCEPT_LOGS_PERCENT && !(messages_collected % COMMS_INTERCEPT_LOG_EVERY))
		add_server_log("Копия пакета данных передана на незарегистрированный адрес.")
	if(ismob(speaker) && is_echo_active() && prob(COMMS_INTERCEPT_ECHO_PROB))
		var/speaker_key = REF(speaker)
		if(world.time >= speaker_last_echo[speaker_key] + COMMS_INTERCEPT_ECHO_COOLDOWN)
			speaker_last_echo[speaker_key] = world.time
			to_chat(speaker, span_warning("В гарнитуре на мгновение слышно слабое эхо вашего голоса."))
	if(percent >= COMMS_INTERCEPT_DIRECTION_PERCENT && (!last_direction_report || messages_collected - last_direction_report >= COMMS_INTERCEPT_DIRECTION_EVERY))
		last_direction_report = messages_collected
		report_direction(receiver)

/datum/objective/comms_intercept/proc/report_direction(obj/item/comms_intercept_receiver/receiver)
	var/direction = get_direction_text(receiver)
	if(!direction)
		return
	var/text = "Поток копий каналов связи уходит от телекоммуникаций [direction]."
	add_server_log(text)
	notify_ais(text)

/datum/objective/comms_intercept/proc/get_direction_text(obj/item/comms_intercept_receiver/receiver)
	var/obj/item/comms_tap/tap = locate() in active_taps
	var/turf/tap_turf = get_turf(tap)
	var/turf/receiver_turf = get_turf(receiver)
	if(!tap_turf || !receiver_turf)
		return null
	return comms_intercept_direction_text(tap_turf, receiver_turf)

/// Shows up in the log browser of every server that handles a department channel
/datum/objective/comms_intercept/proc/add_server_log(text)
	for(var/obj/machinery/telecomms/server/server in GLOB.telecomm_machines)
		if(!length(server.freq_listening & comms_intercept_frequencies()))
			continue
		var/datum/comm_log_entry/log = new
		log.input_type = "Corrupt File"
		log.name = "data packet ([md5("[REF(log)][world.time]")])"
		log.parameters["name"] = "Unknown"
		log.parameters["job"] = "Unknown"
		log.parameters["message"] = text
		log.parameters["language"] = /datum/language/common
		if(length(server.log_entries) >= COMMS_INTERCEPT_MAX_LOG_ENTRIES)
			server.log_entries.Cut(1, 2)
		server.log_entries += log

/datum/objective/comms_intercept/proc/notify_ais(text)
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		to_chat(ai, span_warning(text))

/datum/objective/comms_intercept/proc/on_upload_started(obj/item/comms_intercept_receiver/receiver)
	if(upload_announced)
		return
	upload_announced = TRUE
	var/area/receiver_area = get_area(receiver)
	notify_ais("Обнаружена исходящая передача перехваченных данных каналов связи. Источник: [receiver_area.name].")
	var/direction = get_direction_text(receiver)
	// Crew only gets a bearing, the exact area goes to the AI
	var/text = "Обнаружена исходящая передача перехваченных данных каналов связи. Сигнал уходит от телекоммуникаций [direction || "в неизвестном направлении"]."
	add_server_log(text)
	var/list/channels = list(RADIO_CHANNEL_COMMAND, RADIO_CHANNEL_ENGINEERING)
	// broadcast() mutates the list
	var/obj/machinery/announcement_system/announcer = get_announcement_system(null, receiver, channels)
	announcer?.broadcast(text, channels.Copy())

/datum/objective/comms_intercept/proc/on_upload_finished()
	upload_done = TRUE
	if(owner?.current)
		to_chat(owner.current, span_notice("Выгрузка перехваченных данных завершена. Заберите дамп ключей шифрования из приёмника и вывезите его со станции."))

/datum/objective/comms_intercept/proc/on_receiver_destroyed(obj/item/comms_intercept_receiver/receiver)
	if(disk_ref || receiver_ref?.resolve() != receiver)
		return
	failed = TRUE
	receiver_ref = null

/obj/item/storage/box/syndie_kit/comms_intercept
	name = "comms intercept kit"
	desc = "Коробка с оборудованием для перехвата каналов связи."

/obj/item/storage/box/syndie_kit/comms_intercept/PopulateContents()
	new /obj/item/comms_tap(src)
	new /obj/item/comms_intercept_receiver(src)
	new /obj/item/paper/guides/antag/comms_intercept(src)

/obj/item/paper/guides/antag/comms_intercept
	default_raw_text = "Агент, ваша задача — добыть ключи шифрования станции.<br>\
	<ul>\
	<li>Установите сетевой жучок в одну из машин телекоммуникаций: приёмник, хаб, шину или сервер. Жучок слышит только те каналы, которые проходят через его машину. Через хаб идут все каналы, остальные машины обрабатывают лишь часть, и сбор на них пойдёт медленнее.</li>\
	<li>Откройте панель машины отвёрткой. Затем найдите служебный разъём с помощью вторичной функции мультитула.</li>\
	<li>Зачистите контакты кусачками и вставьте жучок. Используйте вторичную функцию мультитула для синхронизации, затем закройте панель отвёрткой.</li>\
	<li>Синхронизировать жучок может только тот, кто его установил. Пока панель открыта, жучок не работает, а преждевременное закрытие заставит начать установку заново.</li>\
	<li>Закрепите приёмник гаечным ключом в любом помещении станции с питанием, кроме самих телекоммуникаций. Приёмник можно переносить, собранные пакеты сохранятся.</li>\
	<li>Пакеты поступают из разговоров экипажа в каналах отделов. Общий канал не шифруется, а ваши собственные сообщения не учитываются.</li>\
	<li>От одного человека можно получить не больше одного пакета за полминуты. Ход сбора отслеживайте на экране приёмника.</li>\
	<li>После сбора пакетов приёмник начнёт трёхминутную выгрузку. Не допускайте, чтобы его открепили, обесточили или сломали.</li>\
	<li>По завершении выгрузки заберите дамп ключей шифрования из приёмника и эвакуируйтесь с ним. Дамп должен находиться при вас.</li>\
	<li>Дамп открывает гарнитуре все каналы отделов: подключите его к гарнитуре, сам дамп останется у вас. Если в гарнитуре сменить ключ шифрования, доступ пропадёт.</li>\
	<li>Чем дольше идёт перехват, тем заметнее утечка: экипаж и ИИ начнут искать жучок и приёмник. Запасной жучок можно приобрести в аплинке.</li>\
	</ul>"

/datum/uplink_item/special_equipment/comms_tap
	name = "Spare Network Bug"
	desc = "Запасной сетевой жучок для перехвата каналов связи."
	item = /obj/item/comms_tap
	cost = 2
	limited_stock = 2
	restricted = TRUE
	purchasable_from = NONE // handed out through extra_purchasable

/obj/item/disk/comms_intercept
	name = "encryption key dump"
	desc = "Носитель с перехваченными ключами шифрования каналов отделов. Подключите к гарнитуре, чтобы получить доступ ко всем каналам."

/obj/item/disk/comms_intercept/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/radio/headset))
		return NONE
	var/obj/item/radio/headset/headset = interacting_with
	if(!length(get_missing_channels(headset)))
		headset.balloon_alert(user, "уже взломана!")
		return ITEM_INTERACT_BLOCKING
	headset.balloon_alert(user, "подключение...")
	if(!do_after(user, 3 SECONDS, headset))
		return ITEM_INTERACT_BLOCKING
	var/list/missing_channels = get_missing_channels(headset)
	if(!length(missing_channels))
		headset.balloon_alert(user, "уже взломана!")
		return ITEM_INTERACT_BLOCKING
	// Written straight into the headset, so swapping its keys rebuilds the channels and drops the access
	for(var/channel_name in missing_channels)
		headset.channels[channel_name] = 1
		LAZYSET(headset.secure_radio_connections, channel_name, add_radio(headset, GLOB.default_radio_channels[channel_name]))
	if(!headset.listening)
		remove_radio_all(headset)
	headset.balloon_alert(user, "каналы добавлены")
	return ITEM_INTERACT_SUCCESS

/obj/item/disk/comms_intercept/proc/get_missing_channels(obj/item/radio/headset/headset)
	. = list()
	for(var/channel_name in GLOB.default_radio_channels)
		if(!(channel_name in headset.channels) && (GLOB.default_radio_channels[channel_name] in comms_intercept_frequencies()))
			. += channel_name

/obj/item/comms_tap
	name = "network bug"
	desc = "Крохотный модуль с парой контактов-зажимов и разъёмом для мультитула."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "suit_sensor"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/telecomms/host
	/// Only the installer can sync it, anyone else just finds it
	var/datum/weakref/installer_ref
	var/calibrated = FALSE
	var/offline_until = 0

/obj/item/comms_tap/Destroy()
	detach()
	return ..()

/obj/item/comms_tap/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(host && loc != host)
		detach()

/obj/item/comms_tap/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!is_comms_tappable(interacting_with))
		return NONE
	var/obj/machinery/telecomms/machine = interacting_with
	if(!machine.panel_open)
		balloon_alert(user, "панель закрыта!")
		return ITEM_INTERACT_BLOCKING
	if(machine.tap_install_stage != COMMS_TAP_STAGE_CONTACTS_STRIPPED)
		balloon_alert(user, "контакты не подготовлены!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "подключение...")
	if(!do_after(user, 5 SECONDS, machine) || machine.tap_install_stage != COMMS_TAP_STAGE_CONTACTS_STRIPPED || loc != user || (locate(/obj/item/comms_tap) in machine))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(src, machine))
		return ITEM_INTERACT_BLOCKING
	machine.tap_install_stage = COMMS_TAP_STAGE_NONE
	installer_ref = WEAKREF(user.mind)
	attach(machine)
	balloon_alert(user, "жучок подключён")
	to_chat(user, span_notice("Жучок подключён. Доступные каналы: [jointext(comms_intercept_channel_names(machine), ", ")]. Синхронизируйте его мультитулом (вторичная функция)."))
	return ITEM_INTERACT_SUCCESS

/obj/item/comms_tap/proc/attach(obj/machinery/telecomms/machine)
	host = machine
	RegisterSignal(host, COMSIG_TELECOMMS_RELAY_INFORMATION, PROC_REF(on_relay))
	RegisterSignal(host, COMSIG_ATOM_EMP_ACT, PROC_REF(on_host_emp))
	RegisterSignal(host, COMSIG_QDELETING, PROC_REF(on_host_deleted))

/obj/item/comms_tap/proc/detach()
	if(!host)
		return
	UnregisterSignal(host, list(COMSIG_TELECOMMS_RELAY_INFORMATION, COMSIG_ATOM_EMP_ACT, COMSIG_QDELETING))
	host = null
	installer_ref = null
	calibrated = FALSE
	update_active()

/obj/item/comms_tap/proc/update_active()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective)
		return
	if(host && calibrated)
		objective.active_taps |= src
	else
		objective.active_taps -= src

/obj/item/comms_tap/proc/is_listening()
	return host && calibrated && !host.panel_open && world.time >= offline_until

/obj/item/comms_tap/proc/on_relay(datum/source, datum/signal/subspace/signal)
	SIGNAL_HANDLER
	if(!is_listening())
		return
	if(!istype(signal, /datum/signal/subspace/vocal) || !(signal.frequency in comms_intercept_frequencies()) || !signal.data["message"])
		return
	GLOB.comms_intercept?.on_intercepted_message(signal)

/obj/item/comms_tap/proc/on_host_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_CONTENTS)
		return
	offline_until = world.time + COMMS_INTERCEPT_TAP_EMP_TIME

/obj/item/comms_tap/proc/on_host_deleted(datum/source)
	SIGNAL_HANDLER
	var/turf/drop_turf = get_turf(host)
	if(drop_turf)
		forceMove(drop_turf)
	else
		detach()

/obj/item/comms_tap/proc/calibrate()
	calibrated = TRUE
	update_active()

/obj/item/comms_intercept_receiver
	name = "intercept receiver"
	desc = "Переносной приёмник с откидной антенной и болтами для крепления к полу."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "supplypod_beacon"
	w_class = WEIGHT_CLASS_SMALL
	var/emp_until = 0
	var/uploading = FALSE
	var/status = COMMS_RECEIVER_OFF

/obj/item/comms_intercept_receiver/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.comms_intercept?.on_receiver_destroyed(src)
	return ..()

/obj/item/comms_intercept_receiver/examine(mob/user)
	. = ..()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective)
		return
	. += span_notice("На экране: [objective.messages_collected]/[objective.target_amount] пакетов.")
	if(!objective.upload_done && can_receive())
		var/list/channel_names = list()
		for(var/obj/item/comms_tap/tap as anything in objective.active_taps)
			if(tap.is_listening())
				channel_names |= comms_intercept_channel_names(tap.host)
		if(length(channel_names))
			. += span_notice("Считываются каналы: [jointext(channel_names, ", ")].")
		else
			. += span_notice("Сигнал от жучка не поступает.")
	if(uploading)
		. += span_notice("Выгрузка: [round(objective.upload_progress * 100 / COMMS_INTERCEPT_UPLOAD_TIME)]%.")
	if(objective.upload_done && !objective.disk_ref)
		. += span_notice("Выгрузка завершена, дамп ключей шифрования готов к извлечению.")
	if(!anchored)
		. += span_notice("Приёмник можно закрепить [EXAMINE_HINT("гаечным ключом")].")

/obj/item/comms_intercept_receiver/attack_hand(mob/user, list/modifiers)
	if(try_extract_disk(user))
		return TRUE
	return ..()

/obj/item/comms_intercept_receiver/attack_self(mob/user, modifiers)
	if(try_extract_disk(user))
		return TRUE
	return ..()

/// Anyone can pull the dump, so security can seize it too
/obj/item/comms_intercept_receiver/proc/try_extract_disk(mob/user)
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective?.upload_done || objective.disk_ref || objective.receiver_ref?.resolve() != src)
		return FALSE
	var/obj/item/disk/comms_intercept/disk = new(drop_location())
	objective.disk_ref = WEAKREF(disk)
	user.put_in_hands(disk)
	balloon_alert(user, "дамп извлечён")
	update_status()
	return TRUE

/obj/item/comms_intercept_receiver/wrench_act(mob/living/user, obj/item/tool)
	if(!isturf(loc))
		return NONE
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/comms_intercept_receiver/set_anchored(anchorvalue)
	. = ..()
	if(anchored)
		GLOB.comms_intercept?.receiver_ref = WEAKREF(src)
	update_status()

/obj/item/comms_intercept_receiver/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emp_until = world.time + COMMS_INTERCEPT_RECEIVER_EMP_TIME
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(uploading && objective)
		objective.upload_progress = 0
	update_status()
	addtimer(CALLBACK(src, PROC_REF(update_status)), COMMS_INTERCEPT_RECEIVER_EMP_TIME)

/obj/item/comms_intercept_receiver/proc/get_status()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective || objective.failed || objective.receiver_ref?.resolve() != src)
		return COMMS_RECEIVER_OFF
	if(objective.upload_done)
		return objective.disk_ref ? COMMS_RECEIVER_OFF : COMMS_RECEIVER_DONE
	if(!can_receive())
		return COMMS_RECEIVER_OFF
	return uploading ? COMMS_RECEIVER_UPLOADING : COMMS_RECEIVER_ONLINE

// shortcut: no area power event here, lights catch up on the next packet, upload tick or anchoring; hook the area power signal if it confuses players
/obj/item/comms_intercept_receiver/proc/update_status()
	var/new_status = get_status()
	if(new_status == status)
		return
	status = new_status
	update_appearance(UPDATE_OVERLAYS)

/obj/item/comms_intercept_receiver/update_overlays()
	. = ..()
	switch(status)
		if(COMMS_RECEIVER_ONLINE)
			. += "sp_orange"
		if(COMMS_RECEIVER_UPLOADING)
			. += "sp_yellow"
		if(COMMS_RECEIVER_DONE)
			. += "sp_green"

/obj/item/comms_intercept_receiver/proc/can_receive()
	if(!anchored || world.time < emp_until || GLOB.comms_intercept?.receiver_ref?.resolve() != src)
		return FALSE
	var/turf/receiver_turf = loc
	if(!isturf(receiver_turf) || !is_station_level(receiver_turf.z))
		return FALSE
	var/area/receiver_area = receiver_turf.loc
	return !istype(receiver_area, /area/station/tcommsat) && receiver_area.powered(AREA_USAGE_EQUIP)

/obj/item/comms_intercept_receiver/proc/start_upload()
	if(uploading)
		return
	uploading = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/comms_intercept_receiver/process(seconds_per_tick)
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective || objective.upload_done || objective.failed)
		uploading = FALSE
		update_status()
		return PROCESS_KILL
	update_status()
	if(!can_receive())
		return
	objective.on_upload_started(src)
	objective.upload_progress += seconds_per_tick SECONDS
	if(objective.upload_progress < COMMS_INTERCEPT_UPLOAD_TIME)
		return
	uploading = FALSE
	objective.on_upload_finished()
	update_status()
	return PROCESS_KILL

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(!GLOB.comms_intercept?.is_echo_active())
		return
	for(var/frequency in comms_intercept_frequencies())
		if(src in GLOB.all_radios["[frequency]"])
			. += span_warning("Индикатор шифрования неровно мигает.")
			return

/obj/machinery/telecomms
	/// Comms tap install progress, reset when the panel closes
	var/tap_install_stage = COMMS_TAP_STAGE_NONE

/obj/machinery/telecomms/on_set_panel_open(old_value)
	. = ..()
	if(!panel_open)
		tap_install_stage = COMMS_TAP_STAGE_NONE

/// Board check. Finding a tap, starting an install and syncing a tap are all the same action
/obj/machinery/telecomms/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	balloon_alert(user, "проверка платы...")
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 50) || !panel_open)
		return ITEM_INTERACT_BLOCKING
	var/obj/item/comms_tap/tap = locate() in src
	if(tap)
		if(!tap.calibrated && tap.installer_ref?.resolve() == user.mind)
			tap.calibrate()
			balloon_alert(user, "синхронизация установлена")
			to_chat(user, span_notice("Синхронизация установлена. Закройте панель отвёрткой, и жучок начнёт считывать каналы."))
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("На плате [declent_ru(GENITIVE)] обнаружен посторонний модуль!"))
		return ITEM_INTERACT_SUCCESS
	if(!is_comms_tappable(src))
		balloon_alert(user, "ничего постороннего")
		return ITEM_INTERACT_SUCCESS
	tap_install_stage = COMMS_TAP_STAGE_PORT_FOUND
	balloon_alert(user, "найден служебный разъём")
	// Only someone carrying a tap gets the next step, board checks shouldn't teach the crew how to install one
	if(locate(/obj/item/comms_tap) in user.get_all_contents())
		to_chat(user, span_notice("Найден служебный разъём. Через [declent_ru(ACCUSATIVE)] проходят каналы: [jointext(comms_intercept_channel_names(src), ", ")]. Зачистите контакты кусачками."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/telecomms/wirecutter_act(mob/living/user, obj/item/tool)
	if(!panel_open || tap_install_stage != COMMS_TAP_STAGE_PORT_FOUND)
		return NONE
	balloon_alert(user, "зачистка контактов...")
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50) || tap_install_stage != COMMS_TAP_STAGE_PORT_FOUND)
		return ITEM_INTERACT_BLOCKING
	tap_install_stage = COMMS_TAP_STAGE_CONTACTS_STRIPPED
	balloon_alert(user, "контакты зачищены")
	if(locate(/obj/item/comms_tap) in user.get_all_contents())
		to_chat(user, span_notice("Контакты зачищены. Вставьте жучок."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/telecomms/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !panel_open)
		return
	balloon_alert(user, "осмотр платы...")
	// Full delay even on a clean machine, otherwise the result leaks early
	if(!do_after(user, 10 SECONDS, src) || !panel_open)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/comms_tap/tap = locate() in src
	if(!tap)
		balloon_alert(user, "ничего постороннего")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	tap.forceMove(drop_location())
	user.put_in_hands(tap)
	to_chat(user, span_warning("Вы извлекаете посторонний модуль из [declent_ru(GENITIVE)]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

#undef COMMS_INTERCEPT_PROB
#undef COMMS_INTERCEPT_MIN_CREW
#undef COMMS_INTERCEPT_MESSAGES_PER_CREW
#undef COMMS_INTERCEPT_SPEAKER_COOLDOWN
#undef COMMS_INTERCEPT_ECHO_PERCENT
#undef COMMS_INTERCEPT_ECHO_PROB
#undef COMMS_INTERCEPT_ECHO_COOLDOWN
#undef COMMS_INTERCEPT_MIN_MESSAGES
#undef COMMS_INTERCEPT_MAX_MESSAGES
#undef COMMS_INTERCEPT_UPLOAD_TIME
#undef COMMS_INTERCEPT_LOGS_PERCENT
#undef COMMS_INTERCEPT_DIRECTION_PERCENT
#undef COMMS_INTERCEPT_LOG_EVERY
#undef COMMS_INTERCEPT_DIRECTION_EVERY
#undef COMMS_INTERCEPT_TAP_EMP_TIME
#undef COMMS_INTERCEPT_RECEIVER_EMP_TIME
#undef COMMS_INTERCEPT_MAX_LOG_ENTRIES
#undef COMMS_RECEIVER_OFF
#undef COMMS_RECEIVER_ONLINE
#undef COMMS_RECEIVER_UPLOADING
#undef COMMS_RECEIVER_DONE
#undef COMMS_TAP_STAGE_NONE
#undef COMMS_TAP_STAGE_PORT_FOUND
#undef COMMS_TAP_STAGE_CONTACTS_STRIPPED
