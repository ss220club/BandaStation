#define COMMS_INTERCEPT_PROB 0
#define COMMS_INTERCEPT_MIN_CREW 15
#define COMMS_INTERCEPT_MESSAGES_PER_CREW 2
#define COMMS_INTERCEPT_MIN_MESSAGES 40
#define COMMS_INTERCEPT_MAX_MESSAGES 100
/// Per-speaker cooldown, so one person can't fill the packet alone
#define COMMS_INTERCEPT_SPEAKER_COOLDOWN (30 SECONDS)
#define COMMS_INTERCEPT_UPLOAD_TIME_MIN (2 MINUTES)
#define COMMS_INTERCEPT_UPLOAD_TIME_MAX (5 MINUTES)
/// From this distance to the tap on, the transmission takes the longest
#define COMMS_INTERCEPT_UPLOAD_FAR_DISTANCE 100
/// Each z-level between the receiver and the tap counts as this many tiles
#define COMMS_INTERCEPT_Z_LEVEL_DISTANCE 30
#define COMMS_INTERCEPT_LOGS_PERCENT 25
#define COMMS_INTERCEPT_DIRECTION_PERCENT 75
/// Add a corrupt log entry every N packets
#define COMMS_INTERCEPT_LOG_EVERY 3
/// Repeat the bearing every N packets so it follows a moved receiver
#define COMMS_INTERCEPT_DIRECTION_EVERY 5
#define COMMS_INTERCEPT_TAP_EMP_TIME (2 MINUTES)
#define COMMS_INTERCEPT_RECEIVER_EMP_TIME (60 SECONDS)
#define COMMS_INTERCEPT_EXTRACT_TIME (30 SECONDS)
#define COMMS_INTERCEPT_MAX_LOG_ENTRIES 400
/// Extra load on the receiver's area APC while transmitting, shows up on the power monitor
#define COMMS_INTERCEPT_RECEIVER_LOAD (10 KILO WATTS)
#define COMMS_INTERCEPT_STATIC_NEAR 10
#define COMMS_INTERCEPT_STATIC_FAR 30

#define COMMS_RECEIVER_OFF 0
#define COMMS_RECEIVER_ONLINE 1
#define COMMS_RECEIVER_UPLOADING 2
#define COMMS_RECEIVER_DONE 3
#define COMMS_RECEIVER_NO_SIGNAL 4

#define COMMS_TAP_SHIELD_WIRES 3
#define COMMS_TAP_WIRE_TIME (4 SECONDS)
#define COMMS_TAP_INSERT_TIME (5 SECONDS)

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

/// get_dist() doesn't work across z-levels, so every level of difference adds a fixed number of tiles
/proc/comms_intercept_tap_distance(turf/tap_turf, turf/receiver_turf)
	var/flat_distance = max(abs(tap_turf.x - receiver_turf.x), abs(tap_turf.y - receiver_turf.y))
	return flat_distance + abs(tap_turf.z - receiver_turf.z) * COMMS_INTERCEPT_Z_LEVEL_DISTANCE

/// Closer to the tap is faster, a null distance (no working tap) takes the longest
/proc/comms_intercept_upload_time(distance)
	if(isnull(distance))
		return COMMS_INTERCEPT_UPLOAD_TIME_MAX
	var/ramp = min(distance, COMMS_INTERCEPT_UPLOAD_FAR_DISTANCE) * (COMMS_INTERCEPT_UPLOAD_TIME_MAX - COMMS_INTERCEPT_UPLOAD_TIME_MIN)
	return COMMS_INTERCEPT_UPLOAD_TIME_MIN + ramp / COMMS_INTERCEPT_UPLOAD_FAR_DISTANCE

/proc/comms_intercept_static_text(distance)
	if(distance < COMMS_INTERCEPT_STATIC_NEAR)
		return "оглушающий треск"
	if(distance <= COMMS_INTERCEPT_STATIC_FAR)
		return "отчётливый треск"
	return "слабый треск"

/// Has to be in the range any station radio can tune to
/proc/comms_intercept_pick_frequency()
	var/list/frequencies = list()
	for(var/frequency in MIN_UNUSED_FREQ to MAX_FREQ step 2)
		if(frequency != FREQ_CONFESSIONAL)
			frequencies += frequency
	return pick(frequencies)

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
	var/heads_warned = FALSE
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
	var/datum/weakref/receiver_ref
	var/list/obj/item/comms_tap/active_taps = list()
	/// Picked at transmission start, radios tuned to it pick up the receiver
	var/transmission_frequency

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
	explanation_text = "Украдите ключи шифрования телекоммуникаций. Инструкция приложена к оборудованию."

