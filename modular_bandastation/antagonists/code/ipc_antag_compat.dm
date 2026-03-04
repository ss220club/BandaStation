// ============================================
// ИПС: СОВМЕСТИМОСТЬ С АНТАГОНИСТАМИ
// ============================================
// КПБ — роботы. Ряд антагонистских механик несовместим с ними физически.
//
// Чейнджлинг: ИПС не может стать чейнджлингом (нет ДНК для поглощения).
// Культ: ИПС может быть завербован в культ, но не может чертить руны
//        (нет крови для ритуала, масло не является жертвенной субстанцией).
// Еретик (путь Луны): ИПС не имеет mob_mood (setup_mood() переопределён
//        в ipc_hud.dm). Прямые обращения mob_mood.adjust_sanity() вызывают
//        рантаймы — переопределяем проки с ?. null-safety.

// ============================================
// ЧЕЙНДЖЛИНГ: ИПС — недопустимый кандидат
// ============================================

/datum/dynamic_ruleset/roundstart/changeling/is_valid_candidate(mob/living/candidate, client/candidate_client)
	if(!..())
		return FALSE
	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	if(istype(species, /datum/species/ipc))
		return FALSE
	return TRUE

// ============================================
// КУЛЬТ: ИПС не может чертить руны кровью
// ============================================

/datum/component/cult_ritual_item/do_scribe_rune(obj/item/tool, mob/living/cultist)
	if(HAS_TRAIT(cultist, TRAIT_NOBLOOD))
		to_chat(cultist, span_warning("Масло КПБ не является жертвенной субстанцией — руна не может быть начертана."))
		return FALSE
	return ..()

// ============================================
// ЕРЕТИК (ПУТЬ ЛУНЫ): NULL-SAFETY ДЛЯ mob_mood
// ============================================

// Mansus Grasp: прямое обращение mob_mood.adjust_sanity(-30) без проверки.
// Заменяем ..() вручную (родитель только вызывает create_mark) + добавляем ?. .
/datum/heretic_knowledge/limited_amount/starting/base_moon/on_mansus_grasp(mob/living/source, mob/living/target)
	create_mark(source, target) // логика родительского проца (limited_amount/starting)

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		to_chat(target, span_danger("You hear echoing laughter from above..but it is dull and distant."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("Сверху доносится смех, отдающийся эхом."))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")
	carbon_target.mob_mood?.adjust_sanity(-30)

// Ringleader ascension aura: цикл по carbon в range(7) обращается к
// mob_mood.sanity без проверки — ИПС в радиусе действия вызовет рантайм.
/datum/heretic_knowledge/ultimate/moon_final/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS
	)

	for(var/mob/living/carbon/carbon_view in range(7, source))
		if(!carbon_view.mob_mood)
			continue
		var/carbon_sanity = carbon_view.mob_mood.sanity
		if(carbon_view.stat != CONSCIOUS)
			continue
		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue
		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MOON)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue
		new /obj/effect/temp_visual/moon_ringleader(get_turf(carbon_view))
		if(carbon_view.has_status_effect(/datum/status_effect/confusion))
			to_chat(carbon_view, span_big(span_hypnophrase("ВАШ РАЗУМ ТРЕЩИТ ОТ ТЫСЯЧИ ГОЛОСОВ, СЛИТЫХ В БЕЗУМНУЮ КАКОФОНИЮ ЗВУКОВ И МУЗЫКИ. КАЖДАЯ ЩЕПКА ВАШЕГО СУЩЕСТВА КРИЧИТ: «БЕГИ».")))
		carbon_view.adjust_confusion(2 SECONDS)
		carbon_view.mob_mood.adjust_sanity(-20)

		if(carbon_sanity >= 10)
			return
		// So our sanity is dead, time to fuck em up
		if(SPT_PROB(20, seconds_per_tick))
			to_chat(carbon_view, span_warning("оно эхом отдаётся в вас!"))
		visible_hallucination_pulse(
			center = get_turf(carbon_view),
			radius = 7,
			hallucination_duration = 50 SECONDS
		)
		carbon_view.adjust_temp_blindness(5 SECONDS)
		if(should_mind_explode(carbon_view))
			to_chat(carbon_view, span_boldbig(span_red(\
				"ВАШИ ЧУВСТВА ОХВАЧЕНЫ УЖАСОМ, КОГДА В ВАШ РАЗУМ ВТОРГАЕТСЯ ПОТУСТОРОННЯЯ СИЛА, ПЫТАЮЩАЯСЯ ПЕРЕПИСЫВАТЬ ВАШЕ СУЩЕСТВО. \
				ВЫ ДАЖЕ НЕ УСПЕВАЕТЕ КРИКНУТЬ, КАК ВАШ ИМПЛАНТ АКТИВИРУЕТ СВОЮ СИСТЕМУ АВАРИЙНОЙ ПСИОНИЧЕСКОЙ ЗАЩИТЫ, СНОСЯ ВАМ ГОЛОВУ.")))
			var/obj/item/bodypart/head/head = locate() in carbon_view.bodyparts
			if(!head?.dismember())
				carbon_view.gib(DROP_ALL_REMAINS)
			var/datum/effect_system/reagents_explosion/explosion = new(get_turf(carbon_view), 1, 1, 1)
			explosion.start(src)
		else
			attempt_conversion(carbon_view, source)

