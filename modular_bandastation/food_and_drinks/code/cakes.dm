/obj/item/food/cake/slavic
	abstract_type = /obj/item/food/cake/slavic
	icon = 'modular_bandastation/food_and_drinks/icons/station_food.dmi'
	inhand_icon_state = null
	venue_value = FOOD_PRICE_CHEAP
	foodtypes = DAIRY|SUGAR|GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	yield = 6

/obj/item/food/cake/slavic/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(istype(current_recipe, /datum/crafting_recipe/food/slavic))
		var/datum/crafting_recipe/food/slavic/recipe = current_recipe
		recipe.return_ingredient_bowls(components, src)

/obj/item/food/cakeslice/slavic
	abstract_type = /obj/item/food/cakeslice/slavic
	icon = 'modular_bandastation/food_and_drinks/icons/station_food.dmi'
	inhand_icon_state = null
	venue_value = FOOD_PRICE_CHEAP
	foodtypes = DAIRY|SUGAR|GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cake/slavic/smetannik_choco
	slice_type = /obj/item/food/cakeslice/slavic/smetannik_choco
	name = "chocolate sour cream cake"
	desc = "Шоколадный сметанник с мягким коржиком и сметанным кремом. Умеренная кислинка дополняет насыщенный шоколадный вкус."
	icon_state = "smetannik_choco"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/sugar = 14,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("сметанный крем" = 2, "шоколадный бисквит" = 1)

/obj/item/food/cakeslice/slavic/smetannik_choco
	name = "chocolate sour cream cake slice"
	desc = "Кусок шоколадного сметанника с мягким коржиком и нежным сметанным кремом."
	icon_state = "smetannik_choco_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("сметанный крем" = 2, "шоколадный бисквит" = 1)

/obj/item/food/slavic/smetannik_choco_raw
	name = "raw chocolate sour cream cake"
	desc = "Заготовка шоколадного сметанника из теста и сметаны. Перед подачей её нужно испечь."
	icon_state = "smetannik_choco_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/sugar = 14,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|RAW
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("сырое тесто" = 2, "сметана" = 1)
	foodtypes_removed_when_cooked = RAW

/obj/item/food/cake/slavic/smetannik
	slice_type = /obj/item/food/cakeslice/slavic/smetannik
	name = "sour cream cake"
	desc = "Сметанник с мягким коржиком и нежным кремом. Лёгкая кислинка сметаны оттеняет сладость выпечки."
	icon_state = "smetannik"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("сметанный крем" = 2, "бисквит" = 1)

/obj/item/food/cakeslice/slavic/smetannik
	name = "sour cream cake slice"
	desc = "Порционный кусок сметанника с мягким коржиком и сметанным кремом."
	icon_state = "smetannik_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("сметанный крем" = 2, "бисквит" = 1)

/obj/item/food/slavic/smetannik_raw
	name = "raw sour cream cake"
	desc = "Заготовка сметанника из теста и сметаны. Готова к выпечке в духовке."
	icon_state = "smetannik_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|RAW
	crafting_complexity = FOOD_COMPLEXITY_3
	tastes = list("сырое тесто" = 2, "сметана" = 1)
	foodtypes_removed_when_cooked = RAW

/obj/item/food/slavic/blini_cake
	name = "blini cake"
	desc = "Торт из тонких блинов, прослоенных сладкой сметаной, с шоколадом и ягодами."
	icon_state = "blini_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 17,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|FRUIT
	crafting_complexity = FOOD_COMPLEXITY_4
	tastes = list("тонкие блины" = 2, "сладкая сметана" = 1, "шоколад" = 1, "ягоды" = 1)

