/obj/item/storage/toolbox/guncase
	desc = "Прочный кейс для оружия с вставками из пенопласта, расположение которых обеспечивает надежную фиксацию оружия, магазинов и дополнительного снаряжения."
	icon = 'modular_bandastation/weapon/icons/guncases.dmi'
	icon_state = "guncase"
	worn_icon = 'modular_bandastation/weapon/icons/guncases_worn.dmi'
	worn_icon_state = "darkcase"
	lefthand_file = 'modular_bandastation/weapon/icons/guncases_lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/guncases_righthand.dmi'
	inhand_icon_state = "darkcase"
	slot_flags = ITEM_SLOT_BACK
	material_flags = NONE
	storage_type = /datum/storage/toolbox/guncase
	var/opened = FANCY_CONTAINER_CLOSED
	weapon_to_spawn = null
	extra_to_spawn = null

/datum/storage/toolbox/guncase
	click_alt_open = FALSE

/obj/item/storage/toolbox/guncase/update_icon_state()
	. = ..()
	icon_state = opened ? "[initial(icon_state)]-open" : initial(icon_state)

/obj/item/storage/toolbox/guncase/Exited(atom/movable/gone, direction)
	. = ..()
	if(opened == FANCY_CONTAINER_CLOSED)
		opened = FANCY_CONTAINER_OPEN
	update_appearance()

/obj/item/storage/toolbox/guncase/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(opened == FANCY_CONTAINER_CLOSED)
		opened = FANCY_CONTAINER_OPEN
	update_appearance()

/obj/item/storage/toolbox/guncase/click_alt(mob/user)
	if(opened == FANCY_CONTAINER_CLOSED)
		opened = FANCY_CONTAINER_OPEN
	update_appearance()
	return atom_storage.open_storage_on_signal(storage_type, user) ? CLICK_ACTION_SUCCESS : NONE

/obj/item/storage/toolbox/guncase/attack_self(mob/user)
	if(opened == FANCY_CONTAINER_CLOSED)
		opened = FANCY_CONTAINER_OPEN
		update_appearance()
		return ..()
	else if(opened == FANCY_CONTAINER_OPEN)
		opened = FANCY_CONTAINER_CLOSED
		update_appearance()
		atom_storage.close_all()

// Small case for pistols and whatnot
/obj/item/storage/toolbox/guncase/pistol
	name = "small gun case"
	icon_state = "guncase_s"
	slot_flags = NONE
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/datum/storage/toolbox/guncase/pistol
	max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/toolbox/guncase/green
	icon_state = "greencase"
	worn_icon_state = "greencase"
	inhand_icon_state = "greencase"

/obj/item/storage/toolbox/guncase/green/pistol
	name = "small gun case"
	icon_state = "greencase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/obj/item/storage/toolbox/guncase/red
	icon_state = "redcase"
	worn_icon_state = "redcase"
	inhand_icon_state = "redcase"

/obj/item/storage/toolbox/guncase/red/pistol
	name = "small gun case"
	icon_state = "redcase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/obj/item/storage/toolbox/guncase/blue
	icon_state = "bluecase"
	worn_icon_state = "bluecase"
	inhand_icon_state = "bluecase"

/obj/item/storage/toolbox/guncase/blue/pistol
	name = "small gun case"
	icon_state = "bluecase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/obj/item/storage/toolbox/guncase/purple
	icon_state = "purplecase"
	worn_icon_state = "purplecase"
	inhand_icon_state = "purplecase"

/obj/item/storage/toolbox/guncase/purple/pistol
	name = "small gun case"
	icon_state = "purplecase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/obj/item/storage/toolbox/guncase/orange
	icon_state = "orangecase"
	worn_icon_state = "orangecase"
	inhand_icon_state = "orangecase"

/obj/item/storage/toolbox/guncase/orange/pistol
	name = "small gun case"
	icon_state = "orangecase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Nanotrasen
/obj/item/storage/toolbox/guncase/ntcase
	icon_state = "ntcase"
	worn_icon_state = "ntcase"
	inhand_icon_state = "ntcase"

/obj/item/storage/toolbox/guncase/ntcase/examine(mob/user)
	. = ..()
	. += "<i>На нём выгравирован логотип <b>[span_blue("Нанотрейзен")]</b>.</i>"

/obj/item/storage/toolbox/guncase/ntcase/pistol
	name = "small gun case"
	icon_state = "ntcase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Nanotrasen Centcom Case
/obj/item/storage/toolbox/guncase/ntspecial
	icon_state = "cc_case"
	worn_icon_state = "cc_case"
	inhand_icon_state = "cc_case"

/obj/item/storage/toolbox/guncase/ntspecial/examine(mob/user)
	. = ..()
	. += "<i>На нём выгравирован позолоченный логотип <b>[span_blue("Нанотрейзен")]</b>.</i>"

/obj/item/storage/toolbox/guncase/ntspecial/pistol
	name = "small gun case"
	icon_state = "cc_case_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// TSF
/obj/item/storage/toolbox/guncase/tsf
	icon_state = "tsfcase"
	worn_icon_state = "tsfcase"
	inhand_icon_state = "tsfcase"

/obj/item/storage/toolbox/guncase/tsf/examine(mob/user)
	. = ..()
	. += "<i>На нём отпечатана эмблема <b>[span_cyan("ТСФ")]</b>.</i>"

/obj/item/storage/toolbox/guncase/tsf/pistol
	name = "small gun case"
	icon_state = "tsfcase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// TSF Special
/obj/item/storage/toolbox/guncase/tsfspec
	icon_state = "tsfspeccase"
	worn_icon_state = "tsfspeccase"
	inhand_icon_state = "tsfspeccase"

