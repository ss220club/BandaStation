/obj/structure/concertspeaker
	name = "\proper концертная колонка"
	desc = "Концертная колонка для синронизации с концертной установкой."
	icon = 'modular_bandastation/objects/icons/obj/machines/jukebox.dmi'
	icon_state = "concertspeaker_unanchored"
	base_icon_state = "concertspeaker"
	anchored = FALSE
	density = FALSE
	layer = 4
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	var/active = FALSE
	var/stat = 0
	var/frequency = 1400
	var/is_synced = FALSE
	var/shell_capacity = SHELL_CAPACITY_SMALL

/obj/structure/concertspeaker/examine()
	. = ..()
	. += "<span class='notice'>Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.</span>"

/obj/structure/concertspeaker/update_icon_state()
	. = ..()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = base_icon_state

/obj/structure/concertspeaker/update_overlays()
	. = ..()
	overlays.Cut()

	if(active)
		overlays += mutable_appearance(icon, "song_act1")
		overlays += mutable_appearance(icon, "song_act2")
		overlays += mutable_appearance(icon, "song_act3a")

	if(anchored)
		if(is_synced)
			overlays += mutable_appearance(icon, "synced")
		else
			overlays += mutable_appearance(icon, "asynced")

/obj/structure/concertspeaker/wrench_act(mob/living/user, obj/item/I)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	if(!anchored && !isinspace())
		to_chat(user, span_notice("You secure [name] to the floor."))
		anchored = TRUE
		density = TRUE
		layer = 5
		update_icon()
		update_overlays()
	else if(anchored)
		to_chat(user, span_notice("You unsecure and disconnect [src]."))
		anchored = FALSE
		density = FALSE
		layer = initial(layer)
		update_icon()
		update_overlays()
		src.force_stop_all_listeners()

	icon_state = "[base_icon_state][anchored ? null : "_unanchored"]"
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

	return TRUE

/obj/structure/concertspeaker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(), shell_capacity)

/obj/structure/concertspeaker/proc/signal_callback()
	active = !active
	update_icon()

/obj/structure/concertspeaker/proc/force_stop_all_listeners()
	for(var/obj/item/integrated_circuit/C in src)
		for(var/obj/item/circuit_component/concert_listener/L in C.attached_components)
			L.stop_playback()

/datum/supply_pack/goody/concert_speaker
	access = NONE
	group = "Imports"
	cost = CARGO_CRATE_VALUE
	crate_name = "Контейнер Колонки Саундхенд"
	crate_type = /obj/structure/closet/crate
	discountable = SUPPLY_PACK_NOT_DISCOUNTABLE
	name = "Колонка Саундхенд"
	desc = "Контейнер содержит упакованную для сборки колонку Саундхенд."
	contains = list(/obj/item/packed_concertspeaker)

/obj/structure/concertspeaker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/concert_master))
		if(!anchored)
			to_chat(user, span_warning("Сначала закрепите колонку."))
			return TRUE

		convert_to_master(user)
		qdel(I)
		return TRUE

	return ..()

/obj/structure/concertspeaker/proc/convert_to_master(mob/user)
	var/turf/T = get_turf(src)
	if(!T) return

	var/obj/machinery/jukebox/concertspeaker/M = new(T)
	M.dir = dir
	M.set_anchored(TRUE)

	// переносим схему, если была
	for(var/obj/item/integrated_circuit/C in contents)
		C.forceMove(M)

	to_chat(user, span_notice("Вы установили DJ-стойку. Колонка стала концертной установкой."))
	qdel(src)

/obj/item/packed_concertspeaker
	name = "Упакованная концертная колонка"
	desc = "Одноразовый упаковочный модуль. После установки распаковывается."
	icon = 'modular_bandastation/objects/icons/obj/machines/jukebox.dmi'
	icon_state = "concertspeaker"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/packed_concertspeaker/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		return

	to_chat(user, span_notice("Вы устанавливаете концертную колонку."))
	var/dir_to_set = user.dir
	var/obj/structure/concertspeaker/S = new
	S.loc = T
	S.dir = dir_to_set
	S.anchored = FALSE
	qdel(src)
