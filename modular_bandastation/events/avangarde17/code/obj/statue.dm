// MARK: Statue
// Статуи храма
/obj/structure/statue/forgoten
	name = "статуя забытой твари"
	desc = "Ваши ноги покашиваются от ужаса. Кажется, вы видели <b> это </b> во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/64x96_statue.dmi'
	icon_state = "forgoten"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	pixel_x = -16
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 0
	abstract_type = /obj/structure/statue/forgoten
	var/list/scary_phrases = list(
		"Вы мимолетом оглядываете статую — в голове вспыхивает чужой шёпот: <b>НЕ СМОТРИ. БЕГИ.</b>",
		"Вы чувствуете, как <b>что-то</b> дышит за вашей спиной...",
		"Стоит лишь взглянуть... Блики черного камня, извивающиеся фигуры, манящий лепет древних языков... Всё это как будто пожирают вашу плоть и разум!",
		"Всепоглащающий холод пронизывает вас...",
		"Ваш разум оплетают болезненные путы... Стоит ли идти дальше?",
		"Нужно бежать из этого места. Сейчас же.",
		"Зачем я смотрю на них?",
		"Ноги как будто обмякли... Идти дальше все трудней и трудней.",
		"Кому здесь могли поклоняться?",
		"<b>Они</b> рядом... <b>Они</b> всегда были здесь... Стоит уходить.",
		"Это ужасающее чувство стеснения в груди... Прямо как в ваших снах!"
	)
	var/list/recent_examiners = list()
	var/examine_cooldown = 1 MINUTES

/obj/structure/statue/forgoten/examine(mob/user)
	. = ..()
	if(!iscarbon(user)) return
	if(recent_examiners[user] && recent_examiners[user] > world.time) return
	recent_examiners[user] = world.time + examine_cooldown
	addtimer(CALLBACK(src, PROC_REF(on_examined), user), 0.2 SECONDS)

/obj/structure/statue/forgoten/proc/on_examined(mob/living/carbon/viewer)
	if(!viewer || viewer.stat != CONSCIOUS) return
	var/msg = pick(scary_phrases)
	to_chat(viewer, span_hypnophrase(msg))
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "tremble")

/obj/structure/statue/forgoten/broke
	name = "разрушенная статуя забытой твари"
	desc = "Даже руины этой статуи наводят неистовый страх... Прямо как в ваших снах."
	icon_state = "broken_forgoten_1"

/obj/structure/statue/forgoten/broke/broke_2
	icon_state = "broken_forgoten_2"

/obj/structure/statue/forgoten/broke/broke_3
	icon_state = "broken_forgoten_3"

/obj/structure/statue/forgoten/forgoten_2
	name = "статуя забытой твари"
	desc = "Вы никогда не видели чего-то более устрашающего и омерзительного. Хотя нет, вы точно видели <b> это </b> во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/64x96_statue.dmi'
	icon_state = "forgoten_2"
	abstract_type = /obj/structure/statue/forgoten/forgoten_2

/obj/structure/statue/forgoten/forgoten_2/broke
	name = "разрушенная статуя забытой твари"
	desc = "Даже руины этой статуи наводят неистовый страх... Прямо как в ваших снах."
	icon_state = "broken_forgoten_4"

/obj/structure/statue/forgoten/forgoten_3
	name = "статуя забытой твари"
	desc = "Вы никогда не видели чего-то более устрашающего и омерзительного. Хотя нет, вы точно видели <b> это </b> во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/32x96_statue.dmi'
	icon_state = "forgoten_3"
	pixel_x = 0
	pixel_y = 7
	abstract_type = /obj/structure/statue/forgoten/forgoten_3

/obj/structure/statue/forgoten/forgoten_3/broke
	name = "разрушенная статуя забытой твари"
	desc = "Даже руины этой статуи наводят неистовый страх... Прямо как в ваших снах."
	icon_state = "broken_forgoten_5"

/obj/structure/statue/forgoten/forgoten_3/broke/broke_2
	icon_state = "broken_forgoten_6"

/obj/structure/statue/forgoten/forgoten_3/broke_3
	icon_state = "broken_forgoten_7"

/obj/structure/statue/forgoten/forgoten_4
	name = "статуя забытой твари"
	desc = "Статуя отвратительной твари выполненная из черного камня. Кажется, вы видели <b> это </b> во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/32x96_statue.dmi'
	icon_state = "forgoten_4"
	layer = ABOVE_MOB_LAYER
	pixel_x = 0
	pixel_y = 7
	abstract_type = /obj/structure/statue/forgoten/forgoten_4

/obj/structure/statue/forgoten/forgoten_5
	name = "статуя забытой твари"
	desc = "Вы никогда не видели чего-то более устрашающего и омерзительного. Хотя нет, вы точно видели <b> это </b> во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "forgoten_5"
	pixel_x = 0
	pixel_y = 7
	anchored = TRUE
	abstract_type = /obj/structure/statue/forgoten/forgoten_5

// Ленин
/obj/structure/statue/lenin
	name = "статуя В.И. Ленина"
	desc = "Настоящей глыбой был Владимир Ильич..."
	icon = 'modular_bandastation/events/avangarde17/icons/64x96_statue.dmi'
	icon_state = "lenin"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	pixel_x = -19
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 90
	abstract_type = /obj/structure/statue/lenin

/obj/structure/statue/lenin/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("Статуя намертво закреплена и не поддаётся инструментам."))
	return TRUE
