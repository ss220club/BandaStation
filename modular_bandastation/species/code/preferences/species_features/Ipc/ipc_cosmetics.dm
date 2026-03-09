// ============================================
// IPC COSMETICS — HEAD ACCESSORIES, FACE, TAIL
// ============================================
// Системы отображения косметики КПБ:
//   — Аксессуары на голове (крылья, рога, антенны и т.д.)
//   — Экран/лицо (выражение монитора)
//   — Хвост
// Наносятся как bodypart overlays на голову/грудь.
// ============================================

#define IPC_HEAD_ACC_ICON 'icons/bandastation/mob/species/ipc/ipc_head_accessories.dmi'
#define IPC_FACE_ICON     'icons/bandastation/mob/species/ipc/ipc_face.dmi'
#define IPC_TAILS_ICON    'icons/bandastation/mob/species/ipc/ipc_tails.dmi'

// Список всех доступных аксессуаров голов (key → human-readable name)
GLOBAL_LIST_INIT(ipc_head_accessory_options, list(
	"wings_s"     = "Крылья",
	"horns_s"     = "Рога",
	"ring_s"      = "Кольцо",
	"antennae_s"  = "Антенны",
	"tvantennae_s"= "TV-антенны",
	"tesla_s"     = "Тесла-катушки",
	"light_s"     = "Фонарь",
	"cyberhead_s" = "Кибер-голова",
	"sidelights_s"= "Боковые огни",
	"antlers_s"   = "Рога (олень)",
	"droneeyes_s" = "Глаза дрона",
	"crowned_s"   = "Корона",
))

// Список всех доступных экранов (key → human-readable name)
GLOBAL_LIST_INIT(ipc_face_options, list(
	"waiting_s"         = "Ожидание",
	"blue_s"            = "Синий",
	"red_s"             = "Красный",
	"green_s"           = "Зелёный",
	"orange_s"          = "Оранжевый",
	"pink_s"            = "Розовый",
	"purple_s"          = "Фиолетовый",
	"yellow_s"          = "Жёлтый",
	"rainbow_s"         = "Радуга",
	"rgb_s"             = "RGB",
	"music_s"           = "Музыка",
	"heart_s"           = "Сердечко",
	"nature_s"          = "Природа",
	"shower_s"          = "Дождь",
	"smoking_s"         = "Дымок",
	"monoeye_s"         = "Моноглаз",
	"blinkingeye_s"     = "Мигающий глаз",
	"goggles_s"         = "Очки",
	"static_s"          = "Помехи",
	"scroll_s"          = "Скролл",
	"console_s"         = "Консоль",
	"breakout_s"        = "Breakout",
	"eight_s"           = "8-бит",
	"gol_glider_s"      = "GOL Планер",
	"off_hesp_alt_s"    = "Выкл. (Hesphiastos)",
	"pink_hesp_alt_s"   = "Розовый (Hesphiastos)",
	"orange_hesp_alt_s" = "Оранжевый (Hesphiastos)",
	"goggles_hesp_alt_s"= "Очки (Hesphiastos)",
	"scroll_hesp_alt_s" = "Скролл (Hesphiastos)",
	"rgb_hesp_alt_s"    = "RGB (Hesphiastos)",
	"rainbow_hesp_alt_s"= "Радуга (Hesphiastos)",
))

// ============================================
// BODYPART OVERLAY: HEAD ACCESSORY
// ============================================

/datum/bodypart_overlay/ipc_head_accessory
	layers = EXTERNAL_ADJACENT
	blocks_emissive = EMISSIVE_BLOCK_NONE
	/// Имя стейта из ipc_head_accessories.dmi
	var/state = ""
	/// Цвет тонирования (null = без тонирования)
	var/icon_color = null

/datum/bodypart_overlay/ipc_head_accessory/generate_icon_cache()
	. = ..()
	. += state
	if(icon_color)
		. += icon_color

