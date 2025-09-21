/mob/living/basic/goat
	attack_verb_continuous = "бодает"
	attack_verb_simple = "бодает"
	death_sound = 'modular_bandastation/mobs/sound/goat_death.ogg'

/mob/living/basic/cow
	attack_verb_continuous = "бодает"
	attack_verb_simple = "бодает"
	death_sound = 'modular_bandastation/mobs/sound/cow_death.ogg'
	damaged_sound = list('modular_bandastation/mobs/sound/cow_damaged.ogg')
	talk_sound = list('modular_bandastation/mobs/sound/cow_talk1.ogg', 'modular_bandastation/mobs/sound/cow_talk2.ogg')

/mob/living/basic/chicken
	name = "курица"
	desc = "Гордая несушка. Яички должны быть хороши!"
	death_sound = 'modular_bandastation/mobs/sound/chicken_death.ogg'
	damaged_sound = list('modular_bandastation/mobs/sound/chicken_damaged1.ogg', 'modular_bandastation/mobs/sound/chicken_damaged2.ogg')
	talk_sound = list('modular_bandastation/mobs/sound/chicken_talk.ogg')
	// holder_type = /obj/item/holder/chicken

/mob/living/basic/chick
	name = "цыпленок"
	desc = "Маленькая прелесть! Но пока что маловата..."
	attack_verb_continuous = "клюёт"
	attack_verb_simple = "клюёт"
	death_sound = 'modular_bandastation/mobs/sound/mouse_squeak.ogg'
	// holder_type = /obj/item/holder/chick

/mob/living/basic/chicken/cock
	name = "петух"
	desc = "Гордый и важный вид."
	gender = MALE
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "cock"
	icon_living = "cock"
	icon_dead = "cock_dead"
	butcher_results = list(/obj/item/food/meat = 4)
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 6
	attack_verb_continuous = "клюёт"
	attack_verb_simple = "клюёт"
	death_sound = 'modular_bandastation/mobs/sound/chicken_death.ogg'
	damaged_sound = list('modular_bandastation/mobs/sound/chicken_damaged1.ogg', 'modular_bandastation/mobs/sound/chicken_damaged2.ogg')
	talk_sound = list('modular_bandastation/mobs/sound/chicken_talk.ogg')
	health = 30
	maxHealth = 30
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	// holder_type = /obj/item/holder/cock

	ai_controller = /datum/ai_controller/basic_controller/goat

	///icon state of the collar we can wear
	var/collar_icon_state

/mob/living/basic/cock/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

/mob/living/basic/pig
	name = "свинья"
	attack_verb_continuous = "лягает"
	attack_verb_simple = "лягает"
	death_sound = 'modular_bandastation/mobs/sound/pig_death.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/pig_talk1.ogg', 'modular_bandastation/mobs/sound/pig_talk2.ogg')
	damaged_sound = list()

/mob/living/basic/turkey	// !!!!
	name = "индюшка"
	desc = "И не благодари."
	death_sound = 'modular_bandastation/mobs/sound/duck_quak1.ogg'

	ai_controller = /datum/ai_controller/basic_controller/goose


/mob/living/basic/goose
	name = "гусь"
	desc = "Прекрасная птица для набива подушек и страха детишек."
	icon_resting = "goose_rest"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 8
	attack_verb_continuous = "щипает"
	attack_verb_simple = "щипает"
	death_sound = 'modular_bandastation/mobs/sound/duck_quak1.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/duck_talk1.ogg', 'modular_bandastation/mobs/sound/duck_talk2.ogg', 'modular_bandastation/mobs/sound/duck_talk3.ogg', 'modular_bandastation/mobs/sound/duck_quak1.ogg', 'modular_bandastation/mobs/sound/duck_quak2.ogg', 'modular_bandastation/mobs/sound/duck_quak3.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/duck_aggro1.ogg', 'modular_bandastation/mobs/sound/duck_aggro2.ogg')

/mob/living/basic/goose/gosling
	name = "гусенок"
	desc = "Симпатичный гусенок. Скоро он станей грозой всей станции."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "gosling"
	icon_living = "gosling"
	icon_dead = "gosling_dead"
	icon_resting = "gosling_rest"
	butcher_results = list(/obj/item/food/meat = 3)
	melee_damage_lower = 0
	melee_damage_upper = 0
	health = 20
	maxHealth = 20

/mob/living/basic/seal	// !!!!!!
	death_sound = 'modular_bandastation/mobs/sound/seal_death.ogg'
