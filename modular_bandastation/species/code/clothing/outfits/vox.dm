/obj/item/clothing/mask/breath/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask, this one seems to designed for a vox beak."
	icon = 'modular_bandastation/objects/icons/obj/clothing/mask/voxmask.dmi'
	worn_icon = 'icons/bandastation/mob/species/vox/clothing/mask.dmi'
	icon_state = "voxmask"
	body_parts_covered = NONE
	flags_cover = NONE
	adjustable = FALSE
	actions_types = null

/obj/item/tank/internals/nitrogen
	name = "nitrogen internals tank"
	desc = "A tank of nitrogen gas designed specifically for use as internals, tuned for the respiratory needs of a Vox. If you're not a Vox, you probably shouldn't use this."
	icon = 'modular_bandastation/species/icons/tanks/tank.dmi'
	icon_state = "nitrogen"
	lefthand_file = 'modular_bandastation/species/icons/tanks/tanks_lefthand.dmi'
	righthand_file = 'modular_bandastation/species/icons/tanks/tanks_righthand.dmi'
	inhand_icon_state = "nitrogen"
	tank_holder_icon_state = null
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/nitrogen/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.moles[/datum/gas/nitrogen] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/nitrogen/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.moles[/datum/gas/nitrogen] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/nitrogen/belt
	icon = 'modular_bandastation/species/icons/tanks/tank.dmi'
	icon_state = "nitrogen_extended"
	worn_icon = 'modular_bandastation/species/icons/tanks/belt.dmi'
	worn_icon_state = "nitrogen_extended"
	lefthand_file = 'modular_bandastation/species/icons/tanks/tanks_lefthand.dmi'
	righthand_file = 'modular_bandastation/species/icons/tanks/tanks_righthand.dmi'
	inhand_icon_state = "nitrogen_extended"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 6
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tank/internals/nitrogen/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.moles[/datum/gas/nitrogen] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/datum/outfit/vox
	name = "Vox Basic Internals"

	mask = /obj/item/clothing/mask/breath/vox
	r_hand = /obj/item/tank/internals/nitrogen/belt/full
	internals_slot = ITEM_SLOT_HANDS