// Moon Amulet channel_amulet: non-heretic пользователь попадает на
// mob_mood.adjust_sanity(-50) без проверки.
/obj/item/clothing/neck/heretic_focus/moon_amulet/channel_amulet(mob/user, atom/target)

	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	if(!IS_HERETIC_OR_MONSTER(living_user))
		living_user.balloon_alert(living_user, "you feel a presence watching you")
		living_user.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		living_user.mob_mood?.adjust_sanity(-50)
		return FALSE
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target

	if(!ishuman(target))
		living_target.adjust_fire_loss(30)
		return TRUE
	var/mob/living/carbon/human/human_target = target
	if(IS_HERETIC_OR_MONSTER(human_target))
		living_user.balloon_alert(living_user, "resists effects!")
		return FALSE
	if(human_target.has_status_effect(/datum/status_effect/moon_slept) || human_target.has_status_effect(/datum/status_effect/moon_converted))
		human_target.balloon_alert(living_user, "causing damage!")
		human_target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 25)
		return FALSE
	if(human_target.can_block_magic(MAGIC_RESISTANCE_MOON))
		return FALSE
	if(!human_target.mob_mood)
		return FALSE
	if(human_target.mob_mood.sanity_level < sanity_threshold)
		human_target.balloon_alert(living_user, "their mind is too strong!")
		human_target.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		human_target.mob_mood.adjust_sanity(-sanity_damage)
	else
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			human_target.balloon_alert(living_user, "their mind almost bends but something protects it!")
			human_target.apply_status_effect(/datum/status_effect/moon_slept)
			return TRUE
		human_target.balloon_alert(living_user, "their mind bends to see the truth!")
		human_target.apply_status_effect(/datum/status_effect/moon_converted)
		living_user.log_message("made [human_target] insane.", LOG_GAME)
		human_target.log_message("was driven insane by [living_user]", LOG_GAME)
	return TRUE

// ============================================
// КАРТИНА «ПЛАЧУЩАЯ»: NULL-SAFETY ДЛЯ mob_mood
// ============================================

// examine_effects: mob_mood.mood_events.Remove() без проверки на null.
/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_hypnophrase("Передохни, пока что..."))
		examiner.mob_mood?.mood_events?.Remove("eldritch_weeping")
		examiner.add_mood_event("weeping_withdrawal", /datum/mood_event/eldritch_painting/weeping_withdrawal)
		return

	to_chat(examiner, span_notice("О, какое искусство! Один только взгляд на него проясняет ваши мысли."))
	examiner.remove_status_effect(/datum/status_effect/hallucination)
	examiner.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)

// ============================================
// БРОНЯ ЛУНЫ: NULL-SAFETY ДЛЯ mob_mood
// ============================================

// on_hud_created/on_hud_remove вызывают mob_mood.unmodify/modify_hud()
// без проверки — ИПС (carbon/human) вызывает крэш при надевании брони.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/on_hud_created(mob/living/carbon/human/wearer)
	SIGNAL_HANDLER
	var/datum/hud/original_hud = wearer.hud_used
	var/list/to_remove = list(/atom/movable/screen/stamina, /atom/movable/screen/healths, /atom/movable/screen/healthdoll/human)
	for(var/removing in original_hud.infodisplay)
		if(is_type_in_list(removing, to_remove))
			original_hud.infodisplay -= removing
			QDEL_NULL(removing)
	wearer.mob_mood?.unmodify_hud()
	health_hud = new(null, original_hud)
	original_hud.infodisplay += health_hud
	original_hud.show_hud(original_hud.hud_version)
	UnregisterSignal(wearer, COMSIG_MOB_HUD_CREATED)
	signal_registered -= COMSIG_MOB_HUD_CREATED

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/on_hud_remove(mob/living/carbon/human/wearer)
	var/datum/hud/original_hud = wearer.hud_used
	original_hud.infodisplay -= health_hud
	QDEL_NULL(health_hud)
	var/atom/movable/screen/stamina/stamina_hud = new(null, original_hud)
	var/atom/movable/screen/healths/old_health_hud = new(null, original_hud)
	var/atom/movable/screen/healthdoll/human/health_doll_hud = new(null, original_hud)
	original_hud.infodisplay += stamina_hud
	original_hud.infodisplay += old_health_hud
	original_hud.infodisplay += health_doll_hud
	wearer.mob_mood?.modify_hud()
	original_hud.show_hud(original_hud.hud_version)

