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

/datum/bodypart_overlay/ipc_head_accessory/generate_icon_cache()
	. = ..()
	. += state

/datum/bodypart_overlay/ipc_head_accessory/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	. = list()
	if(!state) return
	. += image(IPC_HEAD_ACC_ICON, icon_state = state, layer = layer)

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
// Один датум рендерит ОБА слоя: BEHIND и FRONT.
// ============================================

/datum/bodypart_overlay/ipc_tail
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	blocks_emissive = EMISSIVE_BLOCK_NONE

/datum/bodypart_overlay/ipc_tail/generate_icon_cache()
	. = ..()
	. += "ipc_tail"

/datum/bodypart_overlay/ipc_tail/get_overlay(layer, obj/item/bodypart/limb)
	. = list()
	switch(layer)
		if(EXTERNAL_BEHIND)
			. += image(IPC_TAILS_ICON, icon_state = "ipc_tail_plug_BEHIND", layer = bitflag_to_layer(EXTERNAL_BEHIND))
		if(EXTERNAL_FRONT)
			. += image(IPC_TAILS_ICON, icon_state = "ipc_tail_plug_FRONT",  layer = bitflag_to_layer(EXTERNAL_FRONT))

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
	chest.add_bodypart_overlay(overlay)

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

	// Формируем список имён → стейтов
	var/list/display_names = list("Нет (убрать)" = "")
	for(var/state in GLOB.ipc_face_options)
		display_names[GLOB.ipc_face_options[state]] = state

	var/chosen_name = tgui_input_list(H, "Выберите изображение экрана:", "Смена экрана КПБ", display_names)
	if(!chosen_name || QDELETED(H) || !istype(H))
		return

	var/chosen_state = display_names[chosen_name]

	// Сохраняем в species var
	var/datum/species/ipc/S = H.dna?.species
	if(istype(S))
		S.ipc_face_state = chosen_state

	apply_ipc_face(H, chosen_state)

#undef IPC_HEAD_ACC_ICON
#undef IPC_FACE_ICON
#undef IPC_TAILS_ICON
