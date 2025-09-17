/mob/living/basic
	response_help   = "тычет"
	response_disarm_continuous = "толкает"
	response_disarm_simple = "толкает"
	response_harm_continuous = "пихает"
	response_harm_simple   = "пихает"
	attack_verb_continuous = "атакует"
	attack_verb_simple = "атакует"
	attack_sound = null
	friendly = "утыкается в" //If the mob does no damage with it's attack
	var/list/damaged_sound = null // The sound played when player hits animal
	var/list/talk_sound = null // The sound played when talk


/mob/living/basic/say(message, verb, sanitize, ignore_speech_problems, ignore_atmospherics)
	. = ..()
	if(. && length(src.talk_sound))
		playsound(src, pick(src.talk_sound), 75, TRUE)

/mob/living/basic/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_alien(mob/living/carbon/alien/humanoid/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)

/mob/living/basic/attack_robot(mob/living/user)
	. = ..()
	if(. && length(src.damaged_sound) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sound), 40, 1)


// Simple animal procs
/mob/living/basic/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)

	if(pull_constraint(AM, supress_message))
		return ..()

/mob/living/basic/proc/pull_constraint(atom/movable/AM, supress_message = FALSE)
	return TRUE


// Animals additions

/* Megafauna */
/mob/living/basic/hostile/megafauna/legion
	death_sound = 'modular_bandastation/mobs/sound/legion_death.ogg'

/mob/living/basic/hostile/megafauna/legion/death(gibbed)
	for(var/area/lavaland/L in world)
		SEND_SOUND(L, sound('modular_bandastation/mobs/sound/legion_death_far.ogg'))
	. = ..()

/* Nar Sie */
/obj/singularity/narsie/large/Destroy()
	SEND_SOUND(world, sound('modular_bandastation/mobs/sound/narsie_rises.ogg'))
	. = ..()


/* Loot Drops */
/obj/effect/spawner/random/bluespace_tap/organic/Initialize(mapload)
	. = ..()
	LAZYADD(loot, list(
		//mob/living/basic/pet/dog/corgi = 5,

		/mob/living/basic/pet/dog/brittany = 2,
		/mob/living/basic/pet/dog/german = 2,
		/mob/living/basic/pet/dog/tamaskan = 2,
		/mob/living/basic/pet/dog/bullterrier = 2,

		//mob/living/basic/pet/cat = 5,

		/mob/living/basic/pet/cat/cak = 2,
		/mob/living/basic/pet/cat/fat = 2,
		/mob/living/basic/pet/cat/white = 2,
		/mob/living/basic/pet/cat/birman = 2,
		/mob/living/basic/pet/cat/spacecat = 2,

		//mob/living/basic/pet/dog/fox = 5,

		/mob/living/basic/pet/dog/fox/forest = 2,
		/mob/living/basic/pet/dog/fox/fennec = 2,
		/mob/living/basic/possum = 2,

		/mob/living/basic/pet/penguin = 5,
		//mob/living/basic/pig = 5,
		))
