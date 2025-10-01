/datum/preference/choiced/skrell_head_tentacle
	savefile_key = "feature_skrell_head_tentacle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Щупальца на голове"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/head_tentacle

/datum/preference/choiced/skrell_head_tentacle/init_possible_values()
	return assoc_to_keys_features(SSaccessories.skrell_head_tentacles_list)

/datum/preference/choiced/skrell_head_tentacle/icon_for(value)
	var/datum/universal_icon/head = uni_icon('icons/bandastation/mob/species/skrell/bodyparts.dmi', "skrell_head")
	head.blend_color(COLOR_TRUE_BLUE, ICON_MULTIPLY)

	var/datum/sprite_accessory/body_marking = SSaccessories.skrell_head_tentacles_list[value]
	var/datum/universal_icon/body_marking_icon = uni_icon(body_marking.icon, "m_skrell_head_tentacle_[body_marking.icon_state]_ADJ")
	body_marking_icon.blend_icon(uni_icon(body_marking.icon, "m_skrell_head_tentacle_[body_marking.icon_state]_FRONT"), ICON_OVERLAY)

	body_marking_icon.blend_color(COLOR_COMMAND_BLUE, ICON_MULTIPLY)
	head.blend_icon(body_marking_icon, ICON_OVERLAY)

	head.crop(10, 19, 22, 31)
	head.scale(32, 32)

	return head

/datum/preference/choiced/skrell_head_tentacle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SKRELL_HEAD_TENTACLE] = value

/datum/preference/choiced/skrell_head_tentacle/create_default_value()
	return pick(SSaccessories.skrell_head_tentacles_list)

/datum/preference/choiced/skrell_head_tentacle/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	return gender == MALE ? /datum/sprite_accessory/skrell_head_tentacle/male::name : /datum/sprite_accessory/skrell_head_tentacle/female::name