/datum/objective/comms_intercept/check_completion()
	if(completed)
		return TRUE
	var/obj/item/disk/comms_intercept/disk = disk_ref?.resolve()
	if(!disk || !considered_escaped(owner))
		return FALSE
	return disk in owner.current.get_all_contents()

/datum/objective/comms_intercept/proc/on_intercepted_message(datum/signal/subspace/vocal/signal)
	if(upload_done || failed)
		return
	var/datum/signal/subspace/root = signal
	while(root.original)
		root = root.original
	// world.time in the key in case a deleted signal's ref gets reused
	var/signal_key = "[REF(root)]-[world.time]"
	if(signal_key == last_signal_key)
		return
	last_signal_key = signal_key
	var/obj/item/comms_intercept_receiver/receiver = receiver_ref?.resolve()
	if(receiver?.status == COMMS_RECEIVER_UPLOADING)
		signal.data["message"] = Gibberish(signal.data["message"], TRUE, 100)
	if(messages_collected >= target_amount)
		return
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
	if(!receiver?.can_receive())
		return
	speaker_last_packet[speaker_key] = world.time
	messages_collected++
	give_hints(receiver)
	receiver.update_status()

/datum/objective/comms_intercept/proc/has_listening_tap()
	for(var/obj/item/comms_tap/tap as anything in active_taps)
		if(tap.is_listening())
			return TRUE
	return FALSE

/datum/objective/comms_intercept/proc/is_collected()
	return !upload_done && !failed && messages_collected >= target_amount

/// Quiet way out: the installer pulls the dump straight off the tap, skipping the transmission
/datum/objective/comms_intercept/proc/extract_from_tap(obj/item/comms_tap/tap, mob/living/user, obj/item/disk/computer/blank)
	upload_done = TRUE
	write_dump(user, blank)
	qdel(tap)
	var/obj/item/comms_intercept_receiver/receiver = receiver_ref?.resolve()
	receiver?.update_status()

/datum/objective/comms_intercept/proc/write_dump(mob/living/user, obj/item/disk/computer/blank)
	qdel(blank)
	var/obj/item/disk/comms_intercept/disk = new(user.drop_location())
	disk_ref = WEAKREF(disk)
	user.put_in_hands(disk)

/datum/objective/comms_intercept/proc/give_hints(obj/item/comms_intercept_receiver/receiver)
	var/percent = messages_collected * 100 / target_amount
	if(percent >= COMMS_INTERCEPT_LOGS_PERCENT && !(messages_collected % COMMS_INTERCEPT_LOG_EVERY))
		add_server_log("Копия пакета данных передана на незарегистрированный адрес.")
	if(percent >= COMMS_INTERCEPT_DIRECTION_PERCENT && (!last_direction_report || messages_collected - last_direction_report >= COMMS_INTERCEPT_DIRECTION_EVERY))
		last_direction_report = messages_collected
		report_direction(receiver)
	if(percent >= COMMS_INTERCEPT_DIRECTION_PERCENT && !heads_warned)
		heads_warned = TRUE
		warn_heads()

/// Nobody checks the server logs on their own, so point the heads at them
/datum/objective/comms_intercept/proc/warn_heads()
	var/obj/machinery/announcement_system/announcer = get_announcement_system()
	if(!announcer)
		return
	var/static/list/warned_jobs = list(JOB_CAPTAIN, JOB_CHIEF_ENGINEER, JOB_RESEARCH_DIRECTOR)
	var/list/head_names = list()
	for(var/mob/living/carbon/human/head as anything in GLOB.human_list)
		if(head.mind?.assigned_role?.title in warned_jobs)
			head_names += head.real_name
	var/list/targets = list()
	for(var/messenger_ref in GLOB.pda_messengers)
		var/datum/computer_file/program/messenger/messenger = GLOB.pda_messengers[messenger_ref]
		if(messenger.computer?.saved_identification in head_names)
			targets += messenger
	if(!length(targets))
		return
	var/datum/signal/subspace/messaging/tablet_message/signal = new(announcer, list(
		"fakename" = "Мониторинг телекоммуникаций",
		"fakejob" = "Автоматическая система оповещения",
		"message" = "Зафиксирована утечка копий пакетов из каналов отделов. Подробности в журнале серверов телекоммуникаций.",
		"targets" = targets,
		"automated" = TRUE,
	))
	signal.send_to_receivers()

/datum/objective/comms_intercept/proc/report_direction(obj/item/comms_intercept_receiver/receiver)
	var/direction = get_direction_text(receiver)
	if(direction)
		add_server_log("Поток копий каналов связи уходит от телекоммуникаций [direction].")

/datum/objective/comms_intercept/proc/get_direction_text(obj/item/comms_intercept_receiver/receiver)
	var/obj/item/comms_tap/tap = locate() in active_taps
	var/turf/tap_turf = get_turf(tap)
	var/turf/receiver_turf = get_turf(receiver)
	if(!tap_turf || !receiver_turf)
		return null
	return comms_intercept_direction_text(tap_turf, receiver_turf)

