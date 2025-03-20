/datum/instrument/guitar/soundhand_rock
	name = "Soundhand Rock Guitar"
	id = "cshrockgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_rock/c5.ogg')

/datum/instrument/guitar/soundhand_metal
	name = "Soundhand Metal Guitar"
	id = "cshmetalgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_metal/c5.ogg')

/datum/instrument/guitar/soundhand_bass
	name = "Soundhand Bass Guitar"
	id = "cshbassgt"
	real_samples = list("36"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c2.ogg',
				"48"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c3.ogg',
				"60"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c4.ogg',
				"72"='modular_bandastation/objects/sounds/guitar/soundhand_bass/c5.ogg')

/datum/instrument/hardcoded/drums
	name = "Drums"
	id = "drums"
	legacy_instrument_ext = "ogg"
	legacy_instrument_path = "soundhand_drums"

/obj/item/instrument/soundhand_metal_guitar
	name = "гитара Арии"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва. Эта гитара украшена пламенем в районе корпуса и подписью Арии Вильвен."
	icon_state = "elguitar_fire"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt","cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_metal_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_bass_guitar
	name = "бас-гитара"
	desc = "Тяжелая гитара с сокращенным количеством широких струн для извлечения низкочастотных звуков."
	icon_state = "bluegitara"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_bass_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_rock_guitar
	name = "рок-гитара"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва"
	icon_state = "elguitar"
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/samurai_guitar_righthand.dmi'
	attack_verb_continuous = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/items/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt")

/obj/structure/musician/drumskit
	name = "\proper барабанная установка"
	desc = "Складная барбанная установка с несколькими томами и тарелками."
	icon = 'modular_bandastation/objects/icons/obj/items/samurai_guitar.dmi'
	icon_state = "drum_red_unanchored"
	base_icon_state = "drum_red"
	layer = 2.5
	anchored = FALSE
	var/active = FALSE
	allowed_instrument_ids = "drums"
	//Использутся, чтобы отслеживать, персонаж должен лежать или "сидеть" (стоять)
	buckle_lying = FALSE
	//Задает состояния и флаги Атома (как я понял) - взято из машинерии, иначе в строчке 75 вышибается ошибка
	var/stat = 0

/obj/structure/musician/drumskit/examine()
	. = ..()
	. += "<span class='notice'>Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.</span>"

/obj/structure/musician/drumskit/Initialize(mapload)
	. = ..()
	//Выбирает инструмент по умолчанию
	song = new(src, "drums")
	song.instrument_range = 15
	song.allowed_instrument_ids = "drums"
	// Для обновления иконки (код взят с кода наушников)
	RegisterSignal(src, COMSIG_INSTRUMENT_START, PROC_REF(start_playing))
	RegisterSignal(src, COMSIG_INSTRUMENT_END, PROC_REF(stop_playing))

/obj/structure/musician/drumskit/proc/start_playing()
	active = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/structure/musician/drumskit/proc/stop_playing()
	active = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/structure/musician/drumskit/wrench_act(mob/living/user, obj/item/I)
	if(active || (resistance_flags & INDESTRUCTIBLE))
		return

	if(!anchored && !isinspace())
		to_chat(user, span_notice("You secure [src] to the floor."))
		anchored = TRUE
		can_buckle = TRUE
		layer = 5
	else if(anchored)
		to_chat(user, span_notice("You unsecure and disconnect [src]."))
		anchored = FALSE
		can_buckle = FALSE
		layer = 2.5

	update_icon()
	icon_state = "[base_icon_state][anchored ? null : "_unanchored"]"

	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

	return TRUE

/obj/structure/musician/drumskit/attack_hand(mob/user)
	add_fingerprint(user)

	if(!anchored)
		return

	ui_interact(user)

/obj/structure/musician/drumskit/update_icon_state()
	. = ..()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else if(anchored)
		icon_state = "[base_icon_state][active ? "_active" : null]"

	setDir(SOUTH)
