/obj/item/kinetic_crusher
	/// This var is used to imitate being weilded if its one handed
	var/acts_as_if_wielded

/obj/item/kinetic_crusher/machete
	icon = 'modular_bandastation/objects/icons/obj/weapons/mining.dmi'
	icon_state = "PKMachete"
	inhand_icon_state = "PKMachete0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_righthand.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
	worn_icon_state = "PKMachete0"
	name = "proto-kinetic machete"
	desc = "Недавние достижения в области технологии прото-кенетик привели к усовершенствованию конструкции ранних прото-кенетический крашеров, а именно к возможности упаковать все \
	те же технологии в компактную форму. Форма мачете была выбрана таким образом, чтобы сделать крашер гораздо более простым в обращении и менее громоздким. Конечно, \
	меньший размер означает, что мощность удара мачете не такая высокая, как у оригинального крашшера, но эта форма позволяет блокировать атаки."
	force = 15
	block_chance = 25
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2)
	attack_verb_continuous = list("slashes", "cuts", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "chop", "cut", "swipe", "slash")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = NONE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 5
	light_on = FALSE
	charged = TRUE
	charge_time = 10
	detonation_damage = 35
	backstab_bonus = 20
	acts_as_if_wielded = TRUE

/obj/item/kinetic_crusher/machete/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 4 SECONDS, \
		effectiveness = 130, \
	)

/obj/item/kinetic_crusher/machete/update_icon_state()
	. = ..()
	inhand_icon_state = "PKMachete0"

/obj/item/kinetic_crusher/spear
	icon = 'modular_bandastation/objects/icons/obj/weapons/mining.dmi'
	icon_state = "PKSpear"
	inhand_icon_state = "PKSpear0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_righthand.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/back/mining.dmi'
	worn_icon_state = "PKSpear0"
	name = "proto-kinetic spear"
	desc = "После того, как НТ наконец-то инвестировали в более совершенные прото-кинетические технологии, отдел исследований и разработок смог создать это новое прото-кинетическое оружие. Объединив все технологии \
	мы смогли поместить все это в форму копья. Прото-кинетические крашеры больше не будут предназначены для самых опытных и склонных к самоубийству шахтеров, но теперь они также будут доступны самым осторожным и \
	параноидальным шахтерам, которые теперь могут наслаждаться (немного меньшей) мощностью дробилки, сохраняя при этом (едва ли) минимальную безопасную дистанцию."
	force = 0
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 15
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2)
	attack_verb_continuous = list("stabs", "impales", "pokes", "jabs")
	attack_verb_simple = list("impale", "stab", "pierce", "jab", "poke")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 8
	light_on = FALSE
	charged = TRUE
	charge_time = 15
	detonation_damage = 35
	backstab_bonus = 20
	reach = 2

/obj/item/kinetic_crusher/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=15)
	AddComponent(/datum/component/butchering, \
		speed = 6 SECONDS, \
		effectiveness = 90, \
	)

/obj/item/kinetic_crusher/spear/update_icon_state()
	. = ..()
	inhand_icon_state = "PKSpear[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent

/obj/item/kinetic_crusher/hammer
	icon = 'modular_bandastation/objects/icons/obj/weapons/mining.dmi'
	icon_state = "PKHammer"
	inhand_icon_state = "PKHammer0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_righthand.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/back/mining.dmi'
	worn_icon_state = "PKHammer0"
	name = "proto-kinetic hammer"
	desc = "Каким-то образом отдел исследований и разработок смог сделать прототип прото-кенетического крашера еще больше, что позволило разместить внутри большее количество деталей и увеличить выходную мощность.. \
	Эта увеличенная выходная мощность позволяет  превосходить мощность, вырабатываемым обычным крашером, и в то же время откидывать цели. К сожалению, тупая головка \
	делает невозможным нанесение ударов в спину."
	force = 0
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2)
	hitsound = 'sound/items/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("slams", "crushes", "smashes", "flattens", "pounds")
	attack_verb_simple = list("slam", "crush", "smash", "flatten", "pound")
	sharpness = NONE
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 5
	light_on = FALSE
	charged = TRUE
	charge_time = 20
	detonation_damage = 90
	backstab_bonus = 0
	acts_as_if_wielded = FALSE

/obj/item/kinetic_crusher/hammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=20)

/obj/item/kinetic_crusher/hammer/attack(mob/living/target, mob/living/user)
	var/relative_direction = get_cardinal_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return
	else if(!QDELETED(target) && !target.anchored)
		var/whack_speed = (2)
		target.throw_at(throw_target, 2, whack_speed, user, gentle = TRUE)

/obj/item/kinetic_crusher/hammer/update_icon_state()
	. = ..()
	inhand_icon_state = "PKHammer[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent

/obj/item/kinetic_crusher/claw
	icon = 'modular_bandastation/objects/icons/obj/weapons/mining.dmi'
	icon_state = "PKClaw"
	inhand_icon_state = "PKClaw0"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/melee_righthand.dmi'
	worn_icon_state = "PKHammer0"
	slot_flags = NONE
	name = "proto-kinetic claws"
	desc = "Это действительно самая компактная версия крашера из когда-либо созданных, он достаточно мал чтобы поместиться в рюкзаке и при этом выполнять функцию крашера. \
	Лучше всего использовать при атаке сзади, награждая тех кто способен нанести то, что мы называем 'критическим ударом'  \
	(ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ) Крашер сделан так, чтобы надеваться поверх перчаток, поэтому не пытайтесь носить крашер как перчатку."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2)
	hitsound = 'sound/items/weapons/pierce.ogg'
	attack_verb_continuous = list("swipes", "slashes", "cuts", "slaps")
	attack_verb_simple = list("swipe", "slash", "cut", "slap")
	sharpness = SHARP_POINTY
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 4
	light_on = FALSE
	charged = TRUE
	charge_time = 10
	detonation_damage = 30
	backstab_bonus = 120
	acts_as_if_wielded = TRUE

/obj/item/kinetic_crusher/claw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 5 SECONDS, \
		effectiveness = 100, \
	)
