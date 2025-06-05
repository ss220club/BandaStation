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
	special = TRUE
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