/datum/objective/comms_intercept/proc/get_upload_time(obj/item/comms_intercept_receiver/receiver)
	var/turf/receiver_turf = get_turf(receiver)
	if(!receiver_turf)
		return COMMS_INTERCEPT_UPLOAD_TIME_MAX
	var/closest_distance
	for(var/obj/item/comms_tap/tap as anything in active_taps)
		var/turf/tap_turf = get_turf(tap)
		if(!tap_turf)
			continue
		var/distance = comms_intercept_tap_distance(tap_turf, receiver_turf)
		if(isnull(closest_distance) || distance < closest_distance)
			closest_distance = distance
	return comms_intercept_upload_time(closest_distance)

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

/datum/objective/comms_intercept/proc/on_upload_started(obj/item/comms_intercept_receiver/receiver)
	if(upload_announced)
		return
	upload_announced = TRUE
	var/direction = get_direction_text(receiver)
	transmission_frequency = comms_intercept_pick_frequency()
	add_server_log("Обнаружена исходящая передача перехваченных данных каналов связи. Сигнал уходит от телекоммуникаций [direction || "в неизвестном направлении"]. Побочный сигнал передатчика на частоте [format_frequency(transmission_frequency)].")

/datum/objective/comms_intercept/proc/on_upload_finished()
	upload_done = TRUE
	for(var/obj/item/comms_tap/tap as anything in active_taps)
		var/obj/machinery/telecomms/machine = tap.host
		do_sparks(3, FALSE, machine)
		machine.visible_message(span_warning("[capitalize(machine.declent_ru(NOMINATIVE))] сыплет искрами и гаснет!"))
		machine.emp_act(EMP_HEAVY)

/datum/objective/comms_intercept/proc/on_receiver_destroyed(obj/item/comms_intercept_receiver/receiver)
	// Until the transmission is done the data is still on the tap
	if(disk_ref || is_collected() || receiver_ref?.resolve() != receiver)
		return
	failed = TRUE
	receiver_ref = null

/obj/item/storage/box/syndie_kit/comms_intercept
	name = "comms intercept kit"
	desc = "Коробка с оборудованием для перехвата каналов связи."

/obj/item/storage/box/syndie_kit/comms_intercept/PopulateContents()
	new /obj/item/comms_tap(src)
	new /obj/item/comms_intercept_receiver(src)
	new /obj/item/disk/computer(src)
	new /obj/item/paper/guides/antag/comms_intercept(src)

/obj/item/paper/guides/antag/comms_intercept/Initialize(mapload)
	. = ..()
	// Inline styles are stripped from regular paper text, so this goes in as advanced HTML
	add_raw_text(guide_text(), advanced_html = TRUE)
	update_appearance()

