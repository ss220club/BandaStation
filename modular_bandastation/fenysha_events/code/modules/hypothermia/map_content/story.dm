/obj/item/keycard/important
	name = "Важный сюжетный ключ"
	color = COLOR_RED
	max_integrity = 250
	armor_type = /datum/armor/disk_nuclear
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/keycard/important/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, TRUE)
	SSpoints_of_interest.make_point_of_interest(src)


/obj/item/keycard/important/hypothermia
	color = COLOR_BLUE_LIGHT


/obj/item/keycard/important/hypothermia/amory_key
	name = "Ключ от тяжёлого арсенала «Звезда»"

/obj/item/keycard/important/hypothermia/ship_control_key
	name = "Ключ управления «Буран»"
	color = COLOR_GOLD
	desc = "Это ключ от консоли управления колониального шаттла класса «Буран». Без него шаттл просто не запустится!"

/obj/item/story_item
	name = "Важный сюжетный предмет"
	max_integrity = 250
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	var/important_text = "Это важный сюжетный предмет! Не теряйте его!"

/obj/item/story_item/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, TRUE)
	SSpoints_of_interest.make_point_of_interest(src)

/obj/item/story_item/examine(mob/user)
	. = ..()
	. += span_boldwarning(important_text)


/obj/item/story_item/hypothermia_applied_ai_core
	name = "установленный ИИ-ядро"
	desc = "Старый позитронный мозг в потрескавшемся корпусе. Кто-то ногтем нацарапал на нём «ТЫВОЖКА». Еле-еле работает."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "spheribrain-searching"
	w_class = WEIGHT_CLASS_BULKY
	important_text = "Это единственный модуль ИИ, способный управлять колониальным шаттлом. Без него корабль не взлетит!"


/obj/item/story_item/hypothermia_fusion_core
	name = "разряженный термоядерный сердечник"
	desc = "Тяжёлый микро-термоядерный сердечник класса РБМК. Последний на колонии. Холодный, но кольца удержания целы. Заправьте его листами плазмы или урана — возможно, снова заработает."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "syndicate-bomb-inactive-wires"
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 20
	important_text = "Без работающего термоядерного сердечника двигатели шаттла не получат питания. Вы не сможете покинуть планету!"

	var/refueled = FALSE

