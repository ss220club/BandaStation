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
	flags_inv = HIDEGLOVES | HIDEJUMPSUIT
	slowdown = 0

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
	order_flags = ORDER_SPECIAL
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
/obj/item/clothing/suit/hardsuit/security
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "hardsuit-sec-old"
	helmettype = /obj/item/clothing/head/helmet/hardsuit/security

// MARK: TSF
/obj/item/clothing/suit/tsf_suitjacket
	name = "federate suit-jacket"
	desc = "Дорогая куртка прямиком из Центральных Миров. Имеет отличительные знаки ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "tsf_suit_jacket"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	worn_icon_state = "tsf_suit_jacket"
	body_parts_covered = CHEST | GROIN | ARMS

// MARK: Etamin ind.
/obj/item/clothing/suit/etamin_coat
	name = "Etamin Ind. officer coat"
	desc = "Этот плащ был создан специально для офицеров корпорации Etamin Industries. Если вы видите его на ком-то, то либо перед вами офицер корпорации, либо тот, кто отдал бешеные бабки за этот плащ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "ei_coat"
	body_parts_covered = CHEST | GROIN | ARMS

// MARK: USSP
/obj/item/clothing/suit/space/ussp_expedition
	name = "'Voskhod' EVA suit"
	desc = "Экспедиционный скафандр \"Восход\", создан для использования в космических экспедицях СССП. \
		Имеет небольшое бронепокрытие для обеспечения защиты в потенциально враждебных сценариях."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "voskhod_suit"
	armor_type = /datum/armor/suit_armor

// MARK: MB Coat
/obj/item/clothing/suit/mb_coat
	name = "elegant coat"
	desc = "Элегантное пальто. Популярно среди тех, кто ценит минимализм и стиль."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "mb_coat"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	body_parts_covered = CHEST | GROIN | ARMS

/obj/item/clothing/accessory/psycross
	name = "unusual silver cross"
	desc = "Серебрянный крест необычной формы. Смотря на него, кажется что он не из этого мира.."
	w_class = WEIGHT_CLASS_TINY
	attachment_slot = NONE
	icon_state = "psycross"
	icon = 'modular_bandastation/expedition/icons/ntci_armor.dmi'
	worn_icon = 'modular_bandastation/expedition/icons/ntci_armor_mob.dmi'
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
	allowed = null
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

/obj/item/clothing/suit/hardsuit/Initialize(mapload)
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

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
	icon = 'modular_bandastation/expedition/icons/armor.dmi'
	worn_icon = 'modular_bandastation/expedition/icons/armor_mob.dmi'
	icon_state = "ntci_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/hardsuit/ntci
	armor_type = /datum/armor/vest_marine_heavy
	slowdown = 0

/obj/item/clothing/head/helmet/hardsuit/ntci
	name = "silver-coated armored hardsuit helmet"
	desc = "Специальный боевой шлем костюма ВКД старой компоновки, такие уже давно не делают. Этот имеет серебрянные вставки, зачем они требуются - неясно."
	icon = 'modular_bandastation/expedition/icons/armor.dmi'
	worn_icon = 'modular_bandastation/expedition/icons/armor_mob.dmi'
	icon_state = "ntci_hardsuit_helmet"
	armor_type = /datum/armor/vest_marine_heavy

/obj/item/clothing/suit/hardsuit/zizo
	name = "avantyne hardsuit"
	desc = "Багровый боевой костюм ВКД старой компоновки, такие уже давно не делают. Этот сделан из неизвестного материала, и выглядит очень зловещим."
	icon = 'modular_bandastation/expedition/icons/armor.dmi'
	worn_icon = 'modular_bandastation/expedition/icons/armor_mob.dmi'
	icon_state = "zizo_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/hardsuit/zizo
	armor_type = /datum/armor/vest_marine_heavy
	slowdown = 0

/obj/item/clothing/head/helmet/hardsuit/zizo
	name = "avantyne hardsuit helmet"
	desc = "Багровый боевой шлем костюма ВКД старой компоновки, такие уже давно не делают. Этот сделан из неизвестного материала, и выглядит очень зловещим. Зачем ему столько визоров?"
	icon = 'modular_bandastation/expedition/icons/armor.dmi'
	worn_icon = 'modular_bandastation/expedition/icons/armor_mob.dmi'
	icon_state = "zizo_hardsuit_helmet"
	armor_type = /datum/armor/vest_marine_heavy
