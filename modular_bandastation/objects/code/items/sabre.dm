/datum/atom_skin/cap_sabre
	abstract_type = /datum/atom_skin/cap_sabre
	change_base_icon_state = TRUE
	new_icon = 'modular_bandastation/objects/icons/obj/weapons/sword.dmi'
	new_lefthand_file = 'modular_bandastation/objects/icons/obj/weapons/saber/saber_left.dmi'
	new_righthand_file = 'modular_bandastation/objects/icons/obj/weapons/saber/saber_right.dmi'

/datum/atom_skin/cap_sabre/default
	preview_name = "Default"
	new_icon_state = "saber_default"
	new_inhand_icon_state = "saber_default"

/datum/atom_skin/cap_sabre/classic
	preview_name = "Classic"
	new_icon_state = "saber_classic"
	new_inhand_icon_state = "saber_classic"

/datum/atom_skin/cap_sabre/ceremonial
	preview_name = "Ceremonial"
	new_icon_state = "saber_ceremonial"
	new_inhand_icon_state = "saber_ceremonial"

/datum/atom_skin/cap_sabre/cossack
	preview_name = "Cossack"
	new_icon_state = "saber_cossack"
	new_inhand_icon_state = "saber_cossack"

/obj/item/melee/sabre/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/cap_sabre)

/datum/component/reskinable_item/cap_sabre/reskin_obj(mob/user)
