/// A native zipup hoodie in the source palette, with its map preview kept in this module.
/obj/item/clothing/suit/hooded/wintercoat/zipup/tsf
	name = "blue hoodie"
	icon = 'modular_bandastation/donor_jobs/icons/tsf_map_icons.dmi'
	icon_state = "/obj/item/clothing/suit/hooded/wintercoat/zipup/donor_tsf"
	greyscale_colors = "#02519a"
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/obj/item/clothing/under/rank/tsf/classic
	abstract_type = /obj/item/clothing/under/rank/tsf/classic
	icon = 'modular_bandastation/donor_jobs/icons/tsf_uniforms.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/rank/tsf/classic/commander
	name = "\improper Trans-Solar Federation commander's uniform"
	desc = "A space-black uniform with gold trim, worn by generals of the Trans-Solar Federation."
	icon_state = "navy_gold"
	inhand_icon_state = "navy_gold"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/tsf_uniforms_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/tsf_uniforms_righthand.dmi'

/// Native cap flipping and dropping consume both original orientations.
/obj/item/clothing/head/soft/tsf
	name = "\improper Trans-Solar Federation marine cap"
	desc = "A soft cap worn by Trans-Solar Federation marines."
	icon = 'modular_bandastation/donor_jobs/icons/tsf_hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_hats_worn.dmi'
	icon_state = "solgovsoft_flipped"
	soft_type = "solgov"
	flipped = TRUE
	dog_fashion = null

/obj/item/clothing/head/soft/tsf/specops
	name = "\improper Trans-Solar Federation Specops marine cap"
	desc = "A cap worn by the Federation's special operations marines."
	icon_state = "solgovelitesoft_flipped"
	soft_type = "solgovelite"

/obj/item/clothing/head/soft/tsf/command
	name = "\improper Trans-Solar Federation lieutenant's cap"
	desc = "A marine cap bearing a lieutenant's insignia."
	icon_state = "solgovcsoft_flipped"
	soft_type = "solgovc"

/obj/item/clothing/head/soft/tsf/command/specops
	name = "\improper Trans-Solar Federation Specops lieutenant's cap"
	desc = "A special operations marine cap bearing a lieutenant's insignia."
	icon_state = "solgovcelitesoft_flipped"
	soft_type = "solgovcelite"

/obj/item/clothing/head/beret/tsf
	name = "\improper Trans-Solar Federation lieutenant's beret"
	desc = "A marine beret bearing a lieutenant's insignia."
	icon = 'modular_bandastation/donor_jobs/icons/tsf_hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_hats_worn.dmi'
	icon_state = "solgovcberet"
	inhand_icon_state = "greyscale_softcap"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
	flags_1 = NONE
	dog_fashion = null

/obj/item/clothing/head/beret/tsf/specops
	name = "\improper Trans-Solar Federation Specops lieutenant's beret"
	desc = "A special operations marine beret bearing a lieutenant's insignia."
	icon_state = "solgovceliteberet"

/// These are cosmetic variants of TG spacesuits, without Paradise's hardsuit machinery.
/obj/item/clothing/head/helmet/space/tsf
	name = "\improper Trans-Solar Federation Specops marine helmet"
	desc = "A space helmet in the colours of the Federation's special operations marines."
	icon = 'modular_bandastation/donor_jobs/icons/tsf_hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_hats_worn.dmi'
	icon_state = "hardsuit0-solgovmarine"

/obj/item/clothing/suit/space/tsf
	name = "\improper Trans-Solar Federation Specops marine space suit"
	desc = "A space suit in the colours of the Federation's special operations marines."
	icon = 'modular_bandastation/donor_jobs/icons/tsf_suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_suits_worn.dmi'
	icon_state = "ert_solgov_marine"

/obj/item/clothing/head/helmet/space/tsf/command
	name = "\improper Trans-Solar Federation Specops lieutenant's helmet"
	desc = "A Federation marine space helmet with gold highlights denoting its wearer's rank."
	icon_state = "hardsuit0-solgovcommand"

/obj/item/clothing/suit/space/tsf/command
	name = "\improper Trans-Solar Federation Specops lieutenant's space suit"
	desc = "A Federation marine space suit with gold highlights denoting its wearer's rank."
	icon_state = "ert_solgov_command"

/// Reuse the existing command coat armour without a toggle requiring nonexistent source sprites.
/obj/item/clothing/suit/armor/tsf_commander
	name = "\improper Trans-Solar Federation commander's jacket"
	desc = "A formal coat worn by the Federation's commanding officers."
	icon = 'modular_bandastation/donor_jobs/icons/tsf_suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/tsf_suits_worn.dmi'
	icon_state = "solgovcommander"
	inhand_icon_state = "b_suit"
	armor_type = /datum/armor/armor_centcom_formal
