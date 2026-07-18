/obj/structure/city_prop
	name = "гемблинг машина"
	icon = 'modular_bandastation/voyaker_events/icons/64x64_urbanrandomprops.dmi'
	icon_state = "slotmachine"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/list/parts = list()

/obj/structure/city_part
	name = ""
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/obj/structure/city_prop/master

/obj/structure/city_part/attackby(obj/item/I, mob/user, params)
	if(master)
		return master.attackby(I, user, params)
	return ..()

/obj/structure/city_prop/streetlamp
	name = "фонарный столб"
	icon_state = "street_off"
	layer = ABOVE_MOB_LAYER

/obj/structure/city_prop/streetlamp/dmg
	name = "сломанный фонарный столб"
	icon_state = "street_dmg"

/obj/structure/city_prop/streetlamp/on
	icon_state = "street_on"
	light_range = 6
	light_power = 1.5
	light_color = "#FFF4CC"

/obj/structure/city_prop/streetlamp/on/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power, light_color)
	start_flicker()

/obj/structure/city_prop/streetlamp/on/proc/start_flicker()
	addtimer(CALLBACK(src, PROC_REF(flicker)), 5 SECONDS)

/obj/structure/city_prop/streetlamp/on/proc/flicker()
	if(QDELETED(src))
		return
	set_light(0)
	addtimer(CALLBACK(src, PROC_REF(restore_light)), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(start_flicker)), 5 SECONDS)

/obj/structure/city_prop/streetlamp/on/proc/restore_light()
	if(QDELETED(src))
		return
	set_light(light_range, light_power, light_color)

/obj/structure/city_prop/trafficlight
	name = "светофор"
	icon_state = "trafficlight"
	layer = ABOVE_MOB_LAYER

/obj/structure/city_prop/trafficlight/dmg
	name = "сломанный светофор"
	icon_state = "trafficlight_damaged"

/obj/structure/city_prop/trafficlight/on
	icon_state = "trafficlight_on"
	light_range = 2
	light_power = 1
	light_color = "#FFD400"

/obj/structure/city_prop/trafficlight/on/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power, "#FFD400")
	start_blink()

/obj/structure/city_prop/trafficlight/on/proc/start_blink()
	addtimer(CALLBACK(src, PROC_REF(blink)), rand(5 SECONDS, 12 SECONDS))

/obj/structure/city_prop/trafficlight/on/proc/blink()
	if(QDELETED(src))
		return
	set_light(0)
	addtimer(CALLBACK(src, PROC_REF(turn_on)), rand(1, 3))

/obj/structure/city_prop/trafficlight/on/proc/turn_on()
	if(QDELETED(src))
		return
	set_light(light_range, light_power, "#FFD400")
	start_blink()

/obj/structure/city_prop/atm
	name = "нерабочий банкомат"
	icon_state = "atm_off"

/obj/structure/city_prop/atm/on
	name = "глючный банкомат"
	icon_state = "atm"
	light_range = 2
	light_power = 1
	light_color = "#72a3db"
	var/atm_cooldown = 10 MINUTES

/obj/structure/city_prop/atm/on/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power, light_color)
	start_bug()

/obj/structure/city_prop/atm/on/proc/start_bug()
	addtimer(CALLBACK(src, PROC_REF(bug_cycle)), rand(3 SECONDS, 8 SECONDS))

/obj/structure/city_prop/atm/on/proc/bug_cycle()
	if(QDELETED(src))
		return
	set_light(0)
	addtimer(CALLBACK(src, PROC_REF(restore)), rand(1, 2))

/obj/structure/city_prop/atm/on/proc/restore()
	if(QDELETED(src))
		return
	set_light(light_range, light_power, light_color)
	start_bug()

/obj/structure/city_prop/atm/on/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < H.next_atm_use)
		var/time_left = round((H.next_atm_use - world.time) / 10)
		to_chat(H, span_warning("Банкомат временно недоступен. Повторите попытку через [time_left] сек."))
		return
	to_chat(H, span_notice("Вы пытаетесь произвести манипуляцию на клавиатуре автомата..."))
	playsound(src, 'sound/machines/computer/keyboard_clicks_1.ogg', 50, TRUE)
	if(!do_after(H, 5 SECONDS))
		return
	var/amount = rand(10, 250)
	var/obj/item/holochip/chip = new(get_turf(H), amount)
	if(!H.put_in_hands(chip))
		chip.forceMove(get_turf(H))
	H.next_atm_use = world.time + atm_cooldown
	to_chat(H, span_green("Банкомат неожиданно выдал вам [amount] кредитов."))

/obj/structure/city_prop/gas_station
	name = "бензоколонка"
	icon_state = "buildingventbig12"
	desc = "Обычная бензоколонка. Возможно, в ней ещё осталось топливо..."
	/// player.ckey -> world.time окончания кулдауна
	var/list/refuel_cooldowns = list()

#define GAS_REFUEL_COOLDOWN (20 MINUTES)

