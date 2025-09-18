/mob/living/basic/mouse/hamster
	name = "хомяк"
	real_name = "хомяк"
	desc = "С надутыми щечками."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	icon_resting = "hamster_rest"
	gender = MALE
	non_standard = TRUE
	speak_chance = 0
	childtype = list(/mob/living/basic/mouse/hamster/baby)
	animal_species = /mob/living/basic/mouse/hamster
	// holder_type = /obj/item/holder/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	maxHealth = 10
	health = 10


/mob/living/basic/mouse/hamster/baby
	name = "хомячок"
	real_name = "хомячок"
	desc = "Очень миленький! Какие у него пушистые щечки!"
	turns_per_move = 2
	response_help_continuous = "полапал"
	response_help_simple = "полапал"
	response_disarm_continuous = "двигает"
	response_disarm_simple = "аккуратно отодвинул"
	response_harm_continuous = "выпихивает"
	response_harm_simple   = "пихнул"
	attack_verb_continuous = "толкает"
	attack_verb_simple = "толкается"
	transform = matrix(0.7, 0, 0, 0, 0.7, 0)
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	// holder_type = /obj/item/holder/hamster


/mob/living/basic/mouse/hamster/baby/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

// Hamster procs
#define MAX_HAMSTER 20
GLOBAL_VAR_INIT(hamster_count, 0)

/mob/living/basic/mouse/hamster/Initialize(mapload)
	. = ..()
	gender = prob(80) ? MALE : FEMALE

	icon_state = initial(icon_state)
	icon_living = initial(icon_living)
	icon_dead = initial(icon_dead)
	icon_resting = initial(icon_resting)

	update_appearance(UPDATE_ICON_STATE, UPDATE_DESC)
	GLOB.hamster_count++

/mob/living/basic/mouse/hamster/Destroy()
	GLOB.hamster_count--
	. = ..()

/mob/living/basic/mouse/hamster/color_pick()
	return

/mob/living/basic/mouse/hamster/update_desc()
	. = ..()
	desc = initial(desc)
	desc += MALE ? " Самец!" : " Самочка! Ох... Нет... "

/mob/living/basic/mouse/hamster/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE

/mob/living/basic/mouse/hamster/Life(seconds, times_fired)
	..()
	if(GLOB.hamster_count < MAX_HAMSTER)
		make_babies()

/mob/living/basic/mouse/hamster/baby/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(show_message)
		to_chat(src, span_warning("Вы слишком малы чтобы что-то тащить."))
	return

/mob/living/basic/mouse/hamster/baby/Life(seconds, times_fired)
	. =..()
	if(.)
		amount_grown++
		if(amount_grown >= 100)
			var/mob/living/basic/A = new /mob/living/basic/mouse/hamster(loc)
			if(mind)
				mind.transfer_to(A)
			qdel(src)

/mob/living/basic/mouse/hamster/baby/on_atom_entered(datum/source, atom/movable/entered)
	if(!ishuman(source) || stat)
		return ..()
	to_chat(source, span_notice("[bicon(src)] раздавлен!"))
	death()
	splat(user = source)
