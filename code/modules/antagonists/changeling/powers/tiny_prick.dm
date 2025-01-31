/datum/action/changeling/sting//parent path, not meant for users afaik
	name = "Tiny Prick"
	desc = "Stabby stabby"

/datum/action/changeling/sting/Trigger(trigger_flags)
	var/mob/user = owner
	if(!user || !user.mind)
		return
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling)
		return
	if(!changeling.chosen_sting)
		set_sting(user)
	else
		unset_sting(user)
	return

/datum/action/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, span_notice("Готовим жало. Используйте Alt+Клик или СКМ по цели, чтобы ужалить ее."))
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	changeling.chosen_sting = src

	changeling.lingstingdisplay.icon_state = button_icon_state
	changeling.lingstingdisplay.SetInvisibility(0, id=type)

/datum/action/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, span_warning("Мы убираем свое жало, пока что мы не можем никого ужалить."))
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	changeling.chosen_sting = null

	changeling.lingstingdisplay.icon_state = null
	changeling.lingstingdisplay.RemoveInvisibility(type)

/mob/living/carbon/proc/unset_sting()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling?.chosen_sting)
			changeling.chosen_sting.unset_sting(src)

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling.chosen_sting)
		to_chat(user, "Мы еще не подготовили наше жало!")
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!length(get_path_to(user, target, max_distance = changeling.sting_range, simulated_only = FALSE)))
		return // no path within the sting's range is found. what a weird place to use the pathfinding system
	if(IS_CHANGELING(target))
		sting_feedback(user, target)
		changeling.chem_charges -= chemical_cost
	return 1

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, span_notice("Мы незаметно жалим [target.name]."))
	if(IS_CHANGELING(target))
		to_chat(target, span_warning("Вы чувствуете небольшой укол."))
	return 1


/datum/action/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "Мы тихо жалим организм, вводя в него ретровирус, который заставляет его трансформироваться."
	helptext = "Жертва трансформируется так же, как генокрад. \
		Для сложных гуманоидов трансформация происходит на время, но ее таймер приостанавливается, пока жертва мертва или находится в стазисе. \
		У более простых гуманоидов, таких как обезьяны, трансформация происходит навсегда. \
		Не предупреждает других. Мутации не передаются."
	button_icon_state = "sting_transform"
	chemical_cost = 33 // Low enough that you can sting only two people in quick succession
	dna_cost = 2
	/// A reference to our active profile, which we grab DNA from
	VAR_FINAL/datum/changeling_profile/selected_dna
	/// Duration of the sting
	var/sting_duration = 8 MINUTES
	/// Set this to false via VV to allow golem, plasmaman, or monkey changelings to turn other people into golems, plasmamen, or monkeys
	var/verify_valid_species = TRUE

/datum/action/changeling/sting/transformation/Grant(mob/grant_to)
	. = ..()
	build_all_button_icons(UPDATE_BUTTON_NAME)

