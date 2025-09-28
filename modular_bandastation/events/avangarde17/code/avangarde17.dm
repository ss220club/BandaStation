// MARK: Avangarde17 Event

// MARK: Turfs
/turf/open/misc/asteroid/moon/cold
	planetary_atmos = TRUE
	initial_gas_mix = COLD_ATMOS

/turf/open/misc/snow/avangarde
	initial_gas_mix = COLD_ATMOS

// MARK: BTR structure. Чисто для красоты, в одну сторону глядит.
/obj/structure/btr
	name = "МБМ-67"
	desc = "Многофункциональный бронированный транспорт проекта \"Красноармеец\". Все люки заперты."
	icon = 'modular_bandastation/events/avangarde17/icons/btr.dmi'
	icon_state = "btr"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	bound_width = 64
	bound_height = 96

// MARK: Portrait structure
/obj/structure/sibirskiy
	name = "портрет Товарища Сибирского Ч.Г."
	desc = "И Сибирский - такой молодой, и юный Январь впереди!"
	icon = 'modular_bandastation/events/avangarde17/icons/portrait.dmi'
	icon_state = "sibirskiy"
	density = FALSE
	anchored = TRUE

/obj/structure/sibirskiy/lenin
	name = "портрет Товарища Ленина В.И."
	desc = "И Ленин - такой молодой, и юный Январь впереди!"
	icon_state = "lenin"

/obj/structure/sibirskiy/lasarys
	name = "портрет Товарища Лазаря М.С."
	desc = "И Лазарь - такой молодой, и юный Январь впереди!"
	icon_state = "lasarys"

// MARK: Misc structure
/obj/structure/shipping_container/kosmologistika/crates
	name = "ящики"
	desc = "Груда ящиков с различным содержимым."
	icon = 'modular_bandastation/events/avangarde17/icons/crates.dmi'
	icon_state = "crates"

/obj/structure/guncase/akm
	name = "AKM locker"
	desc = "A locker that holds modern Sable AKM."
	case_type = "AKM"
	gun_category = /obj/item/gun/ballistic/automatic/sabel/auto/modern/no_mag

/obj/structure/lep
	name = "вышка ЛЭП"
	desc = "Молчат..."
	icon = 'modular_bandastation/events/avangarde17/icons/lep.dmi'
	icon_state = "lep"
	layer = ABOVE_MOB_LAYER
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	bound_width = 64

// MARK: Statues
// Lenin
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

// Forgoten
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

// MARK: Temple Arch. Не осилил оверрайд.
/obj/structure/temple_arch
	name = "арка храмовых врат"
	desc = "Циклопическая арка над входом в храм, высеченная из черного камня."
	icon = 'modular_bandastation/events/avangarde17/icons/160x160.dmi'
	icon_state = "arch_full"
	appearance_flags = 0
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	pixel_x = -64
	pixel_y = -43
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay
	color = "#adadad"

/obj/structure/temple_arch/Initialize(mapload)
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('modular_bandastation/events/avangarde17/icons/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL)

/obj/structure/temple_arch/singularity_pull(atom/singularity, current_size)
	return 0

// MARK: I'LL CAST KONU CURSE!!!
/obj/structure/gate_part
	name = "храмовые врата"
	desc = "Проклятые чёрные врата забытого храма. Кажется, вы видели их во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part.dmi'
	icon_state = "left"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	layer = BELOW_MOB_LAYER
	color = "#adadad"

/obj/structure/gate_part/right
	icon_state = "right"

/obj/structure/gate_part/top
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part_top.dmi'
	icon_state = "top"
	layer = ABOVE_ALL_MOB_LAYER
	density = FALSE
	opacity = TRUE

/obj/structure/gate_part/bottom
	icon = 'modular_bandastation/events/avangarde17/icons/gate_part_bottom.dmi'
	icon_state = "bottom"
	density = FALSE
	opacity = TRUE

/obj/machinery/door/password/voice/temple
	name = "храмовые врата"
	desc = "Проклятые чёрные врата забытого храма. Кажется, вы видели их во снах..."
	icon = 'modular_bandastation/events/avangarde17/icons/gate_door.dmi'
	icon_state = "closed"
	password = "куб"
	opacity = FALSE
	door_open = 'sound/effects/stonedoor_openclose.ogg'
	door_close = 'sound/effects/stonedoor_openclose.ogg'
	door_deny = 'sound/effects/shieldbash.ogg'

// MARK: Tomb
/obj/structure/tomb
	name = "колонна из черного камня"
	desc = "От её узоров отходит странная пульсация... Прямо как из ваших снов!"
	icon = 'modular_bandastation/events/avangarde17/icons/32x96_statue.dmi'
	icon_state = "tomb_1"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/tomb/tomb_2
	name = "разрушенная колонна из черного камня"
	desc = "Полуразрушенная колонна из черного камня... Прямо как из ваших снов!"
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "tomb_3"
	layer = BELOW_MOB_LAYER

/obj/structure/tomb/tomb_3
	name = "разрушенная колонна из черного камня"
	desc = "Полуразрушенная колонна из черного камня... Прямо как из ваших снов!"
	icon_state = "tomb_2"

/obj/structure/tomb/obelisk
	name = "чёрный обелиск"
	desc = "Ужасающий черный обелиск, несущий запретные знания в своих письменах."
	icon_state = "obelisk"

/obj/structure/tomb/obelisk_2
	name = "поврежденный чёрный обелиск"
	desc = "Разрушенный ужасающий черный обелиск, несущий запретные знания в своих письменах."
	icon = 'modular_bandastation/events/avangarde17/icons/32x64_statue.dmi'
	icon_state = "obelisk_2"

// MARK: book
/obj/item/dark_book
	name = "тёмная книга"
	desc = "Старый том в тёмном кожаном переплёте, покрытый странными письменами."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "book1"
	w_class = WEIGHT_CLASS_SMALL
	color = "#4b4b4b"

/obj/item/dark_book/attack_self(mob/user)
	if(!user) return FALSE
	to_chat(user, span_hypnophrase("Вам неизвестен этот язык."))
	return TRUE

// MARK: Barricade
/obj/structure/barricade/concrete_block
	name = "бетонный блок"
	desc = "Бетонное ограждение. Поможет в качестве укрытия."
	icon = 'modular_bandastation/events/avangarde17/icons/barricade.dmi'
	icon_state = "concrete_block"
	max_integrity = 280
	proj_pass_rate = 40
	pass_flags_self = LETPASSTHROW

/obj/structure/barricade/concrete_block/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

// MARK: Areas
/area/awaymission/avangarde17
	name = "Авангард-17"
	icon_state = "awaycontent1"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/avangarde17/outside
	name = "Лес"
	icon_state = "awaycontent17"
	base_lighting_alpha = 120

/area/awaymission/avangarde17/outside/base
	name = "Аванпост КССП"
	icon_state = "awaycontent3"
	var/sound_file = 'modular_bandastation/events/avangarde17/audio/red_army.ogg'
	var/sound_channel = 61
	var/max_volume = 20
	var/fade_tick = 0.3 SECONDS
	var/fade_duration = 1.5 SECONDS
	var/check_period = 3 SECONDS

	var/play_duration = 4 MINUTES + 40 SECONDS
	var/silence_duration = 20 SECONDS
	var/is_phase_play = FALSE

	var/list/current_volumes = list()
	var/list/target_volumes  = list()
	var/list/attached_mobs   = list()

/area/awaymission/avangarde17/inside
	name = "Аванпост КССП"
	icon_state = "awaycontent4"
	static_lighting = TRUE
	base_lighting_alpha = 0

/area/awaymission/avangarde17/inside/cave
	name = "Пещеры"
	icon_state = "awaycontent5"

/area/awaymission/avangarde17/inside/temple
	name = "Древний храм"
	icon_state = "awaycontent6"

/area/awaymission/avangarde17/outside/base/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(update_members)), check_period, TIMER_LOOP | TIMER_STOPPABLE)
	addtimer(CALLBACK(src, PROC_REF(process_fades)),  fade_tick,   TIMER_LOOP | TIMER_STOPPABLE)
	start_cycle()