/obj/item/food/slavic/meat_blini_pie
	name = "meat blini pie"
	desc = "Слоёный пирог из мясных блинов со стейком, грибами, луком и кетчупом."
	icon_state = "meat_blini_pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/protein = 14,
	)
	foodtypes = MEAT|VEGETABLES|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4
	tastes = list("жареное мясо" = 2, "грибы и лук" = 1, "томатный соус" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/cakeslice/slavic/tvorozhnik
	name = "cottage cheese cake slice"
	desc = "Кусок творожного пирога с мягкой серединой и румяной корочкой."
	icon_state = "tvorozhnik_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("запечённый творог" = 2, "сладкое тесто" = 1)

/obj/item/food/cakeslice/slavic/tvorozhnik_berries
	name = "berry cottage cheese cake slice"
	desc = "Кусок творожника с ягодами. Сочная кисло-сладкая добавка оттеняет запечённый творог."
	icon_state = "tvorozhnik_berries_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|FRUIT
	tastes = list("запечённый творог" = 2, "ягоды" = 1)

/obj/item/food/cakeslice/slavic/tvorozhnik_condensed_milk
	name = "condensed milk cottage cheese cake slice"
	desc = "Кусок творожного пирога, покрытый густым сгущённым молоком."
	icon_state = "tvorozhnik_condmilk_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("запечённый творог" = 2, "сгущённое молоко" = 1)

/obj/item/food/cakeslice/slavic/tvorozhnik_berry_smetana
	name = "berry and sour cream cottage cheese cake slice"
	desc = "Кусок творожника с ягодами и сметаной. Нежная основа дополнена свежей кислинкой."
	icon_state = "tvorozhnik_berry_smetana_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 3,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|FRUIT
	tastes = list("запечённый творог" = 2, "ягоды" = 1)

/obj/item/food/cake/slavic/tvorozhnik
	slice_type = /obj/item/food/cakeslice/slavic/tvorozhnik
	name = "cottage cheese cake"
	desc = "Запечённый творожный пирог с нежной серединой и золотистой корочкой."
	icon_state = "tvorozhnik"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 24,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 9,
	)
	tastes = list("запечённый творог" = 2, "сладкое тесто" = 1)
	max_volume = 100

/obj/item/food/cake/slavic/tvorozhnik_berries
	slice_type = /obj/item/food/cakeslice/slavic/tvorozhnik_berries
	name = "berry cottage cheese cake"
	desc = "Творожный пирог с ягодами. Сочная кисло-сладкая добавка сочетается с мягкой запечённой основой."
	icon_state = "tvorozhnik_berries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 24,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 9,
	)
	foodtypes = DAIRY|SUGAR|FRUIT|GRAIN
	tastes = list("запечённый творог" = 2, "ягоды" = 1)

/obj/item/food/cake/slavic/tvorozhnik_condensed_milk
	slice_type = /obj/item/food/cakeslice/slavic/tvorozhnik_condensed_milk
	name = "condensed milk cottage cheese cake"
	desc = "Творожник, покрытый сгущённым молоком. Густое сладкое покрытие дополняет нежный пирог."
	icon_state = "tvorozhnik_condmilk"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 24,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment/protein = 9,
	)
	tastes = list("запечённый творог" = 2, "сгущённое молоко" = 1)

/obj/item/food/cake/slavic/tvorozhnik_berry_smetana
	slice_type = /obj/item/food/cakeslice/slavic/tvorozhnik_berry_smetana
	name = "berry and sour cream cottage cheese cake"
	desc = "Творожный пирог с ягодами и сметаной. Мягкая основа, сочные ягоды и лёгкая сливочная кислинка."
	icon_state = "tvorozhnik_berry_smetana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 24,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 12,
	)
	foodtypes = DAIRY|SUGAR|FRUIT|GRAIN
	tastes = list("запечённый творог" = 2, "ягоды" = 1)

/obj/item/food/slavic/tvorozhnik_raw
	name = "raw cottage cheese cake"
	desc = "Сырая творожная масса с мукой, яйцом, сахаром и сметаной, подготовленная для выпечки пирога."
	icon_state = "tvorozhnik_raw"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 9,
		/datum/reagent/consumable/nutriment/protein = 9,
	)
	foodtypes = DAIRY|SUGAR|GRAIN|RAW
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("сырое творожное тесто" = 1)
	foodtypes_removed_when_cooked = RAW

/obj/item/food/slavic/smetannik_choco_raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/cake/slavic/smetannik_choco, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)

/obj/item/food/slavic/smetannik_raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/cake/slavic/smetannik, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)

/obj/item/food/slavic/tvorozhnik_raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/cake/slavic/tvorozhnik, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)