// ============================================
// МАСКА БЕЗУМИЯ: NULL-SAFETY ДЛЯ mob_mood
// ============================================

// process(): direct_sanity_drain() вызывается на всех human_in_range,
// включая ИПС (subtype carbon/human), у которых mob_mood = null.
/obj/item/clothing/mask/madness_mask/process(seconds_per_tick)
	if(!local_user)
		return PROCESS_KILL

	if(IS_HERETIC_OR_MONSTER(local_user) && HAS_TRAIT(src, TRAIT_NODROP))
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range) || human_in_range.stat > SOFT_CRIT || human_in_range.is_blind())
			continue

		if(human_in_range.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			continue

		if(!human_in_range.mob_mood)
			continue

		human_in_range.mob_mood.direct_sanity_drain(rand(-2, -20) * seconds_per_tick)

		if(SPT_PROB(60, seconds_per_tick))
			human_in_range.adjust_hallucinations_up_to(10 SECONDS, 120 SECONDS)

		if(SPT_PROB(40, seconds_per_tick))
			human_in_range.set_jitter_if_lower(10 SECONDS)

		if(human_in_range.get_stamina_loss() <= 85 && SPT_PROB(30, seconds_per_tick))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjust_stamina_loss(10)

		if(SPT_PROB(25, seconds_per_tick))
			human_in_range.set_dizzy_if_lower(10 SECONDS)

// ============================================
// СТАТУС «MOON_CONVERTED»: NULL-SAFETY ДЛЯ mob_mood
// ============================================

// on_apply(): -150 + mob_mood.sanity без проверки.
// При mob_mood = null используем sanity = 0 (максимальное исцеление).
/datum/status_effect/moon_converted/on_apply()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.adjust_brute_loss(-150 + (owner.mob_mood?.sanity ?? 0))
	owner.adjust_fire_loss(-150 + (owner.mob_mood?.sanity ?? 0))

	to_chat(owner, span_hypnophrase(("ЛУНА УКАЗЫВАЕТ ТЕБЕ ПРАВДУ И ЛЖЕЦЫ ПЫТАЮТСЯ СКРЫТЬ ЕЕ, УБЕЙ ИХ ВСЕХ!!!</span>")))
	owner.balloon_alert(owner, "они лгут... ОНИ ВСЕ ЛГУТ!!!")
	owner.SetUnconscious(60 SECONDS, ignore_canstun = FALSE)
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/moon, "[id] status effect", duration = duration, affects_us = FALSE, affects_others = TRUE)
	return TRUE

// ============================================
// СНАРЯД ЛУННОГО ПАРАДА и ЗАКЛИНАНИЕ РАЗРЫВ РАЗУМА
// ============================================
// Эти два проца начинают с . = ..() — полный оверрайд в модуле потеряет
// важную логику родительских проков (стандартная обработка снаряда / спелла).
// Минимальные ?. фиксы остаются в базовых файлах:
//   code/modules/antagonists/heretic/magic/moon_parade.dm:85
//   code/modules/antagonists/heretic/magic/mind_gate.dm:47,58,61

// ============================================
// КРОВЯНЫЕ ЧЕРВИ: ВЗАИМОДЕЙСТВИЕ С ИПС
// ============================================

// Попытка укусить металлический корпус КПБ ломает зубы червю.
// Зубы отрастают обратно через минуту.
/mob/living/basic/blood_worm
	var/teeth_broken = FALSE

/mob/living/basic/blood_worm/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	if(isliving(target) && HAS_TRAIT(target, TRAIT_NOBLOOD))
		if(teeth_broken)
			to_chat(src, span_warning("Ваши зубы ещё не отросли — нельзя кусать металлический корпус."))
			return
		visible_message(
			span_danger("[src] вонзает зубы в металлическое тело [target] — и отскакивает с хрустом!"),
			span_userdanger("Вы вгрызаетесь в металлический корпус КПБ — ваши зубы ломаются!"),
		)
		playsound(src, 'sound/items/weapons/bite.ogg', 50)
		apply_damage(5, BRUTE)
		teeth_broken = TRUE
		addtimer(CALLBACK(src, PROC_REF(regrow_teeth)), 1 MINUTES)
		return
	return ..()

/mob/living/basic/blood_worm/proc/regrow_teeth()
	teeth_broken = FALSE
	to_chat(src, span_notice("Ваши зубы отросли — вы снова можете кусать."))
