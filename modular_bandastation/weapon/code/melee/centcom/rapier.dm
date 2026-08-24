/obj/item/melee/sabre/centcom
	force = 35
	demolition_mod = 1
	block_chance = 60
	armour_penetration = 75

/obj/item/melee/sabre/centcom/rapier
	name = "fleet officer's rapier"
	desc = "Элегантное оружие более цивилизованной эпохи. Выполнено в классическом стиле с данью флотским традициям прошлого."
	icon = 'modular_bandastation/weapon/icons/melee/sword.dmi'
	icon_state = "centcom_sabre"
	inhand_icon_state = "centcom_sabre"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'

/obj/item/melee/sabre/centcom/katana
	name = "fleet officer's katana"
	desc = "Элегантное оружие более цивилизованной эпохи. Выполнено в азиатском стиле с данью Земным культурам прошлого."
	icon = 'modular_bandastation/weapon/icons/melee/sword.dmi'
	icon_state = "centcom_katana"
	inhand_icon_state = "centcom_katana"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	hitsound = 'sound/items/weapons/bladeslice.ogg'

/obj/item/melee/sabre/centcom_tanto
	name = "fleet officer's tantos"
	desc = "Приливы и Отливы: Парные танто. Один забирает защиту, второй — жизнь. Движения владельца подобны штормовому морю."
	icon = 'modular_bandastation/weapon/icons/melee/sword.dmi'
	icon_state = "centcom_tanto"
	inhand_icon_state = "centcom_tanto"
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	force = 20
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	demolition_mod = 1
	block_chance = 50
	armour_penetration = 35

/obj/item/melee/sabre/centcom_tanto/Initialize(mapload)
	. = ..()
	attack_speed = 4

/datum/storage/centcom_sabre_belt
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/datum/storage/centcom_sabre_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/melee/sabre/centcom/rapier)

/obj/item/storage/belt/sheath/centcom_rapier
	name = "fleet officer's rapier sheath"
	desc = "Богато украшенные ножны, предназначенные для хранения офицерской рапиры."
	icon = 'modular_bandastation/weapon/icons/melee/sheath.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sheath_onmob.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "centcom_sheath"
	worn_icon_state = "centcom_sheath"
	inhand_icon_state = "centcom_sheath"
	storage_type = /datum/storage/centcom_sabre_belt

/obj/item/storage/belt/sheath/centcom_rapier/PopulateContents()
	new /obj/item/melee/sabre/centcom/rapier(src)

/datum/storage/centcom_katana_belt
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/datum/storage/centcom_katana_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/melee/sabre/centcom/katana)

/obj/item/storage/belt/sheath/centcom_katana
	name = "fleet officer's katana sheath"
	desc = "Богато украшенные деревянные ножны, предназначенные для хранения офицерской катаны."
	icon = 'modular_bandastation/weapon/icons/melee/sheath.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sheath_onmob.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "katana_sheath"
	worn_icon_state = "katana_sheath"
	inhand_icon_state = "katana_sheath"
	storage_type = /datum/storage/centcom_katana_belt

<<<<<<< HEAD
/obj/item/storage/belt/sheath/centcom_katana/PopulateContents()
	new /obj/item/melee/sabre/centcom/katana(src)
=======
/obj/item/storage/belt/centcom_katana/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/centcom_katana/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/centcom_katana/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(length(contents))
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/centcom_katana/PopulateContents()
	new /obj/item/melee/sabre/centcom_katana(src)

/datum/storage/centcom_tanto_belt
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/datum/storage/centcom_tanto_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/melee/sabre/centcom_tanto)

/obj/item/storage/belt/sheath/tanto
	name = "fleet officer's tanto sheath's"
	desc = "Матово-черные двойные ножны для танто, перевязанные серебряной нитью. Сконструированы так, что оба танто можно достать одновременно за доли секунды"
	icon = 'modular_bandastation/weapon/icons/melee/sheath.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sheath_onmob.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "tanto_sheath"
	worn_icon_state = "tanto_sheath"
	inhand_icon_state = "tanto_sheath"
	storage_type = /datum/storage/centcom_tanto_belt
	desc_controls = "Нажмите Alt+ЛКМ, чтобы быстро достать клинок."

/obj/item/storage/belt/sheath/tanto/PopulateContents()
	new /obj/item/melee/sabre/centcom_tanto(src)
>>>>>>> 35628b9c1ef (Добавил штуку-дрюку)
