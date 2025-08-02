
// see code/module/crafting/table.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/crafting_recipe/food/carrotcake
	name = "Морковный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/carrot = 2
	)
	result = /obj/item/food/cake/carrot
	category = CAT_CAKE

/datum/crafting_recipe/food/cheesecake
	name = "Чизкейк"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/cake/cheese
	category = CAT_CAKE

/datum/crafting_recipe/food/applecake
	name = "Яблочный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/apple = 2
	)
	result = /obj/item/food/cake/apple
	category = CAT_CAKE

/datum/crafting_recipe/food/orangecake
	name = "Апельсиновый торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/orange = 2
	)
	result = /obj/item/food/cake/orange
	category = CAT_CAKE

/datum/crafting_recipe/food/limecake
	name = "Лаймовый торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/lime = 2
	)
	result = /obj/item/food/cake/lime
	category = CAT_CAKE

/datum/crafting_recipe/food/lemoncake
	name = "Лимонный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/lemon = 2
	)
	result = /obj/item/food/cake/lemon
	category = CAT_CAKE

/datum/crafting_recipe/food/chocolatecake
	name = "Шоколадный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/chocolatebar = 2
	)
	result = /obj/item/food/cake/chocolate
	category = CAT_CAKE

/datum/crafting_recipe/food/birthdaycake
	name = "Торт на день рождения"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/flashlight/flare/candle = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/caramel = 2
	)
	result = /obj/item/food/cake/birthday
	added_foodtypes = JUNKFOOD
	category = CAT_CAKE

/datum/crafting_recipe/food/energycake
	name = "Энергетический торт"
	reqs = list(
		/obj/item/food/cake/birthday = 1,
		/obj/item/melee/energy/sword = 1,
	)
	blacklist = list(/obj/item/food/cake/birthday/energy)
	result = /obj/item/food/cake/birthday/energy
	category = CAT_CAKE

/datum/crafting_recipe/food/braincake
	name = "Мозговой торт"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/food/cake/plain = 1
	)
	result = /obj/item/food/cake/brain
	added_foodtypes = MEAT | GORE
	category = CAT_CAKE

/datum/crafting_recipe/food/slimecake
	name = "Слаймовый торт"
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/food/cake/plain = 1
	)
	result = /obj/item/food/cake/slimecake
	category = CAT_CAKE

/datum/crafting_recipe/food/pumpkinspicecake
	name = "Тыквенный торт с пряностями"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/pumpkin = 2
	)
	result = /obj/item/food/cake/pumpkinspice
	category = CAT_CAKE

/datum/crafting_recipe/food/holycake
	name = "Ангельский торт"
	reqs = list(
		/datum/reagent/water/holywater = 15,
		/obj/item/food/cake/plain = 1
	)
	result = /obj/item/food/cake/holy_cake
	category = CAT_CAKE

/datum/crafting_recipe/food/poundcake
	name = "Кекс"
	reqs = list(
		/obj/item/food/cake/plain = 4
	)
	result = /obj/item/food/cake/pound_cake
	added_foodtypes = JUNKFOOD
	category = CAT_CAKE

/datum/crafting_recipe/food/hardwarecake
	name = "Аппаратный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/circuitboard = 2,
		/datum/reagent/toxin/acid = 5
	)
	result = /obj/item/food/cake/hardware_cake
	added_foodtypes = GROSS
	category = CAT_CAKE

/datum/crafting_recipe/food/berry_chocolate_cake
	name = "Клубнично-шоколадный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/chocolatebar = 2,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/berry_chocolate_cake
	removed_foodtypes = JUNKFOOD
	category = CAT_CAKE

/datum/crafting_recipe/food/pavlovacream
	name = "Павлова с кремом"
	reqs = list(
		/datum/reagent/consumable/eggwhite = 12,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/whipped_cream = 10,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/pavlova
	added_foodtypes = SUGAR|DAIRY
	category = CAT_CAKE

/datum/crafting_recipe/food/pavlovakorta
	name = "Павлова с корта-кремом"
	reqs = list(
		/datum/reagent/consumable/eggwhite = 12,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/korta_milk = 10,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/pavlova/nuts
	added_foodtypes = SUGAR|NUTS
	category = CAT_CAKE

/datum/crafting_recipe/food/berry_vanilla_cake
	name = "Торт с черникой и клубникой"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/berry_vanilla_cake
	category = CAT_CAKE

/datum/crafting_recipe/food/clowncake
	name = "Клоунский торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/sundae = 2,
		/obj/item/food/grown/banana = 5
	)
	result = /obj/item/food/cake/clown_cake
	category = CAT_CAKE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/vanillacake
	name = "Ванильный торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/vanillapod = 2
	)
	result = /obj/item/food/cake/vanilla_cake
	category = CAT_CAKE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/trumpetcake
	name = "Торт космонавта"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/trumpet = 2,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/berryjuice = 5
	)
	result = /obj/item/food/cake/trumpet
	added_foodtypes = FRUIT
	category = CAT_CAKE


/datum/crafting_recipe/food/cak
	name = "Которт"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/food/cake/birthday = 1,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/basic/pet/cat/cak
	category = CAT_CAKE //Cat! Haha, get it? CAT? GET IT? We get it - Love Felines

/datum/crafting_recipe/food/fruitcake
	name = "Английский фруктовый торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/no_raisin = 1,
		/obj/item/food/grown/cherries = 1,
		/datum/reagent/consumable/ethanol/rum = 5
	)
	result = /obj/item/food/cake/fruit
	removed_foodtypes = JUNKFOOD
	category = CAT_CAKE

/datum/crafting_recipe/food/plumcake
	name = "Сливовый торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/plum = 2
	)
	result = /obj/item/food/cake/plum
	category = CAT_CAKE

/datum/crafting_recipe/food/weddingcake
	name = "Свадебный торт"
	reqs = list(
		/obj/item/food/cake/plain = 4,
		/datum/reagent/consumable/sugar = 120,
	)
	result = /obj/item/food/cake/wedding
	category = CAT_CAKE

/datum/crafting_recipe/food/pineapple_cream_cake
	name = "Ананасово-кремовый торт"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/pineapple = 1,
		/datum/reagent/consumable/cream = 20,
	)
	result = /obj/item/food/cake/pineapple_cream_cake
	category = CAT_CAKE
