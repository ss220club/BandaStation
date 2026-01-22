
// ============================================
// ЗАКРЫТИЕ ПАНЕЛИ ГАЕЧНЫМ КЛЮЧОМ (EMERGENCY)
// ============================================

/datum/surgery_operation/limb/ipc_emergency_close_panel
	name = "Закрутить панель (аварийно)"
	desc = "Быстро закрутить открытую панель шасси IPC гаечным ключом."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 1.5 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/tools/ratchet.ogg'

	implements = list(
		TOOL_WRENCH = 1,
		/obj/item/wrench = 1
	)

/datum/surgery_operation/limb/ipc_emergency_close_panel/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	// Проверяем bodytype
	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!limb?.owner?.dna?.species || !istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Только для грудной клетки и головы
	if(limb.body_zone != BODY_ZONE_CHEST && limb.body_zone != BODY_ZONE_HEAD)
		return FALSE

	// Проверяем что панель открыта или подготовлена
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel)
		return FALSE

	// Можно закрыть если панель открыта (1) или подготовлена (2)
	if(panel.panel_state == 0) // IPC_PANEL_CLOSED
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_emergency_close_panel/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете закручивать панель на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает закручивать панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_emergency_close_panel/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(panel)
		panel.panel_state = 0 // IPC_PANEL_CLOSED

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы закрутили панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закрутил панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Панель доступа закрыта."))
	playsound(limb, 'sound/items/tools/ratchet.ogg', 50, TRUE)

/datum/surgery_operation/limb/incise_skin
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/amputate
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC | BODYTYPE_PEG)


/datum/surgery_operation/limb/autopsy
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/bioware
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/prepare_cavity
	required_bodytype = ~(BODYTYPE_IPC)

/datum/surgery_operation/limb/filter_blood
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/retract_skin
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/close_skin
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/clamp_bleeders
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/unclamp_bleeders
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/saw_bones
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/fix_bones
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/drill_bones
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/incise_organs
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/lipoplasty
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/organ_manipulation
	required_bodytype = ~(BODYTYPE_IPC | BODYTYPE_ROBOTIC)

