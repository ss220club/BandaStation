//Ximikoa //
/obj/item/seeds/ximikoa
	name = "ximikoa seed pack"
	desc = "Из этих семян вырастает ксими'коа — типичная скреллийская приправа со сладким вкусом."
	icon_state = "seed-ximikoa"
	species = "ximikoa"
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "ximikoa-grow"
	icon_dead = "ximikoa-dead"
	icon_harvest = "ximikoa-harvest"
	plantname = "Ximikoa"
	product = /obj/item/food/grown/ximikoa
	lifespan = 55
	endurance = 35
	yield = 3
	potency = 30
	instability = 15
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/red, /datum/plant_gene/trait/safe_instability)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/consumable/sugar = 0.05, /datum/reagent/copper = 0.02)
	graft_gene = /datum/plant_gene/trait/glow/red
	mutatelist = null

/obj/item/food/grown/ximikoa
	seed = /obj/item/seeds/ximikoa
	name = "ксими'коа"
	desc = "Эти извивающиеся красные стебли, напоминающие земляных червей, растут в водах болот Куорргла."
	icon_state = "ximikoa_fruits"
	bite_consumption_mod = 0.25
	foodtypes = FRUIT
	tastes = list("sweet grass" = 1)

// Gomoa //
/obj/item/seeds/gomoa
	name = "gomoa mycelium pack"
	desc = "Гомоа — это небольшой оранжевый гриб, который растёт на полях равнин Кси'Корисал."
	icon_state = "mycelium-gomoa"
	species = "gomoa"
	icon_grow = "gomoa-grow"
	icon_dead = "gomoa-dead"
	icon_harvest = "gomoa-harvest"
	plantname = "Gomoa"
	growing_icon = 'icons/obj/service/hydroponics/growing_mushrooms.dmi'
	lifespan = 100
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	instability = 5
	growthstages = 4
	product = /obj/item/food/grown/mushroom/gomoa
	genes = list(/datum/plant_gene/trait/glow/orange, /datum/plant_gene/trait/plant_type/fungal_metabolism)
	graft_gene = /datum/plant_gene/trait/glow/orange
	mutatelist = null
	reagents_add = list(/datum/reagent/silver = 0.1, /datum/reagent/phosphorus = 0.05, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 30

/obj/item/food/grown/mushroom/gomoa
	seed = /obj/item/seeds/gomoa
	bite_consumption_mod = 1
	name = "кластер Гомоа"
	desc = "Это не только один из основных ингредиентов основного продукта питания скреллов, но и биолюминесцентные свойства его спор используются при создании сложных узоров на «Ко'ем» — валюте скреллов."
	icon_state = "gomoa"
	tastes = list("mushroom" = 1, "silver" = 2)
