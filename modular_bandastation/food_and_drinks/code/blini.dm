/obj/item/food/slavic/meat_blini
	name = "meat blin"
	desc = "Тонкий блин из мясного теста, обжаренный до румяной корочки."
	icon_state = "meat_blini"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = MEAT
	crafting_complexity = FOOD_COMPLEXITY_2
	tastes = list("жареное мясо" = 2)

/obj/item/food/slavic/blini
	abstract_type = /obj/item/food/slavic/blini
	foodtypes = GRAIN|DAIRY|SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/slavic/blini/meat_based
	abstract_type = /obj/item/food/slavic/blini/meat_based
	foodtypes = MEAT|VEGETABLES

/obj/item/food/slavic/blini/tvorog
	name = "blini with cottage cheese"
	desc = "Тонкие блинчики с мягкой творожной начинкой и лёгкой сладостью."
	icon_state = "blini_tvorog"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("тонкий блин" = 2, "творог" = 1)

/obj/item/food/slavic/blini/smetana
	name = "blini with sour cream"
	desc = "Румяные блины с густой сметаной. Её кислинка оттеняет мягкий вкус теста."
	icon_state = "blini_smetana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/protein = 3,
	)
	tastes = list("тонкий блин" = 2, "сметана" = 1)

/obj/item/food/slavic/blini/berries
	name = "blini with berries"
	desc = "Блинчики с сочной ягодной начинкой и кисло-сладким вкусом."
	icon_state = "blini_berries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 2,
	)
	foodtypes = GRAIN|FRUIT|SUGAR
	tastes = list("тонкий блин" = 2, "ягоды" = 1)

/obj/item/food/slavic/blini/chocolate
	name = "blini with chocolate"
	desc = "Мягкие блины с насыщенной шоколадной начинкой."
	icon_state = "blini_chocolate"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 5,
	)
	foodtypes = GRAIN|SUGAR
	tastes = list("тонкий блин" = 2, "шоколад" = 1)

/obj/item/food/slavic/blini/apple
	name = "blini with apple"
	desc = "Тонкие блинчики с яблочной начинкой и лёгким фруктовым ароматом."
	icon_state = "blini_apple"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sugar = 2,
	)
	foodtypes = GRAIN|FRUIT|SUGAR
	tastes = list("тонкий блин" = 2, "яблоко" = 1)

/obj/item/food/slavic/blini/condensed_milk
	name = "blini with condensed milk"
	desc = "Блины с густым сгущённым молоком и сладким сливочным вкусом."
	icon_state = "blini_condensed_milk"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("тонкий блин" = 2, "сгущённое молоко" = 1)

/obj/item/food/slavic/blini/soy
	name = "blini with soybeans"
	desc = "Блинчики с начинкой из соевых бобов. Мягкое тесто сочетается с плотной бобовой начинкой."
	icon_state = "blini_soy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|SUGAR|VEGETABLES
	tastes = list("тонкий блин" = 2, "соевые бобы" = 1)

/obj/item/food/slavic/blini/pumpkin
	name = "blini with pumpkin"
	desc = "Блины с мягкой тыквенной начинкой, придающей им лёгкую сладость."
	icon_state = "blini_pumpkin"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	foodtypes = GRAIN|VEGETABLES|SUGAR
	tastes = list("тонкий блин" = 2, "тыква" = 1)

/obj/item/food/slavic/blini/pineapple
	name = "blini with pineapple"
	desc = "Тонкие блины с сочной ананасовой начинкой и выраженной фруктовой кислинкой."
	icon_state = "blini_pineapple"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/pineapplejuice = 5,
	)
	foodtypes = GRAIN|PINEAPPLE|SUGAR|FRUIT
	tastes = list("тонкий блин" = 2, "ананас" = 1)

/obj/item/food/slavic/blini/peanut_butter
	name = "blini with peanut butter"
	desc = "Блинчики с густой арахисовой пастой и насыщенным ореховым вкусом."
	icon_state = "blini_peanut_butter"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/peanut_butter = 5,
		/datum/reagent/consumable/sugar = 2,
	)
	foodtypes = GRAIN|NUTS|SUGAR
	tastes = list("тонкий блин" = 2, "арахисовая паста" = 1)

