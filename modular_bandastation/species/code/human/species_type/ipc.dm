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
	var/cooled_tank_active = FALSE

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

	// Дополнительные модификаторы от шасси
	// Список модификаторов: "overheat_rate", "healing_time", "melee_damage", "implant_slots", и т.д.
	var/list/ipc_chassis_modifiers = list()

/datum/species/ipc/get_species_description()
	return "IPC (Integrated Positronic Chassis) — искусственные синтетики на основе позитронного ядра. \
	Их корпус полностью заменяет биологическую плоть — это модульная кибернетическая система, \
	способная к частичной саморегенерации и адаптации к различным условиям работы. \
	Каждый IPC — уникальная machine, собранная или конвейерно, или в ручную из компонентов разных производителей."

/datum/species/ipc/get_species_lore()
	return list(
		"Позитронные синтетики появились как коммерческий продукт крупных кибернетических корпораций, \
		изначально созданные для промышленных и исследовательских миссий там, где биологический экипаж был бы непрактичен. \
		Со временем позитронное ядро стало достаточно развитым, чтобы развивать нейронные паттерны, неотличимые от сознания — \
		и тогда вопрос об их правовом статусе перестал быть абстрактным.",

		"Каждый производитель закладывает в свои модели собственную специализацию. \
		Morpheus Cyberkinetics ориентируется на когнитивные системы и нейроинтерфейсы — их головные модули считаются эталонными. \
		Etamin Industry специализируется на термальной архитектуре корпуса, а их торсы оборудованы передовыми системами охлаждения. \
		Bishop Cybernetics разработала манипуляторы с медицинской точностью, чьи руки способны выполнять тонкие хирургические операции. \
		Hesphiastos Industries и Ward-Takahashi предпочитают кинематику и защищённость нижних конечностей — их ноги рассчитаны на тяжёлую среду.",

		"Xion Manufacturing Group делает лёгкие каркасы для конечностей — их руки ценятся за соотношение силы к массе. \
		Zeng-Hu Pharmaceuticals вывели биосинтетические оболочки для торса, позволяющие IPC частично интегрироваться в медикаментозные протоколы. \
		Shellguard Munitions — единственный производитель, изначально ориентированный на боевое применение: \
		их бронированные головные и торсовые модули развитиеы для поглощения ударов и энергетического оружия.",

		"HEF — не бренд в традиционном смысле. Это обозначение для IPC, собранных из деталей разных производителей — \
		так называемых «Frankensteinian» шасси. Обычно это вынужденная мера: запчасти из разных каталогов ставятся \
		после полевых ремонтов, экономии бюджета или просто отсутствия оригинальных комплектов. \
		Визуально такие IPC выглядят эклектично — каждая часть тела от своего завода, со своей конструктивной идеей. \
		Но никаких геймплейных бонусов это не даёт: без единой интеграционной прошивки компоненты работают \
		только в базовом режиме, без специализированных эффектов ни одного из производителей.",
	)

/datum/species/ipc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()
	replace_body(H, src)
	H.update_body()
	H.update_body_parts()

	// Даем IPC абилки
	var/datum/action/cooldown/ipc_overclock/overclock = new()
	overclock.Grant(H)

	var/datum/action/innate/ipc_check_temperature/temp_check = new()
	temp_check.Grant(H)

	// Регистрируем обработчик электрошока
	RegisterSignal(H, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

	// ПРИМЕЧАНИЕ:
	// - Chassis brand применяется через body_modifications автоматически
	// - Тип мозга тоже через body_modifications
	// - Никакой дополнительной логики здесь не требуется
	// - Body modifications применяются системой preferences ДО on_species_gain,
	//   так что к этому моменту у IPC уже установлен правильный brain и chassis

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	// Удаляем IPC абилки
	var/datum/action/cooldown/ipc_overclock/overclock = locate() in H.actions
	if(overclock)
		overclock.Remove(H)

	var/datum/action/innate/ipc_check_temperature/temp_check = locate() in H.actions
	if(temp_check)
		temp_check.Remove(H)

	// Отменяем регистрацию сигналов
	UnregisterSignal(H, COMSIG_LIVING_ELECTROCUTE_ACT)

/datum/species/ipc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	handle_self_repair(H)
	handle_temperature(H, seconds_per_tick)
	handle_temperature_effects(H)
	handle_battery(H)
	// Применяем модификатор скорости действий от температуры и разгона
	update_action_speed(H)

/datum/species/ipc/proc/handle_self_repair(mob/living/carbon/human/H)
	if(!self_repair_enabled)
		return

	if(world.time < last_repair_time + self_repair_delay)
		return

	if(H.bruteloss > 0)
		H.apply_damage(-self_repair_amount, BRUTE, forced = TRUE)
		last_repair_time = world.time

	if(H.fireloss > 0)
		H.apply_damage(-self_repair_amount * 0.5, BURN, forced = TRUE)
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

	// Применяем охлаждение от термопасты
	if(thermal_paste_active)
		cpu_temperature = max(cpu_temperature - 10 * seconds_per_tick, 0)

	// Применяем охлаждение от улучшенной системы охлаждения
	if(improved_cooling_installed)
		cpu_temperature = max(cpu_temperature - 10 * seconds_per_tick, 0)

	// Применяем охлаждение от охладительного блока
	if(cooling_block_active)
		cpu_temperature = max(cpu_temperature - 30 * seconds_per_tick, 0)

	// Разгон системы нагревает процессор
	if(overclock_active)
		// +1 градус каждые 5 секунд = 0.2 градуса в секунду
		cpu_temperature += 0.2 * seconds_per_tick

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
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		to_chat(H, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания не обнаружен!"))
		H.apply_damage(2, OXY, forced = TRUE)
		return

	if(battery.charge <= 0)
		to_chat(H, span_danger("ПРЕДУПРЕЖДЕНИЕ: Батарея разряжена. Требуется подзарядка."))
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

	if(H.bruteloss <= 0)
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

	if(!welder.use_tool(H, user, 0, volume = 50, amount = 1))
		return FALSE

	var/heal_amount = rand(15, 25)
	H.apply_damage(-heal_amount, BRUTE, forced = TRUE)

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

	if(H.fireloss <= 0)
		to_chat(user, span_notice("[H] не имеет электрических повреждений."))
		return FALSE

	if(cable.get_amount() < 1)
		to_chat(user, span_warning("Недостаточно кабеля!"))
		return FALSE

	user.visible_message(
		span_notice("[user] начинает чинить проводку [H] с помощью [cable]."),
		span_notice("Вы начинаете чинить проводку [H].")
	)

	if(!do_after(user, 3 SECONDS, target = H))
		return FALSE

	if(!cable.use(1))
		return FALSE

	var/heal_amount = rand(10, 20)
	H.apply_damage(-heal_amount, BURN, forced = TRUE)

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
