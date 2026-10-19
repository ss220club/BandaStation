/** Разрешает совместные команды ИИ только в физически настроенных помещениях. */
/obj/machinery/ai/master_subcontroller
	name = "master subcontroller"
	desc = "Координатор ИИ (Master Subcontroller). Контроллер совместных операций ИИ. Проведите под ним оптоволоконный кабель. Робототехники настраивают разрешённые зоны мультитулом на месте."
	icon = 'modular_bandastation/ai_overhaul/icons/telecomms.dmi'
	icon_state = "hub"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	circuit = /obj/item/circuitboard/machine/ai_master_subcontroller
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_RD)
	/// Помещения, в которых физически разрешены совместные команды ИИ.
	var/list/enabled_areas = list()

/obj/machinery/ai/master_subcontroller/Destroy()
	enabled_areas.Cut()
	return ..()

/** Проверяет готовность запитанного и закреплённого координатора. */
/obj/machinery/ai/master_subcontroller/proc/available()
	return anchored && !panel_open && !(machine_stat & (BROKEN | NOPOWER | EMPED)) && isturf(loc) && !!network_cable()

/** Проверяет, разрешены ли совместные команды в указанном помещении. */
/obj/machinery/ai/master_subcontroller/proc/covers(area/target)
	return available() && (!target || (target in enabled_areas))

/** Разрешает настройку зон только человеку с физическим доступом и правами. */
/obj/machinery/ai/master_subcontroller/proc/can_configure(mob/living/user)
	return !QDELETED(src) && user && !issilicon(user) && user.Adjacent(src) && !user.incapacitated && allowed(user)

/obj/machinery/ai/master_subcontroller/multitool_act(mob/living/user, obj/item/tool)
	if(!can_configure(user))
		balloon_alert(user, "нужен местный доступ робототехники!")
		return ITEM_INTERACT_BLOCKING
	var/list/options = list()
	var/area_index = 0
	for(var/area/station/zone in GLOB.areas)
		options["[++area_index]. [zone.declent_ru()] — [(zone in enabled_areas) ? "ВКЛЮЧЕНО" : "отключено"]"] = zone
	var/choice = tgui_input_list(user, "Выберите зону, чтобы разрешить или запретить совместные команды ИИ.", name, options)
	if(!choice || !can_configure(user))
		return ITEM_INTERACT_BLOCKING
	var/area/zone = options[choice]
	if(zone in enabled_areas)
		enabled_areas -= zone
	else
		enabled_areas += zone
	log_game("[key_name(user)] [(zone in enabled_areas) ? "enabled" : "disabled"] subcontroller coverage for [zone] at [AREACOORD(src)].")
	balloon_alert(user, "разрешения зон обновлены")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/master_subcontroller/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "hub_o", "hub", tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai/master_subcontroller/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai/master_subcontroller/examine(mob/user)
	. = ..()
	. += span_notice("[available() ? "Координатор работает" : "Координатор недоступен: проверьте питание, панель, болты и оптоволоконный кабель"].")
	. += span_notice("Разрешённых зон: [length(enabled_areas)]. В этих зонах открывает мгновенный доступ к панелям ЛКП и воздушных сигнализаций и позволяет использовать блокировку помещения. Настройте зоны мультитулом на месте.")

/** Ищет работающий координатор своей сети, при target также проверяет разрешённую зону. */
/mob/living/silicon/ai/proc/find_subcontroller(area/target)
	RETURN_TYPE(/obj/machinery/ai/master_subcontroller)
	SSai_networks.rebuild()
	if(control_disabled || stat == DEAD || !istype(loc, /obj/machinery/ai/data_core))
		return null
	var/obj/machinery/ai/data_core/host = loc
	if(!host.ai_network || !host.has_power() || (host.machine_stat & (BROKEN | EMPED)))
		return null
	for(var/obj/machinery/ai/master_subcontroller/controller in host.ai_network.nodes)
		if(controller.covers(target))
			return controller
	return null

/** Плата для сборки координатора ИИ штатными инструментами. */
/obj/item/circuitboard/machine/ai_master_subcontroller
	name = "Master Subcontroller"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ai/master_subcontroller
	req_components = list(/datum/stock_part/capacitor = 2, /datum/stock_part/matter_bin = 1, /obj/item/stack/cable_coil = 5)

/** Открывает изготовление платы координатора ИИ. */
/datum/design/board/ai_master_subcontroller
	name = "Master Subcontroller"
	desc = "Настраиваемый координатор совместных операций ИИ."
	build_path = /obj/item/circuitboard/machine/ai_master_subcontroller
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
