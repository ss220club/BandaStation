/** Обслуживает местную нейросеть с модульного компьютера через физический разъём. */
/datum/computer_file/program/neural_service
	filename = "neuralservice"
	filedesc = "Обслуживание нейросети"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	extended_desc = "Диагностика местной сети ИИ и серверных задач. Для подключения нажмите устройством ПКМ по оптоволоконному кабелю, ядру или серверу поблизости."
	program_icon = "network-wired"
	program_open_overlay = "generic"
	program_flags = PROGRAM_ON_NTNET_STORE
	run_access = list(ACCESS_ROBOTICS, ACCESS_RD, ACCESS_TCOMMS)
	size = 8
	tgui_id = "NtosNeuralService"
	/// Слабая ссылка на местный физический разъём компьютера.
	var/datum/weakref/endpoint_ref
	/// Включает сравнение ресурсов без команд обслуживания.
	var/benchmark_mode = FALSE
	/// Сохранённые показания для сравнения с текущим оборудованием.
	var/list/baseline
	/// Сеть исходного снимка; сравнение сбрасывается при смене подключения.
	var/datum/weakref/baseline_network_ref

/** Сравнивает ресурсы сети с сохранённым снимком без команд обслуживания. */
/datum/computer_file/program/neural_service/benchmark
	filename = "neuralbenchmark"
	filedesc = "Тест ресурсов нейросети"
	extended_desc = "Сравнение CPU и RAM местной сети ИИ до и после обслуживания оборудования. Использует снимок текущего сеанса, а не рекорды всей станции."
	program_icon = "gauge-high"
	size = 4
	benchmark_mode = TRUE

/datum/computer_file/program/neural_service/tap(atom/tapped_atom, mob/living/user, list/modifiers)
	if(!istype(tapped_atom, /obj/machinery/ai) && !istype(tapped_atom, /obj/structure/ai_ethernet))
		return FALSE
	if(!can_run(user) || !computer?.Adjacent(tapped_atom) || !user.Adjacent(tapped_atom))
		return FALSE
	stop_download()
	endpoint_ref = WEAKREF(tapped_atom)
	baseline = null
	baseline_network_ref = null
	computer.balloon_alert(user, "местный узел выбран")
	return TRUE

/datum/computer_file/program/neural_service/kill_program(mob/user)
	stop_download()
	endpoint_ref = null
	baseline = null
	baseline_network_ref = null
	return ..()

/** Определяет нейросеть компьютера через его местный физический разъём. */
/datum/computer_file/program/neural_service/proc/local_network()
	RETURN_TYPE(/datum/ai_network)
	if(QDELETED(computer) || !computer.enabled)
		baseline = null
		baseline_network_ref = null
		return
	SSai_networks.rebuild()
	var/atom/endpoint = endpoint_ref?.resolve()
	if(!endpoint && !endpoint_ref)
		var/list/local_cables = ai_cables_on_tile(get_turf(computer))
		endpoint = length(local_cables) == 1 ? local_cables[1] : null
	if(QDELETED(endpoint) || !computer.Adjacent(endpoint))
		baseline = null
		baseline_network_ref = null
		return
	var/datum/ai_network/network
	if(istype(endpoint, /obj/machinery/ai))
		var/obj/machinery/ai/node = endpoint
		var/responding = !(node.machine_stat & (BROKEN | EMPED | NOPOWER))
		if(istype(node, /obj/machinery/ai/data_core))
			var/obj/machinery/ai/data_core/core = node
			responding = core.has_power() && !(core.machine_stat & (BROKEN | EMPED))
		if(!responding)
			baseline = null
			baseline_network_ref = null
			return
		network = node.ai_network
	else if(istype(endpoint, /obj/structure/ai_ethernet))
		var/obj/structure/ai_ethernet/cable = endpoint
		network = cable.ai_network
	if(baseline_network_ref?.resolve() != network)
		baseline = null
		baseline_network_ref = null
	return network

