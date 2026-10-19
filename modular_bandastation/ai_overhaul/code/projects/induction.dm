/** Базовое исследование дистанционной индукционной зарядки. */
/datum/ai_project/induction_basic
	name = "Bluespace Induction Basics"
	description = "Базовое исследование для индукционных систем: дистанционной зарядки киборгов и аварийного питания ЛКП."
	research_cost = 1500
	ram_required = 0
	can_be_run = FALSE
	category = AI_PROJECT_INDUCTION

/** Разрешает общей индукционной способности заряжать киборгов. */
/datum/ai_project/induction_cyborg
	name = "Bluespace Induction - Cyborgs"
	description = "Позволяет зарядить любого видимого киборга на 33%."
	research_cost = 2500
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION

	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_cyborg/finish()
	var/datum/action/innate/ai/ranged/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/charge_borg_or_apc)
	if(ability)
		ability.works_on_borgs = TRUE
		ability.name = "Зарядить киборга"
		ability.desc = "Нажмите на киборга, чтобы зарядить его на 33%."
	else
		ability = locate(/datum/action/innate/ai/ranged/charge_borg_or_apc) in ai.actions
		ability.works_on_borgs = TRUE
		ability.name = "Зарядить киборга или ЛКП"
		ability.desc = "Нажмите на киборга или ЛКП, чтобы зарядить его на 33%."


/** Разрешает общей индукционной способности заряжать ЛКП. */
/datum/ai_project/induction_apc
	name = "Bluespace Induction - APCs"
	description = "Позволяет зарядить любой видимый ЛКП на 33%."
	research_cost = 2500
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION

	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_apc/finish()
	var/datum/action/innate/ai/ranged/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/charge_borg_or_apc)
	if(ability)
		ability.name = "Зарядить ЛКП"
		ability.desc = "Нажмите на ЛКП, чтобы зарядить его на 33%."
	else
		ability = locate(/datum/action/innate/ai/ranged/charge_borg_or_apc) in ai.actions
		ability.name = "Зарядить киборга или ЛКП"
		ability.desc = "Нажмите на киборга или ЛКП, чтобы зарядить его на 33%."
	ability.works_on_apcs = TRUE


/** Общая заряжаемая способность для обеих веток индукции. */
/datum/action/innate/ai/ranged/charge_borg_or_apc
	name = "Зарядить киборга или ЛКП"
	desc = "В зависимости от улучшений заряжает одного видимого киборга или ЛКП на 33%."
	button_icon_state = "electrified"
	uses = 1
	max_uses = 1
	enable_text = span_notice("Вы подготавливаете блюспейс-индукционные катушки. Нажмите на киборга или ЛКП, чтобы зарядить его батарею на 33%.")
	disable_text = span_notice("Вы отключаете индукционные катушки.")

	/// Разрешает индукционной способности заряжать киборгов.
	var/works_on_borgs = FALSE
	/// Разрешает индукционной способности заряжать ЛКП.
	var/works_on_apcs = FALSE

/datum/action/innate/ai/ranged/charge_borg_or_apc/do_ability(mob/living/user, atom/clicked_on)
	if(!iscyborg(clicked_on) && !isapc(clicked_on))
		to_chat(owner, span_warning("Можно заряжать только киборгов или ЛКП!"))
		return FALSE
	if(!works_on_borgs && iscyborg(clicked_on))
		to_chat(owner, span_warning("Можно заряжать только ЛКП!"))
		return FALSE
	if(!works_on_apcs && isapc(clicked_on))
		to_chat(owner, span_warning("Можно заряжать только киборгов!"))
		return FALSE

	owner.playsound_local(owner, SFX_SPARKS, 50, FALSE)
	if(charge_borg_or_apc(clicked_on))
		unset_ranged_ability(owner)
		adjust_uses(-1)
		do_sparks(3, FALSE, clicked_on)
		to_chat(owner, span_notice("Вы заряжаете [clicked_on.declent_ru(ACCUSATIVE)]."))
		clicked_on.audible_message(span_userdanger("От [clicked_on.declent_ru(GENITIVE)] доносится тихое электрическое жужжание!"))
	return TRUE

/** Заряжает подходящую неполную батарею на треть и сообщает об успешном результате. */
/datum/action/innate/ai/ranged/charge_borg_or_apc/proc/charge_borg_or_apc(atom/target)
	if(!target || QDELETED(target))
		return
	if(iscyborg(target))
		var/mob/living/silicon/robot/robot = target
		log_game("[key_name(usr)] charged [robot.name].")
		if(!robot.cell)
			to_chat(owner, span_warning("У [robot.declent_ru(GENITIVE)] нет батареи для зарядки!"))
			return FALSE
		if(robot.cell.charge >= robot.cell.maxcharge)
			to_chat(owner, span_warning("Батарея [robot.declent_ru(GENITIVE)] уже полностью заряжена!"))
			return FALSE
		robot.charge(null, robot.cell.maxcharge * 0.33)
		return TRUE
	if(isapc(target))
		var/obj/machinery/power/apc/apc = target
		var/turf/target_turf = get_turf(apc)
		log_game("[key_name(usr)] charged [apc.name] at [AREACOORD(target_turf)].")
		if(!apc.cell)
			to_chat(owner, span_warning("В ЛКП нет батареи для зарядки!"))
			return FALSE
		if(apc.cell.charge >= apc.cell.maxcharge)
			to_chat(owner, span_warning("ЛКП уже полностью заряжен!"))
			return FALSE
		apc.cell.give(apc.cell.maxcharge * 0.33)
		return TRUE

/datum/action/innate/ai/ranged/charge_borg_or_apc/adjust_uses(amt, silent)
	uses = clamp(uses + amt, 0, max_uses)
	build_all_button_icons()

/datum/action/innate/ai/ranged/charge_borg_or_apc/IsAvailable(feedback = FALSE)
	return uses > 0 && ..()
