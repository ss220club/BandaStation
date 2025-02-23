/datum/bounty/item/mech/New()
	..()
	description = "Высшее руководство заказало один из мехов типа [name], который должен быть доставлен как можно быстрее. Отправьте его для получения большой выплаты."

/datum/bounty/item/mech/ship(obj/shipped)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/mecha = shipped
	mecha.wreckage = null // So the mech doesn't explode.

/datum/bounty/item/mech/ripleymk2
	name = "APLU MK-II \"Рипли\""
	reward = CARGO_CRATE_VALUE * 26
	wanted_types = list(/obj/vehicle/sealed/mecha/ripley/mk2 = TRUE)

/datum/bounty/item/mech/clarke
	name = "Кларк"
	reward = CARGO_CRATE_VALUE * 32
	wanted_types = list(/obj/vehicle/sealed/mecha/clarke = TRUE)

/datum/bounty/item/mech/odysseus
	name = "Одиссей"
	reward = CARGO_CRATE_VALUE * 22
	wanted_types = list(/obj/vehicle/sealed/mecha/odysseus = TRUE)

/datum/bounty/item/mech/gygax
	name = "Гигакс"
	reward = CARGO_CRATE_VALUE * 56
	wanted_types = list(/obj/vehicle/sealed/mecha/gygax = TRUE)

/datum/bounty/item/mech/durand
	name = "Дюранд"
	reward = CARGO_CRATE_VALUE * 40
	wanted_types = list(/obj/vehicle/sealed/mecha/durand = TRUE)
