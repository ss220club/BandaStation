// ============================================
// IPC ПОКОЛЕНИЕ IV: КИБЕРДЕКА
// ============================================
// + Кибердека: взлом дверей, консолей, турелей в радиусе CYBERDECK_SCAN_RANGE
// + Сниженный урон от ЭМИ (emp_vulnerability = 1)
// + +20% эффективности действий
// + Охлаждение в покое / у АПЦ / в холодных зонах
// - Нагрузка (heat) растёт от действий и взломов
// - При heat >= CYBERDECK_OVERHEAT_AT: ожоги + перебои
// - Требует больше ресурсов (ipc_repair_cost_mod = 1.5)
// - ЭМИ временно отключает кибердеку

#define IPC_GEN4_TRAIT_SOURCE "ipc_gen4"

/datum/actionspeed_modifier/ipc_gen4_bonus
	id = "ipc_gen4_bonus"
	variable = FALSE
	multiplicative_slowdown = -0.2  // +20% эффективности

/datum/action/innate/ipc_cyberdeck
	name = "Кибердека"
	desc = "Открыть интерфейс кибердеки для взлома устройств."
	button_icon_state = "ipc_os"
	/// Ссылка на вид КПБ
	var/datum/species/ipc/ipc_species = null

/datum/action/innate/ipc_cyberdeck/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !ipc_species)
		return
	if(ipc_species.cyberdeck_disabled)
		H.balloon_alert(H, "кибердека отключена (ЭМИ)")
		playsound(H, 'sound/machines/buzz/buzz-two.ogg', 30, FALSE)
		return
	if(ipc_species.cyberdeck_heat >= CYBERDECK_MAX_HEAT)
		H.balloon_alert(H, "перегрев кибердеки!")
		playsound(H, 'sound/machines/buzz/buzz-two.ogg', 30, FALSE)
		return
	// Открываем TGUI
	ipc_species.cyberdeck_ui_interact(H)

/datum/action/innate/ipc_cyberdeck/Remove(mob/M)
	. = ..()
	ipc_species = null

// ============================================
// ПРИМЕНЕНИЕ / СНЯТИЕ
// ============================================

/datum/species/ipc/proc/apply_gen4_cyberdeck(mob/living/carbon/human/H)
	// Сниженный ЭМИ урон
	emp_vulnerability = 1
	// Повышенная стоимость ремонта
	ipc_repair_cost_mod = 1.5
	// Начальное тепло
	cyberdeck_heat = 0
	cyberdeck_disabled = FALSE
	last_heat_dissipate_time = world.time

	// Бонус к действиям +20%
	H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen4_bonus)

	// Выдаём абилку кибердеки
	var/datum/action/innate/ipc_cyberdeck/cyberdeck_action = new()
	cyberdeck_action.ipc_species = src
	cyberdeck_action.Grant(H)

/datum/species/ipc/proc/remove_gen4_cyberdeck(mob/living/carbon/human/H)
	emp_vulnerability = 2
	ipc_repair_cost_mod = 1.0
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen4_bonus)

	var/datum/action/innate/ipc_cyberdeck/cyberdeck_action = locate() in H.actions
	if(cyberdeck_action)
		cyberdeck_action.Remove(H)

// ============================================
// ТИКОВАЯ ЛОГИКА
// ============================================

/datum/species/ipc/proc/handle_gen4_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	// Повторно включаем кибердеку после ЭМИ
	if(cyberdeck_disabled && world.time >= cyberdeck_reenable_time)
		cyberdeck_disabled = FALSE
		to_chat(H, span_notice("КИБЕРДЕКА: Системы перезагружены. Кибердека активна."))

	// Охлаждение кибердеки
	handle_gen4_cooling(H, seconds_per_tick)

	// Эффекты перегрева
	if(cyberdeck_heat >= CYBERDECK_OVERHEAT_AT)
		handle_gen4_overheat(H, seconds_per_tick)

