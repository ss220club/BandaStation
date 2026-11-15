/obj/item/food/station_food/cookie
	abstract_type = /obj/item/food/station_food/cookie
	foodtypes = GRAIN|DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/station_food/cookie/cooked
	abstract_type = /obj/item/food/station_food/cookie/cooked
	food_flags = FOOD_FINGER_FOOD

/obj/item/food/station_food/cookie/raw
	abstract_type = /obj/item/food/station_food/cookie/raw
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	foodtypes_removed_when_cooked = RAW
	/// Cooked food type produced by baking this shape.
	var/obj/item/food/cooked_result

/obj/item/food/station_food/cookie/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, cooked_result, rand(30 SECONDS, 40 SECONDS), TRUE, TRUE)

/obj/item/food/station_food/shortbread_dough
	name = "shortbread dough"
	desc = "Плотное песочное тесто с маслянистой текстурой. Подходит для печенья и сладкой выпечки."
	icon_state = "shortbread_dough"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "сливочное масло" = 1)

/obj/item/food/station_food/shortbread_dough_flat
	name = "rolled shortbread dough"
	desc = "Тонко раскатанный пласт песочного теста, готовый к разделке."
	icon_state = "shortbread_dough_flat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "сливочное масло" = 1)

/obj/item/food/station_food/shortbread_dough_slice
	name = "cut shortbread dough"
	desc = "Порция песочного теста для формирования печенья и небольшой выпечки."
	icon_state = "shortbread_dough_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "сливочное масло" = 1)

/obj/item/food/station_food/choco_shortbread_dough
	name = "chocolate shortbread dough"
	desc = "Песочное тесто с шоколадом. После выпечки приобретает рассыпчатую текстуру."
	icon_state = "choco_shortbread_dough"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "шоколад" = 1)

/obj/item/food/station_food/choco_shortbread_dough_flat
	name = "rolled chocolate shortbread dough"
	desc = "Раскатанный пласт шоколадного песочного теста для печенья и коржей."
	icon_state = "choco_shortbread_dough_flat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "шоколад" = 1)

/obj/item/food/station_food/choco_shortbread_dough_slice
	name = "cut chocolate shortbread dough"
	desc = "Небольшая порция шоколадного песочного теста, подготовленная к формовке."
	icon_state = "choco_shortbread_dough_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	foodtypes = GRAIN|DAIRY|SUGAR|RAW
	crafting_complexity = FOOD_COMPLEXITY_1
	tastes = list("сырое песочное тесто" = 2, "шоколад" = 1)

/obj/item/food/station_food/cookie/raw/plain
	abstract_type = /obj/item/food/station_food/cookie/raw/plain
	name = "raw shortbread cookie"
	desc = "Фигурная заготовка из песочного теста. Перед подачей её нужно испечь."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("сырое песочное тесто" = 1)

/obj/item/food/station_food/cookie/raw/plain/heart
	icon_state = "cookie_raw_heart"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/heart

/obj/item/food/station_food/cookie/raw/plain/star_big
	icon_state = "cookie_raw_star_big"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/star_big

/obj/item/food/station_food/cookie/raw/plain/star_small
	icon_state = "cookie_raw_star_small"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/star_small

/obj/item/food/station_food/cookie/raw/plain/round
	icon_state = "cookie_raw_round"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/round

/obj/item/food/station_food/cookie/raw/plain/pendant
	icon_state = "cookie_raw_pendant"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/pendant

/obj/item/food/station_food/cookie/raw/plain/stick
	icon_state = "cookie_raw_stick"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/stick

/obj/item/food/station_food/cookie/raw/plain/fish
	icon_state = "cookie_raw_fish"
	cooked_result = /obj/item/food/station_food/cookie/cooked/plain/fish

/obj/item/food/station_food/cookie/cooked/plain
	abstract_type = /obj/item/food/station_food/cookie/cooked/plain
	name = "shortbread cookie"
	desc = "Золотистое песочное печенье с рассыпчатой текстурой и мягким сливочным вкусом."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("рассыпчатое песочное тесто" = 1)

/obj/item/food/station_food/cookie/cooked/plain/heart
	icon_state = "cookie_heart"

/obj/item/food/station_food/cookie/cooked/plain/star_big
	icon_state = "cookie_star_big"

/obj/item/food/station_food/cookie/cooked/plain/star_small
	icon_state = "cookie_star_small"

/obj/item/food/station_food/cookie/cooked/plain/round
	icon_state = "cookie_round"

/obj/item/food/station_food/cookie/cooked/plain/pendant
	icon_state = "cookie_pendant"

/obj/item/food/station_food/cookie/cooked/plain/stick
	icon_state = "cookie_stick"

/obj/item/food/station_food/cookie/cooked/plain/fish
	icon_state = "cookie_fish"

/obj/item/food/station_food/cookie/cooked/glazed
	abstract_type = /obj/item/food/station_food/cookie/cooked/glazed
	name = "glazed shortbread cookie"
	desc = "Рассыпчатое песочное печенье, покрытое сладкой сахарной глазурью."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	tastes = list("песочное тесто" = 2, "сахарная глазурь" = 1)

