// MARK: Armor //

// CentCom
/obj/item/clothing/suit/armor/centcom_formal/field
	name = "field officer's tunic"
	desc = "Строгое и надежное армированное пальто для тяжелой работы непосредственно на объектах Компании. Не пропитывается кровью."
	icon_state = "centcom_field_officer"
	inhand_icon_state = "centcom_field"

/obj/item/clothing/suit/armor/centcom_formal/officer
	name = "fleet officer's greatcoat"
	desc = "Удобный мундир для повседневного ношения."
	icon_state = "centcom_officer"

// Blueshield
/datum/atom_skin/blueshield_armor
	abstract_type = /datum/atom_skin/blueshield_armor
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/blueshield_armor/slim
	preview_name = "Slim"
	new_icon_state = "blueshield_armor"

/datum/atom_skin/blueshield_armor/marine
	preview_name = "Marine"
	new_icon_state = "blueshield_marine"

/datum/atom_skin/blueshield_armor/bulky
	preview_name = "Bulky"
	new_icon_state = "vest_black"

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield's armor"
	desc = "A tight-fitting kevlar-lined vest with a blue badge on the chest of it."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield_armor"
	body_parts_covered = CHEST

/obj/item/clothing/suit/armor/vest/blueshield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/blueshield_armor)

/obj/item/clothing/suit/armor/vest/blueshield_jacket
	name = "blueshield's jacket"
	desc = "An expensive kevlar-lined jacket with a golden badge on the chest and \"NT\" emblazoned on the back. It weighs surprisingly little, despite how heavy it looks."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/armor/vest/blueshield_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// Security
/obj/item/clothing/suit/armor/vest/bomber
	name = "security bomber"
	desc = "Стильная черная куртка-бомбер, украшенная красной полосой слева. Выглядит сурово."
	icon_state = "bombersec"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/bomber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/coat
	name = "security coat"
	desc = "Пальто, усиленный специальным сплавом для защиты и стиля."
	icon_state = "secgreatcoat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/caftan
	name = "security caftan"
	desc = "Это длинный и довольно удобный наряд, плотно сидящий на плечах. Выглядит так, как будто он создан в трудные времена."
	icon_state = "seccaftan"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

// MARK: TSF
/obj/item/clothing/suit/armor/centcom_formal/tsf_commander
	name = "federate commander greatcoat"
	desc = "Мундир командующего офицера КМП ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "tsf_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/tsf_overcoat
	name = "federate overcoat"
	desc = "Стильное пальто с отличительными знаками ТСФ.\
	Неофициально считается деловой одеждой представителей Федерации."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "tsf_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/tsf_overcoat
	dog_fashion = null

/datum/armor/tsf_overcoat
	melee = 5
	bullet = 0
	laser = 10
	energy = 0
	bomb = 0
	fire = 5
	acid = 0
	wound = 0

/obj/item/clothing/suit/armor/swat/tsf_heavy
	name = "'Juggernaut' armor"
	desc = "Тяжелая броня ТСФ, состоящая из множества слоев разных усиленных бронеплит и нано-кевлара. Отлично защищает от любых повреждений, особенно от пуль. Броня для самых серьезных защитников Федерации."
	armor_type = /datum/armor/armor_heavy

// MARK: USSP
/obj/item/clothing/suit/armor/centcom_formal/ussp_commander
	name = "soviet general greatcoat"
	desc = "Парадная шинель генерала КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/ussp
	name = "soviet overcoat"
	desc = "Стандартная шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/ussp/officer
	name = "soviet officer overcoat"
	desc = "Офицерская шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat_officer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/ussp_officer
	name = "tactical soviet armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с чёткими опознавательными знаками командира отряда. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, главное верить и не задавать вопросов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/security/ussp_security
	name = "large tactical soviet armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, с дополнительными наколенниками. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, главное верить и не задавать вопросов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_security"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/engineer/ussp_engineer
	name = "tactical soviet utility armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с дополнительными инженерными подсумками и бронированием. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, но возможно чуть лучше так как имеет дополнительный слой стали, главное верить."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_engineer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/medic/ussp_medic
	name = "tactical soviet medic's armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с чёткими опознавательными знаками медика отряда. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, но защиту от военных преступлений не предоставляет."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_medic"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/riot/ussp_riot
	name = "OMON armor"
	desc = "Стандартная тактическая противоударная броня бойцов групп быстрого реагирования \"ОМОН\" для подавления беспорядков. \
		Отлично защищает от колюще-режущих и ударных повреждений. "
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_riot"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/swat/ussp_heavy
	name = "heavy soviet armor"
	desc = "Тяжелая броня советского производства, состоит из усиленных титано-керамических плит и множества слоев нанокевлара. \
		Отлично защищает от любых повреждений, особенно от пуль. Броня для настоящих суровых советских Джаггернаутов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_heavy"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/armor_heavy

