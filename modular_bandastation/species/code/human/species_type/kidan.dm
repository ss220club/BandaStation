/datum/species/kidan
	name = "\improper Кидан"
	plural_form = "Киданы"
	id = SPECIES_KIDAN

	inherent_traits = list()
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/kidan
	mutantbrain = /obj/item/organ/brain/kidan
	mutantheart = /obj/item/organ/heart/kidan
	mutantlungs = /obj/item/organ/lungs/kidan
	mutanteyes = /obj/item/organ/eyes/kidan
	mutanttongue = /obj/item/organ/tongue/kidan
	mutantliver = /obj/item/organ/liver/kidan
	mutantstomach = /obj/item/organ/stomach/kidan

	exotic_bloodtype = BLOOD_TYPE_KIDAN

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/kidan,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/kidan,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/kidan,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/kidan,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/kidan,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/kidan
	)
	payday_modifier = 0.9

	bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT +75

/datum/species/kidan/create_pref_unique_perks()
	var/list/to_add = list()

	// --- Хитиновый панцирь (описание) ---
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-halved",
			SPECIES_PERK_NAME = "Хитиновый панцирь",
			SPECIES_PERK_DESC = "Прочный экзоскелет снижает физический урон на 20% в ближнем бою и 10% от пуль."
		)
	)
	// --- Физический урон (Brute)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Устойчивость к физическому урону",
			SPECIES_PERK_DESC = "[plural_form] устойчивы к физическому урону."
		)
	)
	// --- Жар
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-full",
			SPECIES_PERK_NAME = "Устойчивость к жаре",
			SPECIES_PERK_DESC = "[plural_form] хорошо переносят высокие температуры."
		)
	)
	// --- Холод
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Слабость к холоду",
			SPECIES_PERK_DESC = "[plural_form] плохо переносят низкие температуры."
		)
	)
	// --- Токсины/Химия
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Слабость к токсинам",
			SPECIES_PERK_DESC = "[plural_form] слабы к токсинам и химическим веществам."
		)
	)
	to_add +=list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Светочувствительность",
			SPECIES_PERK_DESC = "Их фасеточные глаза болезненно реагируют на яркий свет, снижая точность и восприятие.",
		)
	)
	return to_add

/datum/species/kidan/get_physical_attributes()
	return "Киданы — насекомоподобные гуманоиды с плотным экзоскелетом и биолюминесцентными антеннами. \
		Они выносливы и устойчивы к жаре, но крайне уязвимы к холоду и токсинам. Их нервная система частично автономна, \
			что позволяет им оставаться активными даже после серьёзных травм."

/datum/species/kidan/get_species_description()
	return "Киданы — дисциплинированная и коллективная раса, родом с планеты Аурум. Их общество построено на \
	иерархии улья, где каждый знает своё место и цель. Они не знают праздности, считая труд \
	основой существования. Благодаря прочному панцирю и высокой выносливости киданы часто \
	используются корпорациями как рабочая сила. Однако их чувствительность к холоду делает \
	пространство вне улья для них опасным.\
	Несмотря на внешнюю покорность, внутри каждого кидана живёт стремление служить улью и \
	сохранить его память, даже вдали от дома."

/datum/species/kidan/get_species_lore()
	return list(
	"Аурум — жаркая, густо заселённая планета с атмосферой, богатой аммиаком. \
			На ней миллиарды киданов живут в гигантских городах-ульях, соединённых тоннелями и \
			биомеханическими структурами. Для них Рой — это не просто общество, а коллективный разум, \
			в котором каждая личность является частью единого целого.",

	"После оккупации ТСФ планета была переименована в Аурумскую Демократическую \
			Республику. Киданы потеряли самостоятельность, став дешёвой рабочей силой. \
			Однако память о свободном Рое всё ещё жива в легендах и песнях трутней.",

		"Культура киданов основана на коллективизме, дисциплине ради общего дела. \
			Они имеют социальную структуру схожую с термитами — матки, трутни и рабочие составляют единую биосоциальную структуру.",

	"Киданы презирают клонирование, считая клонов пустыми оболочками без души Роя. \
			Тем не менее, корпорации продолжают производить таких существ, вызывая внутренние конфликты \
			среди киданов, работающих под властью Nanotrasen."
	)