/obj/item/food/slavic/blini/ham_cheese
	name = "blini with ham and cheese"
	desc = "Блины с обжаренным беконом и мягким сыром."
	icon_state = "blini_ham_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	foodtypes = GRAIN|MEAT|DAIRY|BREAKFAST
	tastes = list("тонкий блин" = 2, "бекон и сыр" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 2)

/obj/item/food/slavic/blini/fish_cucumber
	name = "blini with fish"
	desc = "Блинчики с рыбной начинкой и свежим огурцом, добавляющим сочность и хруст."
	icon_state = "blini_fish_cucumber"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	foodtypes = GRAIN|DAIRY|SEAFOOD|VEGETABLES
	tastes = list("тонкий блин" = 2, "рыба и свежий огурец" = 1)

/obj/item/food/slavic/blini/meat
	name = "blini with meat"
	desc = "Румяные блинчики с начинкой из обжаренного мяса."
	icon_state = "blini_meat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	foodtypes = GRAIN|MEAT|VEGETABLES
	tastes = list("тонкий блин" = 2, "жареное мясо" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 2)

/obj/item/food/slavic/blini/potato_mushroom
	name = "blini with potatoes and mushrooms"
	desc = "Блины с картофелем и грибами. Мягкая картофельная начинка пропитана грибным ароматом."
	icon_state = "blini_potato_mushroom"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|VEGETABLES
	tastes = list("тонкий блин" = 2, "картофель и грибы" = 1)

/obj/item/food/slavic/blini/beetroot
	name = "blini with beetroot"
	desc = "Блинчики со свёклой и чесноком. Сладковатая овощная начинка обладает лёгкой остротой."
	icon_state = "blini_beetroot"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN|VEGETABLES
	tastes = list("тонкий блин" = 2, "свёкла и чеснок" = 1)

/obj/item/food/slavic/blini/meat_based/cucumber
	name = "meat blini with cucumber"
	desc = "Мясные блины со свежим огурцом. Хрустящая начинка дополняет обжаренное мясное тесто."
	icon_state = "meat_blini_cucumber"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	tastes = list("жареное мясо" = 2, "свежий огурец" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/slavic/blini/meat_based/combo
	name = "meat blini meat combo"
	desc = "Мясные блины с начинкой из нескольких мясных продуктов. Плотное и сытное блюдо."
	icon_state = "meat_blini_combo"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 12,
	)
	tastes = list("жареное мясо" = 2, "мясное ассорти" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/slavic/blini/meat_based/cabbage
	name = "inside-out cabbage roll blini"
	desc = "Мясные блины с капустной начинкой. Сочетание мяса и капусты напоминает голубцы."
	icon_state = "meat_blini_cabbage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("жареное мясо" = 2, "тушёная капуста" = 1)

/obj/item/food/slavic/blini/meat_based/spicy
	name = "spicy meat blini"
	desc = "Мясные блины с острым перцем. Пряная начинка оставляет заметное жгучее послевкусие."
	icon_state = "meat_blini_spicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("жареное мясо" = 2, "острый перец" = 1)

/obj/item/food/slavic/blini/meat_based/mushroom
	name = "meat blini with mushrooms"
	desc = "Мясные блины с грибной начинкой и насыщенным ароматом жареных грибов."
	icon_state = "meat_blini_mushroom"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nutriment/protein = 9,
	)
	tastes = list("жареное мясо" = 2, "жареные грибы" = 1)