/obj/item/storage/toolbox/guncase/tsfspec/examine(mob/user)
	. = ..()
	. += "<i>На нём отпечатана эмблема <b>[span_cyan("ТСФ")]</b>.</i>"

/obj/item/storage/toolbox/guncase/tsfspec/pistol
	name = "small gun case"
	icon_state = "tsfspeccase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Syndicate
/obj/item/storage/toolbox/guncase/syndicate
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/syndicate/examine(mob/user)
	. = ..()
	. += "<i>Он отмечен эмблемой <b>[span_red("Когломерата Синдиката")]</b>.</i>"

/obj/item/storage/toolbox/guncase/syndicate/pistol
	name = "small gun case"
	icon_state = "syndicase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/obj/item/storage/toolbox/guncase/traitor
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol
	extra_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/bulldog
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/c20r
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/smartgun
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/clandestine
	icon_state = "syndicase_s"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/m90gl
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/rocketlauncher
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/revolver
	icon_state = "syndicase_s"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/sword_and_board
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/cqc
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/doublesword
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/china_lake
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/monkeycase
	icon_state = "syndicase_s"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/syndiesledge
	name = "syndicate sledgehammer case"
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"
	weapon_to_spawn = /obj/item/sledgehammer/syndie
	extra_to_spawn = /obj/item/clothing/head/utility/welding

/obj/item/storage/toolbox/guncase/syndiesledge/PopulateContents()
	new weapon_to_spawn(src)
	new extra_to_spawn(src)

// Interdyne Pharmaceuticals
/obj/item/storage/toolbox/guncase/interdyne
	icon_state = "dynecase"
	worn_icon_state = "dynecase"
	inhand_icon_state = "dynecase"

/obj/item/storage/toolbox/guncase/interdyne/examine(mob/user)
	. = ..()
	. += "<i>На нём отпечатана эмблема логотип <b>[span_green("Interdyne Pharmaceuticals")]</b>.</i>"

/obj/item/storage/toolbox/guncase/interdyne/pistol
	name = "small gun case"
	icon_state = "dynecase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/// Interdyne Special Case
/obj/item/storage/toolbox/guncase/interdynespec
	icon_state = "dynespeccase"
	worn_icon_state = "dynespeccase"
	inhand_icon_state = "dynespeccase"

/obj/item/storage/toolbox/guncase/interdynespec/examine(mob/user)
	. = ..()
	. += "<i>На нём отпечатана эмблема логотип <b>[span_green("Interdyne Pharmaceuticals")]</b>.</i>"

/obj/item/storage/toolbox/guncase/interdynespec/pistol
	name = "small gun case"
	icon_state = "dynespeccase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Yellow cases
/obj/item/storage/toolbox/guncase/yellowcase
	icon_state = "yellowcase"
	worn_icon_state = "yellowcase"
	inhand_icon_state = "yellowcase"

/obj/item/storage/toolbox/guncase/pistol/trappiste_small_case
	icon_state = "yellowcase_s"
	worn_icon_state = "yellowcase_s"
	inhand_icon_state = "yellowcase_s"

/obj/item/storage/toolbox/guncase/pistol/trappiste_small_case/examine(mob/user)
	. = ..()
	. += "<i>В верхней части заметно размещена пятью квадратами сетка <b>[span_red("Trappiste Fabriek")]</b>.</i>"

// Xhihao Light Arms
/obj/item/storage/toolbox/guncase/xhihao_large_case
	icon_state = "case_xhihao"

/obj/item/storage/toolbox/guncase/xhihao_large_case/examine(mob/user)
	. = ..()
	. += "<i>На нём незаметно нанесена торговая марка <b>[span_purple("Xhihao Light Arms")]</b>.</i>"

/obj/item/storage/toolbox/guncase/soviet
	desc = "Оружейный кейс с символикой СССП отпечатаной на верхней части."
	icon_state = "sovietcase"
	worn_icon_state = "sovietcase"
	inhand_icon_state = "sovietcase"

/obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/PopulateContents()
	new weapon_to_spawn (src)
	for(var/i in 1 to 2)
		new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/ntcase/pistol/gp9
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/gp9/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol/rubber

/obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/gp9/sec
	extra_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol/rubber

/obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/no_ammo
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/gp9/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty

/obj/item/storage/toolbox/guncase/green/pistol/revolver_c38
	weapon_to_spawn = /obj/item/gun/ballistic/revolver/c38/detective

/obj/item/storage/toolbox/guncase/blue/shotgun
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/automatic/combat
	extra_to_spawn = /obj/item/storage/belt/bandolier

/obj/item/storage/toolbox/guncase/blue/shotgun/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)

/obj/item/storage/toolbox/guncase/ntcase/laser
	weapon_to_spawn = /obj/item/gun/energy/laser

/obj/item/storage/toolbox/guncase/ntcase/laser_carbine
	weapon_to_spawn = /obj/item/gun/energy/laser/carbine

/obj/item/storage/toolbox/guncase/ntcase/pistol/laser_pistol
	weapon_to_spawn = /obj/item/gun/energy/laser/pistol

/obj/item/storage/toolbox/guncase/ntcase/pistol/laser_soul
	weapon_to_spawn = /obj/item/gun/energy/laser/soul

/obj/item/storage/toolbox/guncase/ntcase/smg
	weapon_to_spawn = /obj/item/gun/energy/disabler/smg

/obj/item/storage/toolbox/guncase/orange/doublebarrel
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/doublebarrel

/obj/item/storage/toolbox/guncase/ntcase/e_gun
	weapon_to_spawn = /obj/item/gun/energy/e_gun
