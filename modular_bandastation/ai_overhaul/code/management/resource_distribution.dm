/** Даёт авторизованному оператору управление общими ресурсами и задачами сети. */
/obj/machinery/computer/ai_resource_distribution
	name = "\improper AI system resource distribution"
	desc = "Консоль распределения вычислительных ресурсов между действующими ИИ."
	req_one_access = list(ACCESS_RD, ACCESS_TCOMMS)
	circuit = /obj/item/circuitboard/computer/ai_resource_distribution
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	authenticated = FALSE
	/// Выбранная консолью сеть; перед использованием повторно проверяется доступность.
	var/datum/ai_network/selected_network

/** Выбирает разрешённую сеть пользователя, отбрасывая устаревшую или чужую лабораторную цель. */
/obj/machinery/computer/ai_resource_distribution/proc/current_network(mob/user)
	RETURN_TYPE(/datum/ai_network)
	SSai_networks.rebuild()
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		return ai.ai_network?.accessible_from(src) ? ai.ai_network : null
	if((selected_network in GLOB.ai_networks) && selected_network.accessible_from(src))
		return selected_network
	selected_network = null
	for(var/datum/ai_network/network as anything in GLOB.ai_networks)
		if(!network.accessible_from(src))
			continue
		for(var/obj/machinery/ai/data_core/core in network.nodes)
			if(ai_supported_location(core) && ai_same_debug_environment(src, core))
				selected_network = network
				return network

/obj/machinery/computer/ai_resource_distribution/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	authenticated = TRUE
	if(user)
		balloon_alert(user, "ограничения доступа обойдены")

/obj/machinery/computer/ai_resource_distribution/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiResources", name)
		ui.open()

/obj/machinery/computer/ai_resource_distribution/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated && can_operate_resources(user)
	data["username"] = user?.name
	data["has_access"] = can_operate_resources(user)
	if(!authenticated || !can_operate_resources(user))
		return data
	var/datum/ai_network/network = current_network(user)
	var/datum/ai_os/pool = network?.resources || GLOB.ai_os
	data["selected_network"] = network ? REF(network) : null
	data["networks"] = list()
	for(var/datum/ai_network/option as anything in GLOB.ai_networks)
		if(!option.accessible_from(src) || (isAI(user) && option != network))
			continue
		data["networks"] += list(list("ref" = REF(option), "name" = option.name))
	data["total_cpu"] = pool.total_cpu
	data["nominal_cpu"] = pool.nominal_cpu
	data["total_ram"] = pool.total_ram
	data["recovery_cost"] = AI_BACKUP_CPU_COST
	data["recovery_cpu"] = network?.spare_cpu() || 0
	data["background_job_count"] = network ? network.background_job_count() : 0
	data["job_weights"] = network?.job_weights
	data["job_weight_total"] = network ? network.background_job_weight() : 0
	data["research_rate"] = AI_RESEARCH_PER_CPU
	data["mining_rate"] = network ? network.mining_income_per_second() : 0
	data["can_withdraw"] = ishuman(user) && user.Adjacent(src) && (allowed(user) || (obj_flags & EMAGGED))
	var/list/subnet_budgets = list()
	var/list/job_plan = network ? network.background_cpu_plan(subnet_budgets) : list()
	data["subnets"] = network ? network.subnet_ui_data(job_plan, subnet_budgets) : list()
	data["research_hosts"] = list()
	if(network)
		for(var/obj/machinery/ai/server_cabinet/cabinet in network.nodes)
			data["research_hosts"] += list(list(
				"ref" = REF(cabinet),
				"name" = cabinet.declent_ru(),
				"area" = "[ai_localized_area(cabinet)]",
				"enabled" = cabinet.background_research,
				"subnet" = cabinet.ai_subnet?.name,
				"research_cpu" = job_plan["research"]?[cabinet] || 0,
				"science_cpu" = job_plan["science"]?[cabinet] || 0,
				"mining_cpu" = job_plan["mining"]?[cabinet] || 0,
				"mining_enabled" = cabinet.background_mining,
				"mining_balance" = cabinet.mining_balance,
				"mining_ready" = cabinet.can_run_background_research(),
				"science_enabled" = cabinet.background_science,
				"science_points" = cabinet.background_science_points,
				"science_pending" = cabinet.background_science_pending,
				"ready" = cabinet.can_run_background_research() && !!ai_station_techweb(cabinet),
				"points" = cabinet.background_research_points,
				"pending" = cabinet.background_research_pending,
				"disk" = cabinet.decryption_disk ? list(
					"cpu" = job_plan["archive"]?[cabinet] || 0,
					"progress" = cabinet.decryption_disk.decryption_progress,
					"cost" = cabinet.decryption_disk.decryption_cost,
					"reward" = cabinet.decryption_disk.research_reward,
					"enabled" = cabinet.decryption_enabled,
					"ready" = cabinet.can_decrypt_disk(),
				) : null,
			))
	data["recoveries"] = list()
	if(network)
		for(var/obj/machinery/ai/data_core/core in network.nodes)
			var/obj/item/ai_neural_backup/backup = core.neural_backup
			if(!backup || !backup.valid_payload() || !core.has_power() || (core.machine_stat & (BROKEN | EMPED)))
				continue
			data["recoveries"] += list(list(
				"ref" = REF(core),
				"name" = backup.stored_ai.real_name,
				"cpu" = job_plan["recovery"]?[backup] || 0,
				"area" = "[ai_localized_area(core)]",
				"progress" = backup.processing_progress,
				"enabled" = backup.recovery_enabled,
				"ready" = !!backup.recovery_host(),
				"battery" = round(backup.battery_remaining / (1 SECONDS)),
			))


	data["total_assigned_cpu"] = pool.total_cpu_assigned()
	data["total_assigned_ram"] = pool.total_ram_assigned()

	data["human_only"] = pool.human_lock
	data["policy_revision"] = network?.resource_policy_revision
	data["can_manage"] = can_operate_resources(user) && (!pool.human_lock || ishuman(user))
	data["can_change_policy"] = !!network && ishuman(user) && can_operate_resources(user)


	data["ais"] = list()

	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(!network || ai.ai_network != network)
			continue
		data["ais"] += list(list(
			"name" = ai.name,
			"ref" = REF(ai),
			"assigned_cpu" = pool.cpu_assigned[ai] ? pool.cpu_assigned[ai] : 0,
			"assigned_ram" = pool.ram_assigned[ai] ? pool.ram_assigned[ai] : 0,
		))

	return data

