//Skrell Recipes, for skrell

// Breads & Bakery

/datum/crafting_recipe/food/plump_rice_flatbread
	name = "Plump helmet rice flatbread"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/datum/reagent/consumable/soymilk = 5,
	)
	result = /obj/item/food/plump_rice_flatbread
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_BREAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/fly_amanita_bun
	name = "Fly amanita bun"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/mushroom/amanita = 1,
	)
	result = /obj/item/food/fly_amanita_bun
	added_foodtypes = MUSHROOM | TOXIC | BREAKFAST
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_BREAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/ximikoa_roll
	name = "Ximikoa rice roll"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/ximikoa = 1,
		/datum/reagent/consumable/flour = 10,
	)
	result = /obj/item/food/ximikoa_roll
	added_foodtypes = SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/capsaicin_focaccia
	name = "Capsaicin fungal focaccia"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/ash_flora/mushroom_stem = 2,
		/datum/reagent/consumable/capsaicin = 5,
	)
	result = /obj/item/food/capsaicin_focaccia
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_BREAD
	meal_category = MEAL_APPETIZER

// Sousp & Stews

/datum/reagent/consumable/nutriment/soup/qerrbalak_stew
	name = "Qerrbalak Fungal Stew"
	description = "A traditional hearty stew from Qerrbalak, rich with dense mushrooms and thick flour broth."
	data = list("mushrooms" = 3, "earthy broth" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#5A4535"

/datum/glass_style/has_foodtype/soup/qerrbalak_stew
	required_drink_type = /datum/reagent/consumable/nutriment/soup/qerrbalak_stew
	name = "Qerrbalak fungal stew"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "qerrbalak_stew"
	drink_type = GRAIN | VEGETABLES | MUSHROOM

/datum/chemical_reaction/food/soup/qerrbalak_stew
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/flour = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/qerrbalak_stew = 40,
	)
	percentage_of_nutriment_converted = 0.15

/datum/reagent/consumable/nutriment/soup/glowshroom_chowder
	name = "Glowshroom Chowder"
	description = "A luminescent, radioactive mushroom chowder made with soothing soymilk."
	data = list("creamy mushrooms" = 2, "tingling radiation" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#7FFF00"

/datum/glass_style/has_foodtype/soup/glowshroom_chowder
	required_drink_type = /datum/reagent/consumable/nutriment/soup/glowshroom_chowder
	name = "glowshroom chowder"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "glowshroom_chowder"
	drink_type = VEGETABLES | MUSHROOM | TOXIC

/datum/chemical_reaction/food/soup/glowshroom_chowder
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/soymilk = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/glowshroom = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/glowshroom_chowder = 40,
		/datum/reagent/uranium/radium = 2,
		/datum/reagent/phosphorus = 2,
	)

/datum/reagent/consumable/nutriment/soup/destroying_angel_bisque
	name = "Destroying Angel Bisque"
	description = "A silky white bisque packed with deadly amanitins. A prized delicacy for Skrell, highly lethal to others."
	data = list("intense umami" = 3, "numbing cold" = 2)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#FFFFFF"

/datum/glass_style/has_foodtype/soup/destroying_angel_bisque
	required_drink_type = /datum/reagent/consumable/nutriment/soup/destroying_angel_bisque
	name = "destroying angel bisque"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "angel_bisque"
	drink_type = VEGETABLES | MUSHROOM | TOXIC

/datum/chemical_reaction/food/soup/destroying_angel_bisque
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/angel = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/destroying_angel_bisque = 40,
	)
	ingredient_reagent_multiplier = 0.5

/datum/reagent/consumable/nutriment/soup/kenin_tofu_soup
	name = "Kenin Tofu Soup"
	description = "A medicinal, pain-relieving soup loaded with reishi mushrooms and silken tofu."
	data = list("soft tofu" = 2, "soothing herbal bitterness" = 2)
	glass_price = FOOD_PRICE_NORMAL
	color = "#BDB76B"

/datum/glass_style/has_foodtype/soup/kenin_tofu_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/kenin_tofu_soup
	name = "Kenin tofu soup"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "kenin_soup"
	drink_type = VEGETABLES | MUSHROOM

/datum/chemical_reaction/food/soup/kenin_tofu_soup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/tofu = 2,
		/obj/item/food/grown/mushroom/reishi = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/kenin_tofu_soup = 40,
		/datum/reagent/medicine/c2/multiver = 2,
	)
	percentage_of_nutriment_converted = 0.1

