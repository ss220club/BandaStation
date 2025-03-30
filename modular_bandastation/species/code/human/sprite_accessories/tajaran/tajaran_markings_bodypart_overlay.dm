// MARK: Tajaran body
/datum/bodypart_overlay/simple/body_marking/tajaran
	dna_feature_key = "tajaran_body_markings"
	applies_to = list(
		/obj/item/bodypart/chest/tajaran,
		/obj/item/bodypart/arm/left/tajaran,
		/obj/item/bodypart/arm/right/tajaran,
		/obj/item/bodypart/leg/left/digitigrade/tajaran,
		/obj/item/bodypart/leg/right/digitigrade/tajaran
	)
	var/aux_color_paw = null

/datum/bodypart_overlay/simple/body_marking/tajaran/get_accessory(name)
	return SSaccessories.tajaran_body_markings_list[name]

/datum/bodypart_overlay/simple/body_marking/tajaran/modify_bodypart_appearance(datum/appearance)
	var/image/a = appearance
	if(a.appearance_flags == 0 && aux_color_paw && (a.icon_state == "tajaran_l_hand" || a.icon_state == "tajaran_r_hand"))
		a.color = aux_color_paw

/datum/bodypart_overlay/simple/body_marking/tajaran/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_BEHIND)
			return -BODY_BEHIND_LAYER
		if(EXTERNAL_ADJACENT)
			return -BODYPARTS_LAYER
		if(EXTERNAL_FRONT)
			return -BODY_FRONT_LAYER
		if(1 << 3)
			return -BODYPARTS_HIGH_LAYER