// MARK: ERT
/obj/item/clothing/suit/armor/swat/ert
	name = "MK.II SWAT Suit"
	desc = "Усовершенствованная версия тактического костюма SWAT. Обеспечивает надежную защиту и помогает пользователю противостоять толчкам в тесном пространстве, не замедляя его движений."
	slowdown = 0

/obj/item/clothing/suit/chaplainsuit/armor/crusader/ert
	name = "ERT crusader's armour"
	desc = "Усовершенствованная броня для крестовых походов против ереси, состоящая из освященного нанометалла и ткани. Обеспечивает очень хорошую защиту от еретиков, не замедляя движения пользователя."
	slowdown = 0
	allowed = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/chaplainsuit/armor/crusader/ert/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/apron/ert
	name = "ERT armoured apron"
	desc = "Фартук из специального легкого кевлара и ткани созданный для уборщиков ОБР. Обеспечивает надежную защиту от врагов чистоты."
	armor_type = /datum/armor/armor_swat
	allowed = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/apron/ert/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/armor/vest/ntci_chestplate
	name = "chestplate armor"
	desc = "Бронежилет сочетающий в себе удобство, лёгкость и хорошую бронезащиту груди и спины. Модульность позволяет собрать его под себя и упрощает замену бронеплит."
	icon_state = "ntci_chestplate_armor"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/vest_marine
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/armor/swat/ntci
	name = "heavy chestplate armor"
	desc = "Модульный тактический комплект, включающий усиленный баллистический бронежилет со встроенными налокотниками и соответствующие сверхпрочные наколенники для обеспечения мобильности и защиты суставов."
	icon_state = "ntci_heavy_armor"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	armor_type = /datum/armor/vest_marine_heavy
	slowdown = 0

/datum/armor/vest_marine_heavy
	melee = 50
	bullet = 50
	laser = 60
	energy = 50
	bomb = 70
	bio = 90
	fire = 100
	acid = 100
	wound = 20

/obj/item/clothing/suit/armor/vest/ntci_chestplate/parka
	name = "silver-coated armored jacket"
	desc = "Cтильный и теплый пуховик с серебрянными вставками надетый поверх модульного бронежилета. Скрывает наличие бронежилета от лишних глаз и обеспечивает отличную терморегуляцию."
	icon_state = "ntci_parka"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/suit/armor/vest/parka/gard
	name = "brown armored military jacket"
	desc = "Теплый пуховик светло-коричневого цвета с вшитыми армированными вкладками. Хорошо греет и защищает владельца."
	icon_state = "gard_parka"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/vest_marine

/obj/item/clothing/suit/armor/vest/parka/gard_long
	name = "brown armored longcoat"
	desc = "Теплое пальто светло-коричневого цвета с вшитыми армированными вкладками. Хорошо греет и защищает владельца."
	icon_state = "gard_long"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	body_parts_covered = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/accessory/psycross
	name = "unusual silver cross"
	desc = "Серебрянный крест необычной формы. Смотря на него, кажется что он не из этого мира.."
	w_class = WEIGHT_CLASS_TINY
	attachment_slot = NONE
	icon_state = "psycross"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	above_suit = TRUE
	alternate_worn_layer = MOB_UPPER_LAYER

// HARDSUIT SHITTTT

/obj/item/clothing/suit/hardsuit
	name = "hardsuit"
	desc = "An older variant of spacesuits, replaced nowadays with MODsuits."
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 1
	armor_type = /datum/armor/suit_space
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	var/helmettype = /obj/item/clothing/head/helmet/hardsuit //so the chaplain hoodie or other hoodies can override this
	/// Alternative mode for hiding the hood, instead of storing the hood in the suit it qdels it, useful for when you deal with hooded suit with storage.
	var/alternative_mode = FALSE
	/// What should be added to the end of the icon state when the hood is up? Set to "" for the suit sprite to not change at all
	var/helmet_up_affix = ""
	/// Icon state added as a worn overlay while the hood is down, leave as "" for no overlay
	var/helmet_down_overlay_suffix = ""
	/// Reference to hood object, if it exists
	var/obj/item/clothing/head/helmet/hardsuit/helmet

