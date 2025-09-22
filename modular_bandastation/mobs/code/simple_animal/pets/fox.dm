/mob/living/basic/pet/fox
	death_sound = 'modular_bandastation/mobs/sound/fox_yelp.ogg'
	// holder_type = /obj/item/holder/fox

/mob/living/basic/pet/fox/fennec
	name = "fennec"
	real_name = "fennec"
	desc = "Миниатюрная лисичка с очень большими ушами. Фенек, фенек, зачем тебе такие большие уши? Чтобы избегать дормитория?"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	icon_resting = "fennec_rest"
	see_in_dark = 10
	// holder_type = /obj/item/holder/fennec

/mob/living/basic/pet/fox/forest
	name = "forest fox"
	real_name = "forest fox"
	desc = "Лесная лисица. Может укусить."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "fox_"
	icon_living = "fox"
	icon_dead = "fox_dead"
	icon_resting = "fox_rest"
	melee_damage_type = BRUTE
	melee_damage_lower = 6
	melee_damage_upper = 12



// named

/mob/living/basic/pet/fox/alisa
	name = "Алиса"
	desc = "Алиса, любимый питомец любого Офицера Специальных Операций. Интересно, что она говорит?"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "alisa"
	icon_living = "alisa"
	icon_dead = "alisa_dead"
	icon_resting = "alisa_rest"
	faction = list("nanotrasen")
	gold_core_spawnable = NO_SPAWN

	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/basic/pet/fox/fennec/fenya
	name = "Феня"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь Магистрат держит его при себе и следит за ним. Но похоже что ему даже нравится быть частью правосудия."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