/** Возвращает местную сеть только при доступных пользователю компьютере и служебной программе. */
/datum/computer_file/program/neural_service/proc/visible_network(mob/user)
	if(!can_run(user))
		return
	var/datum/ai_network/network = local_network()
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		if(ai.ai_network != network)
			return
	return network

/** Проверяет права на изменение ресурсов с учётом общей политики сети. */
/datum/computer_file/program/neural_service/proc/can_allocate_resources(mob/user)
	return !benchmark_mode && ishuman(user) && !user.incapacitated && user.Adjacent(computer) && can_run(user, access_to_check = list(ACCESS_RD, ACCESS_TCOMMS))

/datum/computer_file/program/neural_service/ui_data(mob/user)
	var/list/data = list("benchmark" = benchmark_mode, "connected" = FALSE)
	if(!benchmark_mode && (can_run(user) || (ishuman(user) && !user.incapacitated && user.Adjacent(computer))))
		var/obj/item/aicard/card = slotted_card()
		data["slot_installed"] = !!card_slot()
		data["card_present"] = !!card
		data["card_name"] = card?.AI?.name
		data["card_busy"] = !!card?.flush || !!card_slot()?.restoring
		data["can_transfer"] = can_transfer(user)
		data["can_eject"] = ishuman(user) && !user.incapacitated && user.Adjacent(computer)
		data["downloading"] = downloading?.name
		data["download_progress"] = download_progress
		var/obj/item/mmi/brain = user.is_holding_item_of_type(/obj/item/mmi) || null
		data["mmi_ref"] = brain ? REF(brain) : null
		data["mmi_name"] = brain?.brainmob?.name || brain?.name
		data["mmi_ready"] = !!brain && CONFIG_GET(flag/allow_ai) && brain.brain_check()
	var/datum/ai_network/network = visible_network(user)
	if(!network)
		return data
	var/datum/ai_os/pool = network.resources
	data["connected"] = TRUE
	data["network"] = REF(network)
	data["name"] = network.name
	data["cpu"] = pool.total_cpu
	data["nominal_cpu"] = pool.nominal_cpu
	data["ram"] = pool.total_ram
	data["spare_cpu"] = network.spare_cpu()
	data["free_ram"] = max(0, pool.total_ram - pool.total_ram_assigned())
	data["jobs"] = network.background_job_count()
	data["segment_count"] = length(network.local_subnets())
	data["baseline"] = baseline
	data["can_manage"] = !benchmark_mode && ishuman(user) && user.Adjacent(computer)
	data["servers"] = list()
	if(benchmark_mode)
		data["records"] = SSai_networks.benchmark_history
		return data
	data += hacked_law_ui_data(user, network)
	var/obj/item/ai_module/module = held_upgrade(user)
	data["upgrade_ref"] = module ? REF(module) : null
	data["upgrade_name"] = module?.declent_ru()
	data["can_install_upgrade"] = can_install_upgrade(user)
	if(module)
		data["upgrade_targets"] = upgrade_ui_data(user, network)
	var/list/job_plan = network.background_cpu_plan()
	data["subnets"] = network.subnet_ui_data(job_plan)
	data["bridges"] = list()
	for(var/obj/machinery/ai/network_bridge/bridge in network.nodes)
		var/responding = !(bridge.machine_stat & (NOPOWER | BROKEN | EMPED))
		data["bridges"] += list(list("ref" = REF(bridge), "area" = "[ai_localized_area(bridge)]", "responding" = responding, "enabled" = responding && bridge.link_enabled, "heading" = responding ? bridge.antenna_heading : null, "bearing" = responding ? bridge.target_bearing() : null, "status" = responding ? (bridge.link_status() || "Связь установлена") : "Нет ответа"))
	data["can_allocate"] = can_allocate_resources(user)
	data["human_only"] = pool.human_lock
	data["policy_revision"] = network.resource_policy_revision
	data["can_change_policy"] = can_transfer(user)
	data["cores"] = list()
	for(var/obj/machinery/ai/data_core/core in network.nodes)
		data["cores"] += list(list("ref" = REF(core), "area" = "[ai_localized_area(core)] ([core.x], [core.y], [core.z])", "ready" = core.can_transfer_ai()))
	data["ais"] = list()
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(ai.ai_network != network)
			continue
		data["ais"] += list(list("ref" = REF(ai), "name" = ai.name, "cpu" = pool.cpu_assigned[ai] || 0, "ram" = pool.ram_assigned[ai] || 0, "can_download" = ai.can_download && ai.can_be_carded && ai.stat != DEAD && istype(ai.loc, /obj/machinery/ai/data_core)))
	for(var/obj/machinery/ai/server_cabinet/cabinet in network.nodes)
		var/responding = !(cabinet.machine_stat & (NOPOWER | BROKEN | EMPED))
		data["servers"] += list(list(
			"ref" = REF(cabinet),
			"area" = "[ai_localized_area(cabinet)]",
			"responding" = responding,
			"status" = responding ? (cabinet.get_holder_status() || "В сети") : "Нет ответа",
			"temperature" = responding ? cabinet.core_temp : null,
			"effective_cpu" = responding ? cabinet.effective_cpu() : null,
			"nominal_cpu" = responding ? cabinet.total_cpu : null,
			"thermal_status" = responding ? cabinet.thermal_status() : null,
			"subnet" = cabinet.ai_subnet?.name,
			"job_cpu" = responding ? ((job_plan["research"]?[cabinet] || 0) + (job_plan["science"]?[cabinet] || 0) + (job_plan["archive"]?[cabinet] || 0) + (job_plan["mining"]?[cabinet] || 0)) : null,
			"jobs_ready" = responding && cabinet.can_run_background_research(),
			"research" = responding && cabinet.background_research,
			"science" = responding && cabinet.background_science,
			"mining" = responding && cabinet.background_mining,
			"mining_balance" = responding ? cabinet.mining_balance : null,
			"archive" = responding && !!cabinet.decryption_disk,
			"recovering" = responding && cabinet.decryption_enabled,
		))
	return data