/obj/item/story_item/hypothermia_fusion_core/attackby(obj/item/W, mob/user, params)
	if(refueled)
		return ..()

	if(istype(W, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = W
		if(P.amount >= 50)
			P.use(50)
			refueled = TRUE
			icon_state = "syndicate-bomb-active-wires"
			desc = "Тяжёлый микро-термоядерный сердечник класса РБМК. Теперь работает — кто-то засунул в него листы плазмы и помолился."
			visible_message(span_notice("[user] засовывает листы плазмы в [src]. Сердечник начинает тихо гудеть."))
			return
		else
			balloon_alert(user, "Недостаточно материала!")
	if(istype(W, /obj/item/stack/sheet/mineral/uranium))
		var/obj/item/stack/sheet/mineral/uranium/U = W
		if(U.amount >= 50)
			U.use(50)
			refueled = TRUE
			icon_state = "syndicate-bomb-active-wires"
			desc = "Тяжёлый микро-термоядерный сердечник класса РБМК. Кто-то приварил к нему пластины урана. Он опасно разогревается... но даст энергию!"
			visible_message(span_danger("[user] вставляет листы урана в [src]. Сердечник начинает тихо гудеть!"))
			return
		else
			balloon_alert(user, "Недостаточно материала!")
	return ..()


/obj/item/story_item/hypothermia_navigation_tape
	name = "кассета с навигационной лентой"
	desc = "Пыльная магнитная лента с надписью «H1132 → ЗЕМЛЯ». Единственная копия координат прыжка из этой системы. Без неё автопилот просто направит шаттл в Солнце."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "tape_yellow"
	w_class = WEIGHT_CLASS_SMALL
	important_text = "Это единственная лента с координатами Земли! Без неё шаттл никуда не полетит и вы сгорите в гиперпространстве!"


/obj/item/story_item/hypothermia_thermal_regulator
	name = "главный клапан терморегуляции"
	desc = "Огромный латунный клапан, вырванный из системы терморегуляции колонии. Без него двигатели шаттла перегреются и взорвутся через 30 секунд после старта."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "valve_1"
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 15
	important_text = "Критически важный клапан терморегуляции! Без него двигатели шаттла взорвутся через полминуты полёта!"


// Шаблон шаттла
/datum/map_template/shuttle/zvezda
	port_id = "event"
	prefix = "_maps/modular_events/"
	suffix = "buran"
	name = "Колониальный шаттл класса «Буран»"
	description = "Колониальный шаттл класса «Буран». Единственный шанс покинуть планету."
	width = 23
	height = 30

/obj/docking_port/mobile/buran
	name = "Колониальный шаттл класса «Буран»"
	shuttle_id = "event"
	width = 23
	height = 30
	movement_force = list("KNOCKDOWN" = 0,"THROW" = 0)

/obj/docking_port/stationary/zvezda_buran
	name = "Стыковочный порт «Буран»"
	hidden = FALSE
	dir = WEST
	dheight = 50
	height = 60
	dwidth = 40
	width = 50
	roundstart_template = /datum/map_template/shuttle/zvezda

/obj/machinery/shuttle_launch_terminal
	name = "терминал запуска шаттла"
	desc = "Терминал запуска шаттла «Буран». Активировать его можно только после вставки всех критических модулей и подтверждения авторизации."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	density = TRUE
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_integrity = 700

	var/obj/item/story_item/hypothermia_applied_ai_core/ai_core
	var/obj/item/story_item/hypothermia_fusion_core/fusion_core
	var/obj/item/story_item/hypothermia_navigation_tape/nav_tape
	var/obj/item/story_item/hypothermia_thermal_regulator/thermal_reg

	var/ready_ai = FALSE
	var/ready_core = FALSE
	var/ready_nav = FALSE
	var/ready_therm = FALSE
	var/key_inserted = FALSE

	var/launch_time = 15 MINUTES
	var/time_left
	var/obj/docking_port/mobile/connected_port = null

	var/launching = FALSE


/obj/machinery/shuttle_launch_terminal/Initialize(mapload)
	. = ..()
	for(var/obj/docking_port/mobile/M in get_area(src))
		connected_port = M
		break

	if(!connected_port)
		stack_trace("Терминал запуска размещён без мобильного стыковочного порта поблизости!")
	add_filter("story_outline", 2, list("type" = "outline", "color" = "#fa3b3b", "size" = 1))


/obj/machinery/shuttle_launch_terminal/examine(mob/user)
	. = ..()
	check_modules()
	if(!ready_ai)
		. += span_warning("Отсутствует установленный ИИ-ядро!")
	if(!ready_core)
		. += span_warning("Отсутствует заправленный термоядерный сердечник!")
	if(!ready_nav)
		. += span_warning("Отсутствует навигационная лента!")
	if(!ready_therm)
		. += span_warning("Отсутствует клапан терморегуляции!")
	if(key_inserted)
		. += span_notice("Ключ вставлен.")
	else
		. += span_warning("Ключ не вставлен.")


/obj/machinery/shuttle_launch_terminal/proc/check_modules()
	ready_ai = !!ai_core
	ready_core = !!fusion_core
	ready_nav = !!nav_tape
	ready_therm = !!thermal_reg
	return ready_ai && ready_core && ready_nav && ready_therm


/obj/machinery/shuttle_launch_terminal/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/keycard/important/hypothermia/ship_control_key))
		if(key_inserted)
			to_chat(user, span_warning("Ключ уже вставлен."))
			return

		if(!check_modules())
			to_chat(user, span_warning("Сначала вставьте все критические модули!"))
			return

		balloon_alert(user, "Запускается процедура старта!")
		visible_message(span_notice("[user] начинает процедуру запуска."))
		if(!do_after(user, 15 SECONDS, src))
			balloon_alert(user, "Процедура прервана!")
			return
		balloon_alert(user, "Запуск шаттла!")
		if(!user.transferItemToLoc(W, src))
			return

		key_inserted = TRUE
		to_chat(user, span_notice("Вы вставляете ключ в терминал."))
		visible_message(span_notice("[user] вставляет ключ управления в терминал запуска."))

		start_launch_countdown(user)
		return

	if(istype(W, /obj/item/story_item/hypothermia_applied_ai_core))
		if(ai_core)
			to_chat(user, span_warning("ИИ-ядро уже установлено!"))
			return

		if(!user.transferItemToLoc(W, src))
			return

		ai_core = W
		to_chat(user, span_notice("Вы вставляете [W] в терминал."))
		visible_message(span_notice("[user] вставляет [W] в терминал."))
		return

	if(istype(W, /obj/item/story_item/hypothermia_fusion_core))
		var/obj/item/story_item/hypothermia_fusion_core/core = W
		if(fusion_core)
			to_chat(user, span_warning("Термоядерный сердечник уже установлен!"))
			return

		if(!core.refueled)
			to_chat(user, span_warning("Термоядерный сердечник не заправлен!"))
			return

		if(!user.transferItemToLoc(W, src))
			return

		fusion_core = W
		to_chat(user, span_notice("Вы вставляете [W] в терминал."))
		visible_message(span_notice("[user] вставляет [W] в терминал."))
		return

	if(istype(W, /obj/item/story_item/hypothermia_navigation_tape))
		if(nav_tape)
			to_chat(user, span_warning("Навигационная лента уже вставлена!"))
			return

		if(!user.transferItemToLoc(W, src))
			return

		nav_tape = W
		to_chat(user, span_notice("Вы вставляете [W] в терминал."))
		visible_message(span_notice("[user] вставляет [W] в терминал."))
		return

	if(istype(W, /obj/item/story_item/hypothermia_thermal_regulator))
		if(thermal_reg)
			to_chat(user, span_warning("Клапан терморегуляции уже установлен!"))
			return

		if(!user.transferItemToLoc(W, src))
			return

		thermal_reg = W
		to_chat(user, span_notice("Вы вставляете [W] в терминал."))
		visible_message(span_notice("[user] вставляет [W] в терминал."))
		return

	return ..()



