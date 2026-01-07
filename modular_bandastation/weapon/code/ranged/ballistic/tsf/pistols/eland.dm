/obj/item/gun/ballistic/revolver/eland
	name = "Eland revolver"
	desc = "Небольшой револьвер с комично коротким стволом и барабаном на восемь патронов калибра .35 Sol Short."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "eland"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/eland
	suppressor_x_offset = 3
	w_class = WEIGHT_CLASS_SMALL
	can_suppress = TRUE

/obj/item/gun/ballistic/revolver/eland/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/revolver/eland/examine_more(mob/user)
	. = ..()
	. += "\"Эланд\" — одно из немногих оружий компании \"Траписте\", не изготовленных по военному контракту. \
		Вместо этого \"Эланд\" начал свою жизнь как полицейское оружие, предлагаемое в качестве пистолета, \
		который наконец-то превзошел все остальные на рынке дешевого полицейского оружия. К сожалению, это \
		совпало с тем, что почти все полицейские силы ТСФ осознали, что они на самом деле \
		комично перефинансированы. Поскольку военное оружие, купленное для полицейских сил, захватило \
		рынок, \"Эланд\" нашел свое место на рынке гражданского оружия для личной защиты. \
		Вероятно, именно по этой причине вы сейчас смотрите на него."

/obj/item/gun/ballistic/revolver/eland/army
	desc = "Небольшой револьвер с комично коротким стволом и барабаном на шесть патронов калибра .38."
	icon_state = "eland_army"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/eland/army
