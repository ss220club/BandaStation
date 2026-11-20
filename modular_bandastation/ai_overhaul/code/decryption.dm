/** Хранит прогресс обработки и одноразовую научную награду независимо от сервера. */
/obj/item/disk/ai_research_archive
	name = "damaged neural research archive"
	desc = "Восстанавливаемый архив исследований нейронного оборудования. Вставьте его в серверный шкаф ИИ и запустите восстановление через консоль ресурсов."
	/// Отмечает уже обработанный архив и защищает награду от повторной выдачи.
	var/decrypted = FALSE
	/// Уже вложенная в архив вычислительная работа в CPU-секундах.
	var/decryption_progress = 0
	/// Работа в CPU-секундах, необходимая для обработки архива.
	var/decryption_cost = 60
	/// Одноразовая награда архива в очках инфраструктуры ИИ.
	var/research_reward = 120

/obj/item/disk/ai_research_archive/examine(mob/user)
	. = ..()
	. += span_notice(decrypted ? "Исследования уже получены. Этот архив не может повторно выдать очки." : "Восстановлено: [round(decryption_progress, 0.1)] / [decryption_cost] CPU·с. Однократно выдаёт [research_reward] очков исследований ИИ.")

/** Объединяет установленные модули, питание и тепловое ограничение вычислительной мощности. */
/obj/machinery/ai/server_cabinet
	/// Физически установленный архив исследований.
	var/obj/item/disk/ai_research_archive/decryption_disk
	/// Разрешает выделять фоновый CPU установленному архиву.
	var/decryption_enabled = FALSE

/** Устанавливает архив в свободный слот сервера при физическом доступе пользователя. */
/obj/machinery/ai/server_cabinet/proc/insert_encrypted_disk(mob/living/user, obj/item/disk/ai_research_archive/disk)
	if(decryption_disk || disk.decrypted || panel_open || !user.transferItemToLoc(disk, src))
		return ITEM_INTERACT_BLOCKING
	decryption_disk = disk
	decryption_enabled = FALSE
	balloon_alert(user, "диск вставлен; используйте консоль ресурсов")
	return ITEM_INTERACT_SUCCESS

/** Останавливает обработку и извлекает архив с сохранением его прогресса. */
/obj/machinery/ai/server_cabinet/proc/eject_decryption_disk()
	decryption_enabled = FALSE
	if(!decryption_disk)
		return
	decryption_disk.forceMove(drop_location())
	decryption_disk = null

/obj/machinery/ai/server_cabinet/multitool_act(mob/living/user, obj/item/tool)
	if(!decryption_disk)
		return ..()
	eject_decryption_disk()
	balloon_alert(user, "диск извлечён")
	return ITEM_INTERACT_SUCCESS

/** Проверяет готовность сервера и наличие незавершённого архива для фоновой обработки. */
/obj/machinery/ai/server_cabinet/proc/can_decrypt_disk()
	return decryption_disk && !QDELETED(decryption_disk) && decryption_disk.loc == src && !decryption_disk.decrypted && ai_station_techweb(src) && can_run_background_research()

/** Вкладывает cpu_seconds вычислительной работы в архив и однократно выдаёт награду. */
/obj/machinery/ai/server_cabinet/proc/process_decryption(cpu_seconds)
	if(!decryption_enabled || !can_decrypt_disk() || !isnum(cpu_seconds) || cpu_seconds <= 0)
		return
	decryption_disk.decryption_progress = min(decryption_disk.decryption_cost, decryption_disk.decryption_progress + cpu_seconds)
	if(decryption_disk.decryption_progress < decryption_disk.decryption_cost)
		return
	if(!decryption_disk.recover_research())
		return
	visible_message(span_notice("[declent_ru(NOMINATIVE)] восстанавливает [decryption_disk.research_reward] очков исследований ИИ и извлекает использованный архив."))
	eject_decryption_disk()

/** Возвращает серверы сети с готовыми к выполнению заданиями обработки архивов. */
/datum/ai_network/proc/decryption_jobs()
	var/list/jobs = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet in nodes)
		if(cabinet.decryption_enabled && cabinet.can_decrypt_disk())
			jobs += cabinet
	return jobs


/** Перечисляет награду архива в местную базу исследований не более одного раза. */
/obj/item/disk/ai_research_archive/proc/recover_research()
	var/datum/techweb/science = ai_station_techweb(src)
	if(decrypted || decryption_progress < decryption_cost || !science)
		return FALSE
	decrypted = TRUE
	name = "spent neural research archive"
	science.adjust_multiple_points(list(TECHWEB_POINT_TYPE_AI = research_reward))
	return TRUE
