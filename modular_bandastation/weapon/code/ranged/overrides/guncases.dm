/obj/item/storage/toolbox/guncase
	desc = "A thick gun case with foam inserts laid out to fit a weapon, magazines, and gear securely."
	icon = 'modular_bandastation/weapon/icons/guncases.dmi'
	icon_state = "guncase"
//	worn_icon = 'modular_nova/modules/modular_weapons/icons/mob/worn/cases.dmi'
//	worn_icon_state = "darkcase"
	lefthand_file = 'modular_bandastation/weapon/icons/guncases_lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/guncases_righthand.dmi'
	inhand_icon_state = "darkcase"
//	slot_flags = ITEM_SLOT_BACK
	material_flags = NONE
	storage_type = /datum/storage/toolbox/guncase
	var/opened = FALSE

/datum/storage/toolbox/guncase
	max_total_storage = 14 // Technically means you could fit multiple large guns in here but it's a case you cant backpack anyways so what it do
	max_slots = 6 // We store some extra items in these so lets make a little extra room

/obj/item/storage/toolbox/guncase/update_icon()
	. = ..()
	if(opened)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/item/storage/toolbox/guncase/click_alt(mob/user)
	opened = !opened
	update_icon()
	return CLICK_ACTION_SUCCESS

/obj/item/storage/toolbox/guncase/attack_self(mob/user)
	. = ..()
	opened = !opened
	update_icon()

//Quick overwrite of TG's guncase PopulateContents() to prevent runtimes
//Now it only tries to spawn stuff if there's actually stuff to spawn
// /obj/item/storage/toolbox/guncase/nova/PopulateContents()
// 	if(weapon_to_spawn)
// 		new weapon_to_spawn (src)
// 	if(extra_to_spawn)
// 		for(var/iterate in 1 to 3)
// 			new extra_to_spawn (src)

// Small case for pistols and whatnot
/obj/item/storage/toolbox/guncase/pistol
	name = "small gun case"
	icon_state = "guncase_s"
	slot_flags = NONE
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

/datum/storage/toolbox/guncase/pistol
	max_specific_storage = WEIGHT_CLASS_NORMAL

/*
	Pre-Colored Variants
	(Since imports don't allow us to do reskins, and we don't want these reskinnable in-round)
*/
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

/*
	Company Cases
	(Subtype off these when making presets supplied by these companies!)
*/

// Nanotrasen
/obj/item/storage/toolbox/guncase/ntcase
	icon_state = "ntcase"
	worn_icon_state = "ntcase"
	inhand_icon_state = "ntcase"

/obj/item/storage/toolbox/guncase/ntcase/examine(mob/user)
	. = ..()
	. += "<i>It is emblazoned with the <b>[span_blue("Nanotrasen")]</b> logo.</i>"

/obj/item/storage/toolbox/guncase/ntcase/pistol
	name = "small gun case"
	icon_state = "ntcase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Nanotrasen Centcom Case (CC/Gold Varient) (used for NTC/Blueshield & Other CC related drops)
/obj/item/storage/toolbox/guncase/ntspecial
	icon_state = "cc_case"
	worn_icon_state = "cc_case"
	inhand_icon_state = "cc_case"

/obj/item/storage/toolbox/guncase/ntspecial/examine(mob/user)
	. = ..()
	. += "<i>It is emblazoned with a gilded <b>[span_blue("Nanotrasen")]</b> logo.</i>"


/obj/item/storage/toolbox/guncase/ntspecial/pistol
	name = "small gun case"
	icon_state = "cc_case_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Solfed
/obj/item/storage/toolbox/guncase/solfed
	icon_state = "solfedcase"
	worn_icon_state = "solfedcase"
	inhand_icon_state = "solfedcase"

/obj/item/storage/toolbox/guncase/solfed/examine(mob/user)
	. = ..()
	. += "<i>It is stamped with the <b>[span_cyan("Solar Federation")]</b> emblem.</i>"

/obj/item/storage/toolbox/guncase/solfed/pistol
	name = "small gun case"
	icon_state = "solfedcase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Solfed Special
/obj/item/storage/toolbox/guncase/solfedspec
	icon_state = "solfedspeccase"
	worn_icon_state = "solfedspeccase"
	inhand_icon_state = "solfedspeccase"

/obj/item/storage/toolbox/guncase/solfedspec/examine(mob/user)
	. = ..()
	. += "<i>It is stamped with the <b>[span_cyan("Solar Federation")]</b> emblem.</i>"

/obj/item/storage/toolbox/guncase/solfedspec/pistol
	name = "small gun case"
	icon_state = "solfedspeccase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Syndicate
/obj/item/storage/toolbox/guncase/syndicate
	icon_state = "syndicase"
	worn_icon_state = "syndicase"
	inhand_icon_state = "syndicase"

/obj/item/storage/toolbox/guncase/syndicate/examine(mob/user)
	. = ..()
	. += "<i>It is marked with <b>[span_red("Syndicate Conglomerate")]</b> insignia.</i>"

/obj/item/storage/toolbox/guncase/syndicate/pistol
	name = "small gun case"
	icon_state = "syndicase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Interdyne Pharmaceuticals
/obj/item/storage/toolbox/guncase/nova/interdyne
	icon_state = "dynecase"
	worn_icon_state = "dynecase"
	inhand_icon_state = "dynecase"

/obj/item/storage/toolbox/guncase/interdyne/examine(mob/user)
	. = ..()
	. += "<i>It is stamped with the <b>[span_green("Interdyne Pharmaceuticals")]</b> logo.</i>"

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
	. += "<i>It is stamped with the <b>[span_green("Interdyne Pharmaceuticals")]</b> logo.</i>"

/obj/item/storage/toolbox/guncase/interdynespec/pistol
	name = "small gun case"
	icon_state = "dynespeccase_s"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/toolbox/guncase/pistol

// Carwo Defense Systems & Trappiste Fabriek
/obj/item/storage/toolbox/guncase/carwo_large_case
	icon_state = "case_carwo"
	worn_icon_state = "carwocase"
	inhand_icon_state = "carwocase"
	//No logo on this case

/obj/item/storage/toolbox/guncase/pistol/trappiste_small_case
	icon_state = "case_trappiste"
	worn_icon_state = "carwocase"
	inhand_icon_state = "carwocase"

/obj/item/storage/toolbox/guncase/pistol/trappiste_small_case/examine(mob/user)
	. = ..()
	. += "<i>The five square grid of <b>[span_red("Trappiste Fabriek")]</b> is displayed prominently on the top.</i>"

// Xhihao Light Arms
/obj/item/storage/toolbox/guncase/xhihao_large_case
	icon_state = "case_xhihao"
	//No pistol variant (yet!)

/obj/item/storage/toolbox/guncase/xhihao_large_case/examine(mob/user)
	. = ..()
	. += "<i>It is subtly marked with <b>[span_purple("Xhihao Light Arms")]</b> trademarking.</i>"

