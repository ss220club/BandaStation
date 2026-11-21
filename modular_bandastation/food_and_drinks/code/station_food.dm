/obj/item/food/station_food
	abstract_type = /obj/item/food/station_food
	icon = 'modular_bandastation/food_and_drinks/icons/station_food.dmi'
	inhand_icon_state = null
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/station_food/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(istype(current_recipe, /datum/crafting_recipe/food/station_food))
		var/datum/crafting_recipe/food/station_food/recipe = current_recipe
		recipe.return_ingredient_bowls(components, src)

/datum/crafting_recipe/food/station_food
	abstract_type = /datum/crafting_recipe/food/station_food
	dish_category = DISH_PASTRY

/** Reuses one ingredient bowl for a plated result and returns any remaining bowls. */
/datum/crafting_recipe/food/station_food/proc/return_ingredient_bowls(list/components, obj/item/food/result)
	var/reuse_bowl = result.trash_type == /obj/item/reagent_containers/cup/bowl
	for(var/obj/item/food/ingredient in components)
		if(ingredient.trash_type != /obj/item/reagent_containers/cup/bowl)
			continue
		if(reuse_bowl)
			reuse_bowl = FALSE
			continue
		SEND_SIGNAL(ingredient, COMSIG_ITEM_USED_AS_INGREDIENT, result)