/datum/reagent/consumable/nutriment/soup/embershroom_lava_stew
	name = "Embershroom Lava Stew"
	description = "A scorching red broth made from Lavaland embershrooms and fire blossoms. Warms the body instantly."
	data = list("blazing heat" = 3, "earthy sulfur" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#FF4500"

/datum/glass_style/has_foodtype/soup/embershroom_lava_stew
	required_drink_type = /datum/reagent/consumable/nutriment/soup/embershroom_lava_stew
	name = "embershroom lava stew"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "embershroom_stew"
	drink_type = VEGETABLES | MUSHROOM

/datum/chemical_reaction/food/soup/embershroom_lava_stew
	required_reagents = list(
		/datum/reagent/water = 40,
	)
	required_ingredients = list(
		/obj/item/food/grown/ash_flora/mushroom_stem = 2,
		/obj/item/food/grown/ash_flora/fireblossom = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/embershroom_lava_stew = 40,
	)
	ingredient_reagent_multiplier = 0.33
	percentage_of_nutriment_converted = 0

/datum/reagent/consumable/nutriment/soup/edens_gaia_noodles
	name = "Eden's Gaia Noodle Soup"
	description = "A sacred glowing soup with noodles floating in an Ambrosia Gaia broth. Induces supreme tranquility."
	data = list("divine sweetness" = 2, "tender noodles" = 2, "pure peace" = 2)
	glass_price = FOOD_PRICE_LEGENDARY
	color = "#a3ff99"

/datum/glass_style/has_foodtype/soup/edens_gaia_noodles
	required_drink_type = /datum/reagent/consumable/nutriment/soup/edens_gaia_noodles
	name = "Eden's Gaia noodle soup"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "gaia_noodle_soup"
	drink_type = VEGETABLES | GRAIN

/datum/chemical_reaction/food/soup/edens_gaia_noodles
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/ambrosia/gaia = 1,
		/obj/item/food/spaghetti/raw = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/edens_gaia_noodles = 40,
	)

/datum/reagent/consumable/nutriment/soup/puffball_gas_soup
	name = "Puffball Gas Soup"
	description = "A fizzy, misty soup releasing mild spore clouds as it is eaten."
	data = list("fizzy vapor" = 2, "sweet spores" = 1)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#9370DB"

/datum/glass_style/has_foodtype/soup/puffball_gas_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/puffball_gas_soup
	name = "puffball gas soup"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "puffball_soup"
	drink_type = VEGETABLES | MUSHROOM | TOXIC

/datum/chemical_reaction/food/soup/puffball_gas_soup
	required_reagents = list(
		/datum/reagent/water = 40,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/odious_puffball = 1,
		/obj/item/food/grown/grass/fairy = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/puffball_gas_soup = 40,
	)

//  MAIN DISHES

