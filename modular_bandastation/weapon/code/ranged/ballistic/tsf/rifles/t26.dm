/obj/item/gun/ballistic/rifle/sniper_rifle/t26
	name = "ASR-26"
	desc = "Тяжелая крупнокалиберная снайперская винтовка ТСФ в калибре .50 BMG."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	icon_state = "t26"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "t26"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "t26"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	recoil = 3
	accepted_magazine_type = /obj/item/ammo_box/magazine/sniper_rounds
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	tac_reloads = TRUE
	rack_delay = 1 SECONDS
	can_suppress = FALSE
	SET_BASE_PIXEL(-16, 0)

/obj/item/gun/ballistic/rifle/sniper_rifle/t26/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/rifle/sniper_rifle/t26/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/rifle/sniper_rifle/t26/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

