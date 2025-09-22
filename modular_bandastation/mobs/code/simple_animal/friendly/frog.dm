/mob/living/basic/frog
	name = "лягушка"
	real_name = "лягушка"
	desc = "Выглядит грустным не по средам и когда её не целуют."
	speak = list("Квак!","КУААК!","Квуак!")
	speak_emote = list("квак","куак","квуак")
	emote_hear = list("квак","куак","квуак")
	emote_see = list("лежит расслабленная", "издает гортанные звуки", "лупает глазками")
	var/scream_sound = list ('modular_bandastation/mobs/sound/frog_scream_1.ogg','modular_bandastation/mobs/sound/frog_scream_2.ogg','modular_bandastation/mobs/sound/frog_scream_3.ogg')
	talk_sound = list('modular_bandastation/mobs/sound/frog_talk1.ogg', 'modular_bandastation/mobs/sound/frog_talk2.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/frog_damaged.ogg')
	death_sound = 'modular_bandastation/mobs/sound/frog_death.ogg'

	// holder_type = /obj/item/holder/frog

/mob/living/basic/frog/toxic
	name = "яркая лягушка"
	real_name = "яркая лягушка"
	desc = "Уникальная токсичная раскраска. Лучше не трогать голыми руками."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	icon_resting = "rare_frog"
	var/toxin_per_touch = 2.5
	var/toxin_type = "toxin"
	gold_core_spawnable = HOSTILE_SPAWN
	// holder_type = /obj/item/holder/frog/toxic

/mob/living/basic/frog/scream
	name = "орущая лягушка"
	real_name = "орущая лягушка"
	desc = "Не любит когда на неё наступают. Используется в качестве наказания за проступки"
	var/squeak_sound = list ('modular_bandastation/mobs/sound/frog_scream1.ogg','modular_bandastation/mobs/sound/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN


/mob/living/basic/frog/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

// Frog procs
/mob/living/basic/frog/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/basic/frog/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(!ishuman(source))
		return
	if(stat)
		return
	to_chat(source, span_notice("[bicon(src)] квакнул!"))

// Toxic frog procs
/mob/living/basic/frog/toxic/attack_hand(mob/living/carbon/human/H as mob)
	if(ishuman(H))
		if(!istype(H.gloves, /obj/item/clothing/gloves))
			for(var/obj/item/organ/external/A in H.bodyparts)
				if(!A.is_robotic())
					if((A.body_part == HAND_LEFT) || (A.body_part == HAND_RIGHT))
						to_chat(H, span_warning("Дотронувшись до [src.name], ваша кожа начинает чесаться!"))
						toxin_affect(H)
						if(H.a_intent == INTENT_DISARM || H.a_intent == INTENT_HARM)
							..()
	..()

/mob/living/basic/frog/toxic/on_atom_entered(datum/source, atom/movable/entered)
	..()
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	if(istype(H.shoes, /obj/item/clothing/shoes))
		return
	for(var/obj/item/organ/external/F in H.bodyparts)
		if(F.is_robotic() || (F.body_part != FOOT_LEFT && !F.body_part == FOOT_RIGHT))
			continue
		toxin_affect(H)
		to_chat(H, span_warning("Ваши ступни начинают чесаться!"))

/mob/living/basic/frog/toxic/proc/toxin_affect(mob/living/carbon/human/M as mob)
	if(M.reagents && !toxin_per_touch == 0)
		M.reagents.add_reagent(toxin_type, toxin_per_touch)

// Scream frog procs
/mob/living/basic/frog/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/basic/frog/toxic/scream
	var/squeak_sound = list ('modular_bandastation/mobs/sound/frog_scream1.ogg','modular_bandastation/mobs/sound/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/toxic/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

// Additional procs
/mob/living/basic/frog/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1,"издаёт боевой клич!")
			playsound(src, pick(src.scream_sound), 50, TRUE)

/mob/living/basic/frog/emote(emote_key, type_override = 1, message, intentional, force_silence)
	if(incapacitated())
		return

	var/on_CD = 0
	emote_key = lowertext(emote_key)
	switch(emote_key)
		if("warcry")
			on_CD = start_audio_emote_cooldown()
		else
			on_CD = 0

	if(!force_silence && on_CD == 1)
		return

	switch(emote_key)
		if("warcry")
			message = "издаёт боевой клич!"
			type_override = 2 //audible
			playsound(src, pick(src.scream_sound), 50, TRUE)
		if("help")
			to_chat(src, "warcry")
	..()

