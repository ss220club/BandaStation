
// see code/module/crafting/table.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/crafting_recipe/food/meatbread
	name = "Мясной хлеб"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/plain = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/meat
	category = CAT_BREAD

/datum/crafting_recipe/food/xenomeatbread
	name = "Ксеномясной хлеб"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/xenomeat
	category = CAT_BREAD

/datum/crafting_recipe/food/spidermeatbread
	name = "Паучий мясной хлеб"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/spider = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/spidermeat
	category = CAT_BREAD

/datum/crafting_recipe/food/sausagebread
	name = "Колбасный хлеб"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/sausage = 2,
	)
	result = /obj/item/food/bread/sausage
	removed_foodtypes = BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/banananutbread
	name = "Банановый хлеб с орехами"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/boiledegg = 3,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/bread/banana
	removed_foodtypes = BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/tofubread
	name = "Тофухлеб"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/tofu
	category = CAT_BREAD

/datum/crafting_recipe/food/creamcheesebread
	name = "Хлеб с кремовым сыром"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/bread/creamcheese
	category = CAT_BREAD

/datum/crafting_recipe/food/mimanabread
	name = "Хлеб из миманы"
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/grown/banana/mime = 1
	)
	result = /obj/item/food/bread/mimana
	category = CAT_BREAD

/datum/crafting_recipe/food/garlicbread
	name = "Чесночный хлеб"
	time = 40
	reqs = list(/obj/item/food/grown/garlic = 1,
				/obj/item/food/breadslice/plain = 1,
				/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/garlicbread
	category = CAT_BREAD

/datum/crafting_recipe/food/butterbiscuit
	name = "Масляный бисквит"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/butterbiscuit
	added_foodtypes = BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/butterdog
	name = "Масло-дог"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1,
		)
	result = /obj/item/food/butterdog
	category = CAT_BREAD

/datum/crafting_recipe/food/baguette
	name = "Багет"
	time = 40
	reqs = list(/datum/reagent/consumable/salt = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/doughslice = 2,
	)
	result = /obj/item/food/baguette
	category = CAT_BREAD

/datum/crafting_recipe/food/raw_breadstick
	name = "Сырая хлебная палочка"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/raw_breadstick
	category = CAT_BREAD

/datum/crafting_recipe/food/raw_croissant
	name = "Сырой круассан"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/datum/reagent/consumable/sugar = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/raw_croissant
	category = CAT_BREAD

/datum/crafting_recipe/food/throwing_croissant
	name = "Метательный круассан"
	reqs = list(
		/obj/item/food/croissant = 1,
		/obj/item/stack/rods = 1,
	)
	result = /obj/item/food/croissant/throwing
	category = CAT_BREAD
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/breaddog
	name = "Живой собакохлеб"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/food/bread/plain = 2,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/basic/pet/dog/breaddog
	category = CAT_BREAD

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/crafting_recipe/food/slimetoast
	name = "Slime toast"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/food/jelliedtoast/slime
	added_foodtypes = TOXIC | BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/jelliedyoast
	name = "Jellied toast"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/food/jelliedtoast/cherry
	added_foodtypes = FRUIT | SUGAR | BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/butteredtoast
	added_foodtypes = BREAKFAST
	category = CAT_BREAD

/datum/crafting_recipe/food/twobread
	name = "Two bread"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/food/breadslice/plain = 2
	)
	result = /obj/item/food/twobread
	category = CAT_BREAD

/datum/crafting_recipe/food/moldybread // why would you make this?
	name = "Moldy Bread"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/grown/mushroom/amanita = 1
		)
	result = /obj/item/food/breadslice/moldy
	removed_foodtypes = VEGETABLES|GRAIN
	added_foodtypes = GROSS
	category = CAT_BREAD

/datum/crafting_recipe/food/breadcat
	name = "Bread cat/bread hybrid"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/tail/cat = 1,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 50,
		/datum/reagent/medicine/strange_reagent = 5
	)
	result = /mob/living/basic/pet/cat/breadcat
	category = CAT_BREAD

/datum/crafting_recipe/food/frenchtoast
	name = "Сырой французский тост"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/egg = 2,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/food/raw_frenchtoast
	added_foodtypes = BREAKFAST
	category = CAT_BREAD