/obj/structure/city_prop/gas_station/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/reagent_containers/cup/fuel_can))
		return ..()
	var/obj/item/reagent_containers/cup/fuel_can/can = I
	var/ckey = user.ckey
	if(!ckey)
		return
	if(refuel_cooldowns[ckey] && refuel_cooldowns[ckey] > world.time)
		var/time_left = round((refuel_cooldowns[ckey] - world.time) / 10)
		balloon_alert(user, "ещё [time_left] сек.")
		return TRUE
	if(can.reagents.total_volume >= can.reagents.maximum_volume)
		balloon_alert(user, "канистра уже полная!")
		return TRUE
	balloon_alert(user, "заправка...")
	playsound(src, 'sound/effects/liquid_pour/liquid_pour1.ogg', 50, TRUE)
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	can.reagents.add_reagent(/datum/reagent/fuel,
		can.reagents.maximum_volume - can.reagents.total_volume)
	refuel_cooldowns[ckey] = world.time + GAS_REFUEL_COOLDOWN
	playsound(src, 'sound/effects/compressed_air/tank_insert_clunky.ogg', 50, TRUE)
	to_chat(user, span_notice("Вы полностью заполняете канистру топливом."))
	return TRUE

/obj/structure/city_prop/gas_station/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/city_part(locate(T.x, T.y + 1, T.z))

/obj/structure/city_prop/telebox
	name = "телефонная будка"
	icon_state = "phonebox_closed_light"
	var/list/search_cooldowns = list()

/obj/structure/city_prop/telebox/interact(mob/living/carbon/human/user)
	. = ..()
	if(!user)
		return
	var/datum/trader_quest/Q = user.trader_quests?[TRADER_SAMOPAL]
	if(!istype(Q, /datum/trader_quest/samopal_letter))
		return
	var/key = REF(user)
	if(search_cooldowns[key] && world.time < search_cooldowns[key])
		var/time_left = round((search_cooldowns[key] - world.time) / 10)
		balloon_alert(user, "будка уже осмотрена. Возможно, другая запись появится здесь через ([time_left] сек.)")
		return
	balloon_alert(user, "ищет записи...")
	if(!do_after(user, 10 SECONDS, target = src))
		return
	new /obj/item/paper/fluff/eftk/telegraph(get_turf(src))
	search_cooldowns[key] = world.time + 10 MINUTES
	balloon_alert(user, "найдены записи")

/obj/structure/city_prop/telebox/broken
	name = "сломанная телефонная будка"
	icon_state = "phonebox_closed_broken"

/obj/structure/city_prop/telebox/broken/interact(mob/living/carbon/human/user)
    balloon_alert(user, "будка сломана")

/obj/structure/city_prop/electrical_substation
	name = "преобразователь подстанции"
	icon = 'modular_bandastation/voyaker_events/icons/64x64.dmi'
	icon_state = "alteviangen"

/obj/structure/city_prop/electrical_substation/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/structure/city_part(locate(T.x + 1, T.y, T.z))

/obj/structure/city_prop/electrical_substation/wreck
	name = "сломанный преобразователь подстанции"
	icon_state = "alteviangenwrecked"

/obj/structure/city_prop/electrical_substation/terminal
	name = "терминал подстанции"
	icon = 'modular_bandastation/voyaker_events/icons/64x64_urbanrandomprops.dmi'
	icon_state = "buildingventbig7_off"

/obj/structure/city_prop/mail_box
	name = "почтовый ящик"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "mailbox"
	var/list/drop_cooldowns = list()

/obj/structure/city_prop/mail_box/proc/place_suture(mob/living/carbon/human/user, obj/item/stack/medical/suture/S)
	if(!user)
		return
	var/datum/trader_quest/Q = user.trader_quests?[TRADER_TERESA]
	if(!istype(Q, /datum/trader_quest/teresa_mailboxes))
		return
	if(!S)
		balloon_alert(user, "нужен медицинский шов")
		return
	var/key = REF(user)
	if(drop_cooldowns[key] && world.time < drop_cooldowns[key])
		balloon_alert(user, "сюда уже положили")
		return
	balloon_alert(user, "закладывает...")
	if(!do_after(user, 5 SECONDS, target = src))
		return
	drop_cooldowns[key] = world.time + 10 MINUTES
	Q.add_progress(user, TRADER_TERESA)
	S.use(S.amount)
	balloon_alert(user, "заложено")

/obj/structure/city_prop/mail_box/open
	name = "открытый почтовый ящик"
	icon_state = "mailbox-open"

/obj/structure/city_prop/mail_box/open/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ishuman(user))
		return
	if(!istype(I, /obj/item/stack/medical/suture))
		return
	place_suture(user, I)

/obj/structure/city_prop/mail_box/old
	name = "старый почтовый ящик"
	icon_state = "mailbox_old"

/obj/structure/city_prop/mail_box/old/open
	name = "открытый старый почтовый ящик"
	icon_state = "mailbox_old-open"