/datum/crafting_recipe/food/raw_plump_fungal_roast
	name = "Raw plump fungal roast"
	reqs = list(
		/obj/item/food/grown/mushroom/gomoa = 1,
		/datum/reagent/consumable/soysauce = 5,
		/datum/reagent/consumable/flour = 5,
	)
	result = /obj/item/food/raw_plump_fungal_roast
	added_foodtypes = MUSHROOM | RAW
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/walking_mushroom_skewer
	name = "Crispy walking mushroom skewer"
	reqs = list(
		/obj/item/food/grown/mushroom/walkingmushroom = 1,
		/obj/item/stack/rods = 1,
		/datum/reagent/consumable/nutriment/fat/oil = 5,
		/datum/reagent/consumable/salt = 1,
	)
	result = /obj/item/food/kebab/walking_mushroom_skewer
	added_foodtypes = MUSHROOM | FRIED
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/psychedelic_tempeh
	name = "Psychedelic tempeh stir-fry"
	reqs = list(
		/obj/item/food/tempeh = 1,
		/obj/item/food/grown/mushroom/libertycap = 1,
		/obj/item/food/rice_dough = 1,
	)
	result = /obj/item/food/psychedelic_tempeh
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/steelcap_dumplings
	name = "Steel cap dumplings"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/grown/log/steel = 1,
		/obj/item/food/grown/ximikoa = 1,
		/datum/reagent/consumable/enzyme = 1,
	)
	result = /obj/item/food/steelcap_dumplings
	added_foodtypes = MUSHROOM | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/skrell_fungal_ramen
	name = "Skrell fungal ramen"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/raw = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/datum/reagent/consumable/soysauce = 5,
		/datum/reagent/water = 10,
	)
	result = /obj/item/food/skrell_fungal_ramen
	added_foodtypes = MUSHROOM | GRAIN
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_NOODLES
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/seraka_flame_roast
	name = "Seraka flame roast"
	reqs = list(
		/obj/item/food/grown/ash_flora/seraka = 1,
		/obj/item/food/grown/ash_flora/cactus_fruit = 1,
		/datum/reagent/consumable/capsaicin = 5,
	)
	result = /obj/item/food/seraka_flame_roast
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/skrell_cheetal_eggplant
	name = "Baked eggplant Skrell cheetal"
	reqs = list(
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/grown/mushroom/gomoa = 1,
		/obj/item/food/grown/plum = 3,
		/datum/reagent/consumable/soysauce = 5,
	)
	result = /obj/item/food/skrell_cheetal_eggplant
	added_foodtypes = VEGETABLES | FRUIT | MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/mindbreaker_fungal_bake
	name = "Mindbreaker fungal bake"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/mushroom/glowshroom/glowcap  = 1,
		/obj/item/food/grown/cannabis/rainbow = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1,
	)
	result = /obj/item/food/mindbreaker_fungal_bake
	added_foodtypes = MUSHROOM | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PIE
	meal_category = MEAL_MAIN_COURSE

/datum/reagent/consumable/nutriment/soup/qerrbalak_eclipse_stew
	name = "Qerrbalak Eclipse Stew"
	description = "A pitch-black psychoactive stew brewed from omega weed, liberty-caps, and shadowshrooms with a pineapple twist."
	data = list("tangy pineapple" = 2, "numbing shadows" = 3, "cosmic trip" = 3)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#0B0014"

/datum/glass_style/has_foodtype/soup/qerrbalak_eclipse_stew
	required_drink_type = /datum/reagent/consumable/nutriment/soup/qerrbalak_eclipse_stew
	name = "Qerrbalak eclipse stew"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "eclipse_stew"
	drink_type = VEGETABLES | MUSHROOM | FRUIT | TOXIC

/datum/chemical_reaction/food/soup/qerrbalak_eclipse_stew
	required_reagents = list(
		/datum/reagent/water = 40,
	)
	required_ingredients = list(
		/obj/item/food/grown/cannabis/ultimate = 1,
		/obj/item/food/grown/mushroom/libertycap = 1,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom = 1,
		/obj/item/food/grown/pineapple = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/qerrbalak_eclipse_stew = 40,
	)
	ingredient_reagent_multiplier = 0.2
	percentage_of_nutriment_converted = 0.1

/datum/crafting_recipe/food/crimson_fungal_mix
	name = "Crimson fungal mix"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/amanita = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/obj/item/food/grown/mushroom/reishi = 1,
		/obj/item/food/grown/mushroom/libertycap = 1,
	)
	result = /obj/item/food/crimson_fungal_mix
	added_foodtypes = MUSHROOM | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/twilight_fungal_paste
	name = "Twilight fungal paste"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1,
		/obj/item/food/grown/grapes = 1,
		/obj/item/food/grown/berries = 1,
	)
	result = /obj/item/food/twilight_fungal_paste
	added_foodtypes = MUSHROOM | FRUIT
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/luminous_white_salad
	name = "Luminous white salad"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/angel = 1,
		/obj/item/food/grown/mushroom/glowshroom = 1,
		/obj/item/food/grown/mushroom/glowshroom/glowcap = 1,
		/obj/item/food/grown/grass/fairy = 1,
		/obj/item/food/grown/citrus/lime = 1,
	)
	result = /obj/item/food/luminous_white_salad
	added_foodtypes = MUSHROOM | TOXIC | FRUIT
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_SALAD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/grand_mycelial_roast
	name = "Grand Qerrbalak Mycelial Roast"
	reqs = list(
		/obj/item/food/crimson_fungal_mix = 1,
		/obj/item/food/twilight_fungal_paste = 1,
		/obj/item/food/luminous_white_salad = 1,
		/datum/reagent/consumable/nutriment/soup/edens_gaia_noodles = 20,
	)
	result = /obj/item/food/grand_mycelial_roast
	added_foodtypes = MUSHROOM | TOXIC | GRAIN
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_MUSHROOM
	meal_category = MEAL_MAIN_COURSE

