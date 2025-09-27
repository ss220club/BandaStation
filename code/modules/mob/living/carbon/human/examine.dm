/// Collects information displayed about src when examined by a user with a medical HUD.
/mob/living/carbon/human/get_medhud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = ..()

	// Insurance summary for MedHUD examine
	var/datum/record/crew/rec = target_record
	if(!rec)
		var/name_for_record = get_face_name(get_id_name(""))
		rec = find_record(name_for_record)
	if(rec)
		. += "<span class='info ml-1'>Insurance: [INSURANCE_TIER_TO_TEXT(rec.insurance_current)]</span>"

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/undershirt = w_uniform
		var/sensor_text = undershirt.get_sensor_text()
		if(sensor_text)
			. += "Статус датчиков: [sensor_text]"
