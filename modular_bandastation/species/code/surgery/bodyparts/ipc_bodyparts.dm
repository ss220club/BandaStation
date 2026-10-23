// IPC limbs keep their own appearance when transplanted, like other TG bodyparts.
// Paradise uses eleven external organs; TG combines them into six bodyparts.
#define IPC_EMP_HEAVY_LIMB_DAMAGE (64.9 / 6)
#define IPC_EMP_LIGHT_LIMB_DAMAGE (39.93 / 6)

/obj/item/bodypart/proc/update_ipc_appearance()
	var/mob/living/carbon/human/human = owner
	if(!istype(human))
		return
	var/is_head = body_zone == BODY_ZONE_HEAD
	var/feature_key = is_head ? FEATURE_IPC_HEAD : FEATURE_IPC_CHASSIS
	var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[human.dna.features[feature_key]]
	if(isnull(chassis) || (is_head && !chassis.has_head) || (!is_head && !chassis.has_body))
		chassis = GLOB.ipc_chassis[/datum/ipc_chassis/morpheus::name]
	icon_static = chassis.icon
	icon = chassis.icon
	species_color = sanitize_hexcolor(human.dna.features[FEATURE_IPC_CHASSIS_COLOR], default = COLOR_BLACK)
	return chassis.name

/obj/item/bodypart/proc/color_ipc_limb(list/limb_images)
	if(is_invisible || !species_color || species_color == COLOR_BLACK)
		return
	for(var/image/limb_image as anything in limb_images)
		if(limb_images[limb_image] & LIMB_OVERLAY_CORE)
			limb_image.color = ipc_additive_color(species_color)

/obj/item/bodypart/proc/ipc_receive_emp(severity)
	// The chassis resists the usual robotic limb paralysis; internal organs still receive EMPs.
	receive_damage(burn = severity == EMP_HEAVY ? IPC_EMP_HEAVY_LIMB_DAMAGE : IPC_EMP_LIGHT_LIMB_DAMAGE)
	do_sparks(number = 1, cardinal_only = FALSE, source = owner || src)
	return TRUE

/obj/item/bodypart/head/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1
	head_flags = HEAD_NO_DISFIGURE
	/// These values belong to the head, not to whichever mob currently wears it.
	var/ipc_head_name = /datum/ipc_chassis/morpheus::name
	var/ipc_display_name = /datum/sprite_accessory/ipc_display/ipc_screen_blue::name
	var/ipc_display_color = COLOR_BLACK
	var/ipc_display_color_secondary = COLOR_WHITE
	var/ipc_antenna_name = /datum/sprite_accessory/ipc_antenna/none::name
	var/ipc_antenna_color = COLOR_BLACK

/obj/item/bodypart/head/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	ipc_head_name = update_ipc_appearance()
	var/mob/living/carbon/human/human = owner
	ipc_display_name = sanitize_inlist(human.dna.features[FEATURE_IPC_SCREEN], get_ipc_display_choices(ipc_head_name), get_default_ipc_display(ipc_head_name))
	ipc_display_color = sanitize_hexcolor(human.dna.features[FEATURE_IPC_SCREEN_COLOR], default = COLOR_BLACK)
	ipc_display_color_secondary = sanitize_hexcolor(human.dna.features[FEATURE_IPC_SCREEN_COLOR_SECONDARY], default = COLOR_WHITE)
	ipc_antenna_name = sanitize_inlist(human.dna.features[FEATURE_IPC_ANTENNA], GLOB.ipc_antennae, /datum/sprite_accessory/ipc_antenna/none::name)
	ipc_antenna_color = sanitize_hexcolor(human.dna.features[FEATURE_IPC_ANTENNA_COLOR], default = COLOR_BLACK)

/obj/item/bodypart/head/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color
	. += list(ipc_head_name, ipc_display_name, ipc_display_color, ipc_display_color_secondary, ipc_antenna_name, ipc_antenna_color)
	. += "[!isnull(owner) && owner.stat != DEAD]"
	. += "[owner?.obscured_slots & HIDEHAIR]"

/obj/item/bodypart/head/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)
	if(is_invisible || (owner?.obscured_slots & HIDEHAIR))
		return
	var/image_dir = dropped ? SOUTH : null
	var/datum/sprite_accessory/ipc_antenna/antenna = GLOB.ipc_antennae[ipc_antenna_name]
	if(antenna && antenna.icon_state != SPRITE_ACCESSORY_NONE)
		var/image/antenna_image = image(antenna.icon, antenna.icon_state, layer = -HAIR_LAYER, dir = image_dir)
		antenna_image.color = ipc_additive_color(ipc_antenna_color)
		if(!dropped)
			owner?.apply_height(antenna_image, UPPER_BODY)
		.[antenna_image] = NONE
	if(!owner || owner.stat == DEAD)
		return
	var/datum/sprite_accessory/ipc_display/display = GLOB.ipc_displays[ipc_display_name]
	if(isnull(display) || display.icon_state == SPRITE_ACCESSORY_NONE)
		return
	var/image/screen_image = image(display.icon, display.icon_state, layer = -BODY_ADJ_LAYER, dir = image_dir)
	screen_image.color = ipc_additive_color(ipc_display_color)
	if(!dropped)
		owner.apply_height(screen_image, UPPER_BODY)
	.[screen_image] = NONE
	if(display.secondary_state)
		var/image/foreground = image(display.icon, display.secondary_state, layer = -BODY_ADJ_LAYER, dir = image_dir)
		foreground.color = list(null, null, null, null, ipc_display_color_secondary)
		if(!dropped)
			owner.apply_height(foreground, UPPER_BODY)
		.[foreground] = NONE

/obj/item/bodypart/head/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/chest/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/chest/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	update_ipc_appearance()

/obj/item/bodypart/chest/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color

/obj/item/bodypart/chest/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)

/obj/item/bodypart/chest/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/arm/left/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/arm/left/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	update_ipc_appearance()

/obj/item/bodypart/arm/left/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color

/obj/item/bodypart/arm/left/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)

/obj/item/bodypart/arm/left/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/arm/right/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/arm/right/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	update_ipc_appearance()

/obj/item/bodypart/arm/right/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color

/obj/item/bodypart/arm/right/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)

/obj/item/bodypart/arm/right/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/leg/left/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/left/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	update_ipc_appearance()

/obj/item/bodypart/leg/left/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color

/obj/item/bodypart/leg/left/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)

/obj/item/bodypart/leg/left/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/leg/right/robot/ipc
	limb_id = SPECIES_IPC
	change_exempt_flags = NONE
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	icon_static = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/right/robot/ipc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	if(!.)
		return
	update_ipc_appearance()

/obj/item/bodypart/leg/right/robot/ipc/generate_icon_key()
	. = ..()
	. += species_color

/obj/item/bodypart/leg/right/robot/ipc/get_limb_icon(dropped)
	. = ..()
	color_ipc_limb(.)

/obj/item/bodypart/leg/right/robot/ipc/emp_effect(severity, protection)
	return ipc_receive_emp(severity)

/obj/item/bodypart/chest/robot/ipc/check_limbs()
	SIGNAL_HANDLER
	// Ordinary augmented humans get thermal immunity here. IPCs use their species' thermal limits.
	return

#undef IPC_EMP_HEAVY_LIMB_DAMAGE
#undef IPC_EMP_LIGHT_LIMB_DAMAGE
