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
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/amor.dmi'
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
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/amor.dmi'
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
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/amor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/bomber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/coat
	name = "security coat"
	desc = "Пальто, усиленный специальным сплавом для защиты и стиля."
	icon_state = "secgreatcoat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/amor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/caftan
	name = "security caftan"
	desc = "Это длинный и довольно удобный наряд, плотно сидящий на плечах. Выглядит так, как будто он создан в трудные времена."
	icon_state = "seccaftan"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/amor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
