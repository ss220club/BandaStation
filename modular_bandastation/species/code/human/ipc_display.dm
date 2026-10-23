/// Compatible choices are checked again when an input returns, as the head can be replaced meanwhile.
/proc/get_ipc_display_choices(head_name)
	var/list/choices = list()
	for(var/display_name in GLOB.ipc_displays)
		var/datum/sprite_accessory/ipc_display/display = GLOB.ipc_displays[display_name]
		if(isnull(display.models_allowed) || (head_name in display.models_allowed))
			choices += display_name
	return choices

/proc/get_default_ipc_display(head_name)
	var/list/choices = get_ipc_display_choices(head_name)
	if(/datum/sprite_accessory/ipc_display/ipc_screen_blue::name in choices)
		return /datum/sprite_accessory/ipc_display/ipc_screen_blue::name
	if(/datum/sprite_accessory/ipc_display/humanoid_optics::name in choices)
		return /datum/sprite_accessory/ipc_display/humanoid_optics::name
	for(var/choice in choices)
		if(choice != /datum/sprite_accessory/ipc_display/off::name)
			return choice
	return /datum/sprite_accessory/ipc_display/off::name

/// Paradise's colored displays and chassis use additive tinting, leaving black as the original palette.
/proc/ipc_additive_color(tint)
	var/list/channels = rgb2num(tint)
	return list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, channels[1] / 255,channels[2] / 255,channels[3] / 255,0)

/datum/action/innate/ipc_display
	name = "Изменить дисплей"
	desc = "Изменить изображение и цвет дисплея или оптики."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "pai_holoform"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// Prevent overlapping input windows from applying stale screen selections.
	var/customizing = FALSE

/datum/action/innate/ipc_display/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/human = owner
	return istype(human) && istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/robot/ipc)

/datum/action/innate/ipc_display/Activate()
	if(customizing || !IsAvailable())
		return
	customizing = TRUE
	customize_display()
	customizing = FALSE

/datum/action/innate/ipc_display/proc/customize_display()
	var/mob/living/carbon/human/human = owner
	var/obj/item/bodypart/head/robot/ipc/head = human.get_bodypart(BODY_ZONE_HEAD)
	var/head_model = head.ipc_head_name
	var/new_display = tgui_input_list(human, "Выберите изображение дисплея или оптики.", name, get_ipc_display_choices(head_model), head.ipc_display_name)
	if(!can_customize(human, head, head_model) || !(new_display in get_ipc_display_choices(head_model)))
		return
	var/new_color = tgui_color_picker(human, "Выберите основной цвет.", name, head.ipc_display_color)
	if(isnull(new_color) || !can_customize(human, head, head_model))
		return
	var/datum/sprite_accessory/ipc_display/display = GLOB.ipc_displays[new_display]
	var/secondary_color = head.ipc_display_color_secondary
	if(display.secondary_state)
		secondary_color = tgui_color_picker(human, "Выберите цвет переднего плана.", name, secondary_color)
		if(isnull(secondary_color) || !can_customize(human, head, head_model))
			return

	head.ipc_display_name = new_display
	head.ipc_display_color = sanitize_hexcolor(new_color, default = COLOR_BLACK)
	head.ipc_display_color_secondary = sanitize_hexcolor(secondary_color, default = COLOR_WHITE)
	human.dna.features[FEATURE_IPC_SCREEN] = new_display
	human.dna.features[FEATURE_IPC_SCREEN_COLOR] = head.ipc_display_color
	human.dna.features[FEATURE_IPC_SCREEN_COLOR_SECONDARY] = head.ipc_display_color_secondary
	human.update_body_parts()

/datum/action/innate/ipc_display/proc/can_customize(mob/living/carbon/human/human, obj/item/bodypart/head/robot/ipc/head, head_model)
	return !QDELETED(src) && !QDELETED(human) && !QDELETED(head) && owner == human && IsAvailable() && head.owner == human && human.get_bodypart(BODY_ZONE_HEAD) == head && head.ipc_head_name == head_model

/datum/species/ipc/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_IPC_CHASSIS] = /datum/ipc_chassis/morpheus::name
	human.dna.features[FEATURE_IPC_HEAD] = /datum/ipc_chassis/morpheus::name
	human.dna.features[FEATURE_IPC_SCREEN] = /datum/sprite_accessory/ipc_display/ipc_screen_blue::name
	human.dna.features[FEATURE_IPC_CHASSIS_COLOR] = COLOR_BLACK
	human.dna.features[FEATURE_IPC_SCREEN_COLOR] = COLOR_BLACK
	human.dna.features[FEATURE_IPC_SCREEN_COLOR_SECONDARY] = COLOR_WHITE
	human.dna.features[FEATURE_IPC_ANTENNA] = /datum/sprite_accessory/ipc_antenna/none::name
	human.dna.features[FEATURE_IPC_ANTENNA_COLOR] = COLOR_BLACK
	human.update_body(is_creating = TRUE)

/datum/species/ipc/randomize_features()
	var/list/features = ..()
	var/datum/preference/choiced/ipc/chassis/chassis_preference = GLOB.preference_entries[/datum/preference/choiced/ipc/chassis]
	var/chassis_name = pick(chassis_preference.get_choices())
	features[FEATURE_IPC_CHASSIS] = chassis_name
	var/datum/ipc_chassis/chassis = GLOB.ipc_chassis[chassis_name]
	features[FEATURE_IPC_HEAD] = chassis.has_head ? chassis_name : /datum/ipc_chassis/morpheus::name
	features[FEATURE_IPC_SCREEN] = get_default_ipc_display(features[FEATURE_IPC_HEAD])
	features[FEATURE_IPC_CHASSIS_COLOR] = COLOR_BLACK
	features[FEATURE_IPC_SCREEN_COLOR] = COLOR_BLACK
	features[FEATURE_IPC_SCREEN_COLOR_SECONDARY] = COLOR_WHITE
	features[FEATURE_IPC_ANTENNA] = /datum/sprite_accessory/ipc_antenna/none::name
	features[FEATURE_IPC_ANTENNA_COLOR] = COLOR_BLACK
	return features
