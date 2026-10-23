#ifdef UNIT_TESTS
#define AI_REVIEW_ASSERT(condition, message) if(!(condition)) { return Fail(message, __FILE__, __LINE__) }

/** Убирает атмосферу из проверки расхода батареи ядра. */
/obj/machinery/ai/data_core/ai_review_test/valid_holder(ignore_temperature = FALSE)
	return !(machine_stat & (BROKEN | EMPED)) && has_power()

/** Разрешает проверку переноса на служебном уровне юнит-тестов. */
/obj/machinery/ai/data_core/ai_review_test/valid_data_core(mob/living/silicon/ai/user)
	return valid_ticks > 0

/** Проверяет расход остатка батареи и смену состояния ядра. */
/datum/unit_test/ai_review_core_battery

/datum/unit_test/ai_review_core_battery/Run()
	var/obj/machinery/ai/data_core/ai_review_test/core = allocate(/obj/machinery/ai/data_core/ai_review_test)
	core.update_use_power(ACTIVE_POWER_USE)
	core.set_machine_stat(NOPOWER)
	core.integrated_battery.charge = core.active_power_usage * 0.025 * 1.5
	core.process(2)
	AI_REVIEW_ASSERT(!core.integrated_battery.charge && !core.has_power(), "Остаток заряда меньше полного тика должен расходоваться до нуля.")
	AI_REVIEW_ASSERT(core.icon_state == "core-offline", "Потеря резервного питания должна обновить изображение ядра.")
	core.valid_ticks = 1
	core.process(2)
	AI_REVIEW_ASSERT(!core.valid_ticks && core.use_power == IDLE_POWER_USE, "Отказавшее ядро должно перейти на штатный учёт потребления в ожидании.")
	core.set_machine_stat(NONE)
	core.process(2)
	AI_REVIEW_ASSERT(core.valid_ticks > 0 && core.use_power == ACTIVE_POWER_USE && core.icon_state == "core", "Восстановление должно обновить изображение и активное потребление.")

/** Проверяет сохранение физических деталей при разрушении шкафа. */
/datum/unit_test/ai_review_server_salvage

/datum/unit_test/ai_review_server_salvage/Run()
	var/obj/machinery/ai/server_cabinet/prefilled/server = allocate(/obj/machinery/ai/server_cabinet/prefilled)
	var/obj/item/server_rack/rack = server.installed_racks[1]
	var/obj/item/ai_cpu/cpu = rack.contained_cpus[1]
	var/obj/item/ai_ram/memory = rack.contained_memory[1]
	var/turf/home = get_turf(server)
	qdel(server)
	AI_REVIEW_ASSERT(!QDELETED(rack) && rack.loc == home && cpu.loc == rack && memory.loc == rack, "Разрушение шкафа должно вернуть исходный модуль с CPU и RAM, без копий и удаления деталей.")

/** Проверяет повторное размещение ИИ после неудачного первого запуска ядра. */
/datum/unit_test/ai_review_startup_retry

/datum/unit_test/ai_review_startup_retry/Run()
	var/obj/machinery/ai/data_core/ai_review_test/core = allocate(/obj/machinery/ai/data_core/ai_review_test)
	core.set_machine_stat(NONE)
	core.valid_ticks = 0
	var/mob/living/brain/brain = allocate(/mob/living/brain)
	var/mob/living/silicon/ai/debug_lab/ai = allocate(/mob/living/silicon/ai/debug_lab, null, brain)
	ai.forceMove(get_turf(core))
	ai.initialize_decentralized_ai()
	AI_REVIEW_ASSERT(!ai.decentralized && !ai.dashboard, "Неудачный первый перенос не должен оставлять ИИ частично инициализированным.")
	core.valid_ticks = MAX_AI_DATA_CORE_TICKS
	AI_REVIEW_ASSERT(core.transfer_AI(ai) && ai.in_network_core() && ai.dashboard && ai.decentralized, "После восстановления ядра прямой повторный перенос должен создать личную панель ИИ.")

/** Проверяет зарядку батареи киборга и невозможность разблокировки с перерезанным проводом. */
/datum/unit_test/ai_review_borg_service

