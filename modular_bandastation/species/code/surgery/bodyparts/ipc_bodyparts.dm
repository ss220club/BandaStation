// ============================================
// КОМПОНЕНТ IPC БОДИПАРТА
// ============================================

/datum/component/ipc_bodypart
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/ipc_bodypart/Initialize(mapload)
	. = ..()
	if(!istype(parent, /obj/item/bodypart))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/ipc_bodypart/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/datum/component/ipc_panel/panel = parent.GetComponent(/datum/component/ipc_panel)
	if(panel?.is_panel_open())
		examine_list += span_notice("Панель доступа открыта.")
	else
		examine_list += span_notice("Панель доступа закрыта.")

// ============================================
// БАЗОВЫЕ ЧАСТИ ТЕЛА IPC
// ============================================

/obj/item/bodypart/chest/ipc
	name = "Корпус КПБ"
	desc = "Основной корпус КПБ, содержащий все жизненно важные системы."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_chest_m"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	is_dimorphic = TRUE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 120

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/chest/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

/obj/item/bodypart/chest/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

// ============================================
// ГОЛОВА
// ============================================

/obj/item/bodypart/head/ipc
	name = "Голова КПБ"
	desc = "Голова КПБ с оптическими и аудио-сенсорами."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_head"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	head_flags = HEAD_LIPS|HEAD_DEBRAIN|HEAD_HAIR
	is_dimorphic = FALSE
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 80

	var/screen_icon = "BSOD"
	var/antenna_type = "None"
	var/brute_reduction = 0
	var/burn_reduction = 0

	/// Суффикс тела для get_limb_icon() вместо стандартного body_zone.
	/// null = использует "ipc_head" (стандарт).
	/// "monitor" = использует "ipc_monitor" (голова-монитор с экраном).
	var/ipc_visual_state = null

/obj/item/bodypart/head/ipc/generate_icon_key()
	. = ..()
	if(ipc_visual_state)
		. += "-[ipc_visual_state]"

/obj/item/bodypart/head/ipc/get_limb_icon(dropped, mob/living/carbon/update_on)
	if(isnull(ipc_visual_state))
		return ..()
	var/old_body_zone = body_zone
	body_zone = ipc_visual_state
	. = ..()
	body_zone = old_body_zone

/obj/item/bodypart/head/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

/obj/item/bodypart/head/ipc/drop_organs(mob/user, violent_removal)
	. = ..()
	var/atom/drop_location = get_atom_on_turf(src)
	for(var/obj/item/organ/internal_organ in contents)
		internal_organ.Remove(owner)
		internal_organ.forceMove(drop_location)

/obj/item/bodypart/head/ipc/monitor
	name = "Голова-монитор КПБ"
	desc = "Голова-монитор КПБ с встроенным дисплеем вместо лица."
	ipc_visual_state = "monitor"

// ============================================
// ЛЕВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/left/ipc
	name = "Левая рука КПБ"
	desc = "Левая рука КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/grip_strength = 1.0
	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/arm/left/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

// ============================================
// ПРАВАЯ РУКА
// ============================================

/obj/item/bodypart/arm/right/ipc
	name = "Правая рука КПБ"
	desc = "Правая рука КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_arm"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/grip_strength = 1.0
	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/arm/right/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

// ============================================
// ЛЕВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/left/ipc
	name = "Левая нога КПБ"
	desc = "Левая нога КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_l_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/leg/left/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

// ============================================
// ПРАВАЯ НОГА
// ============================================

/obj/item/bodypart/leg/right/ipc
	name = "Правая нога КПБ"
	desc = "Правая нога КПБ."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_r_leg"
	icon_greyscale = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	limb_id = SPECIES_IPC
	biological_state = BIO_ROBOTIC
	bodytype = BODYTYPE_IPC
	max_damage = 70

	var/chassis_type = "Unbranded"
	var/brute_reduction = 0
	var/burn_reduction = 0

/obj/item/bodypart/leg/right/ipc/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ipc_panel)
	AddComponent(/datum/component/ipc_bodypart)

// ============================================
// УРОН И СПАРКИ
// ============================================

/// Общая логика IPC урона
/// Вызывается из каждого receive_damage вместо дублирования кода.
/obj/item/bodypart/proc/ipc_on_receive_damage(brute, burn)
	if(brute > 10 || burn > 10)
		do_sparks(3, TRUE, src)
	if(get_damage() >= max_damage * 0.8 && owner && prob(20))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критическое повреждение [name]!"))

// ============================================
// ПРИСОЕДИНЕНИЕ КОНЕЧНОСТЕЙ
// ============================================

/obj/item/bodypart/chest/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	var/gender_suffix = (H.gender == FEMALE) ? "f" : "m"
	icon_state = "ipc_chest_[gender_suffix]"
	return TRUE

/obj/item/bodypart/head/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/arm/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/left/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE

/obj/item/bodypart/leg/right/ipc/try_attach_limb(mob/living/carbon/human/H, special)
	if(!..())
		return FALSE
	to_chat(H, span_notice("Системная диагностика: [name] подключена и функционирует нормально."))
	return TRUE
