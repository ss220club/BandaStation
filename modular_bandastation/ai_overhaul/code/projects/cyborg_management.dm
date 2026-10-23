/** Базовое исследование для обслуживания связанных киборгов. */
/datum/ai_project/cyborg_management_basic
	name = "Cyborg Management Basics"
	description = "Защищённые протоколы обслуживания подключённых киборгов. Открывает проекты дистанционной разблокировки и сброса модели."
	research_cost = 2500
	can_be_run = FALSE
	category = AI_PROJECT_CYBORG

/** Открывает дистанционное снятие блокировки связанного киборга. */
/datum/ai_project/cyborg_management_unlock
	name = "Cyborg Management - Unlock"
	description = "Снимает блокировку активного подключённого киборга. Требует восстанавливаемого заряда разрешения на обслуживание."
	research_cost = 2500
	research_requirements = list(/datum/ai_project/cyborg_management_basic)
	category = AI_PROJECT_CYBORG
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/ai_borg_maintenance/unlock
	ability_recharge_cost = 2500

/datum/ai_project/cyborg_management_unlock/finish()
	add_ability(ability_path)

/** Открывает дистанционный сброс модели связанного киборга. */
/datum/ai_project/cyborg_management_reset
	name = "Cyborg Management - Reset"
	description = "Сбрасывает модель активного подключённого киборга. Требует восстанавливаемого заряда разрешения на обслуживание."
	research_cost = 2500
	research_requirements = list(/datum/ai_project/cyborg_management_basic)
	category = AI_PROJECT_CYBORG
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/ai_borg_maintenance/reset
	ability_recharge_cost = 2500

/datum/ai_project/cyborg_management_reset/finish()
	add_ability(ability_path)

/** Проверяет связь с киборгом и расходует заряд на разрешённое обслуживание. */
/datum/action/innate/ai/ranged/ai_borg_maintenance
	uses = 1
	max_uses = 1
	button_icon_state = "robotic_factory"
	enable_text = span_notice("Выберите подключённого киборга для дистанционного обслуживания.")
	disable_text = span_notice("Дистанционное обслуживание отменено.")

/datum/action/innate/ai/ranged/ai_borg_maintenance/IsAvailable(feedback = FALSE)
	return uses > 0 && owner_AI && !owner_AI.control_disabled && owner_AI.in_network_core() && ..()

/datum/action/innate/ai/ranged/ai_borg_maintenance/adjust_uses(amount, silent)
	uses = clamp(uses + amount, 0, max_uses)
	build_all_button_icons()

/datum/action/innate/ai/ranged/ai_borg_maintenance/do_ability(mob/living/user, atom/clicked_on)
	if(user != owner_AI || !IsAvailable() || !iscyborg(clicked_on))
		return FALSE
	var/mob/living/silicon/robot/borg = clicked_on
	if(borg.stat == DEAD || !(borg in owner_AI.connected_robots) || !owner_AI.can_see(borg))
		return FALSE
	if(!perform_maintenance(borg))
		return FALSE
	log_game("[key_name(owner_AI)] used [name] on connected cyborg [key_name(borg)].")
	to_chat(borg, span_notice("[owner_AI] выполнил дистанционное обслуживание: [name]."))
	adjust_uses(-1)
	unset_ranged_ability(user)
	return TRUE

/** Выполняет выбранную операцию обслуживания уже проверенного связанного киборга. */
/datum/action/innate/ai/ranged/ai_borg_maintenance/proc/perform_maintenance(mob/living/silicon/robot/borg)
	return FALSE

/** Снимает блокировку связанного киборга. */
/datum/action/innate/ai/ranged/ai_borg_maintenance/unlock
	name = "Разблокировать киборга"
	desc = "Снять блокировку подключённого киборга."

/datum/action/innate/ai/ranged/ai_borg_maintenance/unlock/perform_maintenance(mob/living/silicon/robot/borg)
	if(!borg.lockcharge || borg.wires?.is_cut(WIRE_LOCKDOWN))
		return FALSE
	borg.SetLockdown(FALSE)
	return TRUE

/** Сбрасывает модель связанного киборга штатным способом. */
/datum/action/innate/ai/ranged/ai_borg_maintenance/reset
	name = "Сбросить модель киборга"
	desc = "Сбросить модель подключённого киборга, чтобы он мог выбрать новую."

/datum/action/innate/ai/ranged/ai_borg_maintenance/reset/perform_maintenance(mob/living/silicon/robot/borg)
	if(!borg.has_model())
		return FALSE
	borg.ResetModel()
	return TRUE