/datum/computer_file/program/neural_service/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	if(action == "rename_network")
		var/datum/ai_network/network = visible_network(ui.user)
		if(!network || !can_allocate_resources(ui.user) || params["network"] != REF(network))
			return FALSE
		var/new_name = tgui_input_text(ui.user, "Назовите подключённую сеть (до 32 символов). После разделения имя сохраняет только один сегмент; при объединении остаётся одно из прежних имён.", "Название сети", network.name, 32)
		if(isnull(new_name))
			return FALSE
		params = params.Copy()
		params["name"] = new_name
	return service_action(action, params, ui.user)

/** Проверяет права и состояние сети перед выполнением команды нейросервиса. */
/datum/computer_file/program/neural_service/proc/service_action(action, list/params, mob/user)
	if(action == "eject_card" && !benchmark_mode)
		if(!ishuman(user) || user.incapacitated || QDELETED(computer) || !user.Adjacent(computer))
			return FALSE
		stop_download()
		return card_slot()?.try_eject(user) || FALSE
	if(action == "stop_download" && !benchmark_mode && can_transfer(user))
		stop_download()
		return TRUE
	var/datum/ai_network/network = visible_network(user)
	if(!network || params["network"] != REF(network))
		return FALSE
	if(action == "snapshot" && benchmark_mode)
		baseline = list("cpu" = network.resources.total_cpu, "ram" = network.resources.total_ram)
		baseline_network_ref = WEAKREF(network)
		return TRUE
	if(benchmark_mode || !ishuman(user) || !user.Adjacent(computer))
		return FALSE
	if(action == "set_human_policy")
		return set_network_policy(params, user, network)
	if(action == "upload_hacked_law")
		return hacked_law_action(params, user, network)
	if(action == "install_upgrade")
		return install_upgrade(params, user, network)
	if(action == "upload_mmi")
		return upload_mmi(params, user, network)
	if(action == "start_download" || action == "upload_card")
		return transfer_action(action, params, user, network)
	if(action in list("allocate_network_cpu", "max_network_cpu", "reset_network_cpu"))
		if(!can_transfer(user))
			return FALSE
		var/datum/ai_subnet/subnet = locate(params["subnet"]) in network.local_subnets()
		if(!network.activity_allocation_action(action, subnet, params["category"], params["amount"], params["expected_revision"]))
			computer.balloon_alert(user, "доля задачи недоступна")
			return FALSE
		log_silicon("[key_name(user)] changed [params["category"]] CPU share in [subnet.name] through Neural Service", list(computer))
		return TRUE
	if(action == "set_subnet_quota" || action == "rename_subnet")
		if(!can_allocate_resources(user))
			return FALSE
		var/datum/ai_subnet/subnet = locate(params["subnet"]) in network.local_subnets()
		if(QDELETED(subnet))
			return FALSE
		if(action == "set_subnet_quota")
			if(!network.set_subnet_quota(subnet, params["amount"]))
				computer.balloon_alert(user, "квота превышает свободную долю")
				return FALSE
		else
			if(!istext(params["name"]))
				return FALSE
			var/new_name = trim(strip_html(params["name"], 32))
			if(!length(new_name))
				return FALSE
			subnet.name = new_name
		log_silicon("[key_name(user)] changed [action] for [subnet.name] through Neural Service", list(computer))
		return TRUE
	if(action == "rename_network")
		if(!can_allocate_resources(user) || !istext(params["name"]))
			return FALSE
		var/new_name = trim(strip_html(params["name"], 32))
		if(!length(new_name))
			return FALSE
		var/old_name = network.name
		network.name = new_name
		log_silicon("[key_name(user)] renamed neural network from [old_name] to [new_name]", list(computer))
		return TRUE
	if(action == "toggle_bridge")
		if(!can_allocate_resources(user))
			return FALSE
		var/obj/machinery/ai/network_bridge/bridge = locate(params["host"]) in network.nodes
		if(!istype(bridge) || QDELETED(bridge) || (bridge.machine_stat & (NOPOWER | BROKEN | EMPED)))
			return FALSE
		bridge.link_enabled = !bridge.link_enabled
		SSai_networks.dirty = TRUE
		log_silicon("[key_name(user)] [bridge.link_enabled ? "enabled" : "disabled"] relay through Neural Service", list(computer, bridge))
		return TRUE
	if(action in list("set_cpu", "set_ram", "max_cpu", "max_ram", "add_ram", "remove_ram", "clear_ai_resources"))
		if(!can_allocate_resources(user) || ((action != "set_cpu" && action != "set_ram") && !can_transfer(user)))
			return FALSE
		var/mob/living/silicon/ai/target = locate(params["host"]) in GLOB.ai_list
		if(QDELETED(target) || target.ai_network != network)
			return FALSE
		var/amount = params["amount"]
		var/success = network.resources.allocation_action(action, target, amount, params["expected_revision"], params["expected_cpu"], params["expected_ram"])
		if(success)
			log_silicon("[key_name(user)] used Neural Service to [action] to [amount] for [key_name(target)]", list(computer, target))
		else
			computer.balloon_alert(user, "ресурсы недоступны или указаны неверно")
		return success
	var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in network.nodes
	if(!istype(cabinet) || QDELETED(cabinet) || (cabinet.machine_stat & (NOPOWER | BROKEN | EMPED)))
		return FALSE
	switch(action)
		if("research")
			cabinet.background_research = !cabinet.background_research
		if("mining")
			cabinet.background_mining = !cabinet.background_mining
		if("science")
			cabinet.background_science = !cabinet.background_science
		if("archive")
			if(!cabinet.decryption_disk)
				return FALSE
			cabinet.decryption_enabled = !cabinet.decryption_enabled
		else
			return FALSE
	log_silicon("[key_name(user)] changed [action] job at [cabinet] through Neural Service", list(computer, cabinet))
	return TRUE
