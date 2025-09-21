/mob/living/basic/bear
	attack_verb_continuous = "рвет"
	attack_verb_simple = "терзает"
	death_sound = 'modular_bandastation/mobs/sound/bear_death.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/bear_talk1.ogg', 'modular_bandastation/mobs/sound/bear_talk2.ogg', 'modular_bandastation/mobs/sound/bear_talk3.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/bear_onerawr1.ogg', 'modular_bandastation/mobs/sound/bear_onerawr2.ogg', 'modular_bandastation/mobs/sound/bear_onerawr3.ogg')
	var/trigger_sound = 'modular_bandastation/mobs/sound/bear_rawr.ogg'

/mob/living/basic/bear/handle_automated_movement()
	if(..())
		playsound(src, src.trigger_sound, 40, 1)
