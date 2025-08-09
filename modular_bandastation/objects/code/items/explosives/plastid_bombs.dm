/obj/item/grenade/c4/c4_makeshift
	name = "Makeshift C-4 charge"
	desc = "Заряд кустарного С-4. За разницы в рецепте немного слабей заводского варианта."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "plastic-explosive0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/bombs_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/bombs_righthand.dmi'
	inhand_icon_state = "c4"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
	worn_icon_state = "c4_makeshift"
	boom_sizes = list(0, 0, 2)

/datum/crafting_recipe/c4_makeshift
	name = "Makeshift C-4 charge"
	result = /obj/item/grenade/c4/c4_makeshift
	reqs = list(
		/obj/item/reagent_containers/c4_small = 1,
		/obj/item/stock_parts/power_store/cell = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/assembly/timer = 1,
	)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/grenade/c4/semtex
	name = "Semtex charge"
	desc = "Заряд семтекса. Мощный и крайне дорогой брат С-4."
	icon = 'modular_bandastation/objects/icons/obj/items/explosives.dmi'
	icon_state = "semtex-explosive0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/bombs_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/bombs_righthand.dmi'
	inhand_icon_state = "semtex"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
	worn_icon_state = "semtex"
	boom_sizes = list(0, 2, 5)

/datum/crafting_recipe/semtex
	name = "Semtex charge"
	result = /obj/item/grenade/c4/semtex
	reqs = list(
		/obj/item/reagent_containers/semtex_small = 1,
		/obj/item/stock_parts/power_store/cell = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/assembly/timer = 1,
	)
	time = 2 SECONDS
	category = CAT_CHEMISTRY
