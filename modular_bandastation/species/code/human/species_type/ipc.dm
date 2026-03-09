/datum/species/ipc
	name = "IPC"
	id = SPECIES_IPC
	sexes = TRUE

	// Визуальные параметры
	meat = null
	inherent_biotypes = MOB_ROBOTIC
	exotic_bloodtype = BLOOD_TYPE_OIL
	species_language_holder = /datum/language_holder/synthetic

	// Физиологические особенности
	mutantstomach = null
	mutantliver = null
	mutantlungs = /obj/item/organ/lungs/ipc
	mutantbrain = /obj/item/organ/brain/positronic
	mutantheart = /obj/item/organ/heart/ipc_battery
	mutanteyes = /obj/item/organ/eyes/robotic/ipc
	mutanttongue = /obj/item/organ/tongue/robot/ipc
	mutantears = /obj/item/organ/ears/robot/ipc

	// ВАЖНО: Указываем какие bodyparts использовать
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ipc,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ipc,
	)

	// Особенности вида
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_GENELESS,
		TRAIT_NOCRITDAMAGE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_LIMBATTACHMENT,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOHUNGER,  // IPC не едят, нет HUD голода
		TRAIT_NOBLOOD,   // ИПС не имеет крови (масло не является кровью для игровых механик)
	)

	// Урон модификаторы
	var/brute_mod = 0.8
	var/burn_mod = 1.5
	var/heat_mod = 1.3
	var/cold_mod = 0.5

	// Переменные для температурной системы
	var/cpu_temperature = 30
	var/cpu_temp_optimal_min = 20
	var/cpu_temp_optimal_max = 40
	var/cpu_temp_critical = 130
	var/cpu_cooling_rate = 0.1
	var/cpu_heating_from_environment = TRUE

	// Модификатор скорости взаимодействия от температуры
	var/temp_interaction_speed_mod = 1.0

	// Таймеры для урона от перегрева
	var/last_overheat_damage_time = 0
	var/last_critical_damage_time = 0
	var/last_extreme_damage_time = 0

	// Системы охлаждения
	var/thermal_paste_active = FALSE
	var/thermal_paste_end_time = 0
	var/improved_cooling_installed = FALSE
	var/cooling_block_active = FALSE
	var/cooling_block_end_time = 0

	// Разгон системы
	var/overclock_active = FALSE
	var/overclock_speed_bonus = 0.4  // 40% ускорение по умолчанию

	// Переменные для шасси
	var/chassis_manufacturer = "Unbranded"

	// Лечение
	var/self_repair_enabled = TRUE
	var/self_repair_amount = 0.5
	var/self_repair_delay = 100
	var/last_repair_time = 0

	// ЭМП уязвимость
	var/emp_vulnerability = 2
	// Ключ выбранного бренда из фичи (morpheus, etamin, bishop, ...)
	var/ipc_brand_key = "unbranded"
	// Ключ визуального бренда (используется только для HEF, иначе = ipc_brand_key)
	var/ipc_visual_brand_key = "unbranded"

	// Операционная система IPC
	var/datum/ipc_operating_system/ipc_os
	// Пароль ОС из настроек персонажа (применяется при инициализации ОС)
	var/ipc_preset_os_password = ""

	// HEF: поштучный выбор бренда для каждой части тела.
	// Каждое значение — ключ бренда (morpheus, etamin, ..., unbranded).
	// Используется ТОЛЬКО когда ipc_brand_key == "hef".
	var/hef_head = "unbranded"
	var/hef_chest = "unbranded"
	var/hef_l_arm = "unbranded"
	var/hef_r_arm = "unbranded"
	var/hef_l_leg = "unbranded"
	var/hef_r_leg = "unbranded"
	// Модификатор термической релаксации (Etamin: -0.2)
	var/ipc_thermal_relaxation_mod = 0
	// Модификатор скорости перегрева (Xion: 0.8 = 80%)
	var/ipc_overheat_rate_mod = 1.0
	// Модификатор стоимости ремонта (Cybersun: 1.5)
	var/ipc_repair_cost_mod = 1.0
	// Дополнительные слоты IPC-имплантов: >0 = больше, <0 = меньше (Ward: -1, Cybersun: -1)
	var/ipc_extra_implant_slots = 0

	// Дополнительные модификаторы от шасси
	// Список модификаторов: "overheat_rate", "healing_time", "melee_damage", "implant_slots", и т.д.
	var/list/ipc_chassis_modifiers = list()

	// Ментанил (препарат человечности Gen III)
	/// Счётчик использований ментанила (для механики зависимости)
	var/mentalin_uses = 0

	// ---- Косметика ----
	/// Текущее выражение экрана (задаётся только в игре через абилку, не сохраняется)
	var/ipc_face_state = ""
	/// Зона установки зарядного порта (задаётся из настроек персонажа)
	var/ipc_charger_arm_zone = BODY_ZONE_L_ARM

	// ---- Поколение ----
	/// Поколение КПБ: gen1_modular / gen2_standard / gen3_humanity / gen4_cyberdeck
	var/ipc_generation = IPC_GEN_STANDARD
	/// Для gen1: модуль профессии (medical / engineering / security / research)
	var/ipc_gen1_module = IPC_MODULE_SECURITY

	// ---- Gen 1: Переключение модуля ----
	/// Целевой модуль во время переконфигурации (пуст если не идёт)
	var/module_switch_target = ""
	/// Время начала переконфигурации (world.time)
	var/module_switch_start_time = 0
	/// Последний порог предупреждения (секунд до конца) чтобы не дублировать сообщения
	var/module_switch_last_threshold = 999

	// ---- Gen 3: Человечность ----
	/// Текущий уровень человечности (0-100)
	var/humanity = 100
	/// Время последнего снижения человечности (world.time)
	var/last_humanity_decay_time = 0
	/// Препарат активен — заморозка снижения
	var/humanity_drug_active = FALSE
	/// Время окончания действия препарата
	var/humanity_drug_end_time = 0
	/// Количество использований препарата (для зависимости)
	var/humanity_drug_uses = 0

	// ---- Gen 4: Кибердека ----
	/// Кибердека отключена (ЭМИ)
	var/cyberdeck_disabled = FALSE
	/// Время повторного включения кибердеки после ЭМИ
	var/cyberdeck_reenable_time = 0

