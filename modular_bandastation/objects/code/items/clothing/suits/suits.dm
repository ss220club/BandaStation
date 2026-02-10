/obj/item/clothing/suit/hooded/shark_costume
	name = "shark costume"
	desc = "Костюм из 'синтетической' кожи акулы, пахнет."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "shark_casual"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	hood_up_affix = ""
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/shark_hood_par

/obj/item/clothing/head/hooded/shark_hood_par
	name = "shark hood"
	desc = "Капюшон, прикрепленный к костюму акулы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hood.dmi'
	icon_state = "shark_casual"

	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEEARS | HIDEHAIR

/obj/item/clothing/suit/hooded/shark_costume/light
	name = "light shark costume"
	icon_state = "shark_casual_light"
	hoodtype = /obj/item/clothing/head/hooded/shark_hood_par/light_par

/obj/item/clothing/head/hooded/shark_hood_par/light_par
	name = "light shark hood"
	icon_state = "shark_casual_light"

/obj/item/clothing/suit/space/deathsquad/officer/syndie
	name = "syndicate officer jacket"
	desc = "Длинная куртка из высокопрочного волокна."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "jacket_syndie"
	flags_inv = HIDEGLOVES | HIDEJUMPSUIT
	slowdown = 0

/obj/item/clothing/suit/space/deathsquad/officer/field
	name = "field fleet officer's jacket"
	desc = "Парадный плащ, разработанный в качестве массового варианта формы Верховного Главнокомандующего. У этой униформы нет тех же защитных свойств, что и у оригинала, но она все ещё является довольно удобным и стильным предметом гардероба."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "ntsc_uniform"

/datum/supply_pack/misc/soundhand_fan
	name = "Soundhand Fan Crate"
	desc = "Содержит фанатские куртки группы Саундхэнд"
	cost = CARGO_CRATE_VALUE * 30
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_SERVICE
	contains = list(
		/obj/item/clothing/suit/soundhand_black_jacket,
		/obj/item/clothing/suit/soundhand_black_jacket,
		/obj/item/clothing/suit/soundhand_olive_jacket,
		/obj/item/clothing/suit/soundhand_olive_jacket,
		/obj/item/clothing/suit/soundhand_brown_jacket,
		/obj/item/clothing/suit/soundhand_brown_jacket,
		/obj/item/clothing/suit/soundhand_white_jacket)
	crate_name = "soundhand Fan crate"

/obj/item/clothing/suit/chef/red
	name = "chef's red apron"
	desc = "Хорошо скроенный поварской китель."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "chef_red"

/* Space Battle */
/obj/item/clothing/suit/space/hardsuit/security
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "hardsuit-sec-old"

// MARK: TSF
/obj/item/clothing/suit/tsf_suitjacket
	name = "federate suit-jacket"
	desc = "Дорогая куртка прямиком из Центральных Миров. Имеет отличительные знаки ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "tsf_suit_jacket"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	worn_icon_state = "tsf_suit_jacket"
	body_parts_covered = CHEST | GROIN | ARMS

// MARK: Etamin ind.
/obj/item/clothing/suit/etamin_coat
	name = "Etamin Ind. officer coat"
	desc = "Этот плащ был создан специально для офицеров корпорации Etamin Industries. Если вы видите его на ком-то, то либо перед вами офицер корпорации, либо тот, кто отдал бешеные бабки за этот плащ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "ei_coat"
	body_parts_covered = CHEST | GROIN | ARMS

// MARK: USSP
/obj/item/clothing/suit/space/ussp_expedition
	name = "'Voskhod' EVA suit"
	desc = "Экспедиционный скафандр \"Восход\", создан для использования в космических экспедицях СССП. \
		Имеет небольшое бронепокрытие для обеспечения защиты в потенциально враждебных сценариях."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "voskhod_suit"
	armor_type = /datum/armor/suit_armor

// MARK: MB Coat
/obj/item/clothing/suit/mb_coat
	name = "elegant coat"
	desc = "Элегантное пальто. Популярно среди тех, кто ценит минимализм и стиль."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "mb_coat"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	body_parts_covered = CHEST | GROIN | ARMS

// MARK: Port NovaSector
// Security
/obj/item/clothing/under/security/alt_skirt
	name = "security alternative skirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "security_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

/obj/item/clothing/under/security/formal
	name = "security formal uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "formal"
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

/obj/item/clothing/under/security/black
	name = "security black uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "security_black"
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

/obj/item/clothing/under/security/turtleneck
	name = "security turtleneck"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "secturtleneck"
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

/obj/item/clothing/under/security/alternative_black
	name = "security alternative black uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "warden_black"
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

// Blueshield
/obj/item/clothing/under/blueshield/skirt/blue
	name = "blueshield's blue skirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/blueshield.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/blueshield.dmi'
	icon_state = "plain_skirt_blue"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_blueshield

/obj/item/clothing/under/blueshield/skirt/black
	name = "blueshield's black skirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/blueshield.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/blueshield.dmi'
	icon_state = "plain_skirt_black"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_blueshield

// Warden
/obj/item/clothing/under/rank/security/warden/alt_skirt/blue
	name = "warden's alternative blue skirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "security_skirt_blue"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

/obj/item/clothing/under/rank/security/warden/formal_blue
	name = "warden's formal blue uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/security.dmi'
	icon_state = "formal_blue"
	inhand_icon_state = null
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/rank_security

// Engineering
/obj/item/clothing/under/engineering/telecomm
	name = "engineering alternative jumpsuit"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/engineering.dmi'
	icon_state = "telecomm"
	can_adjust = TRUE

/obj/item/clothing/under/engineering/telecomm/skirt
	name = "engineering alternative jumpskirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/engineering.dmi'
	icon_state = "telecomm_skirt"
	can_adjust = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/engineering/mechanic
	name = "mechanic uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/engineering.dmi'
	icon_state = "engineering_guard_uniform"

// Research
/obj/item/clothing/under/scientist/utility
	name = "science utility uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/rnd.dmi'
	icon_state = "util_sci"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

// Medical
/obj/item/clothing/under/medical/paramed_light
	name = "light paramedic uniform"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/medical.dmi'
	icon_state = "paramedic_light"

/obj/item/clothing/under/medical/paramed_light/skirt
	name = "light paramedic skirt"
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/medical.dmi'
	icon_state = "paramedic_light_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
