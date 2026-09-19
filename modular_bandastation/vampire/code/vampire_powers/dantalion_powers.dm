/datum/vampire_passive/increment_thrall_cap
	var/new_cap = 2

/datum/vampire_passive/increment_thrall_cap/New()
	gain_desc = "Теперь вы можете подчинить ещё одного человека — вплоть до [new_cap]."
	. = ..()

/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/vampire)
	vampire.subclass.thrall_cap = max(vampire.subclass.thrall_cap, new_cap)

/datum/vampire_passive/increment_thrall_cap/two
	new_cap = 3

/datum/vampire_passive/increment_thrall_cap/three
	new_cap = 4


/datum/action/cooldown/spell/pointed/vampire_enthrall
	name = "Подчинение"
	desc = "Используйте большую часть своей силы, чтобы обратить верность тех, кто никому не предан, только себе."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vampire_enthrall"
	cooldown_time = 1 MINUTES
	cast_range = 1

/datum/action/cooldown/spell/pointed/vampire_enthrall/New(Target)
	. = ..()
	add_vampire_ability(150, FALSE)

/datum/action/cooldown/spell/pointed/vampire_enthrall/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_enthrall/cast(mob/living/carbon/human/target)
	. = ..()
	var/mob/living/user = owner
	user.visible_message(span_warning("[user.declent_ru(NOMINATIVE)] кусает [target.declent_ru(ACCUSATIVE)] за шею!"), span_warning("Вы кусаете [target.declent_ru(ACCUSATIVE)] за шею и начинаете передавать силу."))
	to_chat(target, span_warning("Вы чувствуете, как щупальца зла проникают в ваш разум."))
	if(!do_after(user, 15 SECONDS, target = target))
		to_chat(user, span_warning("Вы или ваша цель сдвинулись."))
		return
	if(QDELETED(user) || QDELETED(target) || !can_enthrall(user, target))
		return
	SEND_SIGNAL(src, COMSIG_VAMPIRE_ABILITY_DEDUCT_BLOOD)
	if(!(SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_ENTHRALL, target) & COMPONENT_VAMPIRE_ABILITY_ENTHRALLED))
		to_chat(user, span_warning("Разум [target.declent_ru(ACCUSATIVE)] ускользает из вашей хватки."))
		return
	target.Stun(4 SECONDS)
	log_combat(user, target, "vampire enthralled")