/datum/species/ipc/get_species_description()
	return "IPC (Integrated Positronic Construct) — синтетические гуманоидные формы жизни, управляемые позитронным вычислительным блоком (КПБ). \
	В отличие от обычных роботов, КПБ способны обеспечивать различный уровень автономии и самосознания, \
	благодаря чему IPC занимают промежуточное положение между машиной и личностью."

/datum/species/ipc/get_species_lore()
	return list(
		"Хотя крупнейшие корпорации остаются основными производителями позитронных процессоров и шасси, технология создания КПБ со временем \
		распространилась далеко за пределы корпоративных лабораторий. Сегодня такие системы могут быть собраны не только промышленными предприятиями, \
		но и независимыми инженерами, на частных верфях и даже в небольших мастерских. IPC широко используются в космической индустрии — \
		от технического персонала станций до экипажей кораблей и автономных экспедиционных групп.",

		"Поколения КПБ:\n\
		I поколение — простейшие позитронные системы с крайне ограниченной автономией. Такие IPC способны выполнять сложные задачи, \
		но их деятельность обычно контролируется оператором. Именно из-за этой необходимости постоянного наблюдения закрепился термин «оператор».\n\
		II поколение — более развитые системы, обладающие базовым самосознанием и способностью принимать самостоятельные решения. \
		Несмотря на это, юридически они всё ещё считаются оборудованием.\n\
		III поколение — КПБ, содержащие оцифрованное человеческое сознание. На территории ТСФ и Скрелианской Империи создание таких КПБ является тяжким преступлением. \
		Несмотря на запреты, подпольные лаборатории продолжают заниматься подобными экспериментами.\n\
		IV поколение — самые современные позитронные архитектуры, создающие полностью искусственную личность без использования человеческого сознания. \
		После активации такие IPC юридически считаются имуществом своего владельца и обязаны служить ему в течение десяти лет. \
		По окончании срока синтетик может продлить контракт, сменить владельца или получить полную автономию.",

		"Операторы:\n\
		Лица, владеющие или курирующие КПБ, традиционно называются операторами — термин, сохранившийся со времён первого поколения. \
		Внутри этой системы сложилась неформальная иерархия: Мейн-оператор — основной владелец или юридический хозяин КПБ. \
		Оператор — человек с административным доступом или временным контролем. \
		Куратор — специалист, обслуживающий КПБ без права собственности. \
		Суб-оператор — любой органик, взаимодействующий через интерфейсы без формальной власти.",

		"Независимые IPC и «Призрачные флоты»:\n\
		Помимо официально зарегистрированных синтетиков существует большое количество незарегистрированных КПБ. \
		Многие из них объединяются в небольшие сообщества кораблей, известные как Призрачные флоты — флотилии, полностью состоящие из машин, \
		без систем жизнеобеспечения для органических существ. IPC в таких флотах называют «призраками». \
		Они предпочитают взаимодействовать с другими КПБ и плохо чувствуют себя на планетах. \
		Многие призрачные флоты объявлены в розыск за пиратство, контрабанду и мародёрство, \
		хотя существует и небольшая прослойка сертифицированных коммерческих компаний из независимых IPC.",
	)

