/obj/item/crafting_items/gunpowder
	name = "низкокачественный оружейный порох"
	desc = "Порох низкого качества с примесями, часто используемый в оружейной промышленности. Подойдёт для изготовления мелкокалиберных и обычных патронов, если знать рецептуру."
	icon = 'modular_bandastation/voyaker_events/icons/powders.dmi'
	icon_state = "powder-low"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	force = 0

/obj/item/crafting_items/gunpowder/medium
	name = "стандартный оружейный порох"
	desc = "Порох заводского качества, часто используемый в оружейной промышленности. Подойдёт для изготовления некоторых мелкокалиберных бронебойных и винтовочных боеприпасов, если знать рецептуру."
	icon_state = "powder-normal"

/obj/item/crafting_items/gunpowder/high
	name = "высококачественный оружейный порох"
	desc = "Порох высокого качества, часто используемый в оружейной промышленности. Подойдёт для изготовления бронебойных и крупнокалиберных боеприпасов любого типа, если знать рецептуру."
	icon_state = "powder-high"

/obj/item/reagent_containers/cup/fuel_can
	name = "канистра для топлива"
	desc = "Металлическая канистра для топлива."
	icon = 'modular_bandastation/voyaker_events/icons/fuel_canister.dmi'
	icon_state = "fuel_can"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10, 25, 50)
	spillable = TRUE
	list_reagents = list(
		/datum/reagent/fuel = 50
	)

/obj/item/reagent_containers/cup/fuel_can/attack(mob/living/M, mob/user)
	return