/obj/machinery/shuttle_launch_terminal/proc/start_launch_countdown(mob/user)
	if(launching)
		return

	launching = TRUE
	time_left = launch_time

	priority_announce("Запущена последовательность старта шаттла. Взлёт через 15 минут.", "Приоритетное оповещение", 'sound/effects/alert.ogg')

	addtimer(CALLBACK(src, PROC_REF(announce_remaining), 10), launch_time - 10 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(announce_remaining), 5), launch_time - 5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(announce_remaining), 1), launch_time - 1 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(launch_shuttle)), launch_time)

	if(istype(SSround_events?.active_event, /datum/full_round_event/hypothermia))
		var/datum/full_round_event/hypothermia/hypo = SSround_events.active_event
		hypo.on_buran_startup()

/obj/machinery/shuttle_launch_terminal/proc/announce_remaining(minutes)
	priority_announce("До запуска шаттла [minutes] минут[minutes > 1 ? "а" : ""].", "Приоритетное оповещение", 'sound/effects/alert.ogg')
	if(minutes <= 1)
		var/message = "Шаттл почти стартует, ещё чуть-чуть и я выживу!"
		for(var/mob/living/player in GLOB.alive_player_list)
			if(ishuman(player))
				to_chat(player, span_boldnotice(message))

/obj/machinery/shuttle_launch_terminal/proc/launch_shuttle()
	priority_announce("ВНИМАНИЕ! ВНИМАНИЕ! ПОСЛЕДОВАТЕЛЬНОСТЬ ЗАПУСКА ЗАВЕРШЕНА. ЗАПУСК ШАТТЛА!", "Приоритетное оповещение", 'sound/effects/alert.ogg')
	connected_port.destination = null
	connected_port.mode = SHUTTLE_IGNITING
	connected_port.setTimer(connected_port.ignitionTime)

	if(istype(SSround_events?.active_event, /datum/full_round_event/hypothermia))
		var/datum/full_round_event/hypothermia/hypo = SSround_events.active_event
		hypo.on_buran_launch()

