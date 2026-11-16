/datum/crafting_recipe/food/station_food/blini_tvorog
	name = "Блины с творогом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/tvorog = 1,
	)
	result = /obj/item/food/station_food/blini_tvorog
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/blini_smetana
	name = "Блины со сметаной"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/smetana = 1,
	)
	result = /obj/item/food/station_food/blini_smetana
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/blini_berries
	name = "Блины с ягодами"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/station_food/blini_berries
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_chocolate
	name = "Блины с шоколадом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/station_food/blini_chocolate
	removed_foodtypes = BREAKFAST|JUNKFOOD
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_apple
	name = "Блины с яблоком"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/apple = 1,
	)
	result = /obj/item/food/station_food/blini_apple
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_condensed_milk
	name = "Блины со сгущенкой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/condensed_milk = 1,
	)
	result = /obj/item/food/station_food/blini_condensed_milk
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_soy
	name = "Блины с соевыми бобами"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/soydope = 1,
	)
	result = /obj/item/food/station_food/blini_soy
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_pumpkin
	name = "Блины с тыквой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/pumpkin = 1,
	)
	result = /obj/item/food/station_food/blini_pumpkin
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_pineapple
	name = "Блины с ананасом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/pineappleslice = 2,
	)
	result = /obj/item/food/station_food/blini_pineapple
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_peanut_butter
	name = "Блины с арахисовой пастой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	result = /obj/item/food/station_food/blini_peanut_butter
	added_foodtypes = NUTS
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/station_food/blini_ham_cheese
	name = "Блины с ветчиной и сыром"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/meat/steak/plain/pig = 2,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/station_food/blini_ham_cheese
	removed_foodtypes = SUGAR
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_fish_cucumber
	name = "Блины с рыбой"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/cucumber = 1,
		/obj/item/food/cheese/curd_cheese = 1,
	)
	result = /obj/item/food/station_food/blini_fish_cucumber
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_meat
	name = "Блины с мясом"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/patty/plain = 2,
		/obj/item/food/grown/herbs = 1,
	)
	result = /obj/item/food/station_food/blini_meat
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_potato_mushroom
	name = "Блины с картошкой и грибами"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
	)
	result = /obj/item/food/station_food/blini_potato_mushroom
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_beetroot
	name = "Блины со свеклой"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/mayonnaise = 5,
	)
	result = /obj/item/food/station_food/blini_beetroot
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_cucumber
	name = "Мясные блины с огурцом"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/tzatziki_sauce = 1,
		/obj/item/food/patty/plain = 1,
		/obj/item/food/onion_slice = 1,
	)
	result = /obj/item/food/station_food/meat_blini_cucumber
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_combo
	name = "Мясные блины - мясное комбо"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/patty/plain = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/meatball = 1,
	)
	result = /obj/item/food/station_food/meat_blini_combo
	added_foodtypes = VEGETABLES
	removed_foodtypes = BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_cabbage
	name = "Мясные блины - голубцы наоборот"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/cabbage = 1,
		/datum/reagent/consumable/nutriment/fat/oil/olive = 5,
	)
	result = /obj/item/food/station_food/meat_blini_cabbage
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_spicy
	name = "Мясные блины острые"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
	)
	result = /obj/item/food/station_food/meat_blini_spicy
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_mushroom
	name = "Мясные блины с грибами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/obj/item/food/grown/mushroom/reishi = 1,
	)
	result = /obj/item/food/station_food/meat_blini_mushroom
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_breakfast
	name = "Блин завтрак"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/bacon = 1,
	)
	result = /obj/item/food/station_food/blini_breakfast
	removed_foodtypes = SUGAR|FRIED
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/blini_sausage
	name = "Блин с сарделькой"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/sausage = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/ketchup = 5,
	)
	result = /obj/item/food/station_food/blini_sausage
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_veggie
	name = "Блин с овощами"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/cucumber = 1,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/station_food/blini_veggie
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_chicken_cream
	name = "Блин курица со сливками"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/meat/steak/chicken = 1,
		/datum/reagent/consumable/cream = 5,
		/obj/item/food/grown/herbs = 1,
	)
	result = /obj/item/food/station_food/blini_chicken_cream
	added_foodtypes = DAIRY
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini_caesar
	name = "Блин цезарь"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/meat/steak/chicken = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/station_food/blini_caesar
	removed_foodtypes = SUGAR|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_shashlik
	name = "Мясной блин Шашлык"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/bbqsauce = 5,
	)
	result = /obj/item/food/station_food/meat_blini_shashlik
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_egg
	name = "Мясной блин с яйцом и грибами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/meat/bacon = 1,
	)
	result = /obj/item/food/station_food/meat_blini_egg
	removed_foodtypes = FRIED|BREAKFAST
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_fish
	name = "Мясной блин с рыбой"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/pickle = 1,
	)
	result = /obj/item/food/station_food/meat_blini_fish
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_veggie
	name = "Мясной блин с овощами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/grown/carrotlike/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/corn = 1,
	)
	result = /obj/item/food/station_food/meat_blini_veggie
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/meat_blini_ambrosia
	name = "Мясной блин с амброзией"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 2,
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/grown/potato = 1,
	)
	result = /obj/item/food/station_food/meat_blini_ambrosia
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/grill/station_food_meat_blini
	name = "Мясной блин"
	reqs = list(/datum/reagent/consumable/pancakebatter/meat = 5)
	result = /obj/item/food/station_food/meat_blini
	steps = list(
		"Смешать в ёмкости 6 ед. желтка, 12 ед. белка, 5 ед. муки, 5 ед. животного белка и 10 ед. воды.",
		"Выплеснуть жидкое тесто на плиту: 5 ед. на один блин (ПКМ в боевом режиме).",
		"Обжарить до готовности и снять с плиты.",
	)
	dish_category = DISH_PASTRY
	meal_category = MEAL_SNACK
