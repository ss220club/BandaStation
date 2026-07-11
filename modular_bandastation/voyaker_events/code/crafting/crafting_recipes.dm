#define CAT_EFTK_QUESTS "EFTK Quests"
#define CAT_EFTK_AMMO "EFTK Ammo"
#define CAT_EFTK_EQUIP "EFTK Equipment"
#define CAT_EFTK_MED "EFTK Medicine"

//MARK: Квестовые предметы.
/datum/crafting_recipe/compact_defib
	name = "Компактный дефибрилятор"
	result = /obj/item/defibrillator/compact
	reqs = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/analyzer = 1,
	)
	parts = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/analyzer = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 8 SECONDS
	category = CAT_EFTK_QUESTS
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/gasanalyther
	name = "Газовый анализатор"
	result = /obj/item/analyzer
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 4 SECONDS
	category = CAT_EFTK_QUESTS
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/medal
	name = "Медаль"
	result = /obj/item/clothing/accessory/medal
	reqs = list(
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_QUESTS
	crafting_flags = CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/trenchcoat
	name = "Кожанная куртка"
	result = /obj/item/clothing/suit/jacket/leather_trenchcoat
	reqs = list(
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/cloth = 5,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 6 SECONDS
	category = CAT_EFTK_QUESTS
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//MARK: Экипировка.
// 1 tier: Базовые рецепты (Требуют изучения рецепта Базового руководства по сборке снаряжения)
/datum/crafting_recipe/armor
	name = "Бронежилет"
	result = /obj/item/clothing/suit/armor/vest
	reqs = list(
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 8 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/helmet
	name = "Шлем"
	result = /obj/item/clothing/head/helmet
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/belt
	name = "Пояс"
	result = /obj/item/storage/belt/military/army
	reqs = list(
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/glasses
	name = "Очки"
	result = /obj/item/clothing/glasses/regular
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/glass = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/flashlight
	name = "фонарик"
	result = /obj/item/flashlight/seclite
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 1,
	)
	parts = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/suppressor
	name = "Глушитель"
	result = /obj/item/suppressor
	reqs = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
		/obj/item/stack/medical/wrap/sticky_tape = 1,
		/obj/item/stack/sheet/leather = 1,
	)
	parts = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 4 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/spess_knife
	name = "Швейцарский нож"
	result = /obj/item/spess_knife
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/screwdriver = 1,
	)
	parts = list(
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/screwdriver = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_SCREWDRIVER
	)
	time = 4 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

// 2 tier: Продвинутые рецепты. (Требуют изучения рецепта Продвинутого руководства по сборке снаряжения.)
/datum/crafting_recipe/sunglasses
	name = "Солнцезащитные очки"
	result = /obj/item/storage/belt/military/army
	reqs = list(
		/obj/item/clothing/glasses = 1,
		/obj/item/stack/sheet/rglass = 1,
	)
	parts = list(
		/obj/item/clothing/glasses = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 4 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/binocular
	name = "Бинокль"
	result = /obj/item/binoculars
	reqs = list(
		/obj/item/clothing/glasses = 1,
		/obj/item/stack/sheet/rglass = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)
	parts = list(
		/obj/item/clothing/glasses = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/meson_glasses
	name = "мезонные очки"
	result = /obj/item/clothing/glasses/meson
	reqs = list(
		/obj/item/clothing/glasses = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stock_parts/subspace/amplifier = 1,
	)
	parts = list(
		/obj/item/clothing/glasses = 1,
		/obj/item/stock_parts/subspace/amplifier = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/night_vision
	name = "Очки ночного видения"
	result = /obj/item/clothing/glasses/night
	reqs = list(
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/stack/sheet/rglass = 1,
		/obj/item/stock_parts/servo = 1,
	)
	parts = list(
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/health_analyzer
	name = "Продвинутый медицинский анализатор"
	result = /obj/item/healthanalyzer/advanced
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	parts = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/marine_helmet
	name = "Шлем морской пехоты"
	result = /obj/item/clothing/head/helmet/marine/security
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stack/sheet/rglass = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/marine_vest
	name = "Броня морской пехоты"
	result = /obj/item/clothing/suit/armor/vest/marine/security
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/cloth = 5,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 7 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/industrial_backpack
	name = "Индустриальный рюкзак"
	result = /obj/item/storage/backpack/industrial
	reqs = list(
		/obj/item/storage/backpack = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/cloth = 3,
	)
	parts = list(
		/obj/item/storage/backpack = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/combat_gloves
	name = "Боевые перчатки"
	result = /obj/item/clothing/gloves/combat
	reqs = list(
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/cloth = 3,
	)
	parts = list(
		/obj/item/clothing/gloves/color/black = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 4 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/jumpboots
	name = "Прыжковые ботинки"
	result = /obj/item/clothing/shoes/bhop
	reqs = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1,
	)
	parts = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_WIRECUTTER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/radsuit
	name = "Костюм радиационной защиты"
	result = /obj/item/clothing/suit/utility/radiation
	reqs = list(
		/obj/item/bikehorn/rubberducky = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/cloth = 3,
	)
	parts = list(
		/obj/item/bikehorn/rubberducky = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/radsuit_hud
	name = "Шлем радиационной защиты"
	result = /obj/item/clothing/head/utility/radiation
	reqs = list(
		/obj/item/bikehorn/rubberducky = 1,
		/obj/item/stack/sheet/rglass = 1,
		/obj/item/stack/sheet/cloth = 2,
	)
	parts = list(
		/obj/item/bikehorn/rubberducky = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/geiger
	name = "Cчётчик Гейгера"
	result = /obj/item/geiger_counter
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1,
	)
	parts = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_MULTITOOL
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/pump
	name = "Пищевая помпа"
	result = /obj/item/organ/cyberimp/chest/pump
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stock_parts/water_recycler = 1,
		/obj/item/stock_parts/servo = 1,
	)
	parts = list(
		/obj/item/stock_parts/water_recycler = 1,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_MULTITOOL
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

// 3 tier: Элитные рецепты. (Требуют изучения рецепта Элитного руководства по сборке снаряжения.)
/datum/crafting_recipe/bag_of_holding
	name = "Блюспейс рюкзак"
	result = /obj/item/storage/backpack/holding
	reqs = list(
		/obj/item/storage/backpack/industrial = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/servo = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/subspace/analyzer = 1,
	)
	parts = list(
		/obj/item/storage/backpack/industrial = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/servo = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/subspace/analyzer = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_WIRECUTTER,
		TOOL_SCREWDRIVER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/thermal_vision
	name = "Термальные очки"
	result = /obj/item/clothing/glasses/hud/toggle/thermal
	reqs = list(
		/obj/item/clothing/glasses/night = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/servo = 1,
		/obj/item/stack/sheet/plastitaniumglass = 1,
	)
	parts = list(
		/obj/item/clothing/glasses/night = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER
	)
	time = 7 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/pinpointer
	name = "Целеуказатель"
	result = /obj/item/pinpointer/crew
	reqs = list(
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/stock_parts/card_reader = 1,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stock_parts/scanning_module = 2,
	)
	parts = list(
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/stock_parts/card_reader = 1,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stock_parts/scanning_module = 2,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER
	)
	time = 5 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/autosurgeon
	name = "Авто-хирург"
	result = /obj/item/autosurgeon
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/reagent_containers/cup/bottle/morphine = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/subspace/ansible = 1,
	)
	parts = list(
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/reagent_containers/cup/bottle/morphine = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/subspace/ansible = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/anti_drop
	name = "Имплант Анти-дроп"
	result = /obj/item/organ/cyberimp/brain/anti_drop
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/weaponcrafting/receiver = 1,
	)
	parts = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/weaponcrafting/receiver = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER,
		TOOL_WELDER,
		TOOL_WIRECUTTER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/cns_rebooter
	name = "Имплант перезапуска ЦНС"
	result = /obj/item/organ/cyberimp/brain/anti_drop
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	parts = list(
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER,
		TOOL_WELDER,
		TOOL_WIRECUTTER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/reviver
	name = "Оживляющий имплант"
	result = /obj/item/organ/cyberimp/chest/reviver
	reqs = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/reagent_containers/hypospray/cmo = 1,
	)
	parts = list(
		/obj/item/stack/sheet/plasteel = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/reagent_containers/hypospray/cmo = 1,
	)
	tool_behaviors = list(
		TOOL_MULTITOOL,
		TOOL_SCREWDRIVER,
		TOOL_WELDER,
		TOOL_WIRECUTTER
	)
	time = 6 SECONDS
	category = CAT_EFTK_EQUIP
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//MARK: Патроны
// Tier 1. Требуют наличия Базового охотничьего руководства по сборке боеприпасов
/datum/crafting_recipe/ammo_9mm_magazine_refill
	name = "Магазин 9мм"
	result = /obj/item/ammo_box/magazine/m9mm
	reqs = list(
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mm_magazine
	name = "Магазин 9мм"
	result = /obj/item/ammo_box/magazine/m9mm
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_310strilka_refill
	name = "Обойма .310 Strilka"
	result = /obj/item/ammo_box/speedloader/strilka310
	reqs = list(
		/obj/item/ammo_box/speedloader/strilka310 = 1,
		/obj/item/ammo_casing/strilka310 = 5,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/speedloader/strilka310 = 1,
		/obj/item/ammo_casing/strilka310 = 5,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_310strilka
	name = "Обойма .310 Strilka"
	result = /obj/item/ammo_box/speedloader/strilka310
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/strilka310 = 5,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/strilka310 = 5,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mm_refill
	name = "Магазин 10мм"
	result = /obj/item/ammo_box/magazine/zashch
	reqs = list(
		/obj/item/ammo_box/magazine/zashch = 1,
		/obj/item/ammo_casing/c10mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/zashch = 1,
		/obj/item/ammo_casing/c10mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mm
	name = "Магазин 10мм"
	result = /obj/item/ammo_box/magazine/zashch
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c10mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c10mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x54r_box
	name = "Коробка патронов 7.62x54ммР"
	result = /obj/item/ammo_box/c762x54mmr
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/c762x54mmr = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/c762x54mmr = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39_ricochet_box
	name = "Коробка спортивных патронов 7.62x39мм"
	result = /obj/item/ammo_box/c762x39/ricochet
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/c762x39 = 45,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/c762x39 = 45,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39magshort_civ_refill
	name = "Укороченный магазин 7.62x39мм с гражданскими патронами"
	result = /obj/item/ammo_box/magazine/c762x39mm/small/civ
	reqs = list(
		/obj/item/ammo_box/magazine/c762x39mm/small/civ = 1,
		/obj/item/ammo_casing/c762x39 = 15,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c762x39mm/small/civ = 1,
		/obj/item/ammo_casing/c762x39 = 15,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39magshort_civ
	name = "Укороченный магазин 7.62x39мм с гражданскими патронами"
	result = /obj/item/ammo_box/magazine/c762x39mm/small/civ
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x39 = 15,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x39 = 15,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39mag_refill
	name = "Магазин 7.62x39мм"
	result = /obj/item/ammo_box/magazine/c762x39mm/ricochet
	reqs = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39mag
	name = "Магазин 7.62x39мм"
	result = /obj/item/ammo_box/magazine/c762x39mm/ricochet
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35sol_refill
	name = "Магазин .35 Sol"
	result = /obj/item/ammo_box/magazine/c35sol_pistol
	reqs = list(
		/obj/item/ammo_box/magazine/c35sol_pistol = 1,
		/obj/item/ammo_casing/c35sol = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c35sol_pistol = 1,
		/obj/item/ammo_casing/c35sol = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35sol
	name = "Магазин .35 Sol"
	result = /obj/item/ammo_box/magazine/c35sol_pistol
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c35sol = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c35sol = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40solshort_refill
	name = "Укороченный магазин .40 Sol "
	result = /obj/item/ammo_box/magazine/c40sol_rifle
	reqs = list(
		/obj/item/ammo_box/magazine/c40sol_rifle = 1,
		/obj/item/ammo_casing/c40sol = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c40sol_rifle = 1,
		/obj/item/ammo_casing/c40sol = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40solshort
	name = "Укороченный магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40solstandard_refill
	name = "Стандартный магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/standard
	reqs = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 1,
		/obj/item/ammo_casing/c40sol = 20,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 1,
		/obj/item/ammo_casing/c40sol = 20,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40solstandart
	name = "Стандартный магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/standard
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 20,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 20,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_12gbuckshot
	name = "Коробка картечных боеприпасов 12 калибра"
	result = /obj/item/storage/box/lethalshot
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/shotgun = 7,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/shotgun = 7,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_uzi9mm_refill
	name = "Магазин 9мм для ПП Узи"
	result = /obj/item/ammo_box/magazine/uzim9mm
	reqs = list(
		/obj/item/ammo_box/magazine/uzim9mm = 1,
		/obj/item/ammo_casing/c9mm = 32,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/uzim9mm = 1,
		/obj/item/ammo_casing/c9mm = 32,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_uzi9mm
	name = "Магазин 9мм для ПП Узи"
	result = /obj/item/ammo_box/magazine/uzim9mm
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 32,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 32,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//Tier 2. Необходимо Продвинутое военное руководство по сборке боеприпасов
/datum/crafting_recipe/frag_grenade
	name = "Осколочная граната"
	result = /obj/item/grenade/frag
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/shard = 1,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/shard = 1,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/flashbang
	name = "Светошумовая граната"
	result = /obj/item/grenade/flashbang
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/rods = 2,
	)
	parts = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/assembly/igniter =  1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/gas_grenade
	name = "Дымовая граната"
	result = /obj/item/grenade/smokebomb
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stock_parts/water_recycler = 1,
	)
	parts = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stock_parts/water_recycler =  1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmhp_refill
	name = "Магазин 9мм для пистолета Макарова (экспансивные)"
	result = /obj/item/ammo_box/magazine/m9mm/hp
	reqs = list(
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m9mm =  1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmhp
	name = "Магазин 9мм для пистолета Макарова (экспансивные)"
	result = /obj/item/ammo_box/magazine/m9mm/hp
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmap_refill
	name = "Магазин 9мм для пистолета Макарова (бронебойные)"
	result = /obj/item/ammo_box/magazine/m9mm/ap
	reqs = list(
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmap
	name = "Магазин 9мм для пистолета Макарова (бронебойные)"
	result = /obj/item/ammo_box/magazine/m9mm/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 12,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mmhp_refill
	name = "Магазин 10мм для пистолета Ансем (экспансивные)"
	result = /obj/item/ammo_box/magazine/m10mm/hp
	reqs = list(
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m10mm/hp = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mmhp
	name = "Магазин 10мм для пистолета Ансем (экспансивные)"
	result = /obj/item/ammo_box/magazine/m10mm/hp
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mmap_refill
	name = "Магазин 10мм для пистолета Ансем (бронебойные)"
	result = /obj/item/ammo_box/magazine/m10mm/ap
	reqs = list(
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m10mm/ap = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_10mmap
	name = "Магазин 10мм для пистолета Ансем (бронебойные)"
	result = /obj/item/ammo_box/magazine/m10mm/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c10mm = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo762x39ion_refill
	name = "Магазин для АМК 7.62x39мм (ионные)"
	result = /obj/item/ammo_box/magazine/c762x39mm/emp
	reqs = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo762x39ion
	name = "Магазин для АМК 7.62x39мм (ионные)"
	result = /obj/item/ammo_box/magazine/c762x39mm/emp
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnek_refill
	name = "Шнековый магазин 9мм для ПП Бизон"
	result = /obj/item/ammo_box/magazine/bison
	reqs = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnek
	name = "Шнековый магазин 9мм для ПП Бизон"
	result = /obj/item/ammo_box/magazine/bison
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnekhp_refill
	name = "Шнековый магазин 9мм для ПП Бизон (экспансивные)"
	result = /obj/item/ammo_box/magazine/bison/hp
	reqs = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnekhp
	name = "Шнековый магазин 9мм для ПП Бизон (экспансивные)"
	result = /obj/item/ammo_box/magazine/bison/hp
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnekap_refill
	name = "Шнековый магазин 9мм для ПП Бизон (бронебойные)"
	result = /obj/item/ammo_box/magazine/bison/ap
	reqs = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/bison = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmshnekap
	name = "Шнековый магазин 9мм для ПП Бизон (бронебойные)"
	result = /obj/item/ammo_box/magazine/bison/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 64,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrum_refill
	name = "Барабанный магазин .35 Sol"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum
	reqs = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrum
	name = "Барабанный магазин .35 Sol"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrumhp_refill
	name = "Барабанный магазин .35 Sol (экспансивные)"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum/hp
	reqs = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrumhp
	name = "Барабанный магазин .35 Sol (экспансивные)"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum/hp
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrumap_refill
	name = "Барабанный магазин .35 Sol (бронебойные)"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	reqs = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c35sol_pistol/drum = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_35soldrumap
	name = "Барабанный магазин .35 Sol (бронебойные)"
	result = /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40sollong_refill
	name = "Удлинённый магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/long
	reqs = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/long = 1,
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/long = 1,
		/obj/item/ammo_casing/c35sol = 35,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40sollong
	name = "Удлинённый магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/long
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_310strilkalong_refill
	name = "Боевой магазин .310 Strilka"
	result = /obj/item/ammo_box/magazine/strilka310
	reqs = list(
		/obj/item/ammo_box/magazine/strilka310 = 1,
		/obj/item/ammo_casing/strilka310 = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/strilka310 = 1,
		/obj/item/ammo_casing/strilka310 = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_310strilkalong
	name = "Боевой магазин .310 Strilka"
	result = /obj/item/ammo_box/magazine/strilka310
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/strilka310 = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/strilka310 = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_45acp_refill
	name = "Магазин .45 для 1911"
	result = /obj/item/ammo_box/magazine/m45
	reqs = list(
		/obj/item/ammo_box/magazine/m45 = 1,
		/obj/item/ammo_casing/c45 = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m45 = 1,
		/obj/item/ammo_casing/c45 = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_45acp
	name = "Магазин .45 для 1911"
	result = /obj/item/ammo_box/magazine/m45
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c45 = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c45 = 8,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_c45_refill
	name = "Магазин .45 для пистолетов"
	result = /obj/item/ammo_box/magazine/c45
	reqs = list(
		/obj/item/ammo_box/magazine/c45 = 1,
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c45 = 1,
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_c45
	name = "Магазин .45 для пистолетов"
	result = /obj/item/ammo_box/magazine/c45
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_WELDER,
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg45_refill
	name = "Магазин .45 для ПП CR-20"
	result = /obj/item/ammo_box/magazine/smgm45
	reqs = list(
		/obj/item/ammo_box/magazine/smgm45 = 1,
		/obj/item/ammo_casing/c45 = 24,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/smgm45 = 1,
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg45
	name = "Магазин .45 для ПП CR-20"
	result = /obj/item/ammo_box/magazine/smgm45
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c45 = 24,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c45 = 10,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmsmgfn_refill
	name = "Магазин 9мм для ПП FN18"
	result = /obj/item/ammo_box/magazine/fn18
	reqs = list(
		/obj/item/ammo_box/magazine/fn18 = 1,
		/obj/item/ammo_casing/c9mm = 40,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/fn18 = 1,
		/obj/item/ammo_casing/c9mm = 40,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmsmgfn
	name = "Магазин 9мм для ПП FN18"
	result = /obj/item/ammo_box/magazine/fn18
	reqs = list(
		/obj/item/ammo_box/magazine/fn18 = 1,
		/obj/item/ammo_casing/c9mm = 40,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 40,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmsteckin_refill
	name = "Магазин 9мм для пистолета Стечкина"
	result = /obj/item/ammo_box/magazine/m9mm_aps
	reqs = list(
		/obj/item/ammo_box/magazine/m9mm_aps = 1,
		/obj/item/ammo_casing/c9mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m9mm_aps = 1,
		/obj/item/ammo_casing/c9mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_9mmsteckin
	name = "Магазин 9мм для пистолета Стечкина"
	result = /obj/item/ammo_box/magazine/m9mm_aps
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c9mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c9mm = 15,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x51fn4_refill
	name = "Магазин 7.62x51мм для винтовки FN4"
	result = /obj/item/ammo_box/magazine/c762x51mm
	reqs = list(
		/obj/item/ammo_box/magazine/c762x51mm = 1,
		/obj/item/ammo_casing/c762x51mm = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c762x51mm = 1,
		/obj/item/ammo_casing/c762x51mm = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x51fn4
	name = "Магазин 7.62x51мм для винтовки FN4"
	result = /obj/item/ammo_box/magazine/c762x51mm
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x51mm = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c762x51mm = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_as32_refill
	name = "Магазин 12G для дробовика AS32"
	result = /obj/item/ammo_box/magazine/as32
	reqs = list(
		/obj/item/ammo_box/magazine/as32 = 1,
		/obj/item/ammo_casing/shotgun = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/as32 = 1,
		/obj/item/ammo_casing/shotgun = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_as32
	name = "Магазин 12G для дробовика AS32"
	result = /obj/item/ammo_box/magazine/as32
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/shotgun = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/shotgun = 8,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//Tier 3. Требуется Элитное руководство ССО по сборке боеприпасов
/datum/crafting_recipe/c4
	name = "Взрывчатка C-4"
	result = /obj/item/grenade/c4
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/assembly/signaler = 1,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/assembly/signaler = 1,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg10mm_refill
	name = "Магазин 10мм для ПП Витязь"
	result = /obj/item/ammo_box/magazine/smg10mm
	reqs = list(
		/obj/item/ammo_box/magazine/smg10mm = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/smg10mm = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg10mm
	name = "Магазин 10мм для ПП Витязь"
	result = /obj/item/ammo_box/magazine/smg10mm
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg10mmap_refill
	name = "Магазин 10мм для ПП Витязь (бронебойные)"
	result = /obj/item/ammo_box/magazine/smg10mm/ap
	reqs = list(
		/obj/item/ammo_box/magazine/smg10mm = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/smg10mm = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_smg10mmap
	name = "Магазин 10мм для ПП Витязь (бронебойные)"
	result = /obj/item/ammo_box/magazine/smg10mm/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c10mm = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39ap_refill
	name = "Магазин для АМК 7.62x39мм (бронебойные)"
	result = /obj/item/ammo_box/magazine/c762x39mm/ap
	reqs = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c762x39mm = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_762x39ap
	name = "Магазин для АМК 7.62x39мм (бронебойные)"
	result = /obj/item/ammo_box/magazine/c762x39mm/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c762x39 = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40soldrum_refill
	name = "Барабанный магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/drum
	reqs = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/drum = 1,
		/obj/item/ammo_casing/c40sol = 60,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/drum = 1,
		/obj/item/ammo_casing/c40sol = 60,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40soldrum
	name = "Барабанный магазин .40 Sol"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/drum
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 60,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c40sol = 60,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40sollongap_refill
	name = "Удлинённый магазин .40 Sol (бронебойные)"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/long/ap
	reqs = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/long/ap = 1,
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/long/ap = 1,
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_40sollongap
	name = "Удлинённый магазин .40 Sol (бронебойные)"
	result = /obj/item/ammo_box/magazine/c40sol_rifle/long/ap
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c40sol = 30,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_c338_refill
	name = "Магазин .338"
	result = /obj/item/ammo_box/magazine/c338
	reqs = list(
		/obj/item/ammo_box/magazine/c338 = 1,
		/obj/item/ammo_casing/c338 = 5,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/c338 = 1,
		/obj/item/ammo_casing/c338 = 5,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_c338
	name = "Магазин .338"
	result = /obj/item/ammo_box/magazine/c338
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c338 = 5,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c338 = 5,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_50ae_refill
	name = "Магазин .50 AE"
	result = /obj/item/ammo_box/magazine/m50
	reqs = list(
		/obj/item/ammo_box/magazine/m50 = 1,
		/obj/item/ammo_casing/a50ae = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m50 = 1,
		/obj/item/ammo_casing/a50ae = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_50ae
	name = "Магазин .50 AE"
	result = /obj/item/ammo_box/magazine/m50
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/a50ae = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/a50ae = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_12gslug
	name = "Коробка 12G (пулевые)"
	result = /obj/item/ammo_box/c12ga/slug
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/shotgun = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/ammo_casing/shotgun = 20,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_357match
	name = "Барабан .357 (высокоточные)"
	result = /obj/item/ammo_box/speedloader/c357/match
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/ammo_casing/c357 = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c357 = 7,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_m233_refill
	name = "Магазин 5.56x45мм"
	result = /obj/item/ammo_box/magazine/m223
	reqs = list(
		/obj/item/ammo_box/magazine/m223 = 1,
		/obj/item/ammo_casing/a223 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/m223 = 1,
		/obj/item/ammo_casing/a223 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_m233
	name = "Магазин 5.56x45мм"
	result = /obj/item/ammo_box/magazine/m223
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/a223 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	parts = list(
		/obj/item/ammo_casing/a223 = 30,
		/obj/item/crafting_items/gunpowder/medium = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_abiel50_refill
	name = "Магазин .160 Абиэль"
	result = /obj/item/ammo_box/magazine/smartgun
	reqs = list(
		/obj/item/ammo_box/magazine/smartgun = 1,
		/obj/item/ammo_casing/c160smart = 50,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	parts = list(
		/obj/item/ammo_box/magazine/smartgun = 1,
		/obj/item/ammo_casing/c160smart = 50,
		/obj/item/crafting_items/gunpowder/high = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/ammo_abiel50
	name = "Магазин .160 Абиэль"
	result = /obj/item/ammo_box/magazine/smartgun
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/ammo_casing/c160smart = 50,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/servo = 1,
	)
	parts = list(
		/obj/item/ammo_casing/c160smart = 50,
		/obj/item/crafting_items/gunpowder/high = 1,
		/obj/item/stock_parts/servo = 1,
	)
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_WELDER,
		TOOL_MULTITOOL
	)
	time = 3 SECONDS
	category = CAT_EFTK_AMMO
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//MARK: Медицина.
//Tier 1. Недорогая медицина. Требуется Базовое руководство фармацевта-практиканта по изготовлению лекарственых препаратов
/datum/crafting_recipe/suture
	name = "Хирургический шов"
	result = /obj/item/stack/medical/suture
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/bandages
	name = "Коробка пластырей"
	result = /obj/item/storage/box/bandages
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/surgical_tape
	name = "Хирургическая лента"
	result = /obj/item/stack/medical/wrap/sticky_tape/surgical
	reqs = list(
		/obj/item/stack/medical/wrap/sticky_tape = 1,
		/obj/item/stack/medical/bandage = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/libital_patch
	name = "Пластырь либитала"
	result = /obj/item/reagent_containers/applicator/patch/libital
	reqs = list(
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/aiuri_patch
	name = "Пластырь аиури"
	result = /obj/item/reagent_containers/applicator/patch/aiuri
	reqs = list(
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/medical/ointment = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 3 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//Tier 2. Продвинутая медицина и наборы. Требуется Продвинутое медицинское руководство по изготовлению лекарственных препаратов
/datum/crafting_recipe/medkit_regular
	name = "Медицинский набор"
	result = /obj/item/storage/medkit/regular
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/stack/medical/wrap/gauze = 3,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	parts = list(
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER
	)
	time = 7 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/spray_libital
	name = "Спрей либитала"
	result = /obj/item/reagent_containers/medigel/libital
	reqs = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
		/obj/item/reagent_containers/applicator/patch/libital = 2,
	)
	parts = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
		/obj/item/reagent_containers/applicator/patch/libital = 2,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/spray_aiuri
	name = "Спрей аиури"
	result = /obj/item/reagent_containers/medigel/aiuri
	reqs = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
		/obj/item/reagent_containers/applicator/patch/aiuri = 2,
	)
	parts = list(
		/obj/item/reagent_containers/cup/soda_cans = 1,
		/obj/item/reagent_containers/applicator/patch/aiuri = 2,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/hypospray
	name = "Гипоспрей"
	result = /obj/item/reagent_containers/hypospray/cmo
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/food/donkpocket/warm = 2,
		/obj/item/weaponcrafting/receiver = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 5 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

//Tier 3. Высококачественная медицина. Необходимо Элитное руководство учёного-химика по изготовлению лекарственных препаратов
/datum/crafting_recipe/surgical_medkit
	name = "Хирургический набор"
	result = /obj/item/storage/medkit/surgery
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/medical/wrap/gauze = 15,
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/weldingtool = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/stack/medical/suture = 2,
	)
	parts = list(
		/obj/item/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/weldingtool = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 7 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE

/datum/crafting_recipe/medkit_advanced
	name = "Универсальный медицинский набор"
	result = /obj/item/storage/medkit/advanced
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/reagent_containers/applicator/patch/libital = 3,
		/obj/item/reagent_containers/blood/o_minus = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 1,
		/obj/item/storage/pill_bottle/penacid = 1,
		/obj/item/stack/medical/wrap/gauze = 6,
		/obj/item/reagent_containers/hypospray/medipen = 2,
	)
	parts = list(
		/obj/item/reagent_containers/applicator/patch/libital = 3,
		/obj/item/reagent_containers/blood/o_minus = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 1,
		/obj/item/storage/pill_bottle/penacid = 1,
		/obj/item/reagent_containers/hypospray/medipen = 2,
	)
	tool_behaviors = list(
		TOOL_WIRECUTTER,
		TOOL_WELDER
	)
	time = 7 SECONDS
	category = CAT_EFTK_MED
	crafting_flags = CRAFT_MUST_BE_LEARNED
	requires_workbench = TRUE
