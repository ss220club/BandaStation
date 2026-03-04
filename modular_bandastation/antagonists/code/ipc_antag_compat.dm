// ============================================
// ИПС: СОВМЕСТИМОСТЬ С АНТАГОНИСТАМИ
// ============================================
// КПБ — роботы. Ряд антагонистских механик несовместим с ними физически.
//
// Чейнджлинг: ИПС не может стать чейнджлингом (нет ДНК для поглощения).
// Культ: ИПС может быть завербован в культ, но не может чертить руны
//        (нет крови для ритуала, масло не является жертвенной субстанцией).
// Еретик (путь Луны): ИПС имеет /datum/mood/ipc_neutral — mob_mood никогда
//        не null, все sanity-проки no-op. Патч базовых файлов не нужен.

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

// leech_living_start_check проверяет get_blood_volume() <= 0, но у ИПС
// blood_volume как var существует (carbon/human наследник) и может быть > 0.
// Без явной проверки червь начнёт сосать ИПС: либо зациклится, либо
// осушит переменную до смерти. Добавляем TRAIT_NOBLOOD guard.
/datum/action/cooldown/mob_cooldown/blood_worm/leech/leech_living_start_check(mob/living/basic/blood_worm/leech, mob/living/target)
	if(HAS_TRAIT(target, TRAIT_NOBLOOD))
		target.balloon_alert(leech, "нет крови!")
		return FALSE
	return ..()
