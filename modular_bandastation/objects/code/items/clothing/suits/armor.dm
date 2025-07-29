// MARK: Armor //

// CentCom
/obj/item/clothing/suit/armor/centcom_formal/field
	name = "field officer's tunic"
	desc = "Строгое и надежное армированное пальто для тяжелой работы непосредственно на объектах Компании. Не пропитывается кровью."
	icon_state = "centcom_field_officer"
	inhand_icon_state = "centcom_field"

/obj/item/clothing/suit/armor/centcom_formal/officer
	name = "fleet officer's greatcoat"
	desc = "Удобный мундир для повседневного ношения."
	icon_state = "centcom_officer"

// Blueshield
/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield's armor"
	desc = "A tight-fitting kevlar-lined vest with a blue badge on the chest of it."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield_armor"
	body_parts_covered = CHEST
	unique_reskin = list(
		"Slim" = "blueshield_armor",
		"Marine" = "blueshield_marine",
		"Bulky" = "vest_black"
	)

/obj/item/clothing/suit/armor/vest/blueshield_jacket
	name = "blueshield's jacket"
	desc = "An expensive kevlar-lined jacket with a golden badge on the chest and \"NT\" emblazoned on the back. It weighs surprisingly little, despite how heavy it looks."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/armor/vest/blueshield_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// Security
/obj/item/clothing/suit/armor/vest/bomber
	name = "security bomber"
	desc = "Стильная черная куртка-бомбер, украшенная красной полосой слева. Выглядит сурово."
	icon_state = "bombersec"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/bomber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/coat
	name = "security coat"
	desc = "Пальто, усиленный специальным сплавом для защиты и стиля."
	icon_state = "secgreatcoat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/caftan
	name = "security caftan"
	desc = "Это длинный и довольно удобный наряд, плотно сидящий на плечах. Выглядит так, как будто он создан в трудные времена."
	icon_state = "seccaftan"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

// MARK: TSF
/obj/item/clothing/suit/armor/centcom_formal/tsf_commander
	name = "federate commander greatcoat"
	desc = "Мундир командующего офицера КМП ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "tsf_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/tsf_overcoat
	name = "federate overcoat"
	desc = "Стильное пальто с отличительными знаками ТСФ.\
	Неофициально считается деловой одеждой представителей Федерации."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "tsf_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/tsf_overcoat
	dog_fashion = null

/datum/armor/tsf_overcoat
	melee = 5
	bullet = 0
	laser = 10
	energy = 0
	bomb = 0
	fire = 5
	acid = 0
	wound = 0

// MARK: USSP
/obj/item/clothing/suit/armor/centcom_formal/ussp_commander
	name = "soviet general greatcoat"
	desc = "Парадная шинель генерала КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/ussp
	name = "soviet overcoat"
	desc = "Стандартная шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/ussp/officer
	name = "soviet officer overcoat"
	desc = "Офицерская шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat_officer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/ussp_officer
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/security/ussp_security
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_security"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/engineer/ussp_engineer
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_engineer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/medic/ussp_medic
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_medic"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/riot/ussp_riot
	name = "OMON armor"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_riot"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