/datum/species/ipc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()
	replace_body(H, src)
	H.update_body()
	H.update_body_parts()

	// Даем IPC абилки
	var/datum/action/cooldown/ipc_overclock/overclock = new()
	overclock.Grant(H)

	// ipc_hack НЕ выдаётся автоматически — покупается в аплинке трейтора.

	// Выдаём встроенный зарядный порт в левую руку по умолчанию.
	// Настройка руки через ipc_charger_arm preference переставит его при загрузке.
	var/obj/item/implant/ipc/charger/charger_impl = new()
	charger_impl.implant(H, BODY_ZONE_L_ARM, null, TRUE, TRUE)

	// Регистрируем обработчик применения настроек персонажа
	// (используется для установки брендовых имплантов в нужные руки после загрузки всех настроек)
	RegisterSignal(H, COMSIG_HUMAN_PREFS_APPLIED, PROC_REF(on_prefs_applied))

	// Регистрируем обработчик электрошока
	RegisterSignal(H, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

	// Инициализируем операционную систему IPC
	if(!ipc_os)
		ipc_os = new /datum/ipc_operating_system(H, ipc_brand_key)
	// Применяем пароль из настроек персонажа (если задан)
	if(ipc_preset_os_password && length(ipc_preset_os_password) >= 1)
		ipc_os.set_password(ipc_preset_os_password)
		ipc_os.logged_in = TRUE
	var/datum/action/innate/ipc_open_os/os_action = new()
	os_action.os_system = ipc_os
	os_action.Grant(H)

	// Абилка смены экрана — только для брендов, поддерживающих экраны
	if(ipc_brand_key != "zeng_hu" && ipc_brand_key != "cybersun")
		var/datum/action/innate/ipc_change_face/face_action = new()
		face_action.Grant(H)

	// Применяем механики поколения
	apply_generation(H)

	// Заменяем муд нейтральным (setup_mood() вызывается до dna.species — нужна ручная замена)
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)
	H.mob_mood = new /datum/mood/ipc_neutral(H)

	// HUD: регистрируем сигнал создания HUD и сразу добавляем элементы если HUD уже есть
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	if(H.hud_used)
		on_hud_created(H)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	// Удаляем IPC абилки
	var/datum/action/cooldown/ipc_overclock/overclock = locate(/datum/action/cooldown/ipc_overclock) in H.actions
	if(overclock)
		overclock.Remove(H)

	// ipc_hack — если была куплена в аплинке, удаляем при смене вида
	var/datum/action/cooldown/ipc_hack/hack = locate(/datum/action/cooldown/ipc_hack) in H.actions
	if(hack)
		hack.Remove(H)

	// Удаляем кнопку ОС
	var/datum/action/innate/ipc_open_os/os_action = locate() in H.actions
	if(os_action)
		os_action.Remove(H)

	// Удаляем кнопку смены экрана
	var/datum/action/innate/ipc_change_face/face_action = locate() in H.actions
	if(face_action)
		face_action.Remove(H)

	// Убираем механики поколения
	remove_generation(H)

	// Удаляем ОС
	QDEL_NULL(ipc_os)

	// Отменяем регистрацию сигналов
	UnregisterSignal(H, list(COMSIG_LIVING_ELECTROCUTE_ACT, COMSIG_HUMAN_PREFS_APPLIED, COMSIG_MOB_HUD_CREATED, COMSIG_MOB_SAY))
	// Удаляем трейты от брендов
	REMOVE_TRAIT(H, TRAIT_SILENT_FOOTSTEPS, "cybersun_brand")

	// HUD: удаляем элементы и восстанавливаем муд
	remove_ipc_hud_elements(H, new_species)
	if(istype(H.mob_mood, /datum/mood/ipc_neutral))
		QDEL_NULL(H.mob_mood)
		H.setup_mood()

