/** Возвращает подходящий модуль в активной руке оператора либо null. */
/datum/computer_file/program/neural_service/proc/held_upgrade(mob/user)
	RETURN_TYPE(/obj/item/ai_module)
	var/obj/item/ai_module/module = user.get_active_held_item()
	return (istype(module, /obj/item/ai_module/upgrade) || istype(module, /obj/item/ai_module/combat)) ? module : null

/** Проверяет физический доступ человека и права на установку модулей. */
/datum/computer_file/program/neural_service/proc/can_install_upgrade(mob/user)
	return !benchmark_mode && !QDELETED(user) && !QDELETED(computer) && ishuman(user) && !user.incapacitated && user.Adjacent(computer) && can_run(user) && (src in computer.stored_files) && (computer.active_program == src || (src in computer.idle_threads))

/** Возвращает получателей штатных модулей корневой стойки законов. */
/datum/computer_file/program/neural_service/proc/upgrade_recipients(obj/machinery/ai_law_rack/base/root)
	var/list/refs = list()
	for(var/mob/living/silicon/ai/ai in assoc_to_values(root.linked_mobs))
		if(!QDELETED(ai))
			refs += REF(ai)
	return jointext(sort_list(refs), ";")

/** Возвращает разрешённые варианты установки удерживаемого модуля для текущей сети. */
/datum/computer_file/program/neural_service/proc/upgrade_ui_data(mob/user, datum/ai_network/network)
	var/list/targets = list()
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(ai.ai_network != network)
			continue
		var/list/racks = list()
		var/obj/machinery/ai_law_rack/base/root = ai.get_law_rack()
		if(!QDELETED(root))
			var/list/candidates = list(root) + root.linked_racks
			for(var/obj/machinery/ai_law_rack/rack as anything in candidates)
				if(QDELETED(rack) || !user.Adjacent(rack))
					continue
				var/list/slots = list()
				for(var/index in 1 to rack.law_slots)
					if((rack.has_core_slot && index == 1) || rack.ai_modules[index])
						continue
					slots += index
				var/list/names = list()
				for(var/mob/living/silicon/ai/recipient in assoc_to_values(root.linked_mobs))
					if(!QDELETED(recipient))
						names += recipient.name
				racks += list(list("ref" = REF(rack), "name" = rack.declent_ru(), "online" = root.is_operational && rack.is_operational, "slots" = slots, "recipients" = names, "signature" = upgrade_recipients(root)))
		var/obj/machinery/ai/data_core/core = ai.loc
		targets += list(list("ref" = REF(ai), "name" = ai.name, "ready" = ai.stat != DEAD && istype(core) && core.can_transfer_ai(), "racks" = racks))
	return targets

/** Проверяет модуль, слот, получателей и сохранённое состояние перед установкой. */
/datum/computer_file/program/neural_service/proc/upgrade_install_valid(mob/user, datum/ai_network/network, mob/living/silicon/ai/ai, obj/machinery/ai_law_rack/rack, obj/item/ai_module/module, slot, signature, held = TRUE)
	if(!can_install_upgrade(user) || QDELETED(network) || local_network() != network || QDELETED(ai) || ai.ai_network != network || ai.stat == DEAD || !istype(ai.loc, /obj/machinery/ai/data_core))
		return FALSE
	var/obj/machinery/ai/data_core/core = ai.loc
	if(!core.can_transfer_ai() || QDELETED(rack) || !rack.is_operational || !user.Adjacent(rack) || QDELETED(module))
		return FALSE
	if(!istype(module, /obj/item/ai_module/upgrade) && !istype(module, /obj/item/ai_module/combat))
		return FALSE
	if(held ? (held_upgrade(user) != module || module.loc != user) : module.loc != rack)
		return FALSE
	if(!isnum(slot) || slot != round(slot) || slot < 1 || slot > rack.law_slots || (rack.has_core_slot && slot == 1) || rack.ai_modules[slot])
		return FALSE
	var/obj/machinery/ai_law_rack/base/root = ai.get_law_rack()
	return !QDELETED(root) && root.is_operational && rack.get_parent_rack() == root && signature == upgrade_recipients(root)

/** Подтверждает установку штатного модуля и заново проверяет доступ после ожидания. */
/datum/computer_file/program/neural_service/proc/install_upgrade(list/params, mob/user, datum/ai_network/network)
	var/obj/item/ai_module/module = held_upgrade(user)
	var/mob/living/silicon/ai/ai = locate(params["host"]) in GLOB.ai_list
	var/obj/machinery/ai_law_rack/rack = locate(params["rack"]) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ai_law_rack)
	var/slot = params["slot"]
	var/signature = params["signature"]
	if(!module || params["module"] != REF(module) || !istype(rack) || !upgrade_install_valid(user, network, ai, rack, module, slot, signature))
		return FALSE
	if(!module.can_install_to_rack(user, rack) || !upgrade_install_valid(user, network, ai, rack, module, slot, signature))
		return FALSE
	if(!user.transferItemToLoc(module, rack))
		return FALSE
	module.pre_user_install_to_rack(user, rack)
	if(!upgrade_install_valid(user, network, ai, rack, module, slot, signature, held = FALSE))
		if(!QDELETED(module) && module.loc == rack)
			user.put_in_hands(module)
		return FALSE
	module.log_install(user, rack)
	var/success = rack.add_ai_module(module, slot)
	if(success)
		rack.balloon_alert_to_viewers("установлен в слот [slot]")
		playsound(rack, 'sound/items/deconstruct.ogg', 50, TRUE)
	return success
