/datum/bodypart_overlay/simple/body_marking/vulpkanin
	dna_feature_key = "vulpkanin_body_markings"
	applies_to = list(/obj/item/bodypart/chest/vulpkanin, /obj/item/bodypart/arm/left/vulpkanin, /obj/item/bodypart/arm/right/vulpkanin, /obj/item/bodypart/leg/left/vulpkanin, /obj/item/bodypart/leg/right/vulpkanin)
	var/aux_color_paw = null

/datum/bodypart_overlay/simple/body_marking/vulpkanin/get_accessory(name)
	return SSaccessories.vulpkanin_body_markings_list[name]

/datum/bodypart_overlay/simple/body_marking/vulpkanin/modify_bodypart_appearance(datum/appearance)
	var/image/a = appearance
	if(a.appearance_flags == 0 && aux_color_paw && (a.icon_state == "vulpkanin_l_hand" || a.icon_state == "vulpkanin_r_hand"))
		a.color = aux_color_paw