/datum/bodypart_overlay/ipc_head_accessory/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	. = list()
	if(!state) return
	var/image/img = image(IPC_HEAD_ACC_ICON, icon_state = state, layer = layer)
	if(icon_color)
		img.color = icon_color
	. += img

// ============================================
// BODYPART OVERLAY: FACE / ЭКРАН
// ============================================

/datum/bodypart_overlay/ipc_face_overlay
	layers = EXTERNAL_FRONT
	blocks_emissive = EMISSIVE_BLOCK_NONE
	/// Имя стейта из ipc_face.dmi
	var/state = ""

/datum/bodypart_overlay/ipc_face_overlay/generate_icon_cache()
	. = ..()
	. += state

/datum/bodypart_overlay/ipc_face_overlay/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	. = list()
	if(!state) return
	. += image(IPC_FACE_ICON, icon_state = state, layer = layer)

// ============================================
// BODYPART OVERLAY: ХВОСТ
// Рендерится только за спрайтом персонажа (EXTERNAL_BEHIND).
// EXTERNAL_FRONT убран — он рендерился поверх тела и давал двойной спрайт.
// ============================================

/datum/bodypart_overlay/ipc_tail
	layers = EXTERNAL_BEHIND
	blocks_emissive = EMISSIVE_BLOCK_NONE
	/// Основной цвет хвоста (null = без тонирования)
	var/icon_color = null
	/// Вторичный цвет хвоста для secondary-спрайтов (null = без тонирования)
	var/secondary_icon_color = null

/datum/bodypart_overlay/ipc_tail/generate_icon_cache()
	. = ..()
	. += "ipc_tail"
	if(icon_color)
		. += icon_color
	if(secondary_icon_color)
		. += secondary_icon_color

/datum/bodypart_overlay/ipc_tail/get_overlay(layer, obj/item/bodypart/limb)
	. = list()
	if(layer != EXTERNAL_BEHIND)
		return .
	var/image/img_behind = image(IPC_TAILS_ICON, icon_state = "ipc_tail_plug_BEHIND", layer = bitflag_to_layer(EXTERNAL_BEHIND))
	if(icon_color)
		img_behind.color = icon_color
	. += img_behind
	if(secondary_icon_color)
		var/image/img_sec_behind = image(IPC_TAILS_ICON, icon_state = "ipc_tail_secondary_plug_BEHIND", layer = bitflag_to_layer(EXTERNAL_BEHIND))
		img_sec_behind.color = secondary_icon_color
		. += img_sec_behind

// ============================================
// APPLY PROCS
// ============================================

/// Устанавливает аксессуар на голове IPC.
/// state = "" убирает аксессуар.
/proc/apply_ipc_head_accessory(mob/living/carbon/human/H, state)
	var/obj/item/bodypart/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return
	// Убираем старый
	for(var/datum/bodypart_overlay/ipc_head_accessory/old in head.bodypart_overlays)
		head.remove_bodypart_overlay(old)
		qdel(old)
	if(!state)
		return
	var/datum/bodypart_overlay/ipc_head_accessory/overlay = new()
	overlay.state = state
	overlay.icon_color = H.dna?.features["ipc_head_accessory_color"]
	head.add_bodypart_overlay(overlay)

/// Устанавливает изображение экрана/лица IPC.
/// state = "" убирает оверлей (стандартный экран бренда остаётся).
/proc/apply_ipc_face(mob/living/carbon/human/H, state)
	var/obj/item/bodypart/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return
	for(var/datum/bodypart_overlay/ipc_face_overlay/old in head.bodypart_overlays)
		head.remove_bodypart_overlay(old)
		qdel(old)
	if(!state)
		return
	var/datum/bodypart_overlay/ipc_face_overlay/overlay = new()
	overlay.state = state
	head.add_bodypart_overlay(overlay)