/datum/unit_test/ai_review_borg_service/Run()
	var/mob/living/brain/brain = allocate(/mob/living/brain)
	var/mob/living/silicon/ai/debug_lab/ai = allocate(/mob/living/silicon/ai/debug_lab, null, brain)
	var/mob/living/silicon/robot/borg = allocate(/mob/living/silicon/robot)
	var/datum/action/innate/ai/ranged/charge_borg_or_apc/charge = allocate(/datum/action/innate/ai/ranged/charge_borg_or_apc)
	charge.Grant(ai)
	borg.cell.charge = 0
	AI_REVIEW_ASSERT(charge.charge_borg_or_apc(borg) && abs(borg.cell.charge - borg.cell.maxcharge * 0.33) < 0.01, "Индукция должна дать батарее 33% без вызова callback API киборга.")
	borg.cell.charge = borg.cell.maxcharge
	AI_REVIEW_ASSERT(!charge.charge_borg_or_apc(borg), "Полная батарея не должна считаться успешной зарядкой.")
	ai.set_control_disabled(TRUE)
	charge.works_on_borgs = TRUE
	AI_REVIEW_ASSERT(!charge.do_ability(ai, borg) && charge.uses == 1, "Отключённое управление не должно позволять зарядку или расходовать её заряд.")
	var/datum/action/innate/ai/ranged/ai_borg_maintenance/unlock/unlock = allocate(/datum/action/innate/ai/ranged/ai_borg_maintenance/unlock)
	borg.wires.cut(WIRE_LOCKDOWN)
	AI_REVIEW_ASSERT(!unlock.perform_maintenance(borg) && borg.lockcharge, "Перерезанный провод должен блокировать дистанционную разблокировку.")

/** Исключает состояние спутников из проверки личного капитанского доступа. */
/obj/machinery/computer/communications/ai_review_test/has_communication()
	return TRUE

/** Проверяет текущего оператора вместо чужой сохранённой сессии. */
/datum/unit_test/ai_review_console_access

/datum/unit_test/ai_review_console_access/Run()
	var/mob/living/carbon/human/operator = allocate(/mob/living/carbon/human)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	operator.put_in_active_hand(card)
	var/obj/machinery/computer/communications/ai_review_test/comms = allocate(/obj/machinery/computer/communications/ai_review_test)
	comms.set_machine_stat(NONE)
	comms.authorize_access = list(ACCESS_CAPTAIN)
	var/old_code = GLOB.ai_control_code
	AI_REVIEW_ASSERT(!comms.issue_ai_control_code(operator) && GLOB.ai_control_code == old_code, "Чужая капитанская сессия не должна разрешать печать или смену аварийного кода.")
	card.access = list(ACCESS_CAPTAIN)
	AI_REVIEW_ASSERT(comms.issue_ai_control_code(operator) && length(GLOB.ai_control_code) == 6, "Текущий капитан должен получить код той же длины, которую принимает форма.")
	GLOB.ai_control_code = old_code
	var/obj/machinery/computer/ai_resource_distribution/console = allocate(/obj/machinery/computer/ai_resource_distribution)
	console.set_machine_stat(NONE)
	console.authenticated = TRUE
	card.access = list()
	var/list/data = console.ui_data(operator)
	AI_REVIEW_ASSERT(!data["authenticated"] && !data["ais"] && !data["recoveries"] && !data["total_cpu"], "Сохранённая сессия не должна раскрывать данные следующему оператору без доступа.")
	card.access = list(ACCESS_RD)
	AI_REVIEW_ASSERT(console.can_operate_resources(operator), "Уполномоченный оператор должен сохранять доступ.")
	console.panel_open = TRUE
	AI_REVIEW_ASSERT(!console.can_operate_resources(operator), "Сервисная панель должна блокировать команды старого окна.")
	var/obj/machinery/ai/network_bridge/bridge = allocate(/obj/machinery/ai/network_bridge)
	bridge.set_machine_stat(NOPOWER)
	var/obj/machinery/computer/ai_server_console/overview = allocate(/obj/machinery/computer/ai_server_console)
	data = overview.ui_data(operator)
	for(var/list/entry as anything in data["bridges"])
		if(entry["ref"] == REF(bridge))
			AI_REVIEW_ASSERT(entry["status"] == "Нет питания" && entry["area"] == ai_localized_area(bridge), "Местный ретранслятор должен показывать известную причину отказа и место.")

/** Проверяет, что отключение незапущенного стенда не создаёт ложную запись отказа. */
/datum/unit_test/ai_review_idle_overclock

/datum/unit_test/ai_review_idle_overclock/Run()
	var/obj/machinery/computer/ai_overclocking/workstation = allocate(/obj/machinery/computer/ai_overclocking)
	var/obj/item/ai_cpu/cpu = allocate(/obj/item/ai_cpu, workstation)
	workstation.inserted_cpu = cpu
	workstation.set_machine_stat(NOPOWER)
	workstation.process()
	AI_REVIEW_ASSERT(!length(cpu.last_overclocking_values) && cpu.loc == get_turf(workstation), "Отказ питания без запущенной проверки должен вернуть CPU без ложного результата разгона.")

/** Проверяет очистку программного трека без вмешательства в ручной выбор. */
/datum/unit_test/ai_review_camera_tracking

