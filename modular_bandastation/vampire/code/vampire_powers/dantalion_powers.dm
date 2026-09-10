/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/vampire)
	vampire.subclass.thrall_cap++
	gain_desc = "Теперь вы можете подчинить ещё одного человека — вплоть до [vampire.subclass.thrall_cap]."

/datum/vampire_passive/increment_thrall_cap/two
/datum/vampire_passive/increment_thrall_cap/three

/datum/action/cooldown/spell/pointed/vampire_enthrall
	name = "Подчинение"
	desc = "Используйте большую часть своей силы, чтобы обратить верность тех, кто никому не предан, только себе."
	gain_desc = "Вы обрели способность подчинять людей своей воле."
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
	user.visible_message(span_warning("[user] кусает [target] за шею!"), span_warning("Вы кусаете [target] за шею и начинаете передавать силу."))
	to_chat(target, span_warning("Вы чувствуете, как щупальца зла проникают в ваш разум."))
	if(!do_after(user, 15 SECONDS, target = target))
		to_chat(user, span_warning("Вы или ваша цель сдвинулись."))
		return
	if(!can_enthrall(user, target))
		return
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/component/vampire_ability/ability = GetComponent(/datum/component/vampire_ability)
	ability.deduct_blood(src)
	var/datum/antagonist/vampire_thrall/thrall = new(vampire)
	if(!target.mind.add_antag_datum(thrall))
		qdel(thrall)
		to_chat(user, span_warning("Разум [target] ускользает из вашей хватки."))
		return
	target.Stun(4 SECONDS)
	log_combat(user, target, "vampire enthralled")

/datum/action/cooldown/spell/pointed/vampire_enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/human/target)
	if(!target.mind)
		to_chat(user, span_warning("Разум [target] недоступен для подчинения."))
		return FALSE
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire.subclass.thrall_cap <= length(vampire.get_thralls()))
		to_chat(user, span_warning("У вас недостаточно сил, чтобы подчинить кого-то ещё."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || target.mind.has_antag_datum(/datum/antagonist/vampire) || target.mind.has_antag_datum(/datum/antagonist/vampire_thrall) || HAS_MIND_TRAIT(target, TRAIT_HOLY))
		target.visible_message(span_warning("[target], похоже, сопротивляется подчинению!"), span_notice("Вы чувствуете знакомое ощущение в черепе, быстро исчезающее без следа."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/vampire_commune
	name = "Общение"
	desc = "Телепатически общайтесь со своими рабами."
	gain_desc = "Вы обрели способность общаться со своими рабами телепатически."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "vamp_communication"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/vampire_commune/New(Target)
	. = ..()
	add_vampire_ability()

/datum/action/cooldown/spell/vampire_commune/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/message = tgui_input_text(user, "Введите сообщение для рабов.", "Общение рабов")
	if(!message)
		return
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire.get_thralls())
		if(thrall.owner?.current)
			to_chat(thrall.owner.current, span_notice("[user.real_name] (Вампир-хозяин): [message]"))
	to_chat(user, span_notice("[user.real_name] (Вампир-хозяин): [message]"))
	log_say("(VAMPIRE) [message]", list("CONNECTION" = user))

/datum/action/cooldown/spell/pointed/vampire_pacify
	name = "Усмирение"
	desc = "Временно усмирите цель, лишив её возможности причинять вред."
	gain_desc = "Вы обрели способность усмирять чьи-то агрессивные наклонности, не позволяя причинять физический вред."
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
	gain_desc = "Вы обрели способность меняться местами с выбранным мобом."
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
	gain_desc = "Вы обрели способность становиться невидимым и создавать иллюзии-приманки."
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
	gain_desc = "Вы обрели способность снимать все обездвиживающие эффекты с ближайших рабов."
	button_icon = 'modular_bandastation/vampire/icons/mob/actions/actions.dmi'
	button_icon_state = "thralls_up"
	cooldown_time = 100 SECONDS
	aoe_radius = 7

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/New(Target)
	. = ..()
	add_vampire_ability(100)

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/get_things_to_cast_on(atom/center)
	. = list()
	var/datum/antagonist/vampire/vampire = owner.mind?.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/antagonist/vampire_thrall/thrall as anything in vampire?.get_thralls())
		if(thrall.owner?.current && get_dist(center, thrall.owner.current) <= aoe_radius)
			. += thrall.owner.current

/datum/action/cooldown/spell/aoe/vampire_rally_thralls/cast_on_thing_in_aoe(mob/living/carbon/human/thrall, atom/caster)
	var/image/overlay = image('modular_bandastation/vampire/icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
	playsound(thrall, 'modular_bandastation/vampire/sound/magic/staff_healing.ogg', 30)
	thrall.SetStun(0)
	thrall.SetKnockdown(0)
	thrall.SetParalyzed(0)
	thrall.SetImmobilized(0)
	thrall.SetUnconscious(0)
	thrall.SetSleeping(0)
	thrall.add_overlay(overlay)
	addtimer(CALLBACK(thrall, TYPE_PROC_REF(/atom, cut_overlay), overlay), 6 SECONDS)

/datum/action/cooldown/spell/vampire_blood_bond
	name = "Кровавая связь"
	desc = "Создаёт между вами и ближайшими рабами сеть, поровну распределяющую весь получаемый урон."
	gain_desc = "Вы обрели способность делить урон между собой и рабами."
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
		user.apply_status_effect(/datum/status_effect/vampire_thrall_net, user.mind.has_antag_datum(/datum/antagonist/vampire))

/datum/action/cooldown/spell/aoe/vampire_hysteria
	name = "Массовая истерия"
	desc = "Наложите мощную иллюзию: после краткого ослепления все поблизости будут видеть друг друга случайными животными."
	gain_desc = "Вы обрели способность после краткого ослепления заставлять всех поблизости видеть друг друга случайными животными."
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
	)
	target.cause_hallucination(pick(animal_delusions), "vampire mass hysteria")

/// A localized delusion used by Mass Hysteria. Each victim sees only the humans around them.
/datum/hallucination/delusion/preset/vampire_hysteria
	random_hallucination_weight = 0

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
