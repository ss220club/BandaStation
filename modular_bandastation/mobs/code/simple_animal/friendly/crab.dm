/mob/living/basic/crab
	death_sound = 'modular_bandastation/mobs/sound/crack_death2.ogg'
	mob_size = MOB_SIZE_SMALL
	response_help  = "гладит"
	response_disarm_continuous = "отталкивает"
	response_disarm_simple = "отталкивает"
	response_harm_continuous = "сдавливает"
	response_harm_simple   = "щипает"
	// holder_type = /obj/item/holder/crab

/mob/living/basic/crab/sea
	name = "морской краб"
	desc = "Кто проживает на дне океана?"
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "bluecrab"
	icon_living = "bluecrab"
	icon_dead = "bluecrab_dead"
	response_help  = "гладит"
	response_disarm_continuous = "отталкивает"
	response_disarm_simple = "отталкивает"
	response_harm_continuous = "сдавливает"
	response_harm_simple   = "щипает"
	health = 50
	maxHealth = 50
	butcher_results = list(/obj/item/food/meat = 3)

/mob/living/basic/crab/royal
	name = "королевский краб"
	desc = "Величественный королевский краб."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "royalcrab"
	icon_living = "royalcrab"
	icon_dead = "royalcrab_dead"
	response_help  = "с уважением гладит"
	response_disarm_continuous = "с уважением отталкивает"
	response_disarm_simple = "с уважением отталкивает"
	response_harm_continuous = "презрительно щипает"
	response_harm_simple   = "щипает без уважения"
	health = 50
	maxHealth = 50
	butcher_results = list(/obj/item/food/meat = 5)

/mob/living/basic/crab/evil
	// holder_type = /obj/item/holder/evilcrab
