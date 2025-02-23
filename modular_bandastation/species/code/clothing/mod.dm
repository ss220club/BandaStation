/obj/item/mod/module/generate_worn_overlay(mutable_appearance/standing)
	. = list()
	if(!mod.active)
		return
	var/used_overlay
	if(overlay_state_use && !COOLDOWN_FINISHED(src, cooldown_timer))
		used_overlay = overlay_state_use
	else if(overlay_state_active && active)
		used_overlay = overlay_state_active
	else if(overlay_state_inactive)
		used_overlay = overlay_state_inactive
	else
		return
	var/mutable_appearance/module_icon = mutable_appearance(overlay_icon_file, used_overlay, layer = standing.layer + 0.1)
	var/mob/living/carbon/user = usr
	if(istype(user))
		var/obj/item/bodypart/head/bodypart_head = user.get_bodypart(BODY_ZONE_HEAD)
		if(bodypart_head && worn_icon_species?[bodypart_head.species_bodytype])
			module_icon = mutable_appearance(worn_icon_species[bodypart_head.species_bodytype], used_overlay, layer = standing.layer + 0.1)
	if(!use_mod_colors)
		module_icon.appearance_flags |= RESET_COLOR
	. += module_icon