/datum/action/changeling/sting/transformation/update_button_name(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	button.desc += " Длительность [DisplayTimeText(sting_duration)] для людей, но таймер приостанавливается, пока они мертвы или находятся в стазисе."
	button.desc += " Стоимость [chemical_cost] химикатов."

/datum/action/changeling/sting/transformation/Destroy()
	selected_dna = null
	return ..()

/datum/action/changeling/sting/transformation/set_sting(mob/user)
	selected_dna = null
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	var/datum/changeling_profile/new_selected_dna = changeling.select_dna()
	if(QDELETED(src) || QDELETED(changeling) || QDELETED(user))
		return
	if(!new_selected_dna || changeling.chosen_sting || selected_dna) // selected other sting or other DNA while sleeping
		return
	if(verify_valid_species && (TRAIT_NO_DNA_COPY in new_selected_dna.dna.species.inherent_traits))
		user.balloon_alert(user, "dna incompatible!")
		return
	selected_dna = new_selected_dna
	return ..()

/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return
	// Similar checks here are ran to that of changeling can_absorb_dna -
	// Logic being that if their DNA is incompatible with us, it's also bad for transforming
	if(!iscarbon(target) \
		|| !target.has_dna() \
		|| HAS_TRAIT(target, TRAIT_HUSK) \
		|| HAS_TRAIT(target, TRAIT_BADDNA) \
		|| (HAS_TRAIT(target, TRAIT_NO_DNA_COPY) && !ismonkey(target))) // sure, go ahead, make a monk-clone
		user.balloon_alert(user, "несовместимое ДНК!")
		return FALSE
	if(target.has_status_effect(/datum/status_effect/temporary_transformation/trans_sting))
		user.balloon_alert(user, "уже трансформирован!")
		return FALSE
	return TRUE

/datum/action/changeling/sting/transformation/sting_action(mob/living/user, mob/living/target)
	var/final_duration = sting_duration
	var/final_message = span_notice("Мы трансформируем [target.declent_ru(ACCUSATIVE)] в [selected_dna.dna.real_name].")
	if(ismonkey(target))
		final_duration = INFINITY
		final_message = span_warning("Наши гены вопят, когда мы трансформируем [target.declent_ru(ACCUSATIVE)] из низшей формы в [selected_dna.dna.real_name] навсегда!")

	if(target.apply_status_effect(/datum/status_effect/temporary_transformation/trans_sting, final_duration, selected_dna.dna))
		..()
		log_combat(user, target, "stung", "transformation sting", " new identity is '[selected_dna.dna.real_name]'")
		to_chat(user, final_message)
		return TRUE
	return FALSE

/datum/action/changeling/sting/false_armblade
	name = "False Armblade Sting"
	desc = "Мы бесшумно жалим человека, впрыскивая ретровирус, который мутирует его руку, временно превращая ее в армблейд. Стоит 20 химикатов."
	helptext = "Жертва формирует армблейд, подобно тому, как это делает генокрад, только этот клинок тупой и бесполезный."
	button_icon_state = "sting_armblade"
	chemical_cost = 20
	dna_cost = 1

/obj/item/melee/arm_blade/false
	desc = "A grotesque mass of flesh that used to be your arm. Although it looks dangerous at first, you can tell it's actually quite dull and useless."
	force = 5 //Basically as strong as a punch
	fake = TRUE

/datum/action/changeling/sting/false_armblade/can_sting(mob/user, mob/target)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		if((HAS_TRAIT(L, TRAIT_HUSK)) || !L.has_dna())
			user.balloon_alert(user, "несовместимое ДНК!")
			return FALSE
	return TRUE

/datum/action/changeling/sting/false_armblade/sting_action(mob/user, mob/target)

	var/obj/item/held = target.get_active_held_item()
	if(held && !target.dropItemToGround(held))
		to_chat(user, span_warning("У цели нельзя снять [held.declent_ru(ACCUSATIVE)], вы не можете наложить на цель ложный армблейд!"))
		return

	..()
	log_combat(user, target, "stung", object = "false armblade sting")
	if(ismonkey(target))
		to_chat(user, span_notice("Наши гены вопят, когда мы жалим [target.name]!"))

	var/obj/item/melee/arm_blade/false/blade = new(target,1)
	target.put_in_hands(blade)
	target.visible_message(span_warning("Страшный клинок образуется вокруг руки [target.declent_ru(GENITIVE)]!"), span_userdanger("Ваша рука скручивается и мутирует, превращаясь в ужасающее чудовище!"), span_hear("Вы слышите, как рвется и разрывается органическая масса!"))
	playsound(target, 'sound/effects/blob/blobattack.ogg', 30, TRUE)

	addtimer(CALLBACK(src, PROC_REF(remove_fake), target, blade), 1 MINUTES)
	return TRUE

/datum/action/changeling/sting/false_armblade/proc/remove_fake(mob/target, obj/item/melee/arm_blade/false/blade)
	playsound(target, 'sound/effects/blob/blobattack.ogg', 30, TRUE)
	target.visible_message(span_warning("С болезненным хрустом, [target.declent_ru(NOMINATIVE)] превращает [blade.declent_ru(ACCUSATIVE)] в руку!"),
	span_warning("[capitalize(blade.declent_ru(NOMINATIVE))] возвращается в нормальное состояние."), span_italics("Вы слышите, как рвется и разрывается органическая масса!"))

	qdel(blade)
	target.update_held_items()

/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "Мы незаметно жалим цель и извлекаем ее ДНК. Стоит 25 химикатов."
	helptext = "Даст вам ДНК вашей цели, позволяя трансформироваться в нее."
	button_icon_state = "sting_extract"
	chemical_cost = 25
	dna_cost = 0

/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
		return changeling.can_absorb_dna(target)

/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	..()
	log_combat(user, target, "stung", "extraction sting")
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(!changeling.has_profile_with_dna(target.dna))
		changeling.add_new_profile(target)
	return TRUE

/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "Мы беззвучно жалим человека, полностью заставляя его замолчать на короткое время. Стоит 20 химикатов."
	helptext = "Не предупреждает жертву о том, что ее ужалили, пока она не попытается заговорить и не сможет."
	button_icon_state = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	..()
	log_combat(user, target, "stung", "mute sting")
	target.adjust_silence(1 MINUTES)
	return TRUE

/datum/action/changeling/sting/blind
	name = "Blind Sting"
	desc = "Мы временно ослепляем нашу жертву. Стоит 25 химикатов."
	helptext = "Это жало полностью ослепляет цель на короткое время и оставляет ее с затуманенным зрением на долгое время. Не действует, если у цели роботизированные глаза или глаза отсутствуют."
	button_icon_state = "sting_blind"
	chemical_cost = 25
	dna_cost = 1

/datum/action/changeling/sting/blind/sting_action(mob/user, mob/living/carbon/target)
	var/obj/item/organ/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.balloon_alert(user, "нет глаз!")
		return FALSE

	if(IS_ROBOTIC_ORGAN(eyes))
		user.balloon_alert(user, "роботизированные глаза!")
		return FALSE

	..()
	log_combat(user, target, "stung", "blind sting")
	to_chat(target, span_danger("Ваши глаза ужасно горят!"))
	eyes.apply_organ_damage(eyes.maxHealth * 0.8)
	target.adjust_temp_blindness(40 SECONDS)
	target.set_eye_blur_if_lower(80 SECONDS)
	return TRUE

/datum/action/changeling/sting/lsd
	name = "Hallucination Sting"
	desc = "Мы вызываем массовый ужас у нашей жертвы. Стоит 10 химикатов."
	helptext = "Мы развиваем способность жалить цель мощным галлюциногенным химикатом. \
			Объект не замечает, что его ужалили, и эффект проявляется через 30-60 секунд."
	button_icon_state = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1

/datum/action/changeling/sting/lsd/sting_action(mob/user, mob/living/carbon/target)
	..()
	log_combat(user, target, "stung", "LSD sting")
	addtimer(CALLBACK(src, PROC_REF(hallucination_time), target), rand(30 SECONDS, 60 SECONDS))
	return TRUE

/datum/action/changeling/sting/lsd/proc/hallucination_time(mob/living/carbon/target)
	if(QDELETED(src) || QDELETED(target))
		return
	target.adjust_hallucinations(180 SECONDS)

/datum/action/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "Мы беззвучно жалим жертву коктейлем из химикатов, который замораживает ее изнутри. Стоит 15 химикатов."
	helptext = "Не предупреждает жертву, хотя она, скорее всего, поймет, что внезапно замерзла."
	button_icon_state = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2

/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	..()
	log_combat(user, target, "stung", "cryo sting")
	if(target.reagents)
		target.reagents.add_reagent(/datum/reagent/consumable/frostoil, 30)
	return TRUE
