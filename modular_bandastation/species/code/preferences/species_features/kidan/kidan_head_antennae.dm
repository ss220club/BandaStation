/datum/preference/choiced/species_feature/kidan_antennae
	savefile_key = "feature_kidan_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Усики"
	should_generate_icons = TRUE
	relevant_organ = /obj/item/organ/antennae/kidan

/datum/preference/choiced/species_feature/kidan_antennae/icon_for(value)
	var/static/datum/universal_icon/kidan_head

	if (isnull(kidan_head))
		kidan_head = uni_icon('icons/bandastation/mob/species/kidan/bodyparts.dmi', "kidan_head")
		kidan_head.blend_icon(uni_icon(/obj/item/organ/eyes/kidan::eye_icon,"[/obj/item/organ/eyes/kidan::eye_icon_state]_l"),ICON_OVERLAY)
		kidan_head.blend_icon(uni_icon(/obj/item/organ/eyes/kidan::eye_icon,"[/obj/item/organ/eyes/kidan::eye_icon_state]_r"),ICON_OVERLAY)

	var/datum/sprite_accessory/A = get_accessory_for_value(value)

	var/datum/universal_icon/icon_with_antennae = kidan_head.copy()
	icon_with_antennae.blend_icon(uni_icon(A.icon,"m_kidan_antennae_[A.icon_state]_FRONT"),ICON_OVERLAY)
	icon_with_antennae.scale(32, 32)
	icon_with_antennae.crop(15, 32 - 31, 15 + 31, 32)

	return icon_with_antennae
