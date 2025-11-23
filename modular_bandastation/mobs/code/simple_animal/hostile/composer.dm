/mob/living/simple_animal/hostile/composer
	name = "композитор"
	desc = "Огромное существо, издающее звуки, отдалённо похожие на музыку. Его тело будто состоит из смеси фарфорового панциря и алой плоти. В центре живота зияет дыра."
	health = 3000
	maxHealth = 3000
	attack_verb_continuous = "поглощает"
	attack_verb_simple = "поглощает"
	attack_sound = 'modular_bandastation/mobs/sound/composer_agro.ogg'
	icon_state = "composer"
	icon_living = "composer"
	icon_dead = ""
	friendly_verb_continuous = "смотрит на"
	friendly_verb_simple = "смотрит на"
	icon = 'modular_bandastation/mobs/icons/composer.dmi'
	speak_emote = list("поёт")
	armour_penetration = 50
	melee_damage_lower = 80
	melee_damage_upper = 80
	speed = 2
	move_to_delay = 10
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 96
	maptext_width = 64
	del_on_death = TRUE
	death_message = "разваливается на куски, превращаясь в пыль."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	footstep_type = FOOTSTEP_MOB_GIANT
	var/idle_sounds = list('modular_bandastation/mobs/sound/composer_idle_1.ogg', 'modular_bandastation/mobs/sound/composer_idle_2.ogg')

/mob/living/simple_animal/hostile/composer/proc/make_idle_sound()
	playsound(src, pick(idle_sounds), 50, TRUE)

/mob/living/simple_animal/hostile/composer/send_speech(message_raw, message_range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods, forced, tts_message, list/tts_filter)
	. = ..()
	if(stat != CONSCIOUS)
		return
	make_idle_sound()

/mob/living/simple_animal/hostile/composer/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!.) //dead or deleted
		return
	if(stat)
		return
	if(SPT_PROB(5, seconds_per_tick))
		make_idle_sound()