/obj/item/paper/guides/antag/comms_intercept/proc/guide_text()
	var/stage = "style='background:#7a0000;color:#fff;font-weight:bold;padding:5px 8px;margin:18px 0 8px;'"
	var/badge = "style='background:#fff;color:#7a0000;padding:0 7px;margin-right:8px;'"
	var/note = "style='border-left:4px solid #7a0000;background:#f6eaea;padding:6px 10px;margin:8px 0;'"
	var/sub = "style='font-weight:bold;color:#7a0000;border-bottom:1px solid #7a0000;margin:12px 0 4px;'"
	var/table = "style='width:100%;border-collapse:collapse;margin:8px 0;'"
	var/th = "style='background:#2b2b2b;color:#fff;border:1px solid #2b2b2b;padding:4px 6px;text-align:left;'"
	var/td = "style='border:1px solid #999;padding:4px 6px;vertical-align:top;'"
	var/step = "style='border:1px solid #7a0000;padding:6px 4px;width:22%;text-align:center;vertical-align:middle;'"
	var/arrow = "style='border:none;color:#7a0000;width:4%;text-align:center;vertical-align:middle;'"
	return "<div style='border:2px solid #7a0000;padding:10px;'>\
	<div style='text-align:center;'>\[syndie_logo width=120]</div>\
	<div style='background:#7a0000;color:#fff;text-align:center;padding:8px;'>\
	<div style='font-size:20px;font-weight:bold;letter-spacing:1px;'>КРАЖА КЛЮЧЕЙ ШИФРОВАНИЯ</div>\
	<div style='font-size:11px;'>Синдикат &middot; инструкция для исполнителя</div>\
	</div>\
	<p>Нам нужны ключи шифрования станции. Готовых ключей здесь нет, их собирают из переговоров экипажа: жучок слушает каналы, приёмник копит пакеты, а в конце вы записываете их на пустой диск. Диск с дампом надо вывезти.</p>\
	<div [sub]>Снаряжение</div>\
	<table [table]>\
	<tr><th [th]>Есть в наборе</th><th [th]>Достать самому</th></tr>\
	<tr><td [td]>Сетевой жучок<br>Приёмник<br>Пустой диск данных</td><td [td]>Отвёртка<br>Кусачки<br>Гаечный ключ</td></tr>\
	</table>\
	<div [note]>На диск из набора на этапе 3 запишется дамп. Если диск потерялся, подойдёт любой другой пустой диск данных КПК, их печатают в РНД.</div>\
	<div [sub]>План</div>\
	<table style='width:100%;border-collapse:separate;border-spacing:0;margin:8px 0;'><tr>\
	<td [step]><small>Этап 1</small><br><b>Жучок</b></td>\
	<td [arrow]>&#9654;</td>\
	<td [step]><small>Этап 2</small><br><b>Приёмник</b></td>\
	<td [arrow]>&#9654;</td>\
	<td [step]><small>Этап 3</small><br><b>Передача</b><br><small>или</small><br><b>Тихое снятие</b></td>\
	<td [arrow]>&#9654;</td>\
	<td style='background:#7a0000;color:#fff;padding:6px 4px;width:22%;text-align:center;vertical-align:middle;'><small>Этап 4</small><br><b>Эвакуация</b></td>\
	</tr></table>\
	Этапы идут по порядку. На третьем выбираете один из двух способов.\
	<div [stage]><span [badge]>1</span>ЖУЧОК</div>\
	Жучок ставится в машину телекоммуникаций и слышит только те каналы, что идут через неё.\
	<table [table]>\
	<tr><th [th] width='40%'>Машина</th><th [th]>Что слышит</th></tr>\
	<tr><td [td]>Хаб</td><td [td]>Все каналы, сбор быстрее всего.</td></tr>\
	<tr><td [td]>Приёмник, шина, сервер</td><td [td]>Часть каналов, сбор дольше.</td></tr>\
	</table>\
	<div [sub]>Установка</div>\
	<ol>\
	<li><b>Отвёрткой</b> откройте панель машины.</li>\
	<li><b>Кусачками</b> перережьте [COMMS_TAP_SHIELD_WIRES] провода экранирования у служебного разъёма.</li>\
	<li>Вставьте <b>жучок</b>, он сразу начнёт слушать.</li>\
	<li>Закройте панель <b>отвёрткой</b>.</li>\
	</ol>\
	Вся установка занимает секунд двадцать. Если закрыли панель до того, как вставили жучок, провода придётся резать заново.\
	<div [stage]><span [badge]>2</span>ПРИЁМНИК</div>\
	Приёмник собирает пакеты, пока он прикручен к полу, в комнате есть питание и жучок на связи.\
	<div [sub]>Запуск сбора</div>\
	<ol>\
	<li>Найдите на станции комнату с питанием. В самих телекоммуникациях приёмник не работает.</li>\
	<li>Прикрутите приёмник <b>гаечным ключом</b>.</li>\
	<li>На приёмнике должен загореться оранжевый огонёк.</li>\
	<li>Ждите. Сколько собрано, видно при осмотре приёмника.</li>\
	</ol>\
	<div [sub]>Огонёк на приёмнике</div>\
	<table [table]>\
	<tr><th [th] width='32%'>Огонёк</th><th [th]>Что значит</th></tr>\
	<tr><td [td]><span style='color:#e07b00;'>&#9679;</span> <b>Оранжевый</b></td><td [td]>Идёт сбор</td></tr>\
	<tr><td [td]><span style='color:#d4b000;'>&#9679;</span> <b>Жёлтый</b></td><td [td]>Идёт передача</td></tr>\
	<tr><td [td]><span style='color:#2e8b57;'>&#9679;</span> <b>Зелёный</b></td><td [td]>Дамп готов, записывайте</td></tr>\
	<tr><td [td]><span style='color:#999;'>&#9675;</span> <b>Не горит</b></td><td [td]>Приёмник не прикручен, нет питания или нет связи с жучком</td></tr>\
	</table>\
	<div [sub]>Что считается пакетом</div>\
	<ul>\
	<li>Сообщение в канале отдела. Общий канал не шифруется и не в счёт.</li>\
	<li>От одного человека засчитывается не чаще раза в полминуты.</li>\
	<li>Ваши собственные сообщения не в счёт.</li>\
	</ul>\
	<div [note]>Приёмник можно открутить и перенести, собранное не пропадёт.</div>\
	<div [stage]><span [badge]>3</span>ДАМП</div>\
	Пакеты собраны, теперь их нужно записать на пустой диск. Способов два: передача заметнее, а для тихого снятия придётся вернуться в телекоммуникации.\
	<table [table]>\
	<tr><th [th] width='24%'></th><th [th]>Передача</th><th [th]>Тихое снятие</th></tr>\
	<tr><td [td]><b>Где</b></td><td [td]>У приёмника</td><td [td]>У машины с жучком</td></tr>\
	<tr><td [td]><b>Сколько</b></td><td [td]>От 2 до 5 минут. Чем ближе приёмник к жучку, тем быстрее.</td><td [td]>Полминуты</td></tr>\
	<tr><td [td]><b>Что заметят</b></td><td [td]>В журнале серверов появится запись с направлением на приёмник и частотой. В каналах пойдёт хрип, а на радио можно будет поймать сигнал.</td><td [td]>Помехи в каналах жучка, пока снимаете. В журнале ничего не останется.</td></tr>\
	<tr><td [td]><b>Кто может</b></td><td [td]>Запустить можете только вы. Записать готовый дамп может любой, у кого есть пустой диск.</td><td [td]>Только тот, кто ставил жучок</td></tr>\
	</table>\
	<div [sub]>Передача</div>\
	<ol>\
	<li>Нажмите на прикрученный приёмник.</li>\
	<li>Охраняйте его до конца. Если приёмник открутят, обесточат или сломают, передача встанет.</li>\
	<li>Огонёк стал зелёным: приложите к приёмнику пустой диск.</li>\
	</ol>\
	<div [note]>После передачи машину с жучком выбьет импульсом. Готовый дамп в приёмнике без присмотра не оставляйте.</div>\
	<div [sub]>Тихое снятие</div>\
	<ol>\
	<li>Вернитесь к машине с жучком и откройте панель <b>отвёрткой</b>.</li>\
	<li>Приложите к машине <b>пустой диск</b>.</li>\
	<li>Стойте рядом, пока дамп не запишется. Если прервут, придётся начинать заново.</li>\
	</ol>\
	<div [stage]><span [badge]>4</span>ЭВАКУАЦИЯ</div>\
	Задание выполнено, если вы улетели со станции живым и с дампом.\
	<ul>\
	<li>Держите дамп при себе до отлёта.</li>\
	<li>Дамп можно приложить к гарнитуре, и она получит все каналы отделов. Сам дамп останется у вас.</li>\
	<li>Если поменять в гарнитуре ключ шифрования, каналы пропадут.</li>\
	</ul>\
	<div [stage]><span [badge]>!</span>ЕСЛИ ЧТО-ТО ПОШЛО НЕ ТАК</div>\
	<table [table]>\
	<tr><th [th] width='38%'>Что случилось</th><th [th]>Что делать</th></tr>\
	<tr><td [td]>Огонёк не загорелся</td><td [td]>Проверьте, что приёмник прикручен и в комнате есть питание. Если всё так, проверьте, что жучок вставлен, а машина включена.</td></tr>\
	<tr><td [td]>Огонёк погас во время сбора</td><td [td]>Жучок сняли или заглушили, или выключили машину. Сходите проверьте. После импульса жучок сам оживёт через пару минут.</td></tr>\
	<tr><td [td]>Жучок потерян</td><td [td]>Запасной есть в аплинке. Собранное никуда не денется.</td></tr>\
	<tr><td [td]>Пустого диска нет</td><td [td]>Подойдёт любой пустой диск данных КПК. Его печатают в РНД, а с занятого диска можно удалить файлы в КПК.</td></tr>\
	<tr><td [td]>Приёмник попал под импульс во время передачи</td><td [td]>Передача начнётся сначала. Подождите минуту и запустите снова.</td></tr>\
	<tr><td [td]>Приёмник потерян после сбора</td><td [td]>Остаётся тихое снятие.</td></tr>\
	<tr><td [td]>Приёмник сломали до конца сбора или с дампом внутри</td><td [td]><b style='color:#7a0000;'>Задание провалено.</b></td></tr>\
	</table>\
	<div [note]><b>Не тяните.</b> Чем дольше идёт перехват, тем больше записей в журнале серверов. На трёх четвертях сбора капитан, главный инженер и директор исследований получат сообщение на КПК, и жучок с приёмником начнут искать.</div>\
	<div style='text-align:center;font-size:11px;font-weight:bold;letter-spacing:2px;color:#7a0000;border-top:2px solid #7a0000;margin-top:14px;padding-top:6px;'>ПОСЛЕ ПРОЧТЕНИЯ УНИЧТОЖИТЬ</div>\
	</div>"