/area/awaymission/avangarde17/outside/base/Destroy()
	for(var/mob/M in attached_mobs)
		if(M?.client)
			SEND_SOUND(M, sound(null, channel = sound_channel))
	current_volumes.Cut()
	target_volumes.Cut()
	attached_mobs.Cut()
	return ..()

/area/awaymission/avangarde17/outside/base/proc/start_cycle()
	is_phase_play = TRUE
	for(var/mob/M in attached_mobs)
		if(!M?.client) continue
		var/sound/start = sound(sound_file)
		start.channel = sound_channel
		start.repeat = TRUE
		start.volume = current_volumes[M] || 0
		SEND_SOUND(M, start)
	update_members()
	addtimer(CALLBACK(src, PROC_REF(begin_silence_phase)), play_duration, TIMER_STOPPABLE)

/area/awaymission/avangarde17/outside/base/proc/begin_silence_phase()
	is_phase_play = FALSE
	for(var/mob/M in attached_mobs)
		target_volumes[M] = 0
	addtimer(CALLBACK(src, PROC_REF(start_cycle)), silence_duration, TIMER_STOPPABLE)

/area/awaymission/avangarde17/outside/base/proc/update_members()
	var/list/in_zone = list()
	for(var/mob/living/player in GLOB.player_list)
		if(!player?.client) continue
		if(get_area(player) == src)
			in_zone[player] = TRUE
			if(!(player in attached_mobs))
				var/sound/seed = sound(sound_file)
				seed.channel = sound_channel
				seed.repeat = TRUE
				seed.volume = 0
				SEND_SOUND(player, seed)
				attached_mobs += player
				current_volumes[player] = 0
			target_volumes[player] = is_phase_play ? max_volume : 0
	for(var/mob/existing in current_volumes.Copy())
		if(!existing?.client)
			detach_listener(existing)
		else if(!(existing in in_zone))
			target_volumes[existing] = 0

/area/awaymission/avangarde17/outside/base/proc/process_fades()
	for(var/mob/listener in current_volumes.Copy())
		if(!listener?.client)
			detach_listener(listener)
			continue
		var/cv = current_volumes[listener]
		var/tv = isnull(target_volumes[listener]) ? 0 : target_volumes[listener]
		if(cv == tv) continue
		var/step = round((max_volume * fade_tick) / max(0.1 SECONDS, fade_duration))
		if(step < 1) step = 1
		var/nv = cv
		if(cv < tv) nv = min(cv + step, tv)
		else        nv = max(cv - step, tv)
		if(abs(nv - cv) >= 2)
			var/sound/update = sound(null)
			update.channel = sound_channel
			update.repeat = TRUE
			update.volume = nv
			update.status = SOUND_UPDATE
			SEND_SOUND(listener, update)
		current_volumes[listener] = nv

/area/awaymission/avangarde17/outside/base/proc/detach_listener(mob/M)
	if(!M) return
	SEND_SOUND(M, sound(null, channel = sound_channel))
	current_volumes -= M
	target_volumes  -= M
	attached_mobs   -= M
