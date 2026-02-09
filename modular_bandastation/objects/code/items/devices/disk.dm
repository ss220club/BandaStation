/obj/item/concert_disk
	name = "music disk"
	desc = "Диск с концертными записями."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "tape_greyscale"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/album_id
	var/color_disk = "FFFFFF"

/obj/item/concert_disk/Initialize(mapload)
	. = ..()
	add_atom_colour("#[color_disk]", FIXED_COLOUR_PRIORITY)

/obj/item/concert_disk/soundhand_01
	name = "Soundhand Anumati"
	album_id = "soundhand_01"
	color_disk = "FFFFFF"

/obj/item/concert_disk/soundhand_02
	name = "Soundhand E-Guitar Blues"
	album_id = "soundhand_02"
	color_disk = "C0392B"

/obj/item/concert_disk/soundhand_03
	name = "Soundhand Mountain Wind"
	album_id = "soundhand_03"
	color_disk = "E67E22"

/obj/item/concert_disk/soundhand_04
	name = "Soundhand Thunderstep"
	album_id = "soundhand_04"
	color_disk = "F1C40F"

/obj/item/concert_disk/soundhand_05
	name = "Soundhand Dream of the Sky"
	album_id = "soundhand_05"
	color_disk = "2ECC71"

/obj/item/concert_disk/soundhand_06
	name = "Soundhand Midnight Carnival"
	album_id = "soundhand_06"
	color_disk = "1ABC9C"

/obj/item/concert_disk/soundhand_07
	name = "Soundhand Ignition"
	album_id = "soundhand_07"
	color_disk = "3498DB"

/obj/item/concert_disk/soundhand_08
	name = "Soundhand Desctruction"
	album_id = "soundhand_08"
	color_disk = "9B59B6"

/obj/item/concert_disk/soundhand_09
	name = "Soundhand Liberty"
	album_id = "soundhand_09"
	color_disk = "2C3E50"

/obj/item/concert_disk/soundhand_10
	name = "Soundhand Tajaran Moment"
	album_id = "soundhand_10"
	color_disk = "314FD2"

/datum/supply_pack/goody/soundhand_disks
	access = NONE
	group = "Imports"
	cost = CARGO_CRATE_VALUE * 5
	crate_name = "Диски Саундхенд"
	crate_type = /obj/structure/closet/crate
	discountable = SUPPLY_PACK_NOT_DISCOUNTABLE
	name = "Диски Саундхенд"
	desc = "Контейнер содержит все диски группы Саундхенд."
	contains = list(
		/obj/item/concert_disk/soundhand_01,
		/obj/item/concert_disk/soundhand_02,
		/obj/item/concert_disk/soundhand_03,
		/obj/item/concert_disk/soundhand_04,
		/obj/item/concert_disk/soundhand_05,
		/obj/item/concert_disk/soundhand_06,
		/obj/item/concert_disk/soundhand_07,
		/obj/item/concert_disk/soundhand_08,
		/obj/item/concert_disk/soundhand_09,
		/obj/item/concert_disk/soundhand_10
		)

//Закоментить/Удалить после ивента
/obj/item/concert_disk/soundhand_concert
	name = "Soundhand Concert"
	album_id = "soundhand_10"
	color_disk = "FF3EFF"
