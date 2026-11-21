/datum/reagent/consumable/pancakebatter
	/// Raw pancake type created when this batter is splashed onto a griddle.
	var/pancake_type = /obj/item/food/pancakes/raw

/** Meat batter using the same pouring and cooking workflow as ordinary pancake batter. */
/datum/reagent/consumable/pancakebatter/meat
	name = "Meat Pancake Batter"
	description = "Жидкое мясное тесто для блинов. Пять единиц на горячей плите превращаются в один блин."
	taste_description = "сырое мясное тесто"
	color = "#B87970"
	pancake_type = /obj/item/food/station_food/meat_blini_raw

/** Water-based meat batter, distinct from the milk-based ordinary pancake recipe. */
/datum/chemical_reaction/food/meat_pancakebatter
	results = list(/datum/reagent/consumable/pancakebatter/meat = 15)
	required_reagents = list(
		/datum/reagent/consumable/eggyolk = 6,
		/datum/reagent/consumable/eggwhite = 12,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/water = 10,
	)
