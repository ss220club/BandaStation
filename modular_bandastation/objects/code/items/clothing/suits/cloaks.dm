// MARK: Cloaks //

// Roboticist
/obj/item/clothing/suit/hooded/roboticist_cloak
	name = "roboticist's coat"
	desc = "Стильный плащ с принтом головы борга на спине. Идеален для тех, кто хочет выделиться и показать свою любовь к робототехнике. На бирке указано: 'Flameholdeir Industries'. Бережно обращайтесь с боргами, пока они не сделали из вас лампочку!"
	icon_state = "robotics_coat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/neck.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/neck.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/roboticist_cloak

/obj/item/clothing/head/hooded/roboticist_cloak
	name = "roboticist's hood"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hood.dmi'
	icon_state = "robotics_hood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

// CentCom
/obj/item/clothing/neck/cloak/centcom
	name = "fleet officer's armor cloak"
	desc = "Свободная накидка из дюраткани, укрепленной пластитановой нитью. Сочетает в себе два основных качества \
	офицерского убранства - пафос и защиту. Старые плащи этой линейки зачастую дарятся капитанам объектов Компании."
	icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/obj/clothing/cloaks/cloaks.dmi'
	worn_icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/mob/clothing/cloaks/cloaks.dmi'
	icon_state = "centcom"
	armor_type = /datum/armor/armor_centcom_cloak
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | FREEZE_PROOF | UNACIDABLE | ACID_PROOF

/datum/armor/armor_centcom_cloak
	melee = 80
	bullet = 80
	laser = 80
	energy = 60
	wound = 30

/obj/item/clothing/neck/cloak/centcom/officer
	name = "fleet officer's official cloak"
	desc = "Свободная накидка из дюраткани, укрепленной пластитановой нитью. Сочетает в себе два основных качества \
	офицерского убранства - пафос и защиту. Эта шитая золотом линейка плащей подходит для официальных встреч."
	icon_state = "centcom_officer"

/obj/item/clothing/neck/cloak/centcom/official
	name = "fleet officer's parade cloak"
	desc = "Свободная накидка из дюраткани, укрепленной пластитановой нитью. Лёгкое и изящное на первый взгляд, \
	это одеяние покрывает своего владельца надежной защитой. Подобные плащи не входят в какую-либо линейку и шьются исключительно на заказ под определенного офицера."
	icon_state = "centcom_official"

/obj/item/clothing/neck/cloak/centcom/admiral
	name = "fleet officer's luxurious cloak"
	desc = "Свободная накидка из дюраткани, укрепленной пластитановой нитью. Сочетает в себе два основных качества \
	офицерского убранства - пафос и защиту. Линейка этих дорогих плащей встречается у крайне состоятельных членов старшего офицерского состава."
	icon_state = "centcom_admiral"

// Blueshield
/obj/item/clothing/neck/cloak/blueshield
	name = "blueshield's cloak"
	desc = "A cloak fit for only the best of bodyguards."
	icon = 'modular_bandastation/objects/icons/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/cloaks.dmi'
	icon_state = "blueshield_cloak"

/obj/item/clothing/neck/cloak/armor/captain/black
	name = "black captain cloak"
	desc = "Носится верховным лидером станции."
	icon = 'modular_bandastation/objects/icons/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/cloaks.dmi'
	icon_state = "capcloak_black"
	worn_icon_state = "capcloak_black"

/obj/item/clothing/neck/cloak/armor/captain/black/Initialize(mapload)
	. = ..()
	desc = "Носится верховным лидером станции [station_name()]."

/obj/item/clothing/neck/cloak/deathsquad/officer/field/cloak_nt
	name = "armored cloak of nanotrassen navy officer"
	desc = "Один из вариантов торжественного одеяния сотрудников Верховного Командования Нанотрейзен, подойдет для официальной встречи или важного вылета. Сшита из лёгкой и сверхпрочной ткани."
	icon = 'modular_bandastation/objects/icons/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/cloaks.dmi'
	icon_state = "ntsc_cloak"

/obj/item/clothing/neck/cloak/deathsquad/officer/field/cloak_nt/coat_nt
	name = "cloak of field nanotrassen navy officer"
	desc = "Парадный плащ нового образца, внедряемый на объектах компании в последнее время. Отличительной чертой является стоячий воротник и резаный подол. Невысокие показатели защиты нивелируются пафосом, источаемым этим плащом."
	icon_state = "ntsc_coat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/cloaks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/cloaks.dmi'

// Skrell Emperor Guard
/obj/item/clothing/neck/cloak/emperor_guard
	name = "emperor guards's mantle"
	desc = "Кроваво-белый плащ Клинков Императора."
	icon = 'modular_bandastation/objects/icons/obj/clothing/neck.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/neck.dmi'
	icon_state = "emperor_guard_manlte"

// Grayscale cloak
/obj/item/clothing/neck/cloak/colorable_cloak
	name = "cloak"
	desc = "Обычный тканевый плащ."
	icon = 'icons/map_icons/clothing/neck.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/neck.dmi'
	icon_state = "/obj/item/clothing/neck/cloak/colorable_cloak"
	post_init_icon_state = "color_cloak"
	greyscale_colors = COLOR_PRISONER_BLACK
	greyscale_config = /datum/greyscale_config/colorable_cloak
	greyscale_config_worn = /datum/greyscale_config/colorable_cloak/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/datum/greyscale_config/colorable_cloak
	name = "Cloak"
	icon_file = 'modular_bandastation/objects/icons/obj/clothing/neck.dmi'
	json_config = 'code/datums/greyscale/json_configs/bandastation/cloak.json'

/datum/greyscale_config/colorable_cloak/worn
	name = "Cloak (Worn)"
	icon_file = 'modular_bandastation/objects/icons/mob/clothing/neck.dmi'

// Fancy cloak
/obj/item/clothing/neck/cloak/fancy_cloak
	name = "fancy cloak"
	desc = "Роскошный шелковистый плащ с золотистой вышивкой и застёжкой, украшенной потускневшим драгоценным камнем.\
	Настоящий антиквариат."
	icon = 'modular_bandastation/objects/icons/obj/clothing/neck.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/neck.dmi'
	icon_state = "fancy_cloak"