/// Включает или убирает хвост на груди IPC.
/proc/apply_ipc_tail(mob/living/carbon/human/H, enabled)
	var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/datum/bodypart_overlay/ipc_tail/old in chest.bodypart_overlays)
		chest.remove_bodypart_overlay(old)
		qdel(old)
	if(!enabled)
		return
	var/datum/bodypart_overlay/ipc_tail/overlay = new()
	overlay.icon_color = H.dna?.features["ipc_tail_color"]
	overlay.secondary_icon_color = H.dna?.features["ipc_tail_secondary_color"]
	chest.add_bodypart_overlay(overlay)

// ============================================
// PREFERENCES: КОСМЕТИКА КПБ
// Отображаются в стандартном меню фичей расы.
// ============================================

/datum/preference/choiced/ipc_head_accessory
	savefile_key = "feature_ipc_head_accessory"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODYPARTS
	main_feature_name = "Аксессуар головы"
	can_randomize = FALSE

/datum/preference/choiced/ipc_head_accessory/init_possible_values()
	var/list/values = list("")
	for(var/key in GLOB.ipc_head_accessory_options)
		values += key
	return values

/datum/preference/choiced/ipc_head_accessory/create_default_value()
	return ""

/datum/preference/choiced/ipc_head_accessory/compile_constant_data()
	. = ..()
	var/list/display_names = list("" = "Нет")
	for(var/key in GLOB.ipc_head_accessory_options)
		display_names[key] = GLOB.ipc_head_accessory_options[key]
	.[CHOICED_PREFERENCE_DISPLAY_NAMES] = display_names

/datum/preference/choiced/ipc_head_accessory/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return istype(species, /datum/species/ipc)

/datum/preference/choiced/ipc_head_accessory/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	target.dna.features["feature_ipc_head_accessory"] = value
	apply_ipc_head_accessory(target, value)

/datum/preference/choiced/ipc_tail
	savefile_key = "feature_ipc_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODYPARTS
	main_feature_name = "Хвост"
	can_randomize = FALSE

/datum/preference/choiced/ipc_tail/compile_constant_data()
	. = ..()
	.[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"none" = "Нет",
		"plug" = "Заглушка"
	)

/datum/preference/choiced/ipc_tail/init_possible_values()
	return list("none", "plug")

/datum/preference/choiced/ipc_tail/create_default_value()
	return "none"

/datum/preference/choiced/ipc_tail/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return istype(species, /datum/species/ipc)

/datum/preference/choiced/ipc_tail/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	target.dna.features["feature_ipc_tail"] = value
	apply_ipc_tail(target, value == "plug")

// ============================================
// PREFERENCE: РУКА ЗАРЯДНИКА
// Выбирает, в какую руку установлен встроенный зарядный порт.
// Если выбрана не та рука, зарядник переустанавливается.
// ============================================

/datum/preference/choiced/ipc_charger_arm
	savefile_key = "feature_ipc_charger_arm"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODYPARTS
	main_feature_name = "Рука зарядника"
	can_randomize = FALSE

/datum/preference/choiced/ipc_charger_arm/compile_constant_data()
	. = ..()
	.[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"left" = "Левая рука",
		"right" = "Правая рука"
	)

/datum/preference/choiced/ipc_charger_arm/init_possible_values()
	return list("left", "right")

/datum/preference/choiced/ipc_charger_arm/create_default_value()
	return "left"

/datum/preference/choiced/ipc_charger_arm/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return istype(species, /datum/species/ipc)

/datum/preference/choiced/ipc_charger_arm/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	var/datum/species/ipc/S = target.dna.species
	var/zone = (value == "right") ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM
	S.ipc_charger_arm_zone = zone

	// Переставляем зарядник в нужную руку если он уже установлен не там
	for(var/obj/item/implant/ipc/charger/existing in target.implants)
		if(existing.installed_in_zone == zone)
			return  // Уже в правильной руке
		// Удаляем и переустанавливаем в нужной руке
		qdel(existing)
		break

	var/obj/item/implant/ipc/charger/impl = new()
	impl.implant(target, zone, null, TRUE, TRUE)

