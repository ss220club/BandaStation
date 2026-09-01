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

/obj/item/storage/belt/sheath/centcom_katana/PopulateContents()
	new /obj/item/melee/sabre/centcom/katana(src)
