// Crafting recipes
// =========================================================================
// 1. РАСКАТЫВАНИЕ ТЕСТА СКАЛКОЙ (ROLLING PIN)
// =========================================================================

/datum/crafting_recipe/food/rollingpin/flat_rice_dough
	name = "Flat rice dough"
	reqs = list(/obj/item/food/rice_dough = 1)
	result = /obj/item/food/flat_rice_dough
	dish_category = DISH_BREAD
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_COMPONENT

// =========================================================================
// 2. НАРЕЗКА СКРЕЛЛЬСКИХ БЛЮД НОЖОМ (KNIFE SLICING)
// =========================================================================

/datum/crafting_recipe/food/knife/fly_amanita_bun_slice
	name = "Fly amanita bun slice"
	reqs = list(/obj/item/food/fly_amanita_bun = 1)
	result = /obj/item/food/fly_amanita_bun_slice
	dish_category = DISH_MUSHROOM
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/mindbreaker_fungal_bake_slice
	name = "Mindbreaker fungal bake slice"
	reqs = list(/obj/item/food/mindbreaker_fungal_bake = 1)
	result = /obj/item/food/mindbreaker_fungal_bake_slice
	dish_category = DISH_PIE
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/mycelial_roast_slice
	name = "Mycelial roast slice"
	reqs = list(/obj/item/food/grand_mycelial_roast = 1)
	result = /obj/item/food/mycelial_roast_slice
	dish_category = DISH_MUSHROOM
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/skrell_citrus_slice
	name = "Citrus coffee cake slice"
	reqs = list(/obj/item/food/cake/skrell_citrus_cake = 1)
	result = /obj/item/food/cakeslice/skrell_citrus_slice
	dish_category = DISH_CAKE
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/blue_cherry_slice
	name = "Blue cherry moonflower cake slice"
	reqs = list(/obj/item/food/cake/blue_cherry_moon_cake = 1)
	result = /obj/item/food/cakeslice/blue_cherry_slice
	dish_category = DISH_CAKE
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/ambrosia_deus_tart_slice
	name = "Ambrosia Deus tart slice"
	reqs = list(/obj/item/food/ambrosia_deus_tart = 1)
	result = /obj/item/food/ambrosia_deus_tart_slice
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/ambrosia_vulgaris_roll_slice
	name = "Ambrosia Vulgaris roll slice"
	reqs = list(/obj/item/food/ambrosia_vulgaris_roll = 1)
	result = /obj/item/food/ambrosia_vulgaris_roll_slice
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/vulgaris_chocolate_roll_slice
	name = "Vulgaris chocolate roll slice"
	reqs = list(/obj/item/food/vulgaris_chocolate_roll = 1)
	result = /obj/item/food/vulgaris_chocolate_roll_slice
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/deus_golden_roll_slice
	name = "Deus golden roll slice"
	reqs = list(/obj/item/food/deus_golden_roll = 1)
	result = /obj/item/food/deus_golden_roll_slice
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/crimson_gaia_roll_slice
	name = "Crimson Gaia roll slice"
	reqs = list(/obj/item/food/crimson_gaia_roll = 1)
	result = /obj/item/food/crimson_gaia_roll_slice
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_DESSERT

// =========================================================================
// 3. ОБЖАРИВАНИЕ И ВЫПЕКАНИЕ (GRILL / OVEN)
// =========================================================================

/datum/crafting_recipe/food/grill/plump_fungal_roast
	reqs = list(/obj/item/food/raw_plump_fungal_roast = 1)
	result = /obj/item/food/plump_fungal_roast
	dish_category = DISH_MUSHROOM
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/oven/plump_fungal_roast
	reqs = list(/obj/item/food/raw_plump_fungal_roast = 1)
	result = /obj/item/food/plump_fungal_roast
	dish_category = DISH_MUSHROOM
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/grill/grilled_rice_cheese
	reqs = list(/obj/item/food/sandwich/rice_cheese = 1)
	result = /obj/item/food/sandwich/grilled_rice_cheese
	dish_category = DISH_SANDWICH
	cuisine_category = CUISINE_SKRELL
	meal_category = MEAL_APPETIZER