/// Рассеивание тепла кибердеки.
/datum/species/ipc/proc/handle_gen4_cooling(mob/living/carbon/human/H, seconds_per_tick)
	if(cyberdeck_heat <= 0)
		cyberdeck_overheated = FALSE
		return

	var/dissipate_rate = CYBERDECK_IDLE_DISSIPATE * seconds_per_tick
	var/turf/T = get_turf(H)

	// Дополнительное охлаждение в холодных зонах
	if(T && T.temperature < 200)  // < -73°C = холодная зона
		dissipate_rate += 2 * seconds_per_tick

	// Охлаждение у АПЦ (если есть рядом)
	for(var/obj/machinery/power/apc/APC in range(1, H))
		dissipate_rate += 3 * seconds_per_tick
		break

	cyberdeck_heat = max(0, cyberdeck_heat - dissipate_rate)

	if(cyberdeck_heat < CYBERDECK_OVERHEAT_AT)
		cyberdeck_overheated = FALSE

/// Эффекты перегрева кибердеки.
/datum/species/ipc/proc/handle_gen4_overheat(mob/living/carbon/human/H, seconds_per_tick)
	if(!cyberdeck_overheated)
		cyberdeck_overheated = TRUE
		to_chat(H, span_userdanger("КИБЕРДЕКА: ПЕРЕГРЕВ! Термальная защита активирована!"))

	// Ожоги каждые ~5 секунд при перегреве
	if(prob(15 * seconds_per_tick))
		H.apply_damage(rand(2, 5), BURN, forced = TRUE)
		to_chat(H, span_danger("Кибердека перегревается — ожог внутренних цепей!"))

	// Визуальные помехи
	if(prob(10 * seconds_per_tick))
		H.set_jitter_if_lower(1 SECONDS)
		if(H.client)
			H.overlay_fullscreen("ipc_glitch", /atom/movable/screen/fullscreen/flash/static)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob, clear_fullscreen), "ipc_glitch", FALSE), 2 SECONDS)

// ============================================
// ЭМИ: ОТКЛЮЧЕНИЕ КИБЕРДЕКИ
// ============================================

/datum/species/ipc/proc/gen4_emp_disable_cyberdeck(mob/living/carbon/human/H, severity)
	var/disable_duration
	switch(severity)
		if(EMP_HEAVY)
			disable_duration = rand(30, 60) SECONDS
			to_chat(H, span_userdanger("ЭМИ: Кибердека отключена! Перезагрузка через [round(disable_duration/10)] сек."))
		if(EMP_LIGHT)
			disable_duration = rand(10, 25) SECONDS
			to_chat(H, span_danger("ЭМИ: Кибердека временно отключена."))
		else
			disable_duration = 15 SECONDS

	cyberdeck_disabled = TRUE
	cyberdeck_reenable_time = world.time + disable_duration
	// Добавляем тепло от ЭМИ
	cyberdeck_heat = min(CYBERDECK_MAX_HEAT, cyberdeck_heat + 20)

// ============================================
// ИНТЕРФЕЙС КИБЕРДЕКИ (TGUI)
// Используем сам /datum/species/ipc как TGUI источник —
// он устойчивый, существует пока живёт персонаж.
// ============================================

/datum/species/ipc/proc/cyberdeck_ui_interact(mob/living/carbon/human/H)
	ui_interact(H)

/datum/species/ipc/ui_state(mob/user)
	return GLOB.always_state

/datum/species/ipc/ui_interact(mob/user, datum/tgui/ui)
	if(ipc_generation != IPC_GEN_CYBERDECK)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IpcCyberdeck")
		ui.open()

/datum/species/ipc/ui_data(mob/user)
	if(ipc_generation != IPC_GEN_CYBERDECK)
		return list()
	var/mob/living/carbon/human/H = user
	var/list/data = list()
	data["heat"] = round(cyberdeck_heat, 1)
	data["max_heat"] = CYBERDECK_MAX_HEAT
	data["overheat_at"] = CYBERDECK_OVERHEAT_AT
	data["disabled"] = cyberdeck_disabled
	data["overheated"] = cyberdeck_overheated

	// Сканируем цели в радиусе
	var/list/targets = list()
	if(istype(H))
		for(var/atom/A in view(CYBERDECK_SCAN_RANGE, H))
			var/target_data = get_cyberdeck_target_data(A)
			if(target_data)
				targets += list(target_data)
	data["targets"] = targets
	return data