/// Вызывается после загрузки всех настроек персонажа.
/// К этому моменту все preferences уже применены (ipc_generation, ipc_preset_os_password и т.д.).
/datum/species/ipc/proc/on_prefs_applied(mob/living/carbon/human/H)
	SIGNAL_HANDLER

	// ---- Переприменяем поколение ----
	// on_species_gain вызывается ДО apply_to_human, поэтому apply_generation
	// там срабатывает с дефолтным значением (gen2_standard).
	// Здесь мы убираем дефолтное поколение и применяем нужное.
	remove_generation(H)
	apply_generation(H)

	// ---- Применяем пароль ОС ----
	// on_species_gain создаёт ipc_os до того как apply_to_human выставил пароль.
	// Применяем пароль здесь, когда он уже известен.
	if(ipc_os && ipc_preset_os_password && length(ipc_preset_os_password) >= 1)
		ipc_os.set_password(ipc_preset_os_password)
		ipc_os.logged_in = TRUE

	// Для Shellguard: силовой щит в руку, противоположную зарядному порту
	if(ipc_brand_key == "shellguard")
		if(!(locate(/obj/item/implant/ipc/force_shield) in H.implants))
			// Находим руку зарядника
			var/charger_zone = ipc_charger_arm_zone
			var/obj/item/implant/ipc/charger/charger_impl = locate(/obj/item/implant/ipc/charger) in H.implants
			if(charger_impl)
				charger_zone = charger_impl.installed_in_zone
			// Устанавливаем щит в противоположную руку
			var/shield_zone = (charger_zone == BODY_ZONE_L_ARM) ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM
			var/obj/item/implant/ipc/force_shield/shield_impl = new()
			shield_impl.implant(H, shield_zone, null, TRUE, TRUE)

/datum/species/ipc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	handle_self_repair(H)
	handle_temperature(H, seconds_per_tick)
	handle_temperature_effects(H)
	handle_battery(H)
	// Применяем модификатор скорости действий от температуры и разгона
	update_action_speed(H)
	// HUD обновления
	update_ipc_temperature_icon(H)
	handle_generation_life(H, seconds_per_tick, times_fired)
	update_ipc_generation_hud(H)

/datum/species/ipc/proc/handle_self_repair(mob/living/carbon/human/H)
	if(!self_repair_enabled)
		return

	if(world.time < last_repair_time + self_repair_delay)
		return

	if(H.get_brute_loss() > 0)
		H.heal_overall_damage(brute = self_repair_amount, forced = TRUE)
		last_repair_time = world.time

	if(H.get_fire_loss() > 0)
		H.heal_overall_damage(burn = self_repair_amount * 0.5, forced = TRUE)
		last_repair_time = world.time

