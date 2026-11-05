// MARK: USSP
/obj/item/clothing/under/rank/ussp
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/ussp.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/ussp.dmi'
	armor_type = /datum/armor/clothing_under/centcom_military

/obj/item/clothing/under/rank/ussp/commander
	name = "soviet general uniform"
	desc = "Униформа высшего командного состава СССП."
	icon_state = "ussp_commander"
	can_adjust = FALSE

/obj/item/clothing/under/rank/ussp/official
	name = "soviet official uniform"
	desc = "Униформа официальных лиц СССП высоких рангов."
	icon_state = "ussp_official"
	can_adjust = FALSE

/obj/item/clothing/under/rank/ussp/soldier
	name = "soviet ryadovoy uniform"
	desc = "Униформа бойца КА СССП."
	icon_state = "ussp_soldier"

/obj/item/clothing/under/rank/ussp/militsiya
	name = "soviet militsiya uniform"
	desc = "Униформа милиционера КА СССП."
	icon_state = "ussp_militsiya"

/obj/item/clothing/under/rank/ussp/officer
	name = "soviet officer uniform"
	desc = "Униформа офицера КА СССП."
	icon_state = "ussp_officer"

/obj/item/clothing/under/rank/ussp/spetsnaz
	name = "SPETSNAZ uniform"
	desc = "Униформа спецназа ГРУ СССП."
	icon_state = "ussp_spetsnaz"
	can_adjust = FALSE

/// Classic USSP appearances retain native clothing behavior and protection.
/obj/item/clothing/under/costume/soviet/ussp
	name = "\improper USSP military uniform"
	desc = "Классическая военная форма КССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/ussp.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/ussp.dmi'
	icon_state = "soviet"
	inhand_icon_state = "g_suit"
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/soviet/ussp/officer
	name = "\improper USSP officer uniform"
	desc = "Классическая форма офицера КССП."
	icon_state = "sovietofficer"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/costume/soviet/ussp/admiral
	name = "\improper USSP admiral uniform"
	desc = "Классическая парадная форма адмирала КССП."
	icon_state = "sovietadmiral"
	inhand_icon_state = "w_suit"