/obj/item/climbing_hook/emergency/safeguard
	name = "страховочный крюк-страховка"
	desc = "Аварийный страховочный крюк, который автоматически срабатывает при падении в пропасть, вытаскивая владельца в безопасное место, но нанося травмы."
	icon_state = "climbingrope_s"
	slot_flags = ITEM_SLOT_BELT
	var/attempting = FALSE	// Чтобы избежать бесконечных циклов
	var/dropping = FALSE

/obj/item/climbing_hook/emergency/safeguard/examine(mob/user)
	. = ..()
	. += span_warning("[name] нужно носить на поясе, чтобы он спас владельца от падения!")

/obj/item/climbing_hook/emergency/safeguard/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT && isliving(user))
		RegisterSignal(user, COMSIG_MOVABLE_CHASM_DROPPED, PROC_REF(on_chasm_drop))

/obj/item/climbing_hook/emergency/safeguard/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_CHASM_DROPPED)

/obj/item/climbing_hook/emergency/safeguard/proc/on_chasm_drop(mob/living/user, turf/chasm_turf)
	SIGNAL_HANDLER
	if(user.stat == DEAD || attempting || dropping)
		return
	attempting = TRUE
	addtimer(CALLBACK(src, PROC_REF(try_rescue), user, chasm_turf), 0)
	return COMPONENT_NO_CHASM_DROP

/obj/item/climbing_hook/emergency/safeguard/proc/try_rescue(mob/living/user, turf/chasm_turf)
	var/list/possible_turfs = list()
	for(var/turf/T in orange(2, chasm_turf))
		if(!T.density && !(ischasm(T) && !HAS_TRAIT(T, TRAIT_CHASM_STOPPED)) && isopenturf(T))
			possible_turfs += T
	if(!length(possible_turfs))
		drop_back(user, chasm_turf)
		return
	var/turf/safe_turf = pick(possible_turfs)
	if(!safe_turf)
		drop_back(user, chasm_turf)
		return
	rescue_user(user, chasm_turf, safe_turf)
	attempting = FALSE

/obj/item/climbing_hook/emergency/safeguard/proc/rescue_user(mob/living/user, turf/chasm_turf, turf/safe_turf)
	chasm_turf.Beam(safe_turf, icon_state = "zipline_hook", time = 1 SECONDS)
	playsound(user, 'sound/items/weapons/zipline_fire.ogg', 50)
	chasm_turf.visible_message(span_warning("Из [user] выстреливает страховочный трос и цепляется за [safe_turf]! [user] вытаскивает[genderize_decode(user, "ся")] в безопасное место!"))
	user.take_bodypart_damage(20)
	user.throw_at(safe_turf, get_dist(user, safe_turf), 1, src, FALSE, TRUE)
	user.forceMove(safe_turf)
	user.Paralyze(5 SECONDS)
	var/datum/component/chasm/chasm_comp = chasm_turf.GetComponent(/datum/component/chasm)
	chasm_comp?.falling_atoms -= WEAKREF(user)

/obj/item/climbing_hook/emergency/safeguard/proc/drop_back(mob/living/user, turf/chasm_turf)
	attempting = FALSE
	var/datum/component/chasm/chasm_comp = chasm_turf.GetComponent(/datum/component/chasm)
	chasm_comp?.falling_atoms -= WEAKREF(user)
	dropping = TRUE
	chasm_comp?.drop(user)
	dropping = FALSE
