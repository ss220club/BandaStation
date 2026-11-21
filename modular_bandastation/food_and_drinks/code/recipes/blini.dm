/datum/crafting_recipe/food/station_food/blini
	abstract_type = /datum/crafting_recipe/food/station_food/blini
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/station_food/blini/breakfast
	abstract_type = /datum/crafting_recipe/food/station_food/blini/breakfast
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/station_food/blini/dessert
	abstract_type = /datum/crafting_recipe/food/station_food/blini/dessert
	meal_category = MEAL_DESSERT
	removed_foodtypes = BREAKFAST

/datum/crafting_recipe/food/station_food/blini/breakfast/tvorog
	name = "Блины с творогом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/tvorog = 1,
	)
	result = /obj/item/food/station_food/blini/tvorog
	removed_foodtypes = BREAKFAST

/datum/crafting_recipe/food/station_food/blini/breakfast/smetana
	name = "Блины со сметаной"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/smetana = 1,
	)
	result = /obj/item/food/station_food/blini/smetana
	removed_foodtypes = BREAKFAST

/datum/crafting_recipe/food/station_food/blini/dessert/berries
	name = "Блины с ягодами"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/station_food/blini/berries

/datum/crafting_recipe/food/station_food/blini/dessert/chocolate
	name = "Блины с шоколадом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/station_food/blini/chocolate
	removed_foodtypes = BREAKFAST|JUNKFOOD

/datum/crafting_recipe/food/station_food/blini/dessert/apple
	name = "Блины с яблоком"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/apple = 1,
	)
	result = /obj/item/food/station_food/blini/apple

/datum/crafting_recipe/food/station_food/blini/dessert/condensed_milk
	name = "Блины со сгущенкой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/station_food/condensed_milk = 1,
	)
	result = /obj/item/food/station_food/blini/condensed_milk

/datum/crafting_recipe/food/station_food/blini/soy
	name = "Блины с соевыми бобами"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/soydope = 1,
	)
	result = /obj/item/food/station_food/blini/soy
	removed_foodtypes = BREAKFAST

/datum/crafting_recipe/food/station_food/blini/dessert/pumpkin
	name = "Блины с тыквой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/grown/pumpkin = 1,
	)
	result = /obj/item/food/station_food/blini/pumpkin

/datum/crafting_recipe/food/station_food/blini/dessert/pineapple
	name = "Блины с ананасом"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/obj/item/food/pineappleslice = 2,
	)
	result = /obj/item/food/station_food/blini/pineapple

/datum/crafting_recipe/food/station_food/blini/dessert/peanut_butter
	name = "Блины с арахисовой пастой"
	reqs = list(
		/obj/item/food/pancakes = 5,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	result = /obj/item/food/station_food/blini/peanut_butter
	added_foodtypes = NUTS

/datum/crafting_recipe/food/station_food/blini/ham_cheese
	name = "Блины с ветчиной и сыром"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/meat/bacon = 2,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/station_food/blini/ham_cheese
	removed_foodtypes = SUGAR

/datum/crafting_recipe/food/station_food/blini/fish_cucumber
	name = "Блины с рыбой"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/cucumber = 1,
		/obj/item/food/cheese/curd_cheese = 1,
	)
	result = /obj/item/food/station_food/blini/fish_cucumber
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/meat
	name = "Блины с мясом"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/meat/cutlet/plain = 2,
		/obj/item/food/grown/herbs = 1,
	)
	result = /obj/item/food/station_food/blini/meat
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/potato_mushroom
	name = "Блины с картошкой и грибами"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
	)
	result = /obj/item/food/station_food/blini/potato_mushroom
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/beetroot
	name = "Блины со свеклой"
	reqs = list(
		/obj/item/food/pancakes = 2,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/mayonnaise = 5,
	)
	result = /obj/item/food/station_food/blini/beetroot
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/meat_cucumber
	name = "Мясные блины с огурцом"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/tzatziki_sauce = 1,
		/obj/item/food/patty/plain = 1,
		/obj/item/food/onion_slice = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/cucumber

/datum/crafting_recipe/food/station_food/blini/meat_combo
	name = "Мясные блины - мясное комбо"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/patty/plain = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/meatball = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/combo
	added_foodtypes = VEGETABLES
	removed_foodtypes = BREAKFAST

/datum/crafting_recipe/food/station_food/blini/meat_cabbage
	name = "Мясные блины - голубцы наоборот"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/cabbage = 1,
		/datum/reagent/consumable/nutriment/fat/oil/olive = 5,
	)
	result = /obj/item/food/station_food/blini/meat_based/cabbage

/datum/crafting_recipe/food/station_food/blini/meat_spicy
	name = "Мясные блины острые"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/spicy

/datum/crafting_recipe/food/station_food/blini/meat_mushroom
	name = "Мясные блины с грибами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 2,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/obj/item/food/grown/mushroom/reishi = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/mushroom

/datum/crafting_recipe/food/station_food/blini/breakfast/breakfast
	name = "Блин завтрак"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/bacon = 1,
	)
	result = /obj/item/food/station_food/blini/breakfast
	removed_foodtypes = SUGAR|FRIED

/datum/crafting_recipe/food/station_food/blini/sausage
	name = "Блин с сарделькой"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/sausage = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/ketchup = 5,
	)
	result = /obj/item/food/station_food/blini/sausage
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/veggie
	name = "Блин с овощами"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/cucumber = 1,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/station_food/blini/veggie
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/chicken_cream
	name = "Блин курица со сливками"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/meat/steak/chicken = 1,
		/datum/reagent/consumable/cream = 5,
		/obj/item/food/grown/herbs = 1,
	)
	result = /obj/item/food/station_food/blini/chicken_cream
	added_foodtypes = DAIRY
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/caesar
	name = "Блин цезарь"
	reqs = list(
		/obj/item/food/pancakes = 1,
		/obj/item/food/meat/steak/chicken = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/station_food/blini/caesar
	removed_foodtypes = SUGAR|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/meat_shashlik
	name = "Мясной блин Шашлык"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/bbqsauce = 5,
	)
	result = /obj/item/food/station_food/blini/meat_based/shashlik

/datum/crafting_recipe/food/station_food/blini/meat_egg
	name = "Мясной блин с яйцом и грибами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/meat/bacon = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/egg
	removed_foodtypes = FRIED|BREAKFAST

/datum/crafting_recipe/food/station_food/blini/meat_fish
	name = "Мясной блин с рыбой"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/pickle = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/fish

/datum/crafting_recipe/food/station_food/blini/meat_veggie
	name = "Мясной блин с овощами"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/grown/carrotlike/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/corn = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/veggie

/datum/crafting_recipe/food/station_food/blini/meat_ambrosia
	name = "Мясной блин с амброзией"
	reqs = list(
		/obj/item/food/station_food/meat_blini = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 2,
		/obj/item/food/grown/bell_pepper = 1,
		/obj/item/food/grown/potato = 1,
	)
	result = /obj/item/food/station_food/blini/meat_based/ambrosia

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
