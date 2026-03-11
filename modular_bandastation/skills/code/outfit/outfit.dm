// Аутфит с протезами Strongarm
// Основан на /datum/outfit/centcom/commander/field

/datum/outfit/centcom/commander/field/strongarm
	name = "Apex Nanotrasen Navy Field Officer"

	// Добавляем протезы обеих рук через post_equip
/datum/outfit/centcom/commander/field/strongarm/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()

	if(visuals_only)
		return

	// Удаляем существующие руки и заменяем на протезы Strongarm
	var/obj/item/bodypart/arm/left/strongarm/left_arm = new()
	var/obj/item/bodypart/arm/right/strongarm/right_arm = new()
	var/obj/item/bodypart/leg/left/strongleg/left_leg = new()
	var/obj/item/bodypart/leg/right/strongleg/right_leg = new()

	// Заменяем левую руку
	var/obj/item/bodypart/old_left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(old_left_arm)
		old_left_arm.drop_limb(special = TRUE)
		qdel(old_left_arm)
	left_arm.replace_limb(H, TRUE)

	// Заменяем правую руку
	var/obj/item/bodypart/old_right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(old_right_arm)
		old_right_arm.drop_limb(special = TRUE)
		qdel(old_right_arm)
	right_arm.replace_limb(H, TRUE)

	// Заменяем левую ногу
	var/obj/item/bodypart/old_left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	if(old_left_leg)
		old_left_leg.drop_limb(special = TRUE)
		qdel(old_left_leg)
	left_leg.replace_limb(H, TRUE)

	// Заменяем правую ногу
	var/obj/item/bodypart/old_right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(old_right_leg)
		old_right_leg.drop_limb(special = TRUE)
		qdel(old_right_leg)
	right_leg.replace_limb(H, TRUE)

	to_chat(H, span_notice("Ваши боевые протезы 'Strongarm' активированы и готовы к использованию."))
