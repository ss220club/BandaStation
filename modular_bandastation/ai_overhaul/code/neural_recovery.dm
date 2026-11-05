/** Сохраняет исходные mob и mind на аварийном носителе после потери всех доступных ядер. */
/mob/living/silicon/ai/proc/preserve_neural_state()
	RETURN_TYPE(/obj/item/ai_neural_backup)
	if(!decentralized || stat != DEAD || HAS_TRAIT(src, TRAIT_SUICIDED) || (!isturf(loc) && !istype(loc, /obj/machinery/ai/data_core)))
		return null
	var/turf/home = get_turf(src)
	if(!home)
		return null
	return new /obj/item/ai_neural_backup(home, src)

/** Временно сохраняет исходного ИИ и mind для вычислительного восстановления в ядре. */
/obj/item/ai_neural_backup
	name = "volatile neural core"
	desc = "Аварийный нейронный накопитель (Volatile Neural Core). Вставьте его в рабочее ядро ИИ и запустите восстановление через консоль ресурсов. Без рабочего ядра батарея разрядится, и сохранённый интеллект будет безвозвратно потерян."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard-404"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	color = "#73d7db"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Исходный ИИ вместе с mind, сохраняемый аварийным носителем.
	var/mob/living/silicon/ai/stored_ai
	/// Оставшееся время автономного сохранения в децисекундах.
	var/battery_remaining = AI_BACKUP_LIFETIME
	/// Уже вложенная в восстановление работа в CPU-секундах.
	var/processing_progress = 0
	/// Разрешает фоновое восстановление при установке носителя в готовое ядро.
	var/recovery_enabled = FALSE
	/// Предотвращает повторное предупреждение об остатке питания носителя.
	var/warned_low_battery = FALSE
	/// Разрешение на карту до аварии, восстанавливаемое после возврата в ядро.
	var/previous_card_permission = TRUE

/obj/item/ai_neural_backup/Initialize(mapload, mob/living/silicon/ai/ai)
	. = ..()
	if(QDELETED(ai) || !ai.decentralized || !ai.dashboard || ai.stat != DEAD || istype(ai.loc, /obj/item/ai_neural_backup))
		return INITIALIZE_HINT_QDEL
	stored_ai = ai
	previous_card_permission = ai.can_be_carded
	ai.can_be_carded = FALSE
	ai.ai_network?.resources.remove_ai(ai)
	ai.ai_network = null
	ai.set_control_disabled(TRUE)
	ai.radio_enabled = FALSE
	ai.dashboard.telemetry_log.recording = FALSE
	for(var/datum/ai_project/project as anything in LAZYCOPY(ai.dashboard.running_projects))
		ai.dashboard.stop_project(project)
	ai.forceMove(src)
	name = "volatile neural core ([ai.real_name])"
	ru_names_rename(ru_names_toml(initial(name), suffix = " ([ai.real_name])", override_base = initial(name)))
	START_PROCESSING(SSobj, src)
	to_chat(ai, span_notice("Аварийный накопитель активен. Исходную нейроструктуру можно восстановить в рабочем ядре ИИ. Без питания накопитель хранит данные [AI_BACKUP_LIFETIME / (1 MINUTES)] минут."))

/obj/item/ai_neural_backup/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(stored_ai?.loc == src)
		QDEL_NULL(stored_ai)
	stored_ai = null
	return ..()

/obj/item/ai_neural_backup/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == stored_ai)
		stored_ai.can_be_carded = previous_card_permission
		stored_ai = null
		recovery_enabled = FALSE

/** Возвращает готовое ядро, в котором физически установлен этот носитель. */
/obj/item/ai_neural_backup/proc/recovery_host()
	RETURN_TYPE(/obj/machinery/ai/data_core)
	var/obj/machinery/ai/data_core/core = loc
	if(!istype(core) || QDELETED(core) || core.neural_backup != src || !core.can_transfer_ai())
		return null
	return core

/** Проверяет наличие исходного ИИ и оставшееся время сохранения носителя. */
/obj/item/ai_neural_backup/proc/valid_payload()
	return !QDELETED(stored_ai) && stored_ai.loc == src && stored_ai.stat == DEAD && !HAS_TRAIT(stored_ai, TRAIT_SUICIDED) && battery_remaining > 0

/obj/item/ai_neural_backup/process(seconds_per_tick)
	if(QDELETED(stored_ai) || stored_ai.loc != src)
		return PROCESS_KILL
	if(recovery_host())
		return
	battery_remaining = max(0, battery_remaining - seconds_per_tick * (1 SECONDS))
	if(!warned_low_battery && battery_remaining <= AI_BACKUP_LIFETIME / 2)
		warned_low_battery = TRUE
		visible_message(span_warning("[declent_ru(NOMINATIVE)] подаёт сигнал: заряд аварийной батареи ниже 50%."))
	if(battery_remaining <= 0)
		visible_message(span_danger("Батарея [declent_ru(GENITIVE)] разрядилась. Нейроструктура потеряна."))
		qdel(src)

/obj/item/ai_neural_backup/examine(mob/user)
	. = ..()
	. += span_notice("Осталось хранения без питания: [round(battery_remaining / (1 SECONDS))] с. Восстановлено: [round(processing_progress, 0.1)] / [AI_BACKUP_CPU_COST] CPU·с.")
	if(recovery_host())
		. += span_notice("Внешнее питание сохраняет данные. Начать или приостановить восстановление можно через консоль ресурсов.")

/** Восстанавливает исходного ИИ в рабочем ядре после завершения вычислительной обработки. */
/obj/item/ai_neural_backup/proc/finish_recovery()
	var/obj/machinery/ai/data_core/core = recovery_host()
	if(!core || !valid_payload() || processing_progress < AI_BACKUP_CPU_COST)
		return FALSE
	var/mob/living/silicon/ai/ai = stored_ai
	if(!core.transfer_AI(ai, from_recovery = TRUE))
		return FALSE
	if(!ai.revive(HEAL_DAMAGE, force_grab_ghost = FALSE))
		stored_ai = ai
		ai.can_be_carded = FALSE
		ai.set_control_disabled(TRUE)
		ai.radio_enabled = FALSE
		ai.ai_network?.resources.remove_ai(ai)
		ai.ai_network = null
		ai.forceMove(src)
		return FALSE
	GLOB.shuttle_caller_list |= ai
	core.visible_message(span_notice("[core.declent_ru(NOMINATIVE)] завершает восстановление нейроструктуры."))
	to_chat(ai, span_notice("Нейроструктура восстановлена. Законы и изученные проекты сохранены. Для возобновления программ запросите CPU и RAM."))
	qdel(src)
	return TRUE

/obj/machinery/ai/data_core
	/// Физически установленный аварийный носитель ИИ.
	var/obj/item/ai_neural_backup/neural_backup

/** Устанавливает действительный аварийный носитель в свободный слот ядра. */
/obj/machinery/ai/data_core/proc/insert_neural_backup(mob/living/user, obj/item/ai_neural_backup/backup)
	if(neural_backup || !backup.valid_payload() || !can_transfer_ai())
		balloon_alert(user, "разъём восстановления недоступен!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(backup, src))
		return ITEM_INTERACT_BLOCKING
	neural_backup = backup
	backup.recovery_enabled = FALSE
	to_chat(user, span_notice("Аварийный накопитель подключён. Запустите восстановление через консоль ресурсов ИИ; будет использован свободный CPU сети."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/multitool_act(mob/living/user, obj/item/tool)
	if(!neural_backup)
		return ..()
	neural_backup.forceMove(drop_location())
	balloon_alert(user, "нейронный накопитель извлечён")
	return ITEM_INTERACT_SUCCESS

