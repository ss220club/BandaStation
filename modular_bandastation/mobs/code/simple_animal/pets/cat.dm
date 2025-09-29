/mob/living/basic/pet/cat
	death_sound = 'modular_bandastation/mobs/sound/cat_meow.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/cat_meow.ogg')
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	// holder_type = /obj/item/holder/cat2

/mob/living/basic/pet/cat/runtime
	// holder_type = /obj/item/holder/cat

/mob/living/basic/pet/cat/cak
	// holder_type = /obj/item/holder/cak

/mob/living/basic/pet/cat/fat
	name = "толстокот"
	desc = "Упитана. Счастлива."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "iriska"
	icon_living = "iriska"
	icon_dead = "iriska_dead"
	gender = FEMALE
	mob_size = MOB_SIZE_LARGE // THICK!!!
	//canmove = FALSE
	butcher_results = list(/obj/item/food/meat = 8)
	maxHealth = 40 // Sooooo faaaat...
	health = 40
	speed = 20 // TOO FAT
	resting = TRUE
	// holder_type = /obj/item/holder/fatcat


/obj/item/mmi/posibrain/sphere/relaymove(mob/living/user, direction)
	return	// LAZY

/mob/living/basic/pet/cat/white
	name = "white cat"
	desc = "Белоснежная шерстка. Плохо различается на белой плитке, зато отлично виден в темноте!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "penny"
	icon_living = "penny"
	icon_dead = "penny_dead"
	gender = MALE
	// holder_type = /obj/item/holder/cak

/mob/living/basic/pet/cat/birman
	name = "birman cat"
	real_name = "birman cat"
	desc = "Священная порода Бирма."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "crusher"
	icon_living = "crusher"
	icon_dead = "crusher_dead"
	gender = MALE
	// holder_type = /obj/item/holder/crusher


/mob/living/basic/pet/cat/black
	name = "black cat"
	real_name = "black cat"
	desc = "Он ужас летящий на крыльях ночи! Он - тыгыдык и спотыкание во тьме ночной! Бойся не заметить черного кота в тени!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "salem"
	icon_living = "salem"
	icon_dead = "salem_dead"
	gender = MALE
	// holder_type = /obj/item/holder/cat

/mob/living/basic/pet/cat/spacecat
	name = "космокот"
	desc = "Космический котенок!!! Он наблюдал за горизонт событий."
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40
	// holder_type = /obj/item/holder/spacecat

/mob/living/basic/pet/cat/spacecat/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