/obj/structure/city_prop/mail_box/old/open/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ishuman(user))
		return
	if(!istype(I, /obj/item/stack/medical/suture))
		return
	place_suture(user, I)

/obj/structure/city_prop/filing_cabinet
	name = "закрытая картотека"
	icon = 'modular_bandastation/voyaker_events/icons/cabinets.dmi'
	icon_state = "filing_cabinet"
	var/list/search_cooldowns = list()

/obj/structure/city_prop/filing_cabinet/interact(mob/living/carbon/human/user)
	. = ..()
	if(!user)
		return
	var/datum/trader_quest/Q = user.trader_quests?[TRADER_ROBINSON]
	if(!istype(Q, /datum/trader_quest/robinson_documents))
		return
	var/area/A = get_area(src)
	if(!istype(A, /area/new_sydney/building/administration))
		balloon_alert(user, "не подходящие картотеки")
		return
	var/key = REF(user)
	if(search_cooldowns[key] && world.time < search_cooldowns[key])
		var/time_left = round((search_cooldowns[key] - world.time) / 10)
		balloon_alert(user, "Картотеки уже осмотрены. Возможно, другие документы появятся здесь через ([time_left] сек.)")
		return
	balloon_alert(user, "ищет записи...")
	if(!do_after(user, 10 SECONDS, target = src))
		return
	new /obj/item/folder/documents(get_turf(src))
	search_cooldowns[key] = world.time + 10 MINUTES
	balloon_alert(user, "найдены записи")

/obj/structure/city_prop/filing_cabinet/open
	name = "открытая картотека"
	icon_state = "filing_cabinet_busted-open"

/obj/structure/city_prop/concrete_barrier
	name = "бетонный барьер"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "concrete_barrier_5"

/obj/structure/city_prop/concrete_barrier/alt
	icon_state = "concrete_barrier_alt"

/obj/structure/city_prop/concrete_barrier/corner
	icon_state = "concrete_barrier_alt_2"

/obj/structure/city_prop/cone
	name = "конувага"
	desc = "Обычный, ничем не примечательный конус. Возможно, когда-то давно - он был человеком, возможно даже талантливым. Но стал окончательно конусом..."
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "cone"
	density = FALSE

/obj/structure/city_prop/mine_sign
	name = "табличка минной опасности"
	desc = "Табличка красного цвета с нарисованным черепом и надписью Мины! белым цветом. Интересно, что же это может значить?..."
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "mine_sign"
	density = FALSE

/obj/structure/city_prop/pallet
	name = "деревянная палета"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "pallet"
	density = FALSE

/obj/structure/city_prop/camp_fire
	name = "потухший костёр"
	icon = 'modular_bandastation/voyaker_events/icons/fires.dmi'
	icon_state = "campfire"
	density = FALSE

/obj/structure/city_prop/camp_fire/lit
	name = "горящий костёр"
	icon_state = "campfire_lit"

/obj/structure/city_prop/fire_barrel
	name = "потухший костёр в бочке"
	icon = 'modular_bandastation/voyaker_events/icons/fires.dmi'
	icon_state = "fire_barrel"

/obj/structure/city_prop/fire_barrel/lit
	name = "потухший костёр в бочке"
	icon = 'modular_bandastation/voyaker_events/icons/fires.dmi'
	icon_state = "fire_barrel_lit"

/obj/structure/city_prop/pallet/stack
	name = "деревянные палеты"
	icon_state = "pallet_stack"
	density = TRUE

/obj/effect/decal/papers
	name = "разбросанные бумаги"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "papers_1"

/obj/effect/decal/papers/two
	icon_state = "papers_2"

/obj/effect/decal/papers/tree
	icon_state = "papers_3"

/obj/effect/decal/books
	name = "разбросанные книги"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "bookstack_2"

/obj/effect/decal/books/two
	icon_state = "bookstack_3"

/obj/effect/decal/books/pile_1
	icon_state = "bookpile_1"

/obj/effect/decal/books/pile_2
	icon_state = "bookpile_2"

/obj/effect/decal/food_stuff
	name = "разбросанная посуда"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "foodstuff_1"

/obj/effect/decal/food_stuff/two
	icon_state = "foodstuff_2"

/obj/effect/decal/food_stuff/tree
	icon_state = "foodstuff_3"

/obj/effect/decal/food_stuff/four
	icon_state = "foodstuff_4"

/obj/effect/decal/trashbags
	name = "разбросанные мусорные мешки"
	icon = 'modular_bandastation/voyaker_events/icons/miscellaneous.dmi'
	icon_state = "trashbags_1"

/obj/effect/decal/trashbags/two
	icon_state = "trashbags_2"

/obj/effect/decal/trashbags/tree
	icon_state = "trashbags_3"

/obj/effect/decal/trashbags/four
	icon_state = "trashbags_4"

/obj/effect/decal/trashbags/five
	icon_state = "trashbags_5"