/datum/action/cooldown/spell/pointed/vampire_enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/human/target)
	if(!target.mind)
		to_chat(user, span_warning("Разум [target.declent_ru(ACCUSATIVE)] недоступен для подчинения."))
		return FALSE
	if(!(SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_CAN_ENTHRALL) & COMPONENT_VAMPIRE_ABILITY_CAN_ENTHRALL))
		to_chat(user, span_warning("У вас недостаточно сил, чтобы подчинить кого-то ещё."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || HAS_TRAIT(target, TRAIT_VAMPIRE_LIKE) || HAS_MIND_TRAIT(target, TRAIT_HOLY))
		target.visible_message(span_warning("[capitalize(target.declent_ru(NOMINATIVE))], похоже, сопротивляется подчинению!"), span_notice("Вы чувствуете знакомое ощущение в голове, быстро исчезающее без следа."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_commune
	name = "Общение с рабами"
	desc = "Телепатически общайтесь со своими рабами и вампиром-хозяином."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vamp_communication"
	cooldown_time = 2 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/cooldown/spell/vampire_commune/New(Target, granted_to_thrall = FALSE)
	. = ..()
	if(!granted_to_thrall)
		add_vampire_ability()

/datum/action/cooldown/spell/vampire_commune/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/list/recipients = list()
	SEND_SIGNAL(owner, COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS, recipients)
	if(!length(recipients))
		to_chat(user, span_warning("Ваша связь с хозяином угасла."))
		return

	var/message = tgui_input_text(user, "Введите сообщение для сети вашего хозяина.", "Общение рабов", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(user))
		return

	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered(message)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return
	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered(message)
	if(soft_filter_result)
		if(tgui_alert(user, "Ваше сообщение содержит «[soft_filter_result[CHAT_FILTER_INDEX_WORD]]». [soft_filter_result[CHAT_FILTER_INDEX_REASON]] Продолжить?", "Слово с предупреждением", list("Да", "Нет")) != "Да")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". Message: \"[html_encode(message)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". Message: \"[message]\"")

	if(QDELETED(src) || QDELETED(user) || !length(recipients))
		if(!QDELETED(user))
			to_chat(user, span_warning("Ваша связь с хозяином угасла."))
		return

	var/is_thrall = HAS_TRAIT(user, TRAIT_VAMPIRE_LIKE) && !HAS_TRAIT(user, TRAIT_VAMPIRE)
	var/title = is_thrall ? "Раб" : "Вампир-хозяин"
	var/span = is_thrall ? "hypnophrase italics" : "hypnophrase bold"
	var/speaker_name = findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (в облике [user.name])"
	var/formatted_message = "<span class='[span]'><b>[title] [speaker_name]:</b> [message]</span>"
	for(var/mob/living/recipient in recipients)
		to_chat(recipient, formatted_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = recipient == user)
		if(recipient != user)
			user.cast_tts(
				recipient,
				message,
				is_local = FALSE,
				effects = list(/datum/singleton/sound_effect/telepathy),
				channel_override = CHANNEL_TTS_TELEPATHY,
				check_deafness = FALSE
			)
	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, user)] [formatted_message]", type = MESSAGE_TYPE_RADIO)
	user.log_talk(message, LOG_SAY, tag = "vampire")

/datum/action/cooldown/spell/pointed/vampire_pacify
	name = "Усмирение"
	desc = "Временно усмирите цель, лишив её возможности причинять вред."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "pacify"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_pacify/New(Target)
	. = ..()
	add_vampire_ability(10)

/datum/action/cooldown/spell/pointed/vampire_pacify/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_pacify/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.affects_vampire(owner))
		cast_on.set_timed_status_effect(30 SECONDS, /datum/status_effect/pacify)

/datum/action/cooldown/spell/pointed/vampire_switch_places
	name = "Подпространственный обмен"
	desc = "Поменяйтесь местами с целью."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "subspace_swap"
	cooldown_time = 30 SECONDS
	cast_range = 7

/datum/action/cooldown/spell/pointed/vampire_switch_places/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/pointed/vampire_switch_places/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/vampire_switch_places/cast(mob/living/target)
	. = ..()
	var/mob/living/user = owner
	if(target.can_block_magic())
		to_chat(user, span_warning("Заклинание не подействовало!"))
		to_chat(target, span_warning("Вы чувствуете, как пространство изгибается, но эффект быстро рассеивается."))
		return
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!do_teleport(target, user_turf, channel = TELEPORT_CHANNEL_MAGIC) || !do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_MAGIC))
		to_chat(user, span_warning("Пространство отказывается изгибаться для обмена."))

/datum/action/cooldown/spell/vampire_decoy
	name = "Создать приманку"
	desc = "Ненадолго станьте невидимым и создайте иллюзию-приманку, чтобы обмануть добычу."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "decoy"
	cooldown_time = 40 SECONDS

/datum/action/cooldown/spell/vampire_decoy/New(Target)
	. = ..()
	add_vampire_ability(30)

/datum/action/cooldown/spell/vampire_decoy/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/mob/living/basic/illusion/escape/decoy = new(get_turf(user))
	decoy.full_setup(user, target_mob = user, life = 20 SECONDS, damage = 0)
	user.alpha = 0
	addtimer(CALLBACK(src, PROC_REF(restore_visibility), user), 6 SECONDS)

