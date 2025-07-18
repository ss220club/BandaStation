// MARK: CentCom
/obj/item/clothing/glasses/hud/security/sunglasses/soo
	name = "special ops officer's HUDSunglasses"
	desc = "Продвинутый ИЛС-визор, стилизованный под солнцезащитные очки. Никто не укроется."
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS

/obj/item/clothing/glasses/hud/security/sunglasses/centcom_officer
	name = "fleet officer's HUDSunglasses"
	desc = "Продвинутый ИЛС-визор, стилизованный под солнцезащитные очки. Почти никто не укроется."
	vision_flags = SEE_MOBS

// MARK: TSF
/obj/item/clothing/glasses/hud/security/sunglasses/tsf
	name = "HUDSunglasses"
	icon_state = "sunhudmed"

/obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	clothing_traits = list(TRAIT_SECURITY_HUD)
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
