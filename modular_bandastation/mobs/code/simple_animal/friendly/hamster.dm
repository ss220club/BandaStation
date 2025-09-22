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
	speak_chance = 0
	// holder_type = /obj/item/holder/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	maxHealth = 10
	health = 10

	///can this hamster breed?
	var/can_breed = TRUE

/mob/living/basic/mouse/hamster/Initialize(mapload)
	. = ..()
	if(can_breed)
		add_breeding_component()

/mob/living/basic/mouse/hamster/proc/add_breeding_component()
	var/static/list/partner_types = typecacheof(list(/mob/living/basic/mouse/hamster))
	var/static/list/baby_types = list(
		/mob/living/basic/mouse/hamster/baby = 1,
	)
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/mouse/hamster)),\
		baby_paths = baby_types,\
		post_birth = post_birth_callback,\
		breed_timer = 5 MINUTES,\
	)

/mob/living/basic/mouse/hamster/baby
	name = "хомячок"
	real_name = "хомячок"
	desc = "Очень миленький! Какие у него пушистые щечки!"
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
	can_breed = FALSE
	var/amount_grown = 0
	// holder_type = /obj/item/holder/hamster

/mob/living/basic/mouse/hamster/baby/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/mouse/hamster/Initialize(mapload)
	. = ..()
	gender = prob(80) ? MALE : FEMALE

	icon_state = initial(icon_state)
	icon_living = initial(icon_living)
	icon_dead = initial(icon_dead)
	icon_resting = initial(icon_resting)

	update_appearance(UPDATE_ICON_STATE, UPDATE_DESC)


/mob/living/basic/mouse/hamster/color_pick()
	return

/mob/living/basic/mouse/hamster/update_desc()
	. = ..()
	desc = initial(desc)
	desc += MALE ? " Самец!" : " Самочка! Ох... Нет... "

/mob/living/basic/mouse/hamster/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE

/mob/living/basic/mouse/hamster/baby/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(show_message)
		to_chat(src, span_warning("Вы слишком малы чтобы что-то тащить."))
	return

/mob/living/basic/mouse/hamster/baby/on_atom_entered(datum/source, atom/movable/entered)
	if(!ishuman(source) || stat)
		return ..()
	to_chat(source, span_notice("[src.name] раздавлен!"))
	death()
	splat()

// Взросление, если нужно будет в будущем - расскомментите.
// Но тогда также рекомендую добавить глобальный список с ограничением в 20 хомяков.
// Пример в проке /mob/living/basic/chicken/proc/egg_laid(obj/item/egg)

// /mob/living/basic/mouse/hamster/baby/Initialize(mapload)
// 	. = ..()
// 	if(!isnull(grow_as)) // we don't have a set time to grow up beyond whatever RNG dictates, and if we somehow get a client, all growth halts.
// 		AddComponent(\
// 			/datum/component/growth_and_differentiation,\
// 			growth_time = null,\
// 			growth_path = grow_as,\
// 			growth_probability = 100,\
// 			lower_growth_value = 0.5,\
// 			upper_growth_value = 1,\
// 			signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
// 			optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
// 		)

// /// We don't grow into a chicken if we're not conscious.
// /mob/living/basic/mouse/hamster/baby/proc/ready_to_grow()
// 	return (stat == CONSCIOUS)