/obj/machinery/computer/ai_resource_distribution/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	return resource_action(action, params, ui.user)

/** Обрабатывает команду консоли с серверной проверкой прав, текущей сети и версии назначений. */
/obj/machinery/computer/ai_resource_distribution/proc/resource_action(action, list/params, mob/user)
	if(!can_operate_resources(user))
		return FALSE
	playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
	var/datum/ai_network/network = current_network(user)
	var/datum/ai_os/pool = network?.resources || GLOB.ai_os
	if(!authenticated)
		if(action == "log_in")
			if(allowed(user) || (obj_flags & EMAGGED))
				authenticated = TRUE
				return TRUE
		return

	if(!allowed(user) && !(obj_flags & EMAGGED))
		return FALSE
	var/is_human = ishuman(user)
	if(pool.human_lock && !is_human && action != "log_out" && action != "select_network")
		balloon_alert(user, "нужен доступ оператора-человека!")
		return FALSE

	switch(action)
		if("allocate_network_cpu", "max_network_cpu", "reset_network_cpu")
			if(!network || params["network"] != REF(network))
				return FALSE
			var/datum/ai_subnet/subnet = locate(params["subnet"]) in network.local_subnets()
			if(!network.activity_allocation_action(action, subnet, params["category"], params["amount"], params["expected_revision"]))
				balloon_alert(user, "доля задачи недоступна")
				return FALSE
			log_silicon("[key_name(user)] changed [params["category"]] CPU share in [subnet.name]", list(src))
			return TRUE
		if("set_subnet_quota", "rename_subnet")
			if(!network || params["network"] != REF(network))
				return FALSE
			var/datum/ai_subnet/subnet = locate(params["subnet"]) in network.local_subnets()
			if(QDELETED(subnet))
				return FALSE
			if(action == "set_subnet_quota")
				if(!network.set_subnet_quota(subnet, params["amount"]))
					balloon_alert(user, "квота превышает свободную долю")
					return FALSE
			else
				if(!istext(params["name"]))
					return FALSE
				var/new_name = trim(strip_html(params["name"], 32))
				if(!length(new_name))
					return FALSE
				subnet.name = new_name
			log_silicon("[key_name(user)] changed [action] for [subnet.name]", list(src))
			return TRUE
		if("set_job_weight")
			if(!network || params["network"] != REF(network) || !network.set_job_weight(params["category"], params["amount"]))
				return FALSE
			log_silicon("[key_name(user)] set [params["category"]] job priority to [params["amount"]]", list(src))
			return TRUE
		if("withdraw_mining")
			var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in GLOB.server_cabinets
			return withdraw_mining(user, cabinet)
		if("toggle_mining")
			var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in GLOB.server_cabinets
			if(!network || QDELETED(cabinet) || !(cabinet in network.nodes))
				return FALSE
			cabinet.background_mining = !cabinet.background_mining
			log_silicon("[key_name(user)] [cabinet.background_mining ? "started" : "paused"] network mining at [cabinet]", list(src, cabinet))
			return TRUE
		if("toggle_decryption")
			var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in GLOB.server_cabinets
			if(!network || QDELETED(cabinet) || !(cabinet in network.nodes) || !cabinet.decryption_disk)
				return FALSE
			cabinet.decryption_enabled = !cabinet.decryption_enabled
			log_silicon("[key_name(user)] [cabinet.decryption_enabled ? "started" : "paused"] archive recovery at [cabinet]", list(src, cabinet))
			return TRUE
		if("toggle_station_research")
			var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in GLOB.server_cabinets
			if(!network || QDELETED(cabinet) || !(cabinet in network.nodes))
				return FALSE
			cabinet.background_science = !cabinet.background_science
			log_silicon("[key_name(user)] [cabinet.background_science ? "started" : "paused"] station research assistance at [cabinet]", list(src, cabinet))
			return TRUE
		if("toggle_background_research")
			var/obj/machinery/ai/server_cabinet/cabinet = locate(params["host"]) in GLOB.server_cabinets
			if(!network || QDELETED(cabinet) || !(cabinet in network.nodes))
				return FALSE
			cabinet.background_research = !cabinet.background_research
			log_silicon("[key_name(user)] [cabinet.background_research ? "started" : "paused"] background AI research at [cabinet]", list(src, cabinet))
			return TRUE
		if("toggle_recovery")
			var/obj/machinery/ai/data_core/core = locate(params["core"]) in GLOB.data_cores
			if(!network || QDELETED(core) || core.ai_network != network || !core.neural_backup?.valid_payload() || !core.has_power() || (core.machine_stat & (BROKEN | EMPED)))
				return FALSE
			core.neural_backup.recovery_enabled = !core.neural_backup.recovery_enabled
			log_silicon("[key_name(user)] [core.neural_backup.recovery_enabled ? "started" : "paused"] neural reconstruction at [core]", list(src, core))
			return TRUE
		if("select_network")
			var/datum/ai_network/choice = locate(params["network"]) in GLOB.ai_networks
			if(!choice || !choice.accessible_from(src) || (isAI(user) && choice != network))
				return FALSE
			selected_network = choice
			return TRUE
		if("log_out")
			authenticated = FALSE
			. = TRUE

		if("clear_ai_resources", "set_cpu", "set_ram", "max_cpu", "max_ram", "add_ram", "remove_ram")
			if(!network || params["network"] != REF(network))
				return FALSE
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"]) in GLOB.ai_list
			if(QDELETED(target_ai) || target_ai.ai_network != network)
				return FALSE
			var/amount = action == "set_cpu" ? params["amount_cpu"] : params["amount_ram"]
			var/success = pool.allocation_action(action, target_ai, amount, params["expected_revision"], params["expected_cpu"], params["expected_ram"])
			if(success)
				log_silicon("[key_name(user)] changed [action] for [key_name(target_ai)] on [network.name]", list(src, target_ai))
			else
				balloon_alert(user, "ресурсы недоступны или указаны неверно")
			return success
		if("set_human_policy")
			if(!is_human || !network || params["network"] != REF(network) || !pool.set_human_lock(params["human_only"], params["expected_human_only"], params["expected_revision"]))
				return FALSE
			log_silicon("[key_name(user)] set resource policy for [network.name] to [pool.human_lock ? "human operators only" : "authorized silicon allowed"]", list(src))
			balloon_alert(user, pool.human_lock ? "только операторы-люди" : "доступ синтетикам включён")
			return TRUE

/** Выдаёт целые кредиты с физического сервера после проверки сети и доступа пользователя. */
/obj/machinery/computer/ai_resource_distribution/proc/withdraw_mining(mob/user, obj/machinery/ai/server_cabinet/cabinet)
	if(!authenticated || !ishuman(user) || !user.Adjacent(src) || user.incapacitated || (machine_stat & (NOPOWER | BROKEN | EMPED)))
		return FALSE
	if(!allowed(user) && !(obj_flags & EMAGGED))
		return FALSE
	var/datum/ai_network/network = current_network(user)
	if(!network || QDELETED(cabinet) || !(cabinet in network.nodes) || !cabinet.can_run_background_research())
		return FALSE
	var/amount = FLOOR(cabinet.mining_balance, 1)
	if(amount < 1)
		return FALSE
	cabinet.mining_balance -= amount
	new /obj/item/holochip(drop_location(), amount)
	log_silicon("[key_name(user)] withdrew [amount] credits from network mining at [cabinet]", list(src, cabinet))
	return TRUE
