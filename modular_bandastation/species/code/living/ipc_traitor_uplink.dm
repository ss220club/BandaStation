// ============================================
// АПЛИНК ТРЕЙТОРА — СПОСОБНОСТИ IPC
// ============================================
// Взлом дверей — слишком сильная способность для рандомного раунда.
// Доступна только антагам-КПБ через аплинк синдиката.

/datum/uplink_item/species_restricted/ipc_hack
	name = "HACK.EXE — Модуль взлома дверей"
	desc = "Программный модуль синдиката для позитронного ядра. После загрузки в ОС — \
		активирует режим взлома: КПБ может вскрывать заблокированные двери электронным способом. \
		Взлом занимает 20 секунд и требует 250 единиц заряда батареи. \
		Не работает на заваренных и забальтованных дверях."
	cost = 4
	item = null
	surplus = 0
	purchasable_from = UPLINK_TRAITORS
	restricted_species = list(SPECIES_IPC)
	uplink_item_flags = SYNDIE_ILLEGAL_TECH  // нет физического предмета, не триггерит детектор

/datum/uplink_item/species_restricted/ipc_hack/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	log_uplink("[key_name(user)] purchased [src] for [cost] telecrystals from [source]'s uplink")
	user.playsound_local(get_turf(user), 'sound/effects/kaching.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	if(purchase_log_vis && uplink_handler.purchase_log)
		uplink_handler.purchase_log.LogPurchase(null, src, cost)

	var/mob/living/carbon/human/H = user
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		to_chat(user, span_warning("HACK.EXE: Модуль несовместим с вашей архитектурой."))
		return

	// Проверяем — не куплен ли уже
	if(locate(/datum/action/cooldown/ipc_hack) in H.actions)
		to_chat(H, span_warning("HACK.EXE: Модуль уже загружен в систему."))
		return

	var/datum/action/cooldown/ipc_hack/hack = new()
	hack.Grant(H)
	to_chat(H, span_boldnotice("HACK.EXE: Модуль взлома дверей успешно загружен и активирован."))
