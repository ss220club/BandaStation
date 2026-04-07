/obj/item/bodypart/chest/ipc
	name = "ipc chassis"
	desc = "Основной корпус КПБ, содержащий все жизненно важные системы."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_chest_m"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	is_dimorphic = TRUE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 120

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0


/obj/item/bodypart/chest/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)


/obj/item/bodypart/head/ipc
	name = "ipc head"
	desc = "Голова КПБ с оптическими и аудио-сенсорами."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_head"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	head_flags = HEAD_LIPS|HEAD_DEBRAIN
	is_dimorphic = FALSE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 80

	var/screen_icon = "BSOD"
	var/antenna_type = "None"
	var/brute_reduction = 0
	var/burn_reduction = 0

	/// для get_limb_icon() вместо стандартного body_zone.
	/// null = использует "ipc_head" (стандарт).
	/// "monitor" = использует "ipc_monitor" (голова-монитор с экраном).
	var/ipc_visual_state = null

/obj/item/bodypart/head/ipc/generate_icon_key()
	. = ..()
	if(ipc_visual_state)
		. += "-[ipc_visual_state]"

/obj/item/bodypart/head/ipc/get_limb_icon(dropped, mob/living/carbon/update_on)
	if(isnull(ipc_visual_state))
		return ..()
	var/old_body_zone = body_zone
	body_zone = ipc_visual_state
	. = ..()
	body_zone = old_body_zone


/obj/item/bodypart/head/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

/obj/item/bodypart/head/ipc/monitor
	name = "ipc head-monitor"
	desc = "Голова-монитор КПБ с встроенным дисплеем вместо лица."
	ipc_visual_state = "monitor"


/obj/item/bodypart/arm/left/ipc
	name = "ipc left arm"
	desc = "Левая рука КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 70

	var/grip_strength = 1.0
	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0


/obj/item/bodypart/arm/right/ipc
	name = "ipc right arm"
	desc = "Правая рука КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 70

	var/grip_strength = 1.0
	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0



/obj/item/bodypart/leg/left/ipc
	name = "ipc left leg"
	desc = "Левая нога КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 70

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0




/obj/item/bodypart/leg/right/ipc
	name = "ipc right leg"
	desc = "Правая нога КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_ROBOTIC
	max_damage = 70

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

// ПРИСОЕДИНЕНИЕ КОНЕЧНОСТЕЙ


/obj/item/bodypart/chest/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
	icon_state = "ipc_chest_[gender_suffix]"
	return TRUE

/obj/item/bodypart/head/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE
