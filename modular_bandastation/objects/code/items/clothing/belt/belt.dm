/obj/item/storage/belt/military/holster
	name = "army belt with holster"
	desc = "Пояс с кобурой используемый военными."
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	icon_state = "military_holster"
	inhand_icon_state = "security"
	worn_icon_state = "military"
	storage_type = /datum/storage/military_belt/holster

/datum/storage/military_belt/holster
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 7

/datum/storage/military_belt/holster/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing/shotgun,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/flashlight/seclite,
		/obj/item/grenade,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/radio,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,

	))