/datum/uplink_item/special_equipment/comms_tap
	name = "Spare Network Bug"
	desc = "Запасной сетевой жучок для перехвата каналов связи."
	item = /obj/item/comms_tap
	cost = 2
	limited_stock = 2
	restricted = TRUE
	purchasable_from = NONE // handed out through extra_purchasable

/proc/is_comms_dump_carrier(obj/item/tool, mob/living/user, atom/target)
	if(!istype(tool, /obj/item/disk/computer))
		return FALSE
	var/obj/item/disk/computer/disk = tool
	if(length(disk.stored_files))
		target.balloon_alert(user, "диск не пуст!")
		return FALSE
	return TRUE

/obj/item/disk/comms_intercept
	name = "encryption key dump"
	desc = "Носитель с перехваченными ключами шифрования каналов отделов. Подключите к гарнитуре, чтобы получить доступ ко всем каналам."
	icon_state = "datadisk8"

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
	if(!headset.get_listening())
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
	desc = "Крохотный модуль с парой контактов-зажимов."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "suit_sensor"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/telecomms/host
	/// Only the installer can pull the dump off it
	var/datum/weakref/installer_ref
	var/offline_until = 0
	/// Heard traffic while packets were still being collected, so it has a dump to hand over
	var/has_data = FALSE
	var/extracting = FALSE

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
	if(machine.tap_shield_wires > 0)
		balloon_alert(user, "мешает экранирование!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "подключение...")
	if(!do_after(user, COMMS_TAP_INSERT_TIME, machine) || !machine.panel_open || machine.tap_shield_wires > 0 || loc != user || (locate(/obj/item/comms_tap) in machine))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(src, machine))
		return ITEM_INTERACT_BLOCKING
	installer_ref = WEAKREF(user.mind)
	attach(machine)
	balloon_alert(user, "жучок подключён")
	to_chat(user, span_notice("Жучок подключён и слушает каналы: [jointext(comms_intercept_channel_names(machine), ", ")]. Панель лучше закрыть отвёрткой."))
	return ITEM_INTERACT_SUCCESS

