/obj/item/gun/ballistic/shotgun/riot/renoster/super
	name = "Kolben enhanced combat shotgun"
	desc = "Мощный дробовик 12-го калибра с удлиненным верхним магазином на десять патронов и встроенным усилителем ствола. \
		Специализированный дробовик для очень конкретных целей, как правило - для воссоединения людей с их предками."
	can_suppress = FALSE
	can_be_sawn_off = FALSE
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/super
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	base_icon_state = "spas20"
	icon_state = "spas20"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "spas20"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "spas20"
	projectile_damage_multiplier = 1.35
	projectile_speed_multiplier = 1
	rack_delay = 0.5 SECONDS
	fire_delay = 0.4 SECONDS
	/// Is this shotgun amped? Used instead of toggling a fire selector. Amped Kolbens switch from semi-auto to manual action, gain increased accuracy, and improved damage.
	var/amped = FALSE
	// Base damage multiplier of the shotgun.
	var/base_damage_mult = 1.35
	/// Base projectile speed multiplier of the shotgun.
	var/base_speed_mult = 1
	/// Base fire delay of the shotgun.
	var/base_fire_delay = 0.4 SECONDS
	/// Amped damage multiplier of the shotgun.
	var/amped_damage_mult = 1.5
	/// Amped projectile speed multiplier of the shotgun.
	var/amped_speed_mult = 1.5
	/// Amped fire delay of the shotgun.
	var/amped_fire_delay = 2 SECONDS
	actions_types = list(/datum/action/item_action/toggle_shotgun_barrel)

/obj/item/gun/ballistic/shotgun/riot/renoster/super/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/shotgun/riot/renoster/super/examine_more(mob/user)
	. = ..()
	. += "\"Колбен\" — это модернизированная версия надежного дробовика \"Реностэр\", известного в ТСФ, с улучшенной конструкцией, которая и без того была смертоносной. \
		Точнее говоря, комплект от Astrom Combat Systems \"ASTROM\" (как он официально называется) представляет собой набор модернизаций и аксессуаров для \"Реностэр\", \
		состоящий из упрочненной ствольной коробки и трубки магазина, смарт-прицела, гибридного модуля прицеливания с защитой для рук и встроенного заряжателя ствола, \
		обеспечивающего улучшенные баллистические характеристики, с дополнительным режимом разгона, связанным с ручным приводом затвора. \
		Однако все это стоит недешево, особенно на гражданском рынке, а это означает, что экземпляры \"Колбен\" обычно появляются только в коллекциях \
		богатых любителей модных новинок или военизированных групп, у которых больше денег, чем уважения к разумной жизни."

/obj/item/gun/ballistic/shotgun/riot/renoster/super/update_overlays()
	. = ..()
	if(amped)
		. += "[initial(icon_state)]_charge"

/obj/item/gun/ballistic/shotgun/riot/renoster/super/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_shotgun_barrel))
		toggle_amp(user)
	else
		..()

/obj/item/gun/ballistic/shotgun/riot/renoster/super/rack(mob/user)
	. = ..()
	if(amped)
		playsound(src, 'sound/items/weapons/kinetic_reload.ogg', 50, TRUE)

/obj/item/gun/ballistic/shotgun/riot/renoster/super/proc/toggle_amp(mob/user)
	amped = !amped
	if(amped)
		semi_auto = FALSE
		casing_ejector = FALSE
		projectile_damage_multiplier = amped_damage_mult
		projectile_speed_multiplier = amped_speed_mult
		fire_delay = amped_fire_delay
		balloon_alert(user, "усилитель включен, режим установлен на ручной")
	else
		semi_auto = TRUE
		casing_ejector = TRUE
		projectile_damage_multiplier = base_damage_mult
		projectile_speed_multiplier = base_speed_mult
		fire_delay = base_fire_delay
		balloon_alert(user, "усилитель выключен, режим установлен на полуавтоматический")
	playsound(user, 'sound/items/weapons/empty.ogg', 100, TRUE)
	update_appearance()
	update_item_action_buttons()

/obj/item/gun/ballistic/shotgun/riot/renoster/super/before_firing(atom/target, mob/user)
	if(amped && chambered && chambered.variance > 0)
		chambered.variance = initial(chambered.variance) / 2.5
	return ..()

/datum/action/item_action/toggle_shotgun_barrel
	button_icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	button_icon_state = "hbarrel0"
	name = "Разгон ствола дробовика \"Колбен\""

/datum/action/item_action/toggle_shotgun_barrel/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/gun/ballistic/shotgun/riot/renoster/super/blicky = target
	if(istype(blicky))
		button_icon_state = "hbarrel[blicky.amped]"
	return ..()
