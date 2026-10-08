/obj/item/gun/energy/pulse/loyalpin
	cell_type = /obj/item/stock_parts/power_store/cell/infinite // This gun used only by deathsquad, it has to be infinite

/obj/item/gun/energy/pulse/pistol/taserless/loyal
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/ballistic/automatic/laser/pistol
	name = "X-02 Laser Pistol"
	desc = "This is an expensive experimental laser pistol. This pistol uses recharchable accumulators, but lacks the ability to be recharge directly."
	icon = 'modular_bandastation/weapon/icons/ranged/energy.dmi'
	icon_state = "hoslaser"
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = "hoslaserkill4"
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/small
	fire_delay = 2 DECISECONDS

/obj/item/ammo_box/magazine/recharge
	icon = 'modular_bandastation/weapon/icons/ranged/energy.dmi'
	icon_state = "recharge-4"
	base_icon_state = "recharge"

/obj/item/ammo_box/magazine/recharge/small
	icon_state = "recharge_small-4"
	base_icon_state = "recharge_small"
	max_ammo = 10
