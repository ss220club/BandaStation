// ============================================
// IPC ABILITIES
// ============================================
// Абилки для IPC: разгон системы, и т.д.

/// Абилка разгона системы - увеличивает скорость действий за счет нагрева процессора
/datum/action/cooldown/ipc_overclock
	name = "Разгон системы"
	desc = "Ускоряет процессы взаимодействия на 40% за счет повышения температуры процессора. Нагревает процессор на 10°C каждые 5 секунд."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "overdrive_0"
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 2 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/ipc_overclock/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Доступна только для IPC
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

/datum/action/cooldown/ipc_overclock/Remove(mob/living/remove_from)
	var/mob/living/carbon/human/H = owner
	if(istype(H) && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		if(S.overclock_active)
			deactivate_overclock(H, S)
	return ..()

/datum/action/cooldown/ipc_overclock/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE

	var/datum/species/ipc/S = H.dna.species

	// Toggle
	if(S.overclock_active)
		deactivate_overclock(H, S)
	else
		activate_overclock(H, S)

	StartCooldown()
	return TRUE

/datum/action/cooldown/ipc_overclock/proc/activate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = TRUE
	button_icon_state = "overdrive_1"
	background_icon_state = "bg_tech_blue_active"
	to_chat(H, span_notice("Разгон системы активирован! Скорость взаимодействия увеличена на [S.overclock_speed_bonus * 100]%."))
	to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Температура процессора будет повышаться!"))
	build_all_button_icons()

/datum/action/cooldown/ipc_overclock/proc/deactivate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = FALSE
	button_icon_state = "overdrive_0"
	background_icon_state = "bg_tech_blue"
	to_chat(H, span_notice("Разгон системы отключен. Процессор вернулся к нормальной работе."))
	build_all_button_icons()

