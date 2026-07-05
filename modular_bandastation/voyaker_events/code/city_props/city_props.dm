/obj/structure/city_prop
	name = "гемблинг машина"
	icon = 'modular_bandastation/voyaker_events/icons/64x64_urbanrandomprops.dmi'
	icon_state = "slotmachine"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	layer = ABOVE_MOB_LAYER

/obj/structure/city_prop/streetlamp
	name = "фонарный столб"
	icon_state = "street_off"

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

/obj/structure/city_prop/telebox
	name = "телефонная будка"
	icon_state = "phonebox_closed_light"

/obj/structure/city_prop/telebox/broken
	name = "сломанная телефонная будка"
	icon_state = "phonebox_closed_broken"

/obj/structure/city_prop/electrical_substation
	name = "преобразователь подстанции"
	icon = 'modular_bandastation/voyaker_events/icons/64x64.dmi'
	icon_state = "alteviangen"

/obj/structure/city_prop/electrical_substation/wreck
	name = "сломанный преобразователь подстанции"
	icon_state = "alteviangenwrecked"

/obj/structure/city_prop/electrical_substation/terminal
	name = "терминал подстанции"
	icon = 'modular_bandastation/voyaker_events/icons/64x64_urbanrandomprops.dmi'
	icon_state = "buildingventbig7_off"