// ============================================
// BRAND FACE FILTERING
// ============================================

/// Возвращает список разрешённых экранов для данного бренда.
/// zeng_hu и cybersun — пустой список (экраны не поддерживаются).
/// hesphiastos — только HESP-варианты (_hesp_alt_s).
/// Все остальные — только обычные экраны (без _hesp_alt_s).
/proc/get_ipc_face_options_for_brand(brand_key)
	if(brand_key == "zeng_hu" || brand_key == "cybersun")
		return list()
	var/list/result = list()
	var/is_hesp = (brand_key == "hesphiastos")
	for(var/state in GLOB.ipc_face_options)
		var/hesp_face = findtext(state, "_hesp_alt_s") > 0
		if(is_hesp == hesp_face)
			result[state] = GLOB.ipc_face_options[state]
	return result

// ============================================
// ACTION: СМЕНА ЭКРАНА (раундовая)
// ============================================

/datum/action/innate/ipc_change_face
	name = "Сменить экран"
	desc = "Изменить изображение на экране своего монитора."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_monitor"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/innate/ipc_change_face/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S))
		return

	// Получаем разрешённые экраны для бренда
	var/list/allowed = get_ipc_face_options_for_brand(S.ipc_brand_key)
	if(!length(allowed))
		to_chat(H, span_warning("Этот бренд шасси не поддерживает смену экрана."))
		return

	// Формируем список: имя → стейт
	var/list/display_names = list("Нет (убрать)" = "")
	for(var/state in allowed)
		display_names[allowed[state]] = state

	var/chosen_name = tgui_input_list(H, "Выберите изображение экрана:", "Смена экрана КПБ", display_names)
	if(!chosen_name || QDELETED(H) || !istype(H))
		return

	var/chosen_state = display_names[chosen_name]
	S.ipc_face_state = chosen_state
	apply_ipc_face(H, chosen_state)

// ============================================
// COLOR PREFERENCES: ЦВЕТ АКСЕССУАРА ГОЛОВЫ И ХВОСТА
// ============================================

/datum/preference/color/ipc_head_accessory_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "ipc_head_accessory_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/ipc_head_accessory_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/ipc_head_accessory_color/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return istype(species, /datum/species/ipc)

/datum/preference/color/ipc_head_accessory_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	target.dna.features["ipc_head_accessory_color"] = value
	// Перерисовываем аксессуар с новым цветом
	apply_ipc_head_accessory(target, target.dna.features["feature_ipc_head_accessory"])

/datum/preference/color/ipc_tail_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "ipc_tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/ipc_tail_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/ipc_tail_color/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	return istype(species, /datum/species/ipc)

/datum/preference/color/ipc_tail_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	target.dna.features["ipc_tail_color"] = value
	// Перерисовываем хвост с новым цветом
	apply_ipc_tail(target, target.dna.features["feature_ipc_tail"] == "plug")

/datum/preference/color/ipc_tail_secondary_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "ipc_tail_secondary_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/ipc_tail_secondary_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/ipc_tail_secondary_color/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE
	var/datum/species/species = GLOB.species_prototypes[preferences.read_preference(/datum/preference/choiced/species)]
	if(!istype(species, /datum/species/ipc))
		return FALSE
	// Показываем только если хвост включён
	return preferences.read_preference(/datum/preference/choiced/ipc_tail) == "plug"

/datum/preference/color/ipc_tail_secondary_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target.dna?.species, /datum/species/ipc))
		return
	target.dna.features["ipc_tail_secondary_color"] = value
	apply_ipc_tail(target, target.dna.features["feature_ipc_tail"] == "plug")

#undef IPC_HEAD_ACC_ICON
#undef IPC_FACE_ICON
#undef IPC_TAILS_ICON
