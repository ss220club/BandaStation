/datum/mod_theme/praetorian
	name = "'Praetorian' escort"
	desc = "A Nanotrasen refit of the Apadyne Technologies modsuit line. Offers higher mobility than the base model, and comes with a snazzy blue-and-black paint job."
	extended_desc = "A licensed copy of the Shellguard Munitions 'Apadyne Technologies' modsuit, the NA-35 'Praetorian' is specially issued to Nanotrasen Asset Protection's Blueshield Corps: \
		elite bodyguards charged with protecting Nanotrasen VIPs. As such, the suit's motor and weight distribution systems have seen a measure of improvement, to allow for the \
		Blueshields to more effectively respond to threats facing their charges. Beyond this and its stylish blue & black paint job, however, the Praetorian differs little \
		from its Shellguard roots, retaining its middling armor ratings and restrictive hardware. Even so, Nanotrasen is more than happy with the design, and has proceeded \
		with a full rollout of the suit to Blueshields across their corporate empire."
	default_skin = "praetorian"
	armor_type = /datum/armor/mod_theme_security
	complexity_max = DEFAULT_MAX_COMPLEXITY - 2
	slowdown_deployed = 0.25
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/knife/combat
	)
	variants = list(
		"praetorian" = list(
			MOD_ICON_OVERRIDE = 'modular_bandastation/objects/icons/obj/clothing/modsuit/mod_clothing.dmi',
			MOD_WORN_ICON_OVERRIDE = 'modular_bandastation/objects/icons/mob/clothing/modsuit/mod_clothing.dmi',
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES|PEPPERPROOF,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/mod_theme/ntci
	name = "'Silver Order' combat"
	desc = "Кастомная модификация линейки МОДкостюмов от Apadyne Technologies. Обеспечивает более высокую мобильность и защиту по сравнению с базовой моделью, а также выделяется черно-серебристой расцветкой."
	extended_desc = "Штучная модификация. Костюм усилен композитными бронеплитами с серебряным напылением, оснащен передовыми модулями и дополнен теплым тяжелым пальтом с посеребренными элементами."
	default_skin = "ntci"
	armor_type = /datum/armor/vest_marine_heavy
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	slowdown_deployed = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	activation_step_time = MOD_ACTIVATION_STEP_TIME * 0.5
	siemens_coefficient = 0
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/knife/combat,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"ntci" = list(
			MOD_ICON_OVERRIDE = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi',
			MOD_WORN_ICON_OVERRIDE = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi',
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES|PEPPERPROOF,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/obj/item/mod/control/pre_equipped/ntci
	theme = /datum/mod_theme/ntci
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/holster,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/shove_blocker/locked,
		/obj/item/mod/module/shooting_assistant,
		/obj/item/mod/module/longfall,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/welding/syndicate,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/flashlight,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
	)