/datum/unit_test/ai_review_camera_tracking/Run()
	var/mob/living/brain/brain = allocate(/mob/living/brain)
	var/mob/living/silicon/ai/debug_lab/ai = allocate(/mob/living/silicon/ai/debug_lab, null, brain)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/manual_target = allocate(/mob/living/carbon/human)
	ai.ai_tracking_tool.set_tracked_mob(target)
	ai.camera_memory_tracked_ref = WEAKREF(target)
	ai.set_camera_memory_target("")
	AI_REVIEW_ASSERT(!ai.ai_tracking_tool.tracked_mob && !length(ai.camera_memory_target), "Пустая цель должна снимать программное отслеживание.")
	ai.ai_tracking_tool.set_tracked_mob(manual_target)
	ai.camera_memory_tracked_ref = WEAKREF(target)
	ai.clear_camera_memory_track()
	AI_REVIEW_ASSERT(ai.ai_tracking_tool.tracked_mob == manual_target, "Остановка программы не должна снимать последующее ручное отслеживание.")

/** Позволяет проверять CPU-план без зависимости от температуры тестового помещения. */
/obj/machinery/ai/server_cabinet/ai_review_test/valid_holder(ignore_temperature = FALSE)
	return TRUE

/** Накопитель фактически перечисленных научных очков тестового сервера. */
/obj/machinery/ai/server_cabinet/ai_review_test
	/// Очки, полученные сервером в проверяемом тике.
	var/science_received = 0

/obj/machinery/ai/server_cabinet/ai_review_test/contribute_station_research(points)
	science_received += points

/** Проверяет общий лимит науки для двух независимых сетей. */
/datum/unit_test/ai_review_shared_science

/datum/unit_test/ai_review_shared_science/Run()
	var/list/networks = list()
	var/list/plans = list()
	var/list/servers = list()
	for(var/index in 1 to 2)
		var/obj/machinery/ai/server_cabinet/ai_review_test/server = allocate(/obj/machinery/ai/server_cabinet/ai_review_test)
		server.background_science = TRUE
		server.total_cpu = 10000
		server.ai_subnet = allocate(/datum/ai_subnet)
		var/datum/ai_network/network = allocate(/datum/ai_network)
		network.nodes = list(server)
		network.resources.total_cpu = 10000
		server.ai_network = network
		networks += network
		servers += server
		plans[network] = network.background_cpu_plan()
	var/list/totals = ai_science_cpu_totals(plans)
	for(var/datum/ai_network/network as anything in networks)
		network.process_background_jobs(1, plans[network], totals)
	var/points = 0
	for(var/obj/machinery/ai/server_cabinet/ai_review_test/server as anything in servers)
		points += server.science_received
	AI_REVIEW_ASSERT(abs(points - AI_STATION_RESEARCH_MAX_PER_SECOND) < 0.01, "Две сети общей научной базы должны делить один лимит 250 очков/с.")

/** Проверяет сохранение настроек и аннулирование старых команд после соединения сегментов. */
/datum/unit_test/ai_review_subnet_merge

/datum/unit_test/ai_review_subnet_merge/Run()
	var/turf/first_tile = run_loc_floor_bottom_left
	var/turf/middle = get_step(first_tile, EAST)
	var/turf/second_tile = get_step(middle, EAST)
	var/obj/machinery/ai/server_cabinet/ai_review_test/first = allocate(/obj/machinery/ai/server_cabinet/ai_review_test, first_tile)
	var/obj/machinery/ai/server_cabinet/ai_review_test/second = allocate(/obj/machinery/ai/server_cabinet/ai_review_test, second_tile)
	first.install_rack(new_rack = allocate(/obj/item/server_rack/roundstart))
	second.install_rack(new_rack = allocate(/obj/item/server_rack/roundstart))
	first.background_science = TRUE
	second.background_science = TRUE
	allocate(/obj/structure/ai_ethernet, first_tile, EAST)
	allocate(/obj/structure/ai_ethernet, second_tile, WEST)
	SSai_networks.rebuild()
	first.ai_subnet.name = "Альфа"
	second.ai_subnet.name = "Бета"
	first.ai_subnet.cpu_quota = 0.2
	second.ai_subnet.cpu_quota = 0.3
	first.ai_subnet.activity_cpu_quotas["research"] = 0.25
	second.ai_subnet.activity_cpu_quotas["research"] = 0.75
	allocate(/obj/structure/ai_ethernet, middle, EAST | WEST)
	SSai_networks.rebuild()
	AI_REVIEW_ASSERT(first.ai_subnet == second.ai_subnet && abs(first.ai_subnet.cpu_quota - 0.5) < 0.001, "Соединённые сегменты должны сохранять сумму ручных резервов CPU.")
	AI_REVIEW_ASSERT(findtext(first.ai_subnet.name, "Альфа") && findtext(first.ai_subnet.name, "Бета"), "Новое имя должно сохранять названия обоих сегментов.")
	AI_REVIEW_ASSERT(abs(first.ai_subnet.activity_cpu_quotas["research"] - 0.55) < 0.001, "Квота задач должна учитывать бюджеты обоих прежних сегментов.")
	var/list/budgets = list()
	var/list/plan = first.ai_network.background_cpu_plan(budgets)
	var/list/rows = first.ai_network.subnet_ui_data(plan, budgets)
	var/list/row = rows[1]
	AI_REVIEW_ASSERT(row["budget"] > row["cpu"], "Интерфейс должен отличать бюджет подсети от фактического расхода задач.")

