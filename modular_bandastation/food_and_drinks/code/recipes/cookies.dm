/datum/crafting_recipe/food/slavic/shortbread_dough
	name = "Песочное тесто"
	reqs = list(
		/datum/reagent/consumable/flour = 15,
		/obj/item/food/butter = 1,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/slavic/shortbread_dough
	added_foodtypes = GRAIN|SUGAR|RAW
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/choco_shortbread_dough
	name = "Шоколадное песочное тесто"
	reqs = list(
		/datum/reagent/consumable/flour = 15,
		/obj/item/food/butter = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/choco_shortbread_dough
	added_foodtypes = GRAIN|RAW
	removed_foodtypes = JUNKFOOD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_heart
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/heart
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_star_big
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/star_big
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_star_small
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/star_small
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_round
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/round
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_pendant
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/pendant
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_stick
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/stick
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_raw_fish
	name = "Сырое песочное печенье"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/plain/fish
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_glazed_heart
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/heart = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/heart
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_star_big
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/star_big = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/star_big
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_star_small
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/star_small = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/star_small
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_round
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/round = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/round
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_pendant
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/pendant = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/pendant
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_stick
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/stick = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/stick
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_glazed_fish
	name = "Песочное печенье с глазурью"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/fish = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/slavic/cookie/cooked/glazed/fish
	removed_foodtypes = JUNKFOOD
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_heart
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/heart = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/heart
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_star_big
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/star_big = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/star_big
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_star_small
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/star_small = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/star_small
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_round
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/round = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/round
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_pendant
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/pendant = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/pendant
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_stick
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/stick = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/stick
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_jam_fish
	name = "Песочное печенье с джемом"
	reqs = list(
		/obj/item/food/slavic/cookie/cooked/plain/fish = 1,
		/datum/reagent/consumable/berryjuice = 2,
	)
	result = /obj/item/food/slavic/cookie/cooked/jam/fish
	added_foodtypes = FRUIT
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_heart
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/heart
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_star_big
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/star_big
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_star_small
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/star_small
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_round
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/round
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_pendant
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/pendant
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_stick
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/stick
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/slavic/cookie_zebra_raw_fish
	name = "Сырое песочное печенье зебра"
	reqs = list(
		/obj/item/food/slavic/shortbread_dough_slice = 1,
		/obj/item/food/slavic/choco_shortbread_dough_slice = 1,
	)
	result = /obj/item/food/slavic/cookie/raw/zebra/fish
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/rollingpin/slavic_shortbread_dough_flat
	name = "Раскатанное песочное тесто"
	reqs = list(/obj/item/food/slavic/shortbread_dough = 1)
	result = /obj/item/food/slavic/shortbread_dough_flat
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/slavic_shortbread_dough_slice
	name = "Порезанное песочное тесто"
	reqs = list(/obj/item/food/slavic/shortbread_dough_flat = 1)
	result = /obj/item/food/slavic/shortbread_dough_slice
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/rollingpin/slavic_choco_shortbread_dough_flat
	name = "Раскатанное шоколадное песочное тесто"
	reqs = list(/obj/item/food/slavic/choco_shortbread_dough = 1)
	result = /obj/item/food/slavic/choco_shortbread_dough_flat
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/slavic_choco_shortbread_dough_slice
	name = "Порезанное шоколадное песочное тесто"
	reqs = list(/obj/item/food/slavic/choco_shortbread_dough_flat = 1)
	result = /obj/item/food/slavic/choco_shortbread_dough_slice
	dish_category = DISH_COOKIE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/oven/slavic_cookie_heart
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/heart = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/heart
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_star_big
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/star_big = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/star_big
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_star_small
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/star_small = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/star_small
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_round
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/round = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/round
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_pendant
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/pendant = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/pendant
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_stick
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/stick = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/stick
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_fish
	name = "Песочное печенье"
	reqs = list(/obj/item/food/slavic/cookie/raw/plain/fish = 1)
	result = /obj/item/food/slavic/cookie/cooked/plain/fish
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_heart
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/heart = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/heart
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_star_big
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/star_big = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/star_big
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_star_small
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/star_small = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/star_small
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_round
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/round = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/round
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_pendant
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/pendant = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/pendant
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_stick
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/stick = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/stick
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/slavic_cookie_zebra_fish
	name = "Песочное печенье зебра"
	reqs = list(/obj/item/food/slavic/cookie/raw/zebra/fish = 1)
	result = /obj/item/food/slavic/cookie/cooked/zebra/fish
	dish_category = DISH_COOKIE
	meal_category = MEAL_SNACK
