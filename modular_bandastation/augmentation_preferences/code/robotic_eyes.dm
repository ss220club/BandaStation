/// Roundstart augments retain the selected eye colors and Paradise's unblurred eye shine.
/obj/item/organ/eyes/robotic/basic/augmented
	eye_color_left = null
	eye_color_right = null
	eye_icon = 'modular_bandastation/augmentation_preferences/icons/human_face.dmi'
	eye_icon_state = "eyes_glow_gs"
	iris_overlay = "eyes_cyber_glow_iris"
	organ_traits = list(TRAIT_LUMINESCENT_EYES)

/obj/item/organ/eyes/robotic/basic/augmented/get_emissive_overlays(mutable_appearance/eye_left, mutable_appearance/eye_right, atom/spokesman)
	return list(
		emissive_appearance(eye_left.icon, eye_left.icon_state, spokesman, -EYES_LAYER, alpha = eye_left.alpha, effect_type = EMISSIVE_NO_BLOOM),
		emissive_appearance(eye_right.icon, eye_right.icon_state, spokesman, -EYES_LAYER, alpha = eye_right.alpha, effect_type = EMISSIVE_NO_BLOOM),
	)