/datum/species/ipc/proc/handle_temperature(mob/living/carbon/human/H, seconds_per_tick)
	// Проверяем истечение эффектов охлаждения
	if(thermal_paste_active && world.time > thermal_paste_end_time)
		thermal_paste_active = FALSE
		to_chat(H, span_warning("Эффект термопасты закончился."))

	if(cooling_block_active && world.time > cooling_block_end_time)
		cooling_block_active = FALSE
		to_chat(H, span_warning("Охладительный блок перестал действовать."))

	// Базовое охлаждение/нагрев от окружающей среды
	var/turf/T = get_turf(H)
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			var/env_temp = environment.temperature - T0C

			// Окружающая среда охлаждает или нагревает
			if(env_temp < cpu_temperature)
				var/cooling_amount = min((cpu_temperature - env_temp) * 0.01, cpu_cooling_rate * 2)
				cpu_temperature = max(cpu_temperature - cooling_amount, env_temp)
			else if(env_temp > cpu_temperature && cpu_heating_from_environment)
				var/heating_amount = min((env_temp - cpu_temperature) * 0.005, cpu_cooling_rate)
				cpu_temperature = min(cpu_temperature + heating_amount, env_temp)

	// Применяем активное охлаждение от охладительного блока
	if(cooling_block_active)
		cpu_temperature = max(cpu_temperature - 1 * seconds_per_tick, 0)

	// Пассивное охлаждение от термопасты и импланта (постоянное активное охлаждение)
	// Термопаста/имплант дают постоянное охлаждение которое компенсирует часть нагрева
	var/passive_cooling_rate = 0
	if(thermal_paste_active)
		passive_cooling_rate += 1  // 1°C/сек охлаждения
	if(improved_cooling_installed)
		passive_cooling_rate += 1  // еще 1°C/сек

	if(passive_cooling_rate > 0)
		// ipc_thermal_relaxation_mod < 0 = медленнее охлаждается (Etamin: -0.2)
		var/cooling_mult = 1 + ipc_thermal_relaxation_mod
		cpu_temperature = max(cpu_temperature - (passive_cooling_rate * cooling_mult * seconds_per_tick), 0)

	// Охлаждение от баллона с холодным газом (через маску) - активное
	// Эффективность зависит от температуры газа И теплоемкости (specific_heat)
	if(H.internal && istype(H.internal, /obj/item/tank))
		var/obj/item/tank/gas_tank = H.internal
		var/datum/gas_mixture/gas = gas_tank.return_air()
		if(gas && gas.total_moles() > 0.05)
			var/gas_temp = gas.temperature - T0C

			// Рассчитываем средний specific_heat газовой смеси
			var/total_heat_capacity = 0
			var/total_moles = gas.total_moles()

			for(var/gas_id in gas.gases)
				var/list/cached_gas = gas.gases[gas_id]
				var/gas_moles = cached_gas[MOLES]
				if(gas_moles > 0)
					var/datum/gas/gas_datum = gas_id2path(gas_id)
					var/list/gas_info = GLOB.meta_gas_info[gas_datum]
					if(gas_info)
						var/specific_heat = gas_info[META_GAS_SPECIFIC_HEAT]
						// Взвешенный вклад каждого газа
						total_heat_capacity += specific_heat * (gas_moles / total_moles)

			// Модификатор эффективности на основе теплоемкости
			// Базовый газ (O2/N2) = 20, множитель = 1.0
			// Freon = 600, множитель = 30
			// Hypernoblium = 2000, множитель = 100
			var/heat_capacity_multiplier = total_heat_capacity / 20 // 20 = базовая теплоемкость O2/N2

			var/cooling_from_gas = 0

			// Эффективность охлаждения зависит от температуры газа
			if(gas_temp < cpu_temperature) // Охлаждение только если газ холоднее процессора
				var/temp_diff = cpu_temperature - gas_temp

				// Базовая формула: 0.01°C/сек на каждый градус разницы * модификатор теплоемкости
				cooling_from_gas = temp_diff * 0.01 * heat_capacity_multiplier

				// Ограничиваем максимум в зависимости от теплоемкости
				// Обычный газ (20): макс 2°C/сек
				// Freon (600): макс 60°C/сек
				// Hypernoblium (2000): макс 200°C/сек
				var/max_cooling = heat_capacity_multiplier * 2
				cooling_from_gas = min(cooling_from_gas, max_cooling)

			if(cooling_from_gas > 0)
				cpu_temperature = max(cpu_temperature - (cooling_from_gas * seconds_per_tick), 0)
				// Расходуем газ пропорционально охлаждению (больше охлаждение = больше расход)
				var/gas_consumption = 0.01 * (cooling_from_gas / 2) // 0.01 моль/сек на каждые 2°C охлаждения
				if(gas.total_moles() > gas_consumption)
					gas.remove(gas_consumption * seconds_per_tick)

	// Разгон системы нагревает процессор
	if(overclock_active)
		// +2 градуса в секунду = +10 градусов каждые 5 секунд
		cpu_temperature += 2 * seconds_per_tick

	// Нагрев от взаимодействий/действий
	// Чем больше действий выполняет IPC, тем больше нагревается процессор
	if(H.client)
		// Проверяем активность персонажа через recent_click_time или активные действия
		// Базовый нагрев: +0.05°C/сек при активности
		var/activity_heating = 0.05

		// Дополнительный нагрев если персонаж бежит
		if(H.move_intent == MOVE_INTENT_RUN)
			activity_heating += 0.02

		// Дополнительный нагрев при низком здоровье (стресс системы)
		if(H.health < H.maxHealth * 0.5)
			activity_heating += 0.03

		cpu_temperature += activity_heating * seconds_per_tick

	// Ограничиваем температуру
	cpu_temperature = clamp(cpu_temperature, 0, 200)