/obj/item/clothing/suit/hardsuit/Initialize(mapload)
	. = ..()
	if (!helmettype)
		return
	AddComponent(\
		/datum/component/toggle_attached_clothing,\
		deployable_type = helmettype,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Helmet",\
		destroy_on_removal = alternative_mode,\
		parent_icon_state_suffix = helmet_up_affix,\
		down_overlay_state_suffix = helmet_down_overlay_suffix, \
		pre_creation_check = CALLBACK(src, PROC_REF(can_create_helmet)),\
		on_created = CALLBACK(src, PROC_REF(on_helmet_created)),\
		on_deployed = CALLBACK(src, PROC_REF(on_helmet_up)),\
		on_removed = CALLBACK(src, PROC_REF(on_helmet_down)),\
	)

/obj/item/clothing/suit/hardsuit/Destroy()
	helmet = null
	return ..()

/// Override to only create the helmet conditionally
/obj/item/clothing/suit/hardsuit/proc/can_create_helmet()
	return TRUE

/// Called when the helmet is instantiated
/obj/item/clothing/suit/hardsuit/proc/on_helmet_created(obj/item/clothing/head/helmet/hardsuit/helmet)
	SHOULD_CALL_PARENT(TRUE)
	src.helmet = helmet
	RegisterSignal(helmet, COMSIG_QDELETING, PROC_REF(on_helmet_deleted))

/// Called when helmet is deleted
/obj/item/clothing/suit/hardsuit/proc/on_helmet_deleted()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	helmet = null

/// Called when the helmet is worn
/obj/item/clothing/suit/hardsuit/proc/on_helmet_up(obj/item/clothing/head/helmet/hardsuit/helmet)
	return

/// Called when the helmet is hidden
/obj/item/clothing/suit/hardsuit/proc/on_helmet_down(obj/item/clothing/head/helmet/hardsuit/helmet)
	return

/obj/item/clothing/suit/toggle
	abstract_type = /obj/item/clothing/suit/toggle
	var/toggle_helmet_noun = "helmet"

/obj/item/clothing/suit/toggle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, toggle_helmet_noun)

/obj/item/clothing/head/helmet/hardsuit
	abstract_type = /obj/item/clothing/head/helmet/hardsuit
	name = "hardsuit helmet"
	desc = "A special hardsuit helmet with solar UV shielding to protect your eyes from harmful rays. An older variant of spacesuits, replaced nowadays with MODsuits."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS
	armor_type = /datum/armor/helmet_space
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	interaction_flags_click = NEED_DEXTERITY
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	equip_delay_other = 5 SECONDS
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/vehicles/mecha/mechmove03.ogg'
	drop_sound = 'sound/vehicles/mecha/mechmove03.ogg'

/obj/item/clothing/suit/hardsuit/ntci
	name = "silver-coated armored hardsuit"
	desc = "Специальный боевой костюм ВКД старой компоновки, такие уже давно не делают. Этот имеет серебрянные вставки, зачем они требуются - неясно."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	icon_state = "ntci_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/hardsuit/ntci
	armor_type = /datum/armor/vest_marine_heavy
	slowdown = 0

/obj/item/clothing/head/helmet/hardsuit/ntci
	name = "silver-coated armored hardsuit helmet"
	desc = "Специальный боевой шлем костюма ВКД старой компоновки, такие уже давно не делают. Этот имеет серебрянные вставки, зачем они требуются - неясно."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	icon_state = "ntci_hardsuit_helmet"
	armor_type = /datum/armor/vest_marine_heavy

/obj/item/clothing/suit/hardsuit/zizo
	name = "avantyne hardsuit"
	desc = "Багровый боевой костюм ВКД старой компоновки, такие уже давно не делают. Этот сделан из неизвестного материала, и выглядит очень зловещим."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	icon_state = "zizo_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/hardsuit/zizo
	armor_type = /datum/armor/vest_marine_heavy
	slowdown = 0

/obj/item/clothing/head/helmet/hardsuit/zizo
	name = "avantyne hardsuit helmet"
	desc = "Багровый боевой шлем костюма ВКД старой компоновки, такие уже давно не делают. Этот сделан из неизвестного материала, и выглядит очень зловещим. Зачем ему столько визоров?"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/ntci_armor.dmi'
	icon_state = "zizo_hardsuit_helmet"
	armor_type = /datum/armor/vest_marine_heavy