/datum/species/ipc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(ipc_generation != IPC_GEN_CYBERDECK)
		return

	var/mob/user = ui.user
	if(!istype(user, /mob/living/carbon/human))
		return TRUE

	if(cyberdeck_disabled)
		user.balloon_alert(user, "кибердека отключена!")
		return TRUE

	if(action == "hack")
		var/uid = params["uid"]
		var/hack_type = params["type"]
		var/hack_action = params["action"]
		if(!uid || !hack_type)
			return TRUE
		do_cyberdeck_hack(user, uid, hack_type, hack_action)
		return TRUE

/// Возвращает данные цели для кибердеки, или null если цель не взламываемая.
/datum/species/ipc/proc/get_cyberdeck_target_data(atom/A)
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = A
		return list(
			"uid" = "\ref[door]",
			"type" = "door",
			"name" = door.name,
			"heat_cost" = CYBERDECK_HEAT_HACK_DOOR,
			"status" = door.density ? "закрыта" : "открыта",
		)
	if(istype(A, /obj/machinery/porta_turret))
		var/obj/machinery/porta_turret/turret = A
		return list(
			"uid" = "\ref[turret]",
			"type" = "turret",
			"name" = turret.name,
			"heat_cost" = CYBERDECK_HEAT_HACK_TURRET,
			"status" = turret.on ? "активна" : "неактивна",
		)
	if(istype(A, /obj/machinery/computer))
		var/obj/machinery/computer/console = A
		return list(
			"uid" = "\ref[console]",
			"type" = "console",
			"name" = console.name,
			"heat_cost" = CYBERDECK_HEAT_HACK_CONSOLE,
			"status" = (console.machine_stat & NOPOWER) ? "без питания" : "активна",
		)
	return null

/datum/species/ipc/proc/do_cyberdeck_hack(mob/living/carbon/human/H, uid, hack_type, hack_action)
	// Находим объект по ref
	var/atom/target = locate(uid)
	if(!target || get_dist(H, target) > CYBERDECK_SCAN_RANGE)
		H.balloon_alert(H, "цель вне зоны досягаемости")
		return

	// Добавляем тепло
	var/heat_cost = 0
	switch(hack_type)
		if("door")
			heat_cost = CYBERDECK_HEAT_HACK_DOOR
		if("turret")
			heat_cost = CYBERDECK_HEAT_HACK_TURRET
		if("console")
			heat_cost = CYBERDECK_HEAT_HACK_CONSOLE

	cyberdeck_heat = min(CYBERDECK_MAX_HEAT, cyberdeck_heat + heat_cost)

	// Выполняем взлом
	switch(hack_type)
		if("door")
			hack_door(H, target, hack_action)
		if("turret")
			hack_turret(H, target, hack_action)
		if("console")
			hack_console(H, target, hack_action)

	playsound(H, 'sound/machines/terminal/terminal_alert.ogg', 40, FALSE)
	SStgui.update_uis(src)  // обновляем интерфейс

/datum/species/ipc/proc/hack_door(mob/living/carbon/human/H, obj/machinery/door/airlock/door, action)
	if(!istype(door))
		return
	switch(action)
		if("open")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом шлюза [door.name] — открываю."))
			door.open(2)
		if("close")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом шлюза [door.name] — закрываю."))
			door.close(2)
		if("bolt")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом шлюза [door.name] — блокирую засовы."))
			door.bolt(TRUE)
		if("unbolt")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом шлюза [door.name] — снимаю блокировку."))
			door.bolt(FALSE)

/datum/species/ipc/proc/hack_turret(mob/living/carbon/human/H, obj/machinery/porta_turret/turret, action)
	if(!istype(turret))
		return
	switch(action)
		if("disable")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом турели [turret.name] — деактивирую."))
			turret.toggle_on(FALSE)
		if("enable")
			to_chat(H, span_notice("КИБЕРДЕКА: Взлом турели [turret.name] — активирую."))
			turret.toggle_on(TRUE)

/datum/species/ipc/proc/hack_console(mob/living/carbon/human/H, obj/machinery/computer/console, action)
	if(!istype(console))
		return
	// Открываем консоль как если бы пользователь подошёл к ней
	to_chat(H, span_notice("КИБЕРДЕКА: Удалённый доступ к [console.name]."))
	console.ui_interact(H)