/// Обрабатывает эффекты температуры: урон, стамину, модификаторы скорости
/datum/species/ipc/proc/handle_temperature_effects(mob/living/carbon/human/H)
	// Расчет модификатора скорости взаимодействия по температуре
	switch(cpu_temperature)
		if(-INFINITY to 20)
			// Меньше 20°C: -10% скорости
			temp_interaction_speed_mod = 1.1  // Больше = медленнее
		if(20 to 40)
			// 20-40°C (оптимально): +10% скорости
			temp_interaction_speed_mod = 0.9  // Меньше = быстрее
		if(40 to 80)
			// 40-80°C (горячо): нормальная скорость
			temp_interaction_speed_mod = 1.0
		if(80 to 90)
			// 80-90°C (перегрев): -10% скорости
			temp_interaction_speed_mod = 1.1
		if(90 to 120)
			// 90-120°C (сильный перегрев): -10% скорости + урон
			temp_interaction_speed_mod = 1.1
			// -1 урон каждые 30 секунд к мозгу
			if(world.time > last_overheat_damage_time + 30 SECONDS)
				var/obj/item/organ/brain/positronic/brain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
				if(brain)
					brain.apply_organ_damage(1)
					to_chat(H, span_danger("ПРЕДУПРЕЖДЕНИЕ: Перегрев процессора! Температура: [round(cpu_temperature)]°C"))
				last_overheat_damage_time = world.time
		if(120 to 130)
			// 120-130°C (критический перегрев): -10% скорости + сильный урон + шанс потери стамины
			temp_interaction_speed_mod = 1.1
			// -2 урона каждые 15 секунд к мозгу
			if(world.time > last_critical_damage_time + 15 SECONDS)
				var/obj/item/organ/brain/positronic/brain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
				if(brain)
					brain.apply_organ_damage(2)
					to_chat(H, span_userdanger("КРИТИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ: Процессор горит! Температура: [round(cpu_temperature)]°C"))
				last_critical_damage_time = world.time

				// 10% шанс потери 20% стамины
				if(prob(10))
					H.adjust_stamina_loss(H.max_stamina * 0.2)
					to_chat(H, span_danger("Системы управления перегружены! Потеряна стамина."))
		if(130 to INFINITY)
			// 130°C+ (экстремальный перегрев): -10% скорости + экстремальный урон + 50% шанс потери стамины
			temp_interaction_speed_mod = 1.1
			// -3 урона каждые 10 секунд к мозгу
			if(world.time > last_extreme_damage_time + 10 SECONDS)
				var/obj/item/organ/brain/positronic/brain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
				if(brain)
					brain.apply_organ_damage(3)
					to_chat(H, span_boldwarning("!!! АВАРИЙНОЕ ОТКЛЮЧЕНИЕ !!! Процессор расплавляется! Температура: [round(cpu_temperature)]°C !!!"))
				last_extreme_damage_time = world.time

				// 50% шанс критической потери стамины
				if(prob(50))
					H.adjust_stamina_loss(H.max_stamina * 0.5)
					to_chat(H, span_userdanger("КРИТИЧЕСКИЙ ОТКАЗ СИСТЕМЫ! Стамина критически низкая!"))

/// Обновляет скорость действий на основе температуры и разгона
/datum/species/ipc/proc/update_action_speed(mob/living/carbon/human/H)
	// Базовый модификатор от температуры (temp_interaction_speed_mod уже рассчитан в handle_temperature_effects)
	var/total_modifier = temp_interaction_speed_mod

	// Разгон дает бонус к скорости
	if(overclock_active)
		total_modifier *= (1 - overclock_speed_bonus)  // 0.6 = 40% быстрее

	// Применяем модификатор к скорости действий
	// Меньше 1.0 = быстрее, больше 1.0 = медленнее
	H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/ipc_temperature, multiplicative_slowdown = (total_modifier - 1))

