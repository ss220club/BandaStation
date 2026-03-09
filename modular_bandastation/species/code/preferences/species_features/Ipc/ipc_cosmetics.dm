// ============================================
// IPC COSMETICS — ХВОСТ КПБ
// ============================================
// Оверлей хвоста. Рендерится только за спрайтом персонажа (EXTERNAL_BEHIND).
// EXTERNAL_FRONT намеренно убран — он рендерился поверх тела и давал двойной спрайт.

#define IPC_TAILS_ICON 'modular_bandastation/species/icons/ipc_tails.dmi'

/datum/bodypart_overlay/ipc_tail
	layers = EXTERNAL_BEHIND
	blocks_emissive = EMISSIVE_BLOCK_NONE
	var/icon_color = null
	var/secondary_icon_color = null

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

#undef IPC_TAILS_ICON