/obj/item/comms_tap/proc/attach(obj/machinery/telecomms/machine)
	host = machine
	RegisterSignal(host, COMSIG_TELECOMMS_RELAY_INFORMATION, PROC_REF(on_relay))
	RegisterSignal(host, COMSIG_ATOM_EMP_ACT, PROC_REF(on_host_emp))
	RegisterSignal(host, COMSIG_QDELETING, PROC_REF(on_host_deleted))
	update_active()

/obj/item/comms_tap/proc/detach()
	if(!host)
		return
	UnregisterSignal(host, list(COMSIG_TELECOMMS_RELAY_INFORMATION, COMSIG_ATOM_EMP_ACT, COMSIG_QDELETING))
	host = null
	installer_ref = null
	update_active()

/obj/item/comms_tap/proc/update_active()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective)
		return
	if(host)
		objective.active_taps |= src
	else
		objective.active_taps -= src

/obj/item/comms_tap/proc/is_listening()
	return host?.on && world.time >= offline_until

/obj/item/comms_tap/proc/on_relay(datum/source, datum/signal/subspace/signal)
	SIGNAL_HANDLER
	if(!istype(signal, /datum/signal/subspace/vocal) || !(signal.frequency in comms_intercept_frequencies()) || !signal.data["message"])
		return
	// Pulling the dump off the board drowns the tapped channels in static
	if(extracting)
		signal.data["message"] = Gibberish(signal.data["message"], TRUE, 100)
		return
	if(!is_listening())
		return
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective)
		return
	if(objective.messages_collected < objective.target_amount)
		has_data = TRUE
	objective.on_intercepted_message(signal)

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

/obj/item/comms_intercept_receiver
	name = "intercept receiver"
	desc = "Переносной приёмник с откидной антенной и болтами для крепления к полу."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "supplypod_beacon"
	w_class = WEIGHT_CLASS_SMALL
	var/emp_until = 0
	var/uploading = FALSE
	var/status = COMMS_RECEIVER_OFF
	var/area/loaded_area

/obj/item/comms_intercept_receiver/Destroy()
	STOP_PROCESSING(SSobj, src)
	loaded_area?.removeStaticPower(COMMS_INTERCEPT_RECEIVER_LOAD, AREA_USAGE_STATIC_EQUIP)
	loaded_area = null
	GLOB.comms_intercept?.on_receiver_destroyed(src)
	return ..()

/obj/item/comms_intercept_receiver/atom_destruction(damage_flag)
	new /obj/item/comms_intercept_receiver_debris(drop_location())
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
	if(!uploading && objective.is_collected() && user.mind == objective.owner)
		. += span_notice("Пакеты собраны. Запустите передачу, нажав на закреплённый приёмник, или снимите дамп с жучка на пустой диск.")
	if(uploading)
		var/upload_time = objective.get_upload_time(src)
		var/time_left = max(upload_time - objective.upload_progress, 0)
		. += span_notice("Передача: [round(min(objective.upload_progress * 100 / upload_time, 100))]%, осталось: [DisplayTimeText(time_left, 1)].")
	if(objective.upload_done && !objective.disk_ref)
		. += span_notice("Передача завершена, дамп ключей шифрования готов к записи на пустой диск.")
	if(!anchored)
		. += span_notice("Приёмник можно закрепить [EXAMINE_HINT("гаечным ключом")].")

