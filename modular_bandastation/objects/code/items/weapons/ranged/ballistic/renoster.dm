// MARK: SolFed shotgun (this was gonna be in a proprietary shotgun shell type outside of 12ga at some point, wild right?)
/obj/item/gun/ballistic/shotgun/riot/renoster
	name = "Renoster shotgun"
	desc = "Тяжелый дробовик двенадцатого калибра, вмещающий шесть патронов. Производится для различных военных подразделений ТСФ и используется ими."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "renoster"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "renoster"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "renoster"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	SET_BASE_PIXEL(-8, 0)
	fire_sound = 'modular_bandastation/objects/sounds/weapons/shotgun_heavy.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/shotgun_rack.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 9
	recoil = 2
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	projectile_damage_multiplier = 1.4
	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Default" = "renoster",
		"Green" = "renoster_green"
	)

/obj/item/gun/ballistic/shotgun/riot/renoster/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/shotgun/riot/renoster/examine_more(mob/user)
	. = ..()
	. += "По своей сути Реностер был разработан как тяжелый полицейский дробовик. \
		Следовательно, он обладает всеми качествами, необходимыми полицейским структурам. \
		Большая вместимость патронов, прочная рама, достаточно большие \
		возможности для модификации, чтобы удовлетворить даже самые обеспеченные \
		миротворческие силы. Неизбежно было и появление этого оружия на гражданских \
		рынках, а заодно и продажи нескольким военным структурам, которые также \
		сочли полезным иметь тяжелый дробовик."

/obj/item/gun/ballistic/shotgun/riot/renoster/update_appearance(updates)
	if(sawn_off)
		suppressor_x_offset = 0
		SET_BASE_PIXEL(0, 0)
	. = ..()

/obj/item/gun/ballistic/shotgun/riot/renoster/black
	name = "tactical Renoster shotgun"
	icon_state = "renoster_black"
	worn_icon_state = "renoster_black"
	inhand_icon_state = "renoster_black"
	recoil = 1
	projectile_damage_multiplier = 1.5

/obj/item/gun/ballistic/shotgun/riot/renoster/black/examine_more(mob/user)
	. = ..()
	. += "На этот вариант установлен более удобный и усовершенственный приклад, что \
		позволяет серьезно уменьшить отдачу. Внутренний механизм также был усилен, \
		что позволяет выстреливать еще более мощные боеприпасы. Этот экземлпяр покрашен в черные \
		и красные цвета для повышения тактикульности и серьезности намерений владельца."
