/obj/item
	var/list/worn_icon_species

/// Returns a fitted sprite only when it contains the requested worn state.
/obj/item/proc/get_species_worn_icon(species_id, state)
	state ||= worn_icon_state || icon_state
	var/species_icon = worn_icon_species?[species_id]
	if(!species_icon)
		return null
	if(species_id == SPECIES_VOX && species_icon == 'icons/bandastation/mob/species/vox/clothing/feet.dmi' && worn_x_dimension == 64 && worn_y_dimension == 64)
		species_icon = 'icons/bandastation/mob/species/vox/clothing/feet_64.dmi'
	if(species_id == SPECIES_VOX && greyscale_config_worn)
		var/static/list/vox_greyscale_configs = list(
			/datum/greyscale_config/jumpsuit/worn = /datum/greyscale_config/jumpsuit/worn/vox,
			/datum/greyscale_config/jumpsuit/prison/worn = /datum/greyscale_config/jumpsuit/prison/worn/vox,
			/datum/greyscale_config/beret/worn = /datum/greyscale_config/beret/worn/vox,
			/datum/greyscale_config/beret_badge/worn = /datum/greyscale_config/beret_badge/worn/vox,
			/datum/greyscale_config/sneakers/worn = /datum/greyscale_config/sneakers/worn/vox,
			/datum/greyscale_config/sneakers_orange/worn = /datum/greyscale_config/sneakers_orange/worn/vox,
			/datum/greyscale_config/bandana/worn = /datum/greyscale_config/bandana/worn/vox,
			/datum/greyscale_config/bandana/striped/worn = /datum/greyscale_config/bandana/striped/worn/vox,
			/datum/greyscale_config/bandana/skull/worn = /datum/greyscale_config/bandana/skull/worn/vox,
		)
		var/vox_config = vox_greyscale_configs[greyscale_config_worn]
		if(!vox_config)
			return null
		species_icon = SSgreyscale.GetColoredIconByType(vox_config, greyscale_colors)
	if(icon_exists(species_icon, state))
		return species_icon
	return null

/obj/item/clothing/head/mod
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/modsuits.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/modsuits.dmi',
		SPECIES_SKRELL = 'icons/bandastation/mob/species/skrell/clothing/modsuits.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modsuits.dmi'
	)

/obj/item/clothing/suit/mod
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/modsuits.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/modsuits.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modsuits.dmi'
	)

/obj/item/mod/module
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/modules.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/modules.dmi',
		SPECIES_SKRELL = 'icons/bandastation/mob/species/skrell/clothing/modules.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modules.dmi'
	)

/obj/item/clothing/suit
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/suit.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/suit.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/suit.dmi'
	)

/obj/item/clothing/head
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/head.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/head.dmi',
		SPECIES_SKRELL = 'icons/bandastation/mob/species/skrell/clothing/head.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/head.dmi'
	)

/obj/item/clothing/under
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/uniform.dmi',
	)

/obj/item/clothing/head/helmet
	worn_icon_species = list(
		SPECIES_VULPKANIN = 'icons/bandastation/mob/species/vulpkanin/clothing/head.dmi',
		SPECIES_TAJARAN = 'icons/bandastation/mob/species/tajaran/clothing/head.dmi',
		SPECIES_SKRELL = 'icons/bandastation/mob/species/skrell/clothing/head.dmi',
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/helmet.dmi',
	)

/obj/item/clothing/mask
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/mask.dmi'
	)

/obj/item/cigarette
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/mask.dmi',
	)

/obj/item/clothing/glasses
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/eyes.dmi'
	)

/obj/item/clothing/ears
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/ears.dmi'
	)

/obj/item/clothing/gloves
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/hands.dmi'
	)

/obj/item/clothing/shoes
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/feet.dmi'
	)

/obj/item/clothing/neck
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/neck.dmi',
	)

/obj/item/storage/backpack
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/back.dmi',
	)

/obj/item/storage/belt
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/belt.dmi',
	)

/obj/item/mod/control
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modsuits.dmi',
	)

/obj/item/clothing/gloves/mod
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modsuits.dmi',
	)

/obj/item/clothing/shoes/mod
	worn_icon_species = list(
		SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/modsuits.dmi',
	)

/datum/greyscale_config/jumpsuit/worn/vox
	name = "Vox jumpsuit (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/color_gags_vox.dmi'

/datum/greyscale_config/jumpsuit/prison/worn/vox
	name = "Vox prison jumpsuit (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/color_gags_vox.dmi'

/datum/greyscale_config/beret/worn/vox
	name = "Vox beret (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/color_gags_vox.dmi'

/datum/greyscale_config/beret_badge/worn/vox
	name = "Vox badged beret (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/color_gags_vox.dmi'

/datum/greyscale_config/sneakers/worn/vox
	name = "Vox sneakers (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/feet.dmi'

/datum/greyscale_config/sneakers_orange/worn/vox
	name = "Vox orange sneakers (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/feet.dmi'

/datum/greyscale_config/bandana/worn/vox
	name = "Vox bandana (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/mask.dmi'

/datum/greyscale_config/bandana/striped/worn/vox
	name = "Vox striped bandana (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/mask.dmi'

/datum/greyscale_config/bandana/skull/worn/vox
	name = "Vox skull bandana (Worn)"
	icon_file = 'icons/bandastation/mob/species/vox/clothing/mask.dmi'
