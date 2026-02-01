/datum/reagent/mutationtoxin/vulpkanin
	name = "Vulpkanin Mutation Toxin"
	description = "Мутационный токсин для превращения в вульпканина."
	color = "#949494"
	race = /datum/species/vulpkanin
	taste_description = "шерсти"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/slime/slimevulpkanin
	results = list(/datum/reagent/mutationtoxin/vulpkanin = 1)
	required_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	required_container = /obj/item/slime_extract/green

/datum/reagent/mutationtoxin/tajaran
	name = "Tajaran Mutation Toxin"
	description = "Мутационный токсин для превращения в таяр."
	color = "#949494"
	race = /datum/species/tajaran
	taste_description = "шерсти"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/slime/slimetajaran
	results = list(/datum/reagent/mutationtoxin/tajaran = 1)
	required_reagents = list(/datum/reagent/consumable/cream = 1)
	required_container = /obj/item/slime_extract/green

/datum/reagent/mutationtoxin/kidan
	name = "Kidan Mutation Toxin"
	description = "Мутационный токсин для превращения в кидана."
	color = "#c58a32"
	race = /datum/species/kidan
	taste_description = "хитин"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/slime/slimekidan
	results = list(/datum/reagent/mutationtoxin/kidan = 1)
	required_reagents = list(/datum/reagent/consumable/nutriment = 1)
	required_container = /obj/item/slime_extract/green
