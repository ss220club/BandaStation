// Аутфит с протезами Strongarm
// Основан на /datum/outfit/centcom/commander/field

/datum/outfit/centcom/commander/field/strongarm
	name = "Nanotrasen Navy Field Officer (Strongarm)"

	// Добавляем протезы обеих рук через post_equip
/datum/outfit/centcom/commander/field/strongarm/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()

	if(visuals_only)
		return

	// Удаляем существующие руки и заменяем на протезы Strongarm
	var/obj/item/bodypart/arm/left/robot/strongarm/left_arm = new()
	var/obj/item/bodypart/arm/right/robot/strongarm/right_arm = new()

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

	to_chat(H, span_notice("Ваши боевые протезы 'Strongarm' активированы и готовы к использованию."))
