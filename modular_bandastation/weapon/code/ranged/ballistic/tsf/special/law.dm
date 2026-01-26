/obj/item/gun/ballistic/rocketlauncher/oneuse
	name = "RL-72 disposable rocket launcher"
	desc = "Это лучший одноразовый ракетный гранатомет, используемый во всей галактике. Его нельзя перезаряжать или разряжать на поле боя. Изначально поставляется в компактном сложенном состоянии."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	base_icon_state = "law"
	icon_state = "law"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "law"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	var/extended = FALSE
	dry_fire_sound = 'modular_bandastation/weapon/sound/ranged/launcher_empty.ogg'
	fire_delay = 1 SECONDS
	pin = /obj/item/firing_pin
	SET_BASE_PIXEL(-16, 0)

/obj/item/gun/ballistic/rocketlauncher/oneuse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/rocketlauncher/oneuse/fire_gun(atom/target, mob/living/user, flag, params)
	if(!extended)
		balloon_alert(user, "нужно разложить!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/gun/ballistic/rocketlauncher/oneuse/load_gun(obj/item/ammo, mob/living/user)
	if(user)
		balloon_alert(user, "оно одноразовое!")
	return FALSE

/obj/item/gun/ballistic/rocketlauncher/oneuse/attack_self(mob/user)
	return ITEM_INTERACT_BLOCKING

/obj/item/gun/ballistic/rocketlauncher/oneuse/examine(mob/user)
	. = ..()
	. += "<b>АЛЬТ + ЛКМ</b> чтобы [extended ? "сложить" : "разложить"] гранатомет."

/obj/item/gun/ballistic/rocketlauncher/oneuse/click_alt(mob/user)
	if(!do_after(user, 20, src))
		return
	extended = !extended
	if(!extended)
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = ITEM_SLOT_BELT
	else
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = NONE

	balloon_alert(user, "[extended ? "разложен" : "сложен"]")
	playsound(src, 'modular_bandastation/weapon/sound/ranged/oneuse_deploy.ogg', 60, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/rocketlauncher/oneuse/update_overlays()
	. = ..()
	if(extended)
		. += "law_extended"

/obj/item/gun/ballistic/rocketlauncher/oneuse/update_icon_state()
	. = ..()
	if(extended)
		inhand_icon_state = "[base_icon_state]_extended"
	else
		inhand_icon_state = "[base_icon_state]"
