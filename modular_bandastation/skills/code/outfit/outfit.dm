/datum/outfit/centcom/commander/field/apex
	name = "Apex Nanotrasen Navy Field Officer"
	suit = null
	mask = null
	belt = /obj/item/storage/belt/holster/ert/full_gp9r
	l_pocket = null
	head = /obj/item/clothing/head/helmet/space/beret/soo
	neck = /obj/item/clothing/neck/cloak/centcom/gr_cape
	uniform = /obj/item/clothing/under/rank/centcom/gr_under
	gloves = /obj/item/clothing/gloves/combat
	backpack_contents = list(
		/obj/item/storage/box/survival/centcom,
		/obj/item/stamp/centcom,
		/obj/item/door_remote/omni,
		/obj/item/flashlight/seclite,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/reagent_containers/hypospray/combat,
		/obj/item/reagent_containers/spray/cleaner
	)
	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/freedom,
		/obj/item/implant/empprotection
	)

/datum/outfit/centcom/commander/field/apex/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()

	if(visuals_only)
		return
	H.maxHealth = 150

	// skills
	var/datum/action/cooldown/spell/dodge_mode/dodge = new()
	dodge.Grant(H)

	// limbs
	var/obj/item/bodypart/arm/left/strongarm/left_arm = new()
	var/obj/item/bodypart/arm/right/strongarm/right_arm = new()
	var/obj/item/bodypart/leg/left/strongleg/left_leg = new()
	var/obj/item/bodypart/leg/right/strongleg/right_leg = new()

	var/obj/item/bodypart/old_left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(old_left_arm)
		old_left_arm.drop_limb(special = TRUE)
		qdel(old_left_arm)
	left_arm.replace_limb(H, TRUE)

	var/obj/item/bodypart/old_right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(old_right_arm)
		old_right_arm.drop_limb(special = TRUE)
		qdel(old_right_arm)
	right_arm.replace_limb(H, TRUE)

	var/obj/item/bodypart/old_left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	if(old_left_leg)
		old_left_leg.drop_limb(special = TRUE)
		qdel(old_left_leg)
	left_leg.replace_limb(H, TRUE)

	var/obj/item/bodypart/old_right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(old_right_leg)
		old_right_leg.drop_limb(special = TRUE)
		qdel(old_right_leg)
	right_leg.replace_limb(H, TRUE)

	// cyberimps
	var/obj/item/organ/cyberimp/chest/pump/centcom/pump = new()
	pump.Insert(H, special = TRUE)

	var/obj/item/organ/cyberimp/eyes/hud/security/shielded/hud_eyes = new()
	hud_eyes.Insert(H, special = TRUE)

	var/obj/item/organ/cyberimp/chest/reviver/reviver = new()
	reviver.Insert(H, special = TRUE)

	var/obj/item/organ/cyberimp/brain/anti_stun/anti_stun = new()
	anti_stun.Insert(H, special = TRUE)
