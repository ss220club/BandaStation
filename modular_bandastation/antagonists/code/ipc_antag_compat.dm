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
