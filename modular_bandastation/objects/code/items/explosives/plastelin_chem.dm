// Different temperatures to ensure everything is cooked correctly (otherwise we get C4 instead of Semtex).
#define SEMTEX_SYNTHESIS_TEMP 210
#define C4_SYNTHESIS_TEMP 280

/datum/chemical_reaction/c4
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/rdx = 8, /datum/reagent/medicine/c2/penthrite = 12, /datum/reagent/fuel/oil = 40)
	required_temp = C4_SYNTHESIS_TEMP
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_EXPLOSIVE
	mix_message = "The solution freezes into a plastid!"

/datum/chemical_reaction/c4/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	if(!location)
		return
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/c4_big(location)

/datum/chemical_reaction/semtex
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/rdx = 20, /datum/reagent/medicine/c2/penthrite = 12, /datum/reagent/fuel/oil = 40, /datum/reagent/tatp = 12)
	required_temp = SEMTEX_SYNTHESIS_TEMP
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_EXPLOSIVE
	mix_message = "The solution freezes into a plastid!"

/datum/chemical_reaction/semtex/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	if(!location)
		return
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/semtex_big(location)
