/// A fabricated chassis has no personality or free components; it is assembled like Paradise's empty IPC frame.
/mob/living/carbon/human/species/ipc_chassis
	name = "шасси КПБ"
	race = /datum/species/ipc
	use_random_name = FALSE

/mob/living/carbon/human/species/ipc_chassis/Initialize(mapload)
	. = ..()
	fully_replace_character_name(newname = "Шасси КПБ ([rand(1, 9999)])")
	for(var/obj/item/organ/organ as anything in organs.Copy())
		organ.Remove(src, special = TRUE)
		qdel(organ)
	for(var/obj/item/bodypart/limb as anything in get_bodyparts())
		if(limb.body_zone == BODY_ZONE_CHEST)
			continue
		// Ordinary removal leaves robotic stumps for the normal prosthetic-replacement operation.
		limb.drop_limb()
		qdel(limb)
	set_nutrition(0, forced = TRUE)
	death()

// Fabricated components carry the same materials as their research designs.
/obj/item/bodypart/head/robot/ipc
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2.5)

/obj/item/organ/heart/ipc
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.375)

/obj/item/organ/cyberimp/arm/power_cord/ipc
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5)

/datum/design/ipc_head
	name = "IPC Head"
	desc = "A replacement IPC head. Sensors and speech hardware are installed separately."
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot/ipc
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2.5)
	construction_time = 35 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)
	research_icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	research_icon_state = "ipc_head"

/datum/design/ipc_chassis
	name = "IPC Chassis"
	desc = "An empty IPC torso. Requires limbs, internal components and an existing positronic brain."
	build_type = MECHFAB
	build_path = /mob/living/carbon/human/species/ipc_chassis
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 20, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3.5)
	construction_time = 40 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)
	research_icon = 'icons/mob/augmentation/augments.dmi'
	research_icon_state = "robo_suit"
	inherit_materials = DESIGN_DONT_INHERIT_MATS

/datum/design/ipc_microbattery
	name = "IPC Microbattery"
	build_type = MECHFAB
	build_path = /obj/item/organ/heart/ipc
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.375)
	construction_time = 20 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_COMPONENTS)

/datum/design/ipc_power_cord
	name = "IPC Power Adapter"
	build_type = MECHFAB
	build_path = /obj/item/organ/cyberimp/arm/power_cord/ipc
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5)
	construction_time = 20 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_COMPONENTS)

/datum/design/ipc_nanopaste
	name = "Nanopaste"
	desc = "A six-dose tube for IPC decontamination. Removes irradiation without repairing existing damage."
	build_type = MECHFAB
	build_path = /obj/item/stack/nanopaste
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.5)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_COMPONENTS)

/// Robotics prints a complete tube rather than the single dose produced by ordinary stack designs.
/datum/design/ipc_nanopaste/create_result(atom/drop_loc, list/custom_materials, amount)
	if(isnull(amount))
		amount = /obj/item/stack/nanopaste::amount
	return ..(drop_loc, custom_materials, amount)
