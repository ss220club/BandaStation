// ============================================================
//  INFECTION ABILITY
// ============================================================

/// Ability for the infector to infect a nearby human with the Khaara virus.
/datum/action/cooldown/spell/pointed/khaara_infect
	name = "Заражение Кхара"
	desc = "Внедрить остатки вируса Кхара в разум цели, подчиняя её воле улья. Цель должна находиться рядом и не иметь ментальной защиты."
	button_icon = 'modular_bandastation/skills/icons/khaara.dmi'
	button_icon_state = "infect"
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	cast_range = 1

/datum/action/cooldown/spell/pointed/khaara_infect/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/H = cast_on
	if(H.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/khaara_infect/cast(mob/living/cast_on)
	. = ..()
	var/datum/status_effect/khaara_survivor/effect = owner.has_status_effect(/datum/status_effect/khaara_survivor)
	if(!effect || !effect.hivemind)
		to_chat(owner, span_warning("Ваш вирус Кхара недостаточно активен для заражения других."))
		return

	var/mob/living/carbon/human/target = cast_on
	effect.hivemind.infect(target, owner)


// ============================================================
//  HIVEMIND COMMUNICATION
// ============================================================

/// Innate action for hivemind communication — available to both infector and thralls.
/datum/action/cooldown/khaara_hivemind_comm
	name = "Речь Улья Кхара"
	desc = "Отправить мысленное сообщение всем участникам улья Кхара."
	button_icon = 'modular_bandastation/skills/icons/khaara.dmi'
	button_icon_state = "hivemind_com"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

	/// Weakref to the hivemind controller
	var/datum/weakref/hivemind_ref

/datum/action/cooldown/khaara_hivemind_comm/New(datum/khaara_hivemind/hivemind)
	. = ..()
	if(hivemind)
		hivemind_ref = WEAKREF(hivemind)

/datum/action/cooldown/khaara_hivemind_comm/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/cooldown/khaara_hivemind_comm/Activate(atom/target)
	var/datum/khaara_hivemind/hivemind = hivemind_ref?.resolve()
	if(!hivemind)
		to_chat(owner, span_warning("Связь с ульем потеряна."))
		return

	var/prompt = "Введите сообщение для улья:"
	if(owner.mind)
		var/datum/antagonist/khaara_thrall/antag = owner.mind.has_antag_datum(/datum/antagonist/khaara_thrall)
		if(antag?.thrall_objective)
			prompt += "\nВаша текущая цель: \"[antag.thrall_objective]\""

	var/message = tgui_input_text(owner, prompt, "Улей Кхара", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return

	log_directed_talk(owner, hivemind.get_infector_mob(), message, LOG_SAY, "khaara hivemind")
	hivemind.broadcast_message(message, owner)
	StartCooldown()


// ============================================================
//  CONTROL PANEL
// ============================================================

/// Innate action for the infector to open the hivemind control panel.
/datum/action/cooldown/khaara_hivemind_panel
	name = "Панель Улья Кхара"
	desc = "Открыть панель управления ульем Кхара для управления заражёнными."
	button_icon = 'modular_bandastation/skills/icons/khaara.dmi'
	button_icon_state = "hivemind_panel"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

	/// Weakref to the hivemind controller
	var/datum/weakref/hivemind_ref

/datum/action/cooldown/khaara_hivemind_panel/New(datum/khaara_hivemind/hivemind)
	. = ..()
	if(hivemind)
		hivemind_ref = WEAKREF(hivemind)

/datum/action/cooldown/khaara_hivemind_panel/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/cooldown/khaara_hivemind_panel/Activate(atom/target)
	var/datum/khaara_hivemind/hivemind = hivemind_ref?.resolve()
	if(!hivemind)
		to_chat(owner, span_warning("Связь с ульем потеряна."))
		return
	if(!hivemind.is_infector(owner))
		to_chat(owner, span_warning("Только источник улья может открыть панель управления."))
		return
	hivemind.ui_interact(owner)
	StartCooldown()