/obj/item/food/station_food/cookie/cooked/glazed/heart
	icon_state = "cookie_glazed_heart"

/obj/item/food/station_food/cookie/cooked/glazed/star_big
	icon_state = "cookie_glazed_star_big"

/obj/item/food/station_food/cookie/cooked/glazed/star_small
	icon_state = "cookie_glazed_star_small"

/obj/item/food/station_food/cookie/cooked/glazed/round
	icon_state = "cookie_glazed_round"

/obj/item/food/station_food/cookie/cooked/glazed/pendant
	icon_state = "cookie_glazed_pendant"

/obj/item/food/station_food/cookie/cooked/glazed/stick
	icon_state = "cookie_glazed_stick"

/obj/item/food/station_food/cookie/cooked/glazed/fish
	icon_state = "cookie_glazed_fish"

/obj/item/food/station_food/cookie/cooked/jam
	abstract_type = /obj/item/food/station_food/cookie/cooked/jam
	name = "shortbread cookie with jam"
	desc = "Песочное печенье с ягодным джемом. Кисло-сладкая начинка дополняет маслянистое тесто."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("песочное тесто" = 2, "ягодный джем" = 1)

/obj/item/food/station_food/cookie/cooked/jam/heart
	icon_state = "cookie_jam_heart"

/obj/item/food/station_food/cookie/cooked/jam/star_big
	icon_state = "cookie_jam_star_big"

/obj/item/food/station_food/cookie/cooked/jam/star_small
	icon_state = "cookie_jam_star_small"

/obj/item/food/station_food/cookie/cooked/jam/round
	icon_state = "cookie_jam_round"

/obj/item/food/station_food/cookie/cooked/jam/pendant
	icon_state = "cookie_jam_pendant"

/obj/item/food/station_food/cookie/cooked/jam/stick
	icon_state = "cookie_jam_stick"

/obj/item/food/station_food/cookie/cooked/jam/fish
	icon_state = "cookie_jam_fish"

/obj/item/food/station_food/cookie/cooked/zebra
	abstract_type = /obj/item/food/station_food/cookie/cooked/zebra
	name = "zebra shortbread cookie"
	desc = "Двухцветное песочное печенье из обычного и шоколадного теста."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("шоколадное песочное тесто" = 1)

/obj/item/food/station_food/cookie/cooked/zebra/heart
	icon_state = "cookie_zebra_heart"

/obj/item/food/station_food/cookie/cooked/zebra/star_big
	icon_state = "cookie_zebra_star_big"

/obj/item/food/station_food/cookie/cooked/zebra/star_small
	icon_state = "cookie_zebra_star_small"

/obj/item/food/station_food/cookie/cooked/zebra/round
	icon_state = "cookie_zebra_round"

/obj/item/food/station_food/cookie/cooked/zebra/pendant
	icon_state = "cookie_zebra_pendant"

/obj/item/food/station_food/cookie/cooked/zebra/stick
	icon_state = "cookie_zebra_stick"

/obj/item/food/station_food/cookie/cooked/zebra/fish
	icon_state = "cookie_zebra_fish"

/obj/item/food/station_food/cookie/raw/zebra
	abstract_type = /obj/item/food/station_food/cookie/raw/zebra
	name = "raw zebra shortbread cookie"
	desc = "Фигурная заготовка с чередующимися участками обычного и шоколадного теста. Готова к выпечке."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("сырое шоколадное тесто" = 1)

/obj/item/food/station_food/cookie/raw/zebra/heart
	icon_state = "cookie_zebra_raw_heart"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/heart

/obj/item/food/station_food/cookie/raw/zebra/star_big
	icon_state = "cookie_zebra_raw_star_big"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/star_big

/obj/item/food/station_food/cookie/raw/zebra/star_small
	icon_state = "cookie_zebra_raw_star_small"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/star_small

/obj/item/food/station_food/cookie/raw/zebra/round
	icon_state = "cookie_zebra_raw_round"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/round

/obj/item/food/station_food/cookie/raw/zebra/pendant
	icon_state = "cookie_zebra_raw_pendant"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/pendant

/obj/item/food/station_food/cookie/raw/zebra/stick
	icon_state = "cookie_zebra_raw_stick"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/stick

/obj/item/food/station_food/cookie/raw/zebra/fish
	icon_state = "cookie_zebra_raw_fish"
	cooked_result = /obj/item/food/station_food/cookie/cooked/zebra/fish

/obj/item/food/station_food/shortbread_dough/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/food/station_food/shortbread_dough_flat, 1, 3 SECONDS, table_required = TRUE, screentip_verb = "Flatten", sound_to_play = /datum/sound_effect/rolling_pin_rolling)

/obj/item/food/station_food/shortbread_dough_flat/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/station_food/shortbread_dough_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/station_food/choco_shortbread_dough/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/food/station_food/choco_shortbread_dough_flat, 1, 3 SECONDS, table_required = TRUE, screentip_verb = "Flatten", sound_to_play = /datum/sound_effect/rolling_pin_rolling)

/obj/item/food/station_food/choco_shortbread_dough_flat/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/station_food/choco_shortbread_dough_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)
