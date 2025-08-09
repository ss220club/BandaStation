
// see code/module/crafting/table.dm

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////


/datum/crafting_recipe/food/humanburger
	name = "Бургер из человечины"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/patty/human = 1
	)
	result = /obj/item/food/burger/human
	category = CAT_BURGER

/datum/crafting_recipe/food/burger
	name = "Обычный бургер"
	reqs = list(
			/obj/item/food/patty/plain = 1,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/plain
	category = CAT_BURGER

/datum/crafting_recipe/food/corgiburger
	name = "Бургер из корги"
	reqs = list(
			/obj/item/food/patty/corgi = 1,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/corgi
	category = CAT_BURGER

/datum/crafting_recipe/food/appendixburger
	name = "Бургер из аппендикса"
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/appendix
	added_foodtypes = MEAT | GORE
	category = CAT_BURGER

/datum/crafting_recipe/food/brainburger
	name = "Бургер из мозга"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/brain
	added_foodtypes = MEAT | GORE
	category = CAT_BURGER

/datum/crafting_recipe/food/xenoburger
	name = "Ксенобургер"
	reqs = list(
		/obj/item/food/patty/xeno = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/xeno
	category = CAT_BURGER

/datum/crafting_recipe/food/bearger
	name = "Медвебургер"
	reqs = list(
		/obj/item/food/patty/bear = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/bearger
	category = CAT_BURGER

/datum/crafting_recipe/food/fishburger
	name = "Сэндвич «Филе-о-Карп»"
	reqs = list(
		/obj/item/food/fishmeat = 1,
		/obj/item/food/bun = 1,
		/obj/item/food/cheese/wedge = 1
	)
	result = /obj/item/food/burger/fish
	category = CAT_BURGER

/datum/crafting_recipe/food/tofuburger
	name = "Тофу-бургер"
	reqs = list(
		/obj/item/food/tofu = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/tofu
	category = CAT_BURGER

/datum/crafting_recipe/food/ghostburger
	name = "Призрачный бургер"
	reqs = list(
		/obj/item/ectoplasm = 1,
		/datum/reagent/consumable/salt = 2,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/ghost
	category = CAT_BURGER

/datum/crafting_recipe/food/clownburger
	name = "Клоунский бургер"
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/clown
	category = CAT_BURGER

/datum/crafting_recipe/food/mimeburger
	name = "Мимский бургер"
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/mime
	category = CAT_BURGER

/datum/crafting_recipe/food/redburger
	name = "Красный бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/red
	category = CAT_BURGER

/datum/crafting_recipe/food/orangeburger
	name = "Оранжевый бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/orange
	category = CAT_BURGER

/datum/crafting_recipe/food/yellowburger
	name = "Желтый бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/yellow
	category = CAT_BURGER

/datum/crafting_recipe/food/greenburger
	name = "Зеленый бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/green
	category = CAT_BURGER

/datum/crafting_recipe/food/blueburger
	name = "Голубой бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/blue
	category = CAT_BURGER

/datum/crafting_recipe/food/purpleburger
	name = "Фиолетовый бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/purple
	category = CAT_BURGER

/datum/crafting_recipe/food/blackburger
	name = "Черный бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/black = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/black
	category = CAT_BURGER

/datum/crafting_recipe/food/whiteburger
	name = "Белый бургер"
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/white = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/white
	category = CAT_BURGER

/datum/crafting_recipe/food/spellburger
	name = "Магический бургер"
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/spell
	category = CAT_BURGER

/datum/crafting_recipe/food/bigbiteburger
	name = "Бургер «мега-кусь»"
	reqs = list(
		/obj/item/food/patty/plain = 3,
		/obj/item/food/bun = 1,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/burger/bigbite
	category = CAT_BURGER

/datum/crafting_recipe/food/superbiteburger
	name = "Бургер «Гига-кусь»"
	reqs = list(
		/datum/reagent/consumable/salt = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/food/patty/plain = 5,
		/obj/item/food/grown/tomato = 4,
		/obj/item/food/cheese/wedge = 3,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/bun = 1,
		/obj/item/food/pickle = 1,

	)
	result = /obj/item/food/burger/superbite
	removed_foodtypes = BREAKFAST
	category = CAT_BURGER

/datum/crafting_recipe/food/slimeburger
	name = "Желейный бургер"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/jelly/slime
	added_foodtypes = TOXIC
	category = CAT_BURGER

/datum/crafting_recipe/food/jellyburger
	name = "Желейный бургер"
	reqs = list(
			/datum/reagent/consumable/cherryjelly = 5,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/jelly/cherry
	added_foodtypes = FRUIT
	category = CAT_BURGER

/datum/crafting_recipe/food/firealarmburger
	name = "Бургер «пожарная тревога»"
	reqs = list(
			/obj/item/food/patty/plain = 1,
			/obj/item/food/grown/ghost_chili = 2,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/firealarm
	category = CAT_BURGER

/datum/crafting_recipe/food/ratburger
	name = "Крысиный бургер"
	reqs = list(
			/obj/item/food/deadmouse = 1,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/rat
	category = CAT_BURGER

/datum/crafting_recipe/food/baseballburger
	name = "Бургер «Хоум Ран»"
	reqs = list(
			/obj/item/melee/baseball_bat = 1,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/baseball
	added_foodtypes = GROSS
	category = CAT_BURGER

/datum/crafting_recipe/food/baconburger
	name = "Бургер с беконом"
	reqs = list(
			/obj/item/food/meat/bacon = 3,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/baconburger
	removed_foodtypes = BREAKFAST
	category = CAT_BURGER

/datum/crafting_recipe/food/empoweredburger
	name = "Заряженный бургер"
	reqs = list(
			/obj/item/stack/sheet/mineral/plasma = 2,
			/obj/item/food/bun = 1
	)
	requirements_mats_blacklist = list(/obj/item/stack/sheet/mineral/plasma)
	result = /obj/item/food/burger/empoweredburger
	added_foodtypes = TOXIC
	category = CAT_BURGER

/datum/crafting_recipe/food/catburger
	name = "Котобургер"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/patty/plain = 1,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/tail/cat = 1,
	)
	result = /obj/item/food/burger/catburger
	added_foodtypes = GORE
	category = CAT_BURGER

/datum/crafting_recipe/food/crabburger
	name = "Крабовый бургер"
	reqs = list(
			/obj/item/food/meat/crab = 2,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/crab
	category = CAT_BURGER

/datum/crafting_recipe/food/cheeseburger
	name = "Чизбургер"
	reqs = list(
			/obj/item/food/patty/plain = 1,
			/obj/item/food/bun = 1,
			/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/burger/cheese
	category = CAT_BURGER

/datum/crafting_recipe/food/soylentburger
	name = "Сойлент-бургер"
	reqs = list(
			/obj/item/food/soylentgreen = 1, //two full meats worth.
			/obj/item/food/bun = 1,
			/obj/item/food/cheese/wedge = 2,
	)
	result = /obj/item/food/burger/soylent
	category = CAT_BURGER

/datum/crafting_recipe/food/ribburger
	name = "«МакРиб» бургер"
	reqs = list(
			/obj/item/food/bbqribs = 1,     //The sauce is already included in the ribs
			/obj/item/food/onion_slice = 1, //feel free to remove if too burdensome.
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/rib
	category = CAT_BURGER

/datum/crafting_recipe/food/mcguffin
	name = "«МакГаффин» бургер"
	reqs = list(
			/obj/item/food/friedegg = 1,
			/obj/item/food/meat/bacon = 2,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/mcguffin
	category = CAT_BURGER

/datum/crafting_recipe/food/chickenburger
	name = "Куриный сэндвич"
	reqs = list(
			/obj/item/food/patty/chicken = 1,
			/datum/reagent/consumable/mayonnaise = 5,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/chicken
	category = CAT_BURGER

/datum/crafting_recipe/food/crazyhamburger
	name = "Сумасшедший бургер"
	reqs = list(
			/obj/item/food/patty/plain = 2,
			/obj/item/food/bun = 1,
			/obj/item/food/cheese/wedge = 2,
			/obj/item/food/grown/chili = 1,
			/obj/item/food/grown/cabbage = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/flashlight/flare = 1,
			/datum/reagent/consumable/nutriment/fat/oil = 15
	)
	result = /obj/item/food/burger/crazy
	category = CAT_BURGER

/datum/crafting_recipe/food/sloppy_moe
	name = "Бургер «Неряшливый Мо»"
	reqs = list(
			/obj/item/food/bun = 1,
			/obj/item/food/meat/cutlet = 2,
			/obj/item/food/onion_slice = 1,
			/datum/reagent/consumable/bbqsauce = 5,
	)
	result = /obj/item/food/burger/sloppy_moe
	category = CAT_BURGER

/datum/crafting_recipe/food/kortaburger
	name = "Plain Rootburger"
	reqs = list(
			/obj/item/food/patty/plain = 1,
			/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/plain/korta
	category = CAT_BURGER

/datum/crafting_recipe/food/ratkorta
	name = "Rat Rootburger"
	reqs = list(
			/obj/item/food/deadmouse = 1,
			/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/rat/korta
	category = CAT_BURGER

/datum/crafting_recipe/food/rootguffin
	name = "Root-Guffin"
	reqs = list(
			/obj/item/food/friedegg = 1,
			/obj/item/food/meat/bacon = 2,
			/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/rootguffin
	category = CAT_BURGER

/datum/crafting_recipe/food/rootrib
	name = "RootRib"
	reqs = list(
			/obj/item/food/bbqribs = 1,     //The sauce is already included in the ribs
			/obj/item/food/onion_slice = 1, //feel free to remove if too burdensome.
			/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/rootrib
	category = CAT_BURGER

/datum/crafting_recipe/food/rootchicken
	name = "Chicken Rootwich"
	reqs = list(
			/obj/item/food/patty/chicken = 1,
			/datum/reagent/consumable/mayonnaise = 5,
			/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/rootchicken
	category = CAT_BURGER

/datum/crafting_recipe/food/rootfish
	name = "Fish rootburger"
	reqs = list(
		/obj/item/food/fishmeat = 1,
		/obj/item/food/rootroll = 1
	)
	result = /obj/item/food/burger/rootfish
	category = CAT_BURGER

/datum/crafting_recipe/food/sloppyroot
	name = "Sssloppy moe"
	reqs = list(
			/obj/item/food/rootroll = 1,
			/obj/item/food/meat/cutlet = 2,
			/obj/item/food/onion_slice = 1,
			/datum/reagent/consumable/bbqsauce = 5,
	)
	result = /obj/item/food/burger/sloppyroot
	category = CAT_BURGER