/** Проверяет ревизию при изменении физических подсетей без изменения общей сети. */
/datum/unit_test/ai_review_subnet_revision

/datum/unit_test/ai_review_subnet_revision/Run()
	var/turf/first_tile = run_loc_floor_bottom_left
	var/turf/middle = get_step(first_tile, EAST)
	var/turf/second_tile = get_step(middle, EAST)
	var/obj/machinery/ai/network_bridge/first = allocate(/obj/machinery/ai/network_bridge, first_tile)
	var/obj/machinery/ai/network_bridge/second = allocate(/obj/machinery/ai/network_bridge, second_tile)
	first.set_machine_stat(NONE)
	second.set_machine_stat(NONE)
	allocate(/obj/structure/ai_ethernet, first_tile, EAST)
	var/obj/structure/ai_ethernet/cable = allocate(/obj/structure/ai_ethernet, middle, EAST | WEST)
	allocate(/obj/structure/ai_ethernet, second_tile, WEST)
	AI_REVIEW_ASSERT(first.connect_to(second), "Ретрансляторы должны соединяться до изменения кабеля.")
	SSai_networks.rebuild()
	var/datum/ai_network/network = first.ai_network
	var/revision = network.resource_policy_revision
	var/list/members = network.nodes + network.cables
	cable.set_ports(WEST)
	SSai_networks.rebuild()
	var/list/new_members = network.nodes + network.cables
	AI_REVIEW_ASSERT(first.ai_network == second.ai_network && !length(members - new_members) && !length(new_members - members), "Мост должен сохранить общий набор участников после физического разделения.")
	AI_REVIEW_ASSERT(first.ai_subnet != second.ai_subnet && network.resource_policy_revision > revision, "Изменение состава физических подсетей должно увеличивать ревизию.")
	AI_REVIEW_ASSERT(!network.activity_allocation_action("allocate_network_cpu", first.ai_subnet, "science", 0.5, revision), "Запоздавшая команда не должна менять квоты обновлённой подсети.")

/** Проверяет повторную авторизацию загрузки закона после подключения модуля. */
/datum/unit_test/ai_review_intrusion_authorization
	/// Текущее разрешение служебной программы в тесте.
	var/authorization_valid = TRUE

/** Возвращает изменяемое разрешение оператора без зависимости от диалога. */
/datum/unit_test/ai_review_intrusion_authorization/proc/authorize()
	return authorization_valid

/datum/unit_test/ai_review_intrusion_authorization/Run()
	var/mob/living/carbon/human/operator = allocate(/mob/living/carbon/human)
	var/obj/machinery/ai_law_rack/base/rack = allocate(/obj/machinery/ai_law_rack/base)
	rack.set_machine_stat(NONE)
	var/obj/item/ai_module/law/syndicate/module = allocate(/obj/item/ai_module/law/syndicate, rack)
	module.laws = list("Проверочный закон.")
	var/list/data = rack.law_intrusion_ui_data(operator)
	AI_REVIEW_ASSERT(!isnull(data["law_intrusion_signature"]), "Корневая стойка должна разрешать загрузку без поля parent_rack в интерфейсе.")
	var/datum/ai_law_intrusion/intrusion = allocate(/datum/ai_law_intrusion, module, rack, 2, ai_law_intrusion_recipients(rack), json_encode(module.laws), operator, CALLBACK(src, PROC_REF(authorize)))
	AI_REVIEW_ASSERT(intrusion.connection_valid(), "После подключения разрешённая загрузка должна продолжаться.")
	authorization_valid = FALSE
	AI_REVIEW_ASSERT(!intrusion.connection_valid(), "Потеря разрешения программы должна прерывать незавершённую загрузку.")
	authorization_valid = TRUE
	operator.forceMove(run_loc_floor_top_right)
	AI_REVIEW_ASSERT(!intrusion.connection_valid(), "Уход оператора от стойки должен прерывать терминальную загрузку.")

#undef AI_REVIEW_ASSERT
#endif
