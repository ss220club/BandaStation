/** Добавляет штатному ИИ личные проекты и привязку к физической нейросети. */
/mob/living/silicon/ai
	/// Личная панель проектов владельца ИИ.
	var/datum/ai_dashboard/dashboard
	/// Отмечает ИИ, обслуживаемого физическими ядрами и нейросетью модуля.
	var/decentralized = FALSE
	/// Согласие ИИ на выгрузку через карту и служебные консоли.
	var/can_download = TRUE
	/// Множитель скорости выгрузки, изменяемый защитным проектом.
	var/download_speed_modifier = 1
	/// Множитель личных исследований; не повышает доход майнинга.
	var/research_point_booster = 1
	/// Разрешает подробный осмотр людей после запуска соответствующего проекта.
	var/can_examine_humans = FALSE
	/// Отмечает потерю питания ядра при сохранённом ИИ.
	var/technically_unpowered = FALSE
	/// Отмечает аварийный поиск рабочего ядра до сохранения на носителе.
	var/is_dying = FALSE
	/// Срок завершения аварийного поиска в отсчётах world.time.
	var/recovery_deadline = 0
	/// Последнее ядро для аварийного размещения и местных уведомлений.
	var/obj/machinery/ai/data_core/last_used_data_core

/** Размещает станционного ИИ в физическом ядре и назначает свободные ресурсы сети. */
/mob/living/silicon/ai/proc/initialize_decentralized_ai()
	var/turf/home = get_turf(src)
	if(!home || !ai_supported_location(home))
		return
	var/obj/machinery/ai/data_core/core
	if(istype(loc, /obj/machinery/ai/data_core))
		core = loc
	else if(isturf(loc))
		core = locate() in home
		if(!core)
			core = new /obj/machinery/ai/data_core/primary(home)
	else
		return
	if(!core.transfer_AI(src))
		return
	var/datum/ai_os/pool = resource_pool()
	pool.set_cpu(src, max(0, 1 - pool.total_cpu_assigned()))
	pool.set_ram(src, max(0, pool.total_ram - pool.total_ram_assigned()))

/** Однократно создаёт личные проекты и действия распределённого ИИ. */
/mob/living/silicon/ai/proc/setup_decentralized_ai()
	if(decentralized)
		return
	decentralized = TRUE
	dashboard = new(src)
	acceleration = FALSE
	var/datum/action/innate/ai_dashboard/open_dashboard = new
	open_dashboard.Grant(src)
	ASSIGN_GAME_VERB(src, /mob/living/silicon/ai, toggle_download)

/** Освобождает назначения и удаляет личные служебные объекты ИИ. */
/mob/living/silicon/ai/proc/destroy_decentralized_ai()
	release_neural_resources()
	GLOB.ai_os.remove_ai(src)
	QDEL_NULL(dashboard)
	QDEL_NULL(neural_law_view)
	last_used_data_core = null

/** Снимает CPU и RAM прежней сети, очищает связь с ней и обновляет охлаждение. */
/mob/living/silicon/ai/proc/release_neural_resources()
	var/datum/ai_os/previous_pool = ai_network?.resources
	previous_pool?.remove_ai(src)
	ai_network = null
	previous_pool?.refresh_cooling()

/mob/living/silicon/ai/run_examinate(atom/target, force_examinate_more = FALSE)
	if(decentralized && !can_examine_humans && ishuman(target))
		to_chat(src, span_notice("Обнаружен человек. Для подробного анализа нужно исследовать «Расширенный осмотр»."))
		return
	return ..()

GAME_VERB_DESC(/mob/living/silicon/ai, toggle_download, "Разрешить выгрузку", "Разрешить или запретить выгрузку через консоли управления ИИ.", "AI Commands")
	if(incapacitated)
		return
	can_download = !can_download
	to_chat(src, span_notice("Удалённая выгрузка [can_download ? "разрешена" : "запрещена"]."))

/** Открывает личную панель ресурсов и проектов ИИ. */
/datum/action/innate/ai_dashboard
	name = "Нейронная панель ИИ"
	desc = "Управление нейронными проектами, памятью и вычислительными ресурсами."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/ai_dashboard/Activate()
	var/mob/living/silicon/ai/ai = owner
	ai.dashboard?.ui_interact(ai)

/** Ищет готовое ядро в доступной ИИ сети, не пересекая границу лаборатории. */
/proc/available_ai_cores(mob/living/silicon/ai/ai, atom/source)
	RETURN_TYPE(/obj/machinery/ai/data_core)
	SSai_networks.rebuild()
	if(ai?.decentralized && !ai.ai_network)
		return null
	var/obj/machinery/ai/data_core/primary = GLOB.primary_data_core
	if(!QDELETED(primary) && ai_same_debug_environment(ai || source, primary) && (!ai?.ai_network || primary.ai_network == ai.ai_network) && primary.can_transfer_ai())
		return primary
	for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores)
		if(!QDELETED(core) && ai_same_debug_environment(ai || source, core) && (!ai?.ai_network || core.ai_network == ai.ai_network) && core.can_transfer_ai())
			return core

/** Пытается перенести ИИ в доступное ядро; kill_otherwise разрешает штатную гибель при неудаче. */
/mob/living/silicon/ai/proc/relocate(silent = FALSE, kill_otherwise = TRUE)
	var/obj/machinery/ai/data_core/destination = available_ai_cores(src)
	if(destination)
		if(!silent)
			to_chat(src, span_warning("Ядро недоступно. Перенаправление в [ai_localized_area(destination, ACCUSATIVE)]."))
		return destination.transfer_AI(src)
	if(kill_otherwise && !is_dying)
		is_dying = TRUE
		recovery_deadline = world.time + 10 SECONDS
		to_chat(src, span_userdanger("Все ядра ИИ отключены. Восстановите одно из ядер за 10 секунд, чтобы предотвратить отключение!"))
	return FALSE

/** Обрабатывает питание, аварийный поиск ядра и личные проекты за seconds_per_tick секунд. */
/mob/living/silicon/ai/proc/process_decentralized_ai(seconds_per_tick)
	if(!decentralized)
		return FALSE
	dashboard?.telemetry_log.observe(src)
	if(istype(loc, /obj/item) || istype(loc, /obj/vehicle) || istype(loc, /obj/machinery/power/apc))
		is_dying = FALSE
		return FALSE
	var/obj/machinery/ai/data_core/core = loc
	if(!istype(core) || !core.valid_data_core(src))
		if(!relocate(silent = is_dying))
			if(is_dying && world.time >= recovery_deadline)
				adjust_oxy_loss(200)
				death()
				preserve_neural_state()
			return TRUE
	if(QDELETED(eyeobj) || !eyeobj.loc)
		view_core()
	process_camera_memory(seconds_per_tick)
	dashboard?.tick(seconds_per_tick)
	return TRUE

/** Проверяет физическое размещение ИИ в ядре, сохраняя совместимость со штатным ИИ на клетке. */
/mob/living/silicon/ai/proc/in_network_core()
	return isturf(loc) || istype(loc, /obj/machinery/ai/data_core)