/obj/item/food/slavic/blini/breakfast
	name = "breakfast blin"
	desc = "Блин с беконом и жареным яйцом. Сытная начинка для плотного завтрака."
	icon_state = "blini_breakfast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	foodtypes = GRAIN|VEGETABLES|MEAT|BREAKFAST|EGG
	tastes = list("тонкий блин" = 2, "бекон и жареное яйцо" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/slavic/blini/sausage
	name = "blin with sausage"
	desc = "Сарделька с соусом, завёрнутая в тонкий блин."
	icon_state = "blini_sausage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	foodtypes = GRAIN|VEGETABLES|MEAT
	tastes = list("тонкий блин" = 2, "сарделька и соус" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/slavic/blini/veggie
	name = "blin with vegetables"
	desc = "Блин с овощной начинкой. Свежие овощи придают ему сочность и лёгкий хруст."
	icon_state = "blini_veggie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 9,
	)
	foodtypes = GRAIN|VEGETABLES
	tastes = list("тонкий блин" = 2, "свежие овощи" = 1)

/obj/item/food/slavic/blini/chicken_cream
	name = "blin with chicken and cream"
	desc = "Блин с курицей в сливочном соусе. Нежная начинка обладает мягким сливочным вкусом."
	icon_state = "blini_chicken_cream"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	foodtypes = GRAIN|VEGETABLES|MEAT|DAIRY
	tastes = list("тонкий блин" = 2, "курица в сливках" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/slavic/blini/caesar
	name = "Caesar blin"
	desc = "Блин с курицей и сырным соусом по мотивам салата «Цезарь»."
	icon_state = "blini_caesar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	foodtypes = GRAIN|VEGETABLES|MEAT
	tastes = list("тонкий блин" = 2, "курица и сырный соус" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/slavic/blini/meat_based/shashlik
	name = "shashlik meat blin"
	desc = "Мясной блин с начинкой из жареного мяса и лука."
	icon_state = "meat_blini_shashlik"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 12,
	)
	tastes = list("жареное мясо" = 2, "жареное мясо и лук" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT * 3)

/obj/item/food/slavic/blini/meat_based/egg
	name = "meat blin with egg and mushrooms"
	desc = "Мясной блин с яйцом и грибами. Мягкая начинка дополнена выраженным грибным вкусом."
	icon_state = "meat_blini_egg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 10,
	)
	foodtypes = VEGETABLES|MEAT|EGG
	tastes = list("жареное мясо" = 2, "яйцо и грибы" = 1)
	custom_materials = list(/datum/material/meat = MEATDISH_MATERIAL_AMOUNT)

/obj/item/food/slavic/blini/meat_based/fish
	name = "meat blin with fish"
	desc = "Мясной блин с рыбной начинкой. В одном блюде сочетаются жареное мясо и рыба."
	icon_state = "meat_blini_fish"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nutriment/protein = 10,
	)
	foodtypes = VEGETABLES|MEAT|SEAFOOD
	tastes = list("жареное мясо" = 2, "рыба" = 1)

/obj/item/food/slavic/blini/meat_based/veggie
	name = "meat blin with vegetables"
	desc = "Мясной блин с овощами. Сочная начинка оттеняет насыщенный вкус мясного теста."
	icon_state = "meat_blini_veggie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	tastes = list("жареное мясо" = 2, "свежие овощи" = 1)

/obj/item/food/slavic/blini/meat_based/ambrosia
	name = "meat blin with ambrosia"
	desc = "Мясной блин с амброзией и овощной начинкой. Зелень придаёт блюду пряный аромат."
	icon_state = "meat_blini_ambrosia"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/capsaicin = 4,
	)
	tastes = list("жареное мясо" = 2, "пряная зелень" = 1)

/obj/item/food/slavic/meat_blini_raw
	name = "raw meat blin"
	desc = "Сырая порция мясного теста, разлитая в форме тонкого блина. Перед подачей её нужно обжарить."
	icon_state = "meat_blini_raw"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("сырое мясное тесто" = 1)
	foodtypes = MEAT | RAW
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/slavic/meat_blini_raw/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/slavic/meat_blini, rand(20 SECONDS, 30 SECONDS), TRUE, TRUE)

/obj/item/food/slavic/meat_blini_raw/food_grilled(datum/source, obj/item/food/grill_result)
	. = ..()
	for(var/datum/reagent/consumable/nutriment/nutriment in grill_result.reagents.reagent_list)
		if(nutriment.carry_food_tastes)
			nutriment.data = counterlist_normalise(grill_result.tastes.Copy())
