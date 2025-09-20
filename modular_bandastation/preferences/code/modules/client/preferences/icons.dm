/mob/living/carbon/human/dummy/regenerate_icons()
	. = ..()
	apply_height_filters(src, TRUE)

/mob/living/carbon/human/dummy/apply_height_filters(mutable_appearance/appearance, only_apply_in_prefs = FALSE)
	if(only_apply_in_prefs)
		return ..()

// Not necessary with above
/mob/living/carbon/human/dummy/apply_height_offsets(mutable_appearance/appearance, upper_torso)
	return