/// Anyone with an empty disk can write the dump, so security can seize it too
/obj/item/comms_intercept_receiver/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/disk/computer) || !GLOB.comms_intercept?.upload_done)
		return ..()
	var/obj/item/disk/computer/disk = tool
	if(!is_comms_dump_carrier(disk, user, src))
		return ITEM_INTERACT_BLOCKING
	if(!can_write_dump())
		balloon_alert(user, "нет готовых данных!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "запись...")
	if(!do_after(user, 3 SECONDS, src) || !can_write_dump() || disk.loc != user || length(disk.stored_files))
		return ITEM_INTERACT_BLOCKING
	GLOB.comms_intercept.write_dump(user, disk)
	balloon_alert(user, "дамп записан")
	update_status()
	return ITEM_INTERACT_SUCCESS

/obj/item/comms_intercept_receiver/proc/can_write_dump()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	return objective?.upload_done && !objective.disk_ref && objective.receiver_ref?.resolve() == src

/obj/item/comms_intercept_receiver/attack_hand(mob/user, list/modifiers)
	if(try_start_upload(user))
		return TRUE
	return ..()

/// Only the traitor starts it, the crew poking a found receiver shouldn't do their job for them
/obj/item/comms_intercept_receiver/proc/try_start_upload(mob/user)
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(uploading || !objective?.is_collected() || !user.mind || user.mind != objective.owner || !can_receive())
		return FALSE
	start_upload()
	balloon_alert(user, "передача запущена")
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
		// Tap and area power changes don't signal the receiver, so poll while anchored
		START_PROCESSING(SSobj, src)
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
	if(uploading)
		return COMMS_RECEIVER_UPLOADING
	return objective.has_listening_tap() ? COMMS_RECEIVER_ONLINE : COMMS_RECEIVER_NO_SIGNAL

/obj/item/comms_intercept_receiver/proc/update_status()
	var/new_status = get_status()
	if(new_status == status)
		return
	status = new_status
	update_load()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/comms_intercept_receiver/proc/update_load()
	var/area/new_area = status == COMMS_RECEIVER_UPLOADING ? get_area(src) : null
	if(new_area == loaded_area)
		return
	loaded_area?.removeStaticPower(COMMS_INTERCEPT_RECEIVER_LOAD, AREA_USAGE_STATIC_EQUIP)
	new_area?.addStaticPower(COMMS_INTERCEPT_RECEIVER_LOAD, AREA_USAGE_STATIC_EQUIP)
	loaded_area = new_area

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
	if(!uploading)
		return anchored ? NONE : PROCESS_KILL
	if(!can_receive())
		return
	objective.on_upload_started(src)
	objective.upload_progress += seconds_per_tick SECONDS
	if(objective.upload_progress < objective.get_upload_time(src))
		return
	uploading = FALSE
	objective.on_upload_finished()
	update_status()
	return PROCESS_KILL

/obj/item/comms_intercept_receiver_debris
	name = "broken intercept receiver"
	desc = "Оплавленный корпус приёмника с обломанной антенной. Восстановлению не подлежит."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "supplypod_beacon"
	color = COLOR_DARK
	w_class = WEIGHT_CLASS_SMALL

/obj/item/radio/examine(mob/user)
	. = ..()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!objective?.transmission_frequency || get_frequency() != objective.transmission_frequency)
		return
	var/obj/item/comms_intercept_receiver/receiver = objective.receiver_ref?.resolve()
	var/turf/radio_turf = get_turf(src)
	var/turf/receiver_turf = get_turf(receiver)
	if(receiver?.status != COMMS_RECEIVER_UPLOADING || !radio_turf || !receiver_turf)
		return
	. += span_warning("Из динамика доносится [comms_intercept_static_text(comms_intercept_tap_distance(radio_turf, receiver_turf))].")

/obj/machinery/telecomms
	/// Reset when the panel closes
	var/tap_shield_wires = COMMS_TAP_SHIELD_WIRES

/obj/machinery/telecomms/on_set_panel_open(old_value)
	. = ..()
	if(!panel_open)
		tap_shield_wires = COMMS_TAP_SHIELD_WIRES

