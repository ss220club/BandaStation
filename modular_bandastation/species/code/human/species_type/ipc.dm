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

	// ПРИМЕЧАНИЕ:
	// - Chassis brand применяется через body_modifications автоматически
	// - Тип мозга тоже через body_modifications
	// - Никакой дополнительной логики здесь не требуется
	// - Body modifications применяются системой preferences ДО on_species_gain,
	//   так что к этому моменту у IPC уже установлен правильный brain и chassis

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

/datum/species/ipc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	handle_self_repair(H)
	handle_temperature(H)
	handle_battery(H)

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

/datum/species/ipc/proc/handle_temperature(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(!T)
		return

	var/datum/gas_mixture/environment = T.return_air()
	if(!environment)
		return

	var/env_temp = environment.temperature - T0C

	if(env_temp < cpu_temperature)
		var/cooling_amount = min((cpu_temperature - env_temp) * 0.01, cpu_cooling_rate * 2)
		cpu_temperature = max(cpu_temperature - cooling_amount, env_temp)
	else if(env_temp > cpu_temperature && cpu_heating_from_environment)
		var/heating_amount = min((env_temp - cpu_temperature) * 0.005, cpu_cooling_rate)
		cpu_temperature = min(cpu_temperature + heating_amount, env_temp)

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