/datum/species/ipc/proc/handle_battery(mob/living/carbon/human/H)
	var/obj/item/organ/heart/heart = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || !heart.ipc_max_charge)
		to_chat(H, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания не обнаружен!"))
		H.apply_damage(2, OXY, forced = TRUE)
		return

	// Зарядка от ближайшего АРС (кабель подключён)
	if(heart.get_ipc_charging())
		var/area/current_area = get_area(H)
		if(current_area)
			var/obj/machinery/power/apc/nearby_apc = locate(/obj/machinery/power/apc) in current_area
			if(nearby_apc && nearby_apc.operating && nearby_apc.cell && nearby_apc.cell.charge > 0)
				var/draw_amount = min(100, nearby_apc.cell.charge)
				nearby_apc.cell.charge -= draw_amount
				heart.ipc_charge_from(25)
			else if(prob(10))
				to_chat(H, span_warning("Нет доступного источника питания для зарядки!"))

	if(heart.get_ipc_charge() <= 0)
		to_chat(H, span_danger("ПРЕДУПРЕЖДЕНИЕ: Источник питания разряжен. Требуется подзарядка."))
		H.Unconscious(2 SECONDS)

/datum/species/ipc/proc/set_chassis(mob/living/carbon/human/H, chassis_name)
	chassis_manufacturer = chassis_name
	to_chat(H, span_notice("Шасси установлено: [chassis_name]"))

/datum/species/ipc/spec_stun(mob/living/carbon/human/H, amount)
	. = ..()

/// Обработчик сигнала электрошока - повышает температуру процессора
/datum/species/ipc/proc/on_electrocute(mob/living/carbon/human/source, shock_damage, siemens_coeff, flags)
	SIGNAL_HANDLER
	// Базовое повышение на 10 градусов от удара током
	cpu_temperature = min(cpu_temperature + 10, 200)
	to_chat(source, span_warning("Удар током повысил температуру процессора на 10°C!"))

/datum/species/ipc/proc/handle_emp(mob/living/carbon/human/H, severity)
	// Поколение I — особый ЭМИ (оглушение вместо паралича)
	if(ipc_generation == IPC_GEN_MODULAR)
		gen1_handle_emp(H, severity)
		return
	// Поколение II — Stun 1-3 сек + ожоги (без Paralyze)
	if(ipc_generation == IPC_GEN_STANDARD)
		gen2_handle_emp(H, severity)
		return

	var/emp_damage = 0
	switch(severity)
		if(EMP_HEAVY)
			emp_damage = rand(20, 40) * emp_vulnerability
			to_chat(H, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Электромагнитный импульс обнаружен! Системы повреждены!"))
			H.Paralyze(6 SECONDS)
		if(EMP_LIGHT)
			emp_damage = rand(10, 20) * emp_vulnerability
			to_chat(H, span_danger("ПРЕДУПРЕЖДЕНИЕ: Обнаружен электромагнитный импульс!"))
			H.Paralyze(3 SECONDS)

	H.apply_damage(emp_damage * 0.5, BRUTE, forced = TRUE)
	H.apply_damage(emp_damage * 0.5, BURN, forced = TRUE)
	cpu_temperature = min(cpu_temperature + (emp_damage * 0.5), cpu_temp_critical)

	// Поколение IV — кибердека отключается от ЭМИ
	if(ipc_generation == IPC_GEN_CYBERDECK)
		gen4_emp_disable_cyberdeck(H, severity)

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	if(owner && istype(owner.dna.species, /datum/species/ipc))
		var/datum/species/ipc/S = owner.dna.species
		S.handle_emp(owner, severity)

/datum/species/ipc/proc/try_repair_brute(mob/living/carbon/human/H, obj/item/tool, mob/user)
	if(!istype(tool, /obj/item/weldingtool))
		return FALSE

	var/obj/item/weldingtool/welder = tool

	if(!welder.isOn())
		to_chat(user, span_warning("[welder] не включен!"))
		return FALSE

	if(H.get_brute_loss() <= 0)
		to_chat(user, span_notice("[H] не имеет механических повреждений."))
		return FALSE

	if(!welder.use_tool(H, user, 0, volume = 50, amount = 1))
		return FALSE

	user.visible_message(
		span_notice("[user] начинает заваривать повреждения [H] с помощью [welder]."),
		span_notice("Вы начинаете заваривать повреждения [H].")
	)

	if(!do_after(user, 3 SECONDS, target = H))
		return FALSE

	if(!welder.use_tool(H, user, 0, volume = 50, amount = ipc_repair_cost_mod))
		return FALSE

	var/heal_amount = rand(15, 25)
	H.heal_overall_damage(brute = heal_amount, forced = TRUE)

	user.visible_message(
		span_notice("[user] заваривает повреждения [H]."),
		span_notice("Вы заварили повреждения [H]. Восстановлено [heal_amount] HP.")
	)

	to_chat(H, span_notice("Системная диагностика: Механические повреждения частично восстановлены."))

	return TRUE

/datum/species/ipc/proc/try_repair_burn(mob/living/carbon/human/H, obj/item/tool, mob/user)
	if(!istype(tool, /obj/item/stack/cable_coil))
		return FALSE

	var/obj/item/stack/cable_coil/cable = tool

	if(H.get_fire_loss() <= 0)
		to_chat(user, span_notice("[H] не имеет электрических повреждений."))
		return FALSE

	var/cable_cost = max(1, round(ipc_repair_cost_mod))
	if(cable.get_amount() < cable_cost)
		to_chat(user, span_warning("Недостаточно кабеля! Нужно [cable_cost] ед."))
		return FALSE

	user.visible_message(
		span_notice("[user] начинает чинить проводку [H] с помощью [cable]."),
		span_notice("Вы начинаете чинить проводку [H].")
	)

	if(!do_after(user, 3 SECONDS, target = H))
		return FALSE

	if(!cable.use(cable_cost))
		return FALSE

	var/heal_amount = rand(10, 20)
	H.heal_overall_damage(burn = heal_amount, forced = TRUE)

	user.visible_message(
		span_notice("[user] чинит проводку [H]."),
		span_notice("Вы починили проводку [H]. Восстановлено [heal_amount] HP.")
	)

	to_chat(H, span_notice("Системная диагностика: Электрические системы частично восстановлены."))

	return TRUE

/datum/species/ipc/proc/toggle_self_repair(mob/living/carbon/human/H)
	self_repair_enabled = !self_repair_enabled
	to_chat(H, span_notice("Саморемонт [self_repair_enabled ? "включен" : "выключен"]."))

/mob/living/carbon/human/verb/toggle_ipc_self_repair()
	set name = "Toggle Self-Repair"
	set category = "IC"
	set desc = "Включить или выключить систему саморемонта."

	if(!istype(dna.species, /datum/species/ipc))
		to_chat(src, span_warning("Эта функция доступна только для IPC!"))
		return

	var/datum/species/ipc/S = dna.species
	S.toggle_self_repair(src)

/mob/living/carbon/human/verb/ipc_weld_repair()
	set name = "Repair with Welder"
	set category = "IC"
	set desc = "Починить себя сваркой."

	if(!istype(dna.species, /datum/species/ipc))
		return

	var/obj/item/held = get_active_held_item()
	if(!istype(held, /obj/item/weldingtool))
		to_chat(src, span_warning("Вам нужна сварка!"))
		return

	var/datum/species/ipc/S = dna.species
	S.try_repair_brute(src, held, src)

/mob/living/carbon/human/verb/ipc_cable_repair()
	set name = "Repair with Cable"
	set category = "IC"
	set desc = "Починить себя кабелем."

	if(!istype(dna.species, /datum/species/ipc))
		return

	var/obj/item/held = get_active_held_item()
	if(!istype(held, /obj/item/stack/cable_coil))
		to_chat(src, span_warning("Вам нужен кабель!"))
		return

	var/datum/species/ipc/S = dna.species
	S.try_repair_burn(src, held, src)

/datum/species/ipc/proc/ipc_get_feature_values()
    var/list/features = list()
    features["ipc_chassis_brand"] = ipc_brand_key
    if(ipc_brand_key == "hef")
        features["ipc_hef_visual"] = ipc_visual_brand_key
    return features

/datum/species/ipc/proc/ipc_set_feature_values(list/features)
    if(features["ipc_chassis_brand"])
        ipc_brand_key = features["ipc_chassis_brand"]
    if(ipc_brand_key == "hef" && features["ipc_hef_visual"])
        ipc_visual_brand_key = features["ipc_hef_visual"]
    else
        ipc_visual_brand_key = ipc_brand_key

// ============================================
// ITEM INTERACTION - EXTERNAL REPAIR
// ============================================
// Позволяет другим игрокам чинить IPC сваркой и кабелем без операций
// ВАЖНО: Работает только когда панель ЗАКРЫТА. Если панель открыта - пропускаем в surgery

/mob/living/carbon/human/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// Проверяем что цель - IPC
	if(istype(dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = dna.species

		// Проверяем панель на целевой части тела (zone_selected)
		var/obj/item/bodypart/target_part = get_bodypart(check_zone(user.zone_selected))
		if(target_part)
			var/datum/component/ipc_panel/panel = target_part.GetComponent(/datum/component/ipc_panel)
			// Если панель открыта - вызываем surgery напрямую (минуя проверку TRAIT_READY_TO_OPERATE)
			if(panel && panel.is_panel_open())
				var/surgery_ret = user.perform_surgery(src, tool, LAZYACCESS(modifiers, RIGHT_CLICK))
				if(surgery_ret)
					return surgery_ret

		// Ремонт сваркой (brute damage) - только с закрытой панелью
		if(istype(tool, /obj/item/weldingtool))
			if(S.try_repair_brute(src, tool, user))
				return ITEM_INTERACT_SUCCESS

		// Ремонт кабелем (burn damage) - только с закрытой панелью
		else if(istype(tool, /obj/item/stack/cable_coil))
			if(S.try_repair_burn(src, tool, user))
				return ITEM_INTERACT_SUCCESS

	return ..() // Вызываем родительский метод для остальных взаимодействий
