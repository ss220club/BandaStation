/obj/item/air_refresher
	name = "air refresher"
	desc = "Флакон, наполненный приторным сильным ароматом. Имеет распылитель"
	icon = 'modular_bandastation/pollution/icons/obj/air_refresher.dmi'
	icon_state = "air_refresher"
	inhand_icon_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/uses_remaining = 20

/obj/item/air_refresher/examine(mob/user)
	. = ..()
	if(uses_remaining)
		. += "Осталось [uses_remaining] использований"
	else
		. += "Пуст."

/obj/item/air_refresher/afterattack(atom/attacked, mob/user, proximity)
	. = ..()
	if(.)
		return
	if(uses_remaining <= 0)
		to_chat(user, span_warning("[src] Пуст!"))
		return TRUE
	uses_remaining--
	var/turf/aimed_turf = get_turf(attacked)
	aimed_turf.pollute_turf(/datum/pollutant/fragrance/air_refresher, 200)
	user.visible_message(span_notice("[user] распыляет в аэрозоль с помощью [src]."), span_notice("Вы распыляете аэрозоль с помощью [src]."))
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(aimed_turf, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	return TRUE

/obj/machinery/pollution_scrubber
	name = "Pollution Scrubber"
	desc = "Скраббер, который будет обрабатывать воздух и отфильтровывать любые загрязнения."
	icon = 'modular_bandastation/pollution/icons/obj/pollution_scrubber.dmi'
	icon_state = "scrubber"
	var/scrub_amount = 2
	var/on = FALSE

/obj/machinery/pollution_scrubber/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	on = !on
	balloon_alert(user, "скраббер [on ? "включён" : "выключен"]")

	update_appearance()

/obj/machinery/pollution_scrubber/update_icon(updates)
	. = ..()
	if(on)
		icon_state = "scrubber_on"
	else
		icon_state = "scrubber"

/obj/machinery/pollution_scrubber/process()
	if(machine_stat)
		return
	if(on && isopenturf(get_turf(src)))
		var/turf/open/open_turf = get_turf(src)
		if(open_turf.pollution)
			open_turf.pollution.scrub_amount(scrub_amount)
			available_energy(100)
