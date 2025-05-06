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


/datum/mod_theme/skrell_raskinta
	name = "raskinta"
	desc = "Боевая броня с функцией костюма для ВКД, созданная для воинов Раскинта Ме'керр-Кэтиш."
	extended_desc = "Массивный бронекостюм, выполненный в черно-синих цветах, является отличительной чертой  \
		военных формирований Раскинта-Кэтиш. Защитные пластины состоят из укрепленной керамики, в то время как \
		каркасные пластины выполнены из сплавов вороной пластали, позволяющей эффективно поглощать и рассеивать энергию \
		через радиаторные отводы на \"хвостовых\" окончаниях шлема. \
		Этот костюм является самым часто встречаемым в штурмовых отрядах Оборонительных Сил Скреллов."
	default_skin = "skrell_sdtf"
	armor_type = /datum/armor/mod_theme_skrell_raskinta
	complexity_max = DEFAULT_MAX_COMPLEXITY
	siemens_coefficient = 0
	slowdown_deployed = 0.25
	activation_step_time = MOD_ACTIVATION_STEP_TIME
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		"skrell_sdtf" = list(
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

/datum/armor/mod_theme_skrell_raskinta
	melee = 15
	bullet = 20
	laser = 45
	energy = 20
	bomb = 30
	bio = 100
	fire = 90
	acid = 90
	wound = 15

/datum/mod_theme/emperor_guard
	name = "emperor guard"
	desc = "Элитная боевая броня гвардейцев Скреллианской империи."
	extended_desc = "Благодаря высшим технологическим достижениям скреллов этот костюм сочетает в себе \
		невероятные показатели защищенности и мобильности, являясь незаменимой вещью на вооружении свирепых Куи'кверр-Кэтиш. \
		Носящие его воины являются личной гвардией Императора и выполняют самые сложные задачи по его воле. \
		Кроваво-белоснежные цвета, отождествляющие кровь врагов и власть Его Величества, скорее всего последнее \
		что вы увидите в своей жизни."
	default_skin = "skrell_guard"
	armor_type = /datum/armor/mod_theme_skrell_guard
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	siemens_coefficient = 0
	slowdown_deployed = 0
	activation_step_time = MOD_ACTIVATION_STEP_TIME * 0.5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		"skrell_guard" = list(
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

/datum/armor/mod_theme_skrell_guard
	melee = 55
	bullet = 55
	laser = 65
	energy = 50
	bomb = 60
	bio = 100
	fire = 100
	acid = 100
	wound = 25
