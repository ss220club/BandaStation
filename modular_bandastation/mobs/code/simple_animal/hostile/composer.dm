/mob/living/basic/composer
	name = "composer"
	desc = "Огромное существо, издающее звуки, отдалённо похожие на музыку. Его тело будто состоит из смеси фарфорового панциря и алой плоти. В центре живота зияет дыра."
	health = 3000
	maxHealth = 3000
	attack_verb_continuous = "пожирает"
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
	obj_damage = 100
	combat_mode = TRUE
	faction = list("composers")
	speed = 2
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 96
	maptext_width = 64
	death_message = "разваливается на куски, превращаясь в пыль."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE)
	unsuitable_atmos_damage = 0
	lighting_cutoff_red = 12
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 34
	max_stamina = 200
	stamina_crit_threshold = BASIC_MOB_NO_STAMCRIT
	stamina_recovery = 5
	max_stamina_slowdown = 12
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_LARGE
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	sight = (SEE_MOBS|SEE_TURFS)
	var/idle_sounds = list('modular_bandastation/mobs/sound/composer_idle_1.ogg', 'modular_bandastation/mobs/sound/composer_idle_2.ogg')

/mob/living/basic/composer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_GIANT)
	AddComponent(/datum/component/seethrough_mob)

/mob/living/basic/composer/proc/make_idle_sound()
	playsound(src, pick(idle_sounds), 50, TRUE)

/mob/living/basic/composer/send_speech(message_raw, message_range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods, forced, tts_message, list/tts_filter)
	. = ..()
	if(stat != CONSCIOUS)
		return
	make_idle_sound()

/mob/living/basic/composer/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!.) //dead or deleted
		return
	if(stat)
		return
	if(SPT_PROB(5, seconds_per_tick))
		make_idle_sound()