/datum/action/cooldown/spell/vampire_decoy/proc/restore_visibility(mob/living/user)
	if(!QDELETED(user))
		user.alpha = initial(user.alpha)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls
	name = "Сбор рабов"
	desc = "Снимает все обездвиживающие эффекты с ваших рабов поблизости."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "thralls_up"
	cooldown_time = 100 SECONDS
	aoe_radius = 7

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/New(Target)
	. = ..()
	add_vampire_ability(100)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/get_things_to_cast_on(atom/center)
	. = list()
	SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_GET_THRALLS_IN_RANGE, center, aoe_radius, .)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/cast_on_thing_in_aoe(mob/living/carbon/human/thrall, atom/caster)
	var/image/overlay = image('modular_bandastation/vampire/icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
	playsound(thrall, 'modular_bandastation/vampire/sound/magic/staff_healing.ogg', 30)
	thrall.SetAllImmobility(0)
	thrall.set_stamina_loss(0)
	thrall.set_resting(FALSE, instant = TRUE)
	thrall.add_overlay(overlay)
	addtimer(CALLBACK(thrall, TYPE_PROC_REF(/atom, cut_overlay), overlay), 6 SECONDS)

/datum/action/cooldown/spell/vampire_blood_bond
	name = "Кровавая связь"
	desc = "Создаёт между вами и ближайшими рабами сеть, поровну распределяющую весь получаемый урон."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "blood_bond"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_blood_bond/New(Target)
	. = ..()
	add_vampire_ability(5)

/datum/action/cooldown/spell/vampire_blood_bond/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/datum/status_effect/vampire_thrall_net/net = user.has_status_effect(/datum/status_effect/vampire_thrall_net)
	if(net)
		qdel(net)
	else
		SEND_SIGNAL(owner, COMSIG_VAMPIRE_ABILITY_TOGGLE_THRALL_NET)

/datum/action/cooldown/spell/aoe/vampire_hysteria
	name = "Массовая истерия"
	desc = "Наложите мощную иллюзию: после краткого ослепления все поблизости будут видеть друг друга случайными животными."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "hysteria"
	cooldown_time = 180 SECONDS
	aoe_radius = 8

/datum/action/cooldown/spell/aoe/vampire_hysteria/New(Target)
	. = ..()
	add_vampire_ability(70)

/datum/action/cooldown/spell/aoe/vampire_hysteria/get_things_to_cast_on(atom/center)
	. = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(target != owner && target.affects_vampire(owner))
			. += target

/datum/action/cooldown/spell/aoe/vampire_hysteria/cast_on_thing_in_aoe(mob/living/carbon/human/target, atom/caster)
	target.flash_act(1, TRUE, TRUE)
	var/list/animal_delusions = list(
		/datum/hallucination/delusion/preset/vampire_hysteria/monkey,
		/datum/hallucination/delusion/preset/vampire_hysteria/corgi,
		/datum/hallucination/delusion/preset/vampire_hysteria/carp,
		/datum/hallucination/delusion/preset/vampire_hysteria/skeleton,
		/datum/hallucination/delusion/preset/vampire_hysteria/zombie,
		/datum/hallucination/delusion/preset/vampire_hysteria/demon,
	)
	target.cause_hallucination(pick(animal_delusions), "vampire mass hysteria")

/// A localized delusion used by Mass Hysteria. Each victim sees only the humans around them.
/datum/hallucination/delusion/preset/vampire_hysteria
	random_hallucination_weight = 0
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/vampire_hysteria/get_delusion_targets()
	. = list()
	for(var/mob/living/carbon/human/nearby_human in view(world.view, hallucinator))
		. += nearby_human

/datum/hallucination/delusion/preset/vampire_hysteria/monkey
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/vampire_hysteria/corgi
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/vampire_hysteria/carp
	delusion_icon_file = 'icons/mob/simple/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/preset/vampire_hysteria/skeleton
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/vampire_hysteria/zombie
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/vampire_hysteria/demon
	delusion_icon_file = 'icons/mob/simple/demon.dmi'
	delusion_icon_state = "slaughter_demon"
	delusion_name = "demon"