// SALADS & APPETIZERS

/datum/crafting_recipe/food/coniine_berry_bowl
	name = "Coniine berry bowl"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/berries/death = 2,
		/obj/item/food/grown/aloe = 1,
		/obj/item/food/grown/bungofruit = 1,
	)
	result = /obj/item/food/salad/coniine_berry
	added_foodtypes = VEGETABLES | FRUIT | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_SALAD
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/soy_fungal_chips
	name = "Soy chips with fungal dip"
	reqs = list(
		/obj/item/food/soydope = 1,
		/obj/item/food/plump_fungal_roast = 1,
	)
	result = /obj/item/food/soy_fungal_chips
	added_foodtypes = VEGETABLES | MUSHROOM | GRAIN
	cuisine_category = CUISINE_SKRELL
	dish_category = MEAL_SNACK
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/moonflower_salad
	name = "Moonflower and plump salad"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/flower/moonflower = 1,
		/obj/item/food/grown/mushroom/gomoa = 1,
		/obj/item/food/grown/cucumber = 1,
	)
	result = /obj/item/food/salad/moonflower_plump
	added_foodtypes = VEGETABLES | MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_SALAD
	meal_category = MEAL_APPETIZER

// BURGERS & WRAPS

/datum/crafting_recipe/food/skrell_tofu_burger
	name = "Skrellian tofu burger"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/grown/mushroom/gomoa = 1,
		/obj/item/food/rice_dough = 1,
	)
	result = /obj/item/food/burger/skrell_tofu
	added_foodtypes = VEGETABLES | MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_BURGER
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/qerr_fungal_taco
	name = "Qerr fungal taco"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/datum/reagent/consumable/garlic = 5,
		/datum/reagent/consumable/soysauce = 5,
	)
	result = /obj/item/food/taco/qerr_fungal
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_TACO
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/destroying_angel_slider
	name = "Destroying angel slider"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/mushroom/angel = 1,
		/obj/item/food/onionrings = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/rice_dough = 1,
	)
	result = /obj/item/food/burger/destroying_angel
	added_foodtypes = MUSHROOM | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_BURGER
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/rice_cheese_sandwich
	name = "Rice cheese sandwich"
	reqs = list(
		/obj/item/food/boiledrice = 2,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/sandwich/rice_cheese
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_SANDWICH
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/fairy_glow_roll
	name = "Fairy glow roll"
	reqs = list(
		/obj/item/food/flat_rice_dough = 1,
		/obj/item/food/grown/grass/fairy = 1,
		/obj/item/food/grown/mushroom/glowshroom/glowcap = 1,
	)
	result = /obj/item/food/fairy_glow_roll
	added_foodtypes = MUSHROOM
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_SANDWICH
	meal_category = MEAL_MAIN_COURSE

// DESSERTS & ROLLS

/datum/crafting_recipe/food/skrell_citrus_cake
	name = "Citrus coffee cake"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/orange = 2,
		/obj/item/food/grown/coffee = 2,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/cake/skrell_citrus_cake
	added_foodtypes = FRUIT | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/blue_cherry_moon_cake
	name = "Blue cherry moonflower cake"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/bluecherries = 2,
		/obj/item/food/grown/flower/moonflower = 1,
		/obj/item/food/grown/cocaleaf = 1,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/cake/blue_cherry_moon_cake
	added_foodtypes = FRUIT | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/liberty_fungus_donuts
	name = "Liberty fungus donut"
	reqs = list(
		/obj/item/food/donut/plain = 1,
		/obj/item/food/grown/mushroom/libertycap = 1,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/donuts/liberty_fungus
	added_foodtypes = MUSHROOM | SUGAR | FRIED
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/skrell_vanilla_pudding
	name = "Skrell vanilla pudding"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/datum/reagent/consumable/soymilk = 10,
		/datum/reagent/consumable/vanilla = 5,
		/obj/item/food/grown/ximikoa = 1,
		/datum/reagent/consumable/flour = 10,
	)
	result = /obj/item/food/skrell_vanilla_pudding
	added_foodtypes = SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/caramelized_plump_cap
	name = "Caramelized plump cap"
	reqs = list(
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/datum/reagent/consumable/caramel = 10,
	)
	result = /obj/item/food/kebab/caramelized_plump_cap
	added_foodtypes = MUSHROOM | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/ambrosia_deus_tart
	name = "Ambrosia Deus tart"
	reqs = list(
		/obj/item/food/cakebatter = 1,
		/obj/item/food/grown/ambrosia/deus = 2,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/ambrosia_deus_tart
	added_foodtypes = VEGETABLES | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/ambrosia_vulgaris_roll
	name = "Ambrosia Vulgaris roll"
	reqs = list(
		/obj/item/food/cakebatter = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 1,
		/obj/item/food/soydope = 1,
	)
	result = /obj/item/food/ambrosia_vulgaris_roll
	added_foodtypes = VEGETABLES
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/vulgaris_chocolate_roll
	name = "Vulgaris chocolate roll"
	reqs = list(
		/obj/item/food/cakebatter = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 1,
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/grown/cocaleaf = 1,
	)
	result = /obj/item/food/vulgaris_chocolate_roll
	added_foodtypes = VEGETABLES | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/deus_golden_roll
	name = "Deus golden roll"
	reqs = list(
		/obj/item/food/cakebatter = 1,
		/obj/item/food/grown/ambrosia/deus = 1,
		/obj/item/food/grown/apple/gold = 1,
		/datum/reagent/consumable/honey = 5,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/deus_golden_roll
	added_foodtypes = VEGETABLES | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/crimson_gaia_roll
	name = "Crimson Gaia roll"
	reqs = list(
		/obj/item/food/cakebatter = 1,
		/obj/item/food/grown/cocaleaf = 1,
		/obj/item/food/grown/ambrosia/gaia = 1,
		/obj/item/grown/novaflower = 1,
		/datum/reagent/consumable/honey = 5,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/crimson_gaia_roll
	added_foodtypes = VEGETABLES | SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_PASTRY
	meal_category = MEAL_DESSERT

// SWEETS & ICE CREAM

/datum/crafting_recipe/food/skrell_vanilla_icecream
	name = "Skrell vanilla ice cream"
	reqs = list(
		/obj/item/popsicle_stick = 1,
		/datum/reagent/consumable/soymilk = 10,
		/datum/reagent/consumable/vanilla = 5,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/skrell_vanilla_icecream
	added_foodtypes = SUGAR
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_FROZEN
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/glowcap_ice_scoop
	name = "Glowcap ice scoop"
	reqs = list(
		/obj/item/popsicle_stick = 1,
		/obj/item/food/grown/mushroom/glowshroom/glowcap  = 1,
		/datum/reagent/consumable/soymilk = 10,
		/datum/reagent/drug/space_drugs = 5,
	)
	result = /obj/item/food/glowcap_ice_scoop
	added_foodtypes = SUGAR | MUSHROOM | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_FROZEN
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/soy_ambrosia_sundae
	name = "Soy ambrosia sundae"
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/obj/item/food/grown/ambrosia/deus = 1,
		/obj/item/food/grown/cocaleaf = 1,
		/datum/reagent/consumable/soymilk = 10,
		/datum/reagent/consumable/coffee = 5,
		/obj/item/food/grown/ximikoa = 1,
	)
	result = /obj/item/food/soy_ambrosia_sundae
	added_foodtypes = SUGAR | VEGETABLES
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_FROZEN
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/fyrsskar_drops
	name = "Fyrsskar drops"
	reqs = list(
		/datum/reagent/consumable/caramel = 10,
		/datum/reagent/consumable/ethanol/fyrsskar_tears = 10,
	)
	result = /obj/item/food/fyrsskar_drops
	added_foodtypes = SUGAR | TOXIC
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/slime_fungus_freeze
	name = "Slime-fungus freeze"
	reqs = list(
		/obj/item/popsicle_stick = 1,
		/obj/item/food/grown/mushroom/libertycap = 1,
		/datum/reagent/consumable/berryjuice = 5,
		/datum/reagent/consumable/soymilk = 5,
	)
	result = /obj/item/food/slime_fungus_freeze
	added_foodtypes = SUGAR | MUSHROOM | FRUIT
	cuisine_category = CUISINE_SKRELL
	dish_category = DISH_FROZEN
	meal_category = MEAL_DESSERT
