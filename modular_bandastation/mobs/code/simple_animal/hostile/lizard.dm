/mob/living/basic/lizard/big
	name = "игуана"
	desc = "Грациозный предок космодраконов. Её взгляд не вызывает никаких враждебных подозрений... Но она по прежнему хочет съесть вас."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "iguana"
	icon_living = "iguana"
	icon_dead = "iguana_dead"
	speak_emote = list("рычит", "ревет")
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 3, /obj/item/stack/sheet/animalhide/lizard = 1)
	response_help_continuous = "гладит"
	response_help_simple = "погладил"
	response_disarm_continuous = "толкает"
	response_disarm_simple = "аккуратно оттолкнул"
	response_harm_continuous = "колошматит"
	response_harm_simple = "ударил"
	speed = 2
	maxHealth = 100
	health = 100
	blood_volume = BLOOD_VOLUME_NORMAL

	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_verb_continuous = "терзает"
	attack_verb_simple = "терзает"
	sharpness = SHARP_EDGED
	attack_vis_effect = ATTACK_EFFECT_BITE

	attack_sound = 'sound/items/weapons/bite.ogg'
	death_sound = 'modular_bandastation/mobs/sound/lizard_death_big.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/lizard_damaged.ogg')

	minimum_survivable_temperature = 250 //Weak to cold
	maximum_survivable_temperature = T0C + 200

	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/lizard/big

/mob/living/basic/lizard/big/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 1.5)

/mob/living/basic/lizard/big/gator
	name = "аллигатор"
	desc = "Величавый аллигатор, так и норовящийся оторвать от вас самый лакомый кусочек. Или кусок. Не путать с крокодилом!"
	icon_state = "gator"
	icon_living = "gator"
	icon_dead = "gator_dead"
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 7, /obj/item/stack/sheet/animalhide/lizard = 5)
	speed = 4
	maxHealth = 300
	health = 300
	obj_damage = 80
	melee_damage_lower = 30
	melee_damage_upper = 80

/mob/living/basic/lizard/big/croco
	name = "крокодил"
	desc = "Не стоит сувать голову ему в пасть! Это негативно сказывается на умственных способностях"
	icon_state = "steppy"
	icon_living = "steppy"
	icon_dead = "steppy_dead"
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 5, /obj/item/stack/sheet/animalhide/lizard = 3)
	maxHealth = 200
	health = 200
	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 50