/obj/machinery/telecomms/examine(mob/user)
	. = ..()
	if(!panel_open)
		return
	if(locate(/obj/item/comms_tap) in src)
		. += span_warning("К служебному разъёму подключён посторонний модуль!")
		return
	// Don't teach the crew how to install one
	if(!is_comms_tappable(src) || !(locate(/obj/item/comms_tap) in user.get_all_contents()))
		return
	if(tap_shield_wires > 0)
		. += span_notice("Служебный разъём закрыт экранированием, проводов: [tap_shield_wires]. Их можно перерезать [EXAMINE_HINT("кусачками")]. Каналы: [jointext(comms_intercept_channel_names(src), ", ")].")
	else
		. += span_notice("Служебный разъём открыт, можно вставить жучок.")

/// Quiet extraction, only the installer can pull the dump off the tap
/obj/machinery/telecomms/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/comms_tap/tap = locate() in src
	if(!istype(tool, /obj/item/disk/computer) || !panel_open || !tap)
		return ..()
	var/datum/objective/comms_intercept/objective = GLOB.comms_intercept
	if(!user.mind || tap.installer_ref?.resolve() != user.mind || !objective?.is_collected())
		return ..()
	if(!is_comms_dump_carrier(tool, user, src))
		return ITEM_INTERACT_BLOCKING
	if(!tap.has_data)
		balloon_alert(user, "на жучке нет данных!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "снятие дампа...")
	tap.extracting = TRUE
	var/extracted = do_after(user, COMMS_INTERCEPT_EXTRACT_TIME, src)
	tap.extracting = FALSE
	var/obj/item/disk/computer/disk = tool
	if(!extracted || !panel_open || QDELETED(tap) || tap.loc != src || disk.loc != user || length(disk.stored_files) || !objective.is_collected())
		return ITEM_INTERACT_BLOCKING
	objective.extract_from_tap(tap, user, disk)
	balloon_alert(user, "дамп снят с жучка")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/telecomms/wirecutter_act(mob/living/user, obj/item/tool)
	if(!panel_open || tap_shield_wires <= 0 || !is_comms_tappable(src) || (locate(/obj/item/comms_tap) in src))
		return NONE
	if(!(locate(/obj/item/comms_tap) in user.get_all_contents()))
		return NONE
	to_chat(user, span_notice("Вы начинаете перерезать провода экранирования, осталось: [tap_shield_wires]."))
	while(tool.use_tool(src, user, COMMS_TAP_WIRE_TIME, volume = 50))
		if(!panel_open || tap_shield_wires <= 0)
			return ITEM_INTERACT_BLOCKING
		tap_shield_wires--
		if(tap_shield_wires <= 0)
			balloon_alert(user, "разъём открыт")
			to_chat(user, span_notice("Последний провод перерезан. Вставьте жучок."))
			break
		to_chat(user, span_notice("Провод перерезан, осталось: [tap_shield_wires]."))
	return ITEM_INTERACT_SUCCESS

#undef COMMS_INTERCEPT_PROB
#undef COMMS_INTERCEPT_MIN_CREW
#undef COMMS_INTERCEPT_MESSAGES_PER_CREW
#undef COMMS_INTERCEPT_SPEAKER_COOLDOWN
#undef COMMS_INTERCEPT_MIN_MESSAGES
#undef COMMS_INTERCEPT_MAX_MESSAGES
#undef COMMS_INTERCEPT_UPLOAD_TIME_MIN
#undef COMMS_INTERCEPT_UPLOAD_TIME_MAX
#undef COMMS_INTERCEPT_UPLOAD_FAR_DISTANCE
#undef COMMS_INTERCEPT_Z_LEVEL_DISTANCE
#undef COMMS_INTERCEPT_LOGS_PERCENT
#undef COMMS_INTERCEPT_DIRECTION_PERCENT
#undef COMMS_INTERCEPT_LOG_EVERY
#undef COMMS_INTERCEPT_DIRECTION_EVERY
#undef COMMS_INTERCEPT_TAP_EMP_TIME
#undef COMMS_INTERCEPT_RECEIVER_EMP_TIME
#undef COMMS_INTERCEPT_EXTRACT_TIME
#undef COMMS_INTERCEPT_MAX_LOG_ENTRIES
#undef COMMS_INTERCEPT_RECEIVER_LOAD
#undef COMMS_INTERCEPT_STATIC_NEAR
#undef COMMS_INTERCEPT_STATIC_FAR
#undef COMMS_RECEIVER_OFF
#undef COMMS_RECEIVER_ONLINE
#undef COMMS_RECEIVER_UPLOADING
#undef COMMS_RECEIVER_DONE
#undef COMMS_RECEIVER_NO_SIGNAL
#undef COMMS_TAP_SHIELD_WIRES
#undef COMMS_TAP_WIRE_TIME
#undef COMMS_TAP_INSERT_TIME
