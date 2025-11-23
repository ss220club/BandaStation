/datum/surgery/healing
	target_mobtypes = list(/mob/living)
	requires_bodypart_type = NONE
	replaced_by = /datum/surgery
	surgery_flags = SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/heal,
		/datum/surgery_step/close,
	)

	var/healing_step_type
	var/antispam = FALSE

/datum/surgery/healing/can_start(mob/user, mob/living/patient)
	. = ..()
	if(!.)
		return .
	if(!(patient.mob_biotypes & (MOB_ORGANIC|MOB_HUMANOID)))
		return FALSE
	return .

/datum/surgery/healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(
			/datum/surgery_step/incise/nobleed,
			healing_step_type, //hehe cheeky
			/datum/surgery_step/close,
		)

/datum/surgery_step/heal
	name = "восстановите тело (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCREWDRIVER = 65,
		TOOL_WIRECUTTER = 60,
		/obj/item/pen = 55)
	repeatable = TRUE
	time = 2.5 SECONDS
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	var/brutehealing = 0
	var/burnhealing = 0
	var/brute_multiplier = 0 //multiplies the damage that the patient has. if 0 the patient wont get any additional healing from the damage he has.
	var/burn_multiplier = 0

/// Returns a string letting the surgeon know roughly how much longer the surgery is estimated to take at the going rate
/datum/surgery_step/heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_step/heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(brutehealing && burnhealing)
		woundtype = "раны"
	else if(brutehealing)
		woundtype = "ушибы"
	else //why are you trying to 0,0...?
		woundtype = "ожоги"
	if(istype(surgery,/datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(
				user,
				target,
				span_notice("Вы пытаетесь наложить швы на [woundtype] у [target.declent_ru(GENITIVE)]."),
				span_notice("[capitalize(user.declent_ru(NOMINATIVE))] пытается наложить швы на [woundtype] у [target.declent_ru(GENITIVE)]."),
				span_notice("[capitalize(user.declent_ru(NOMINATIVE))] пытается наложить швы на [woundtype] у [target.declent_ru(GENITIVE)]."),
			)
		display_pain(target, "Ваши [woundtype] чертовски болят!")

/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
		if(!..())
			break

/datum/surgery_step/heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/user_msg = "Вы успешно обрабатываете раны у [target.declent_ru(GENITIVE)]" //no period, add initial space to "addons"
	var/target_msg = "[capitalize(user.declent_ru(NOMINATIVE))] успешно обрабатывает раны у [target.declent_ru(GENITIVE)]" //see above
	var/brute_healed = brutehealing
	var/burn_healed = burnhealing
	var/dead_patient = FALSE
	if(target.stat == DEAD) //dead patients get way less additional heal from the damage they have.
		brute_healed += round((target.getBruteLoss() * (brute_multiplier * 0.2)),0.1)
		burn_healed += round((target.getFireLoss() * (burn_multiplier * 0.2)),0.1)
		dead_patient = TRUE
	else
		brute_healed += round((target.getBruteLoss() * brute_multiplier),0.1)
		burn_healed += round((target.getFireLoss() * burn_multiplier),0.1)
		dead_patient = FALSE
	if(!get_location_accessible(target, target_zone))
		brute_healed *= 0.55
		burn_healed *= 0.55
		user_msg += " по силе возможностей, пока на них надета одежда"
		target_msg += " по силе их возможностей, пока на них надета одежда"
	target.heal_bodypart_damage(brute_healed,burn_healed)

	user_msg += get_progress(user, target, brute_healed, burn_healed)

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user) && !dead_patient) //Morbid folk don't care about tending the dead as much as tending the living
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_tend_wounds", /datum/mood_event/morbid_tend_wounds)

	display_results(
		user,
		target,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)
	if(istype(surgery, /datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		the_surgery.antispam = TRUE
	return ..()

/datum/surgery_step/heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("Вы ошибаетесь!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] зашивает некоторые раны у [target.declent_ru(GENITIVE)]."),
		target_detailed = TRUE,
	)
	var/brute_dealt = brutehealing * 0.8
	var/burn_dealt = burnhealing * 0.8
	brute_dealt += round((target.getBruteLoss() * (brute_multiplier * 0.5)),0.1)
	burn_dealt += round((target.getFireLoss() * (burn_multiplier * 0.5)),0.1)
	target.take_bodypart_damage(brute_dealt, burn_dealt, wound_bonus=CANT_WOUND)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/healing/brute
	name = "Залечить раны (Ушибы)"

/datum/surgery/healing/brute/basic
	name = "Залечить раны (Ушибы, Базово)"
	replaced_by = /datum/surgery/healing/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/brute/basic
	desc = "Хирургическая процедура, обеспечивающая базовое лечение ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/datum/surgery/healing/brute/upgraded
	name = "Залечить раны (Ушибы, Продв.)"
	replaced_by = /datum/surgery/healing/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded
	desc = "Хирургическая процедура, обеспечивающая продвинутое лечение ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/datum/surgery/healing/brute/upgraded/femto
	name = "Залечить раны (Ушибы, Экспер.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded/femto
	desc = "Хирургическая процедура, которая обеспечивает экспериментальное лечение ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/brute/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!brute_healed)
		return

	var/estimated_remaining_steps = target.getBruteLoss() / brute_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Оставшиеся ушибы: <font color='#ff3333'>[target.getBruteLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", осталось зашить пару царапин и все"
			if(3 to 6)
				progress_text = ", осталось залатать всего-лишь пару ушибов"
			if(6 to 9)
				progress_text = ", продолжайте лечить разрывы тканей"
			if(9 to 12)
				progress_text = ", надо подсобраться, ведь операция будет ещё долго идти"
			if(12 to 15)
				progress_text = ", судя по внешнему виду, тело больше напоминает отбивную, нежели чем человеческое тело"
			if(15 to INFINITY)
				progress_text = ", вам кажется, что вы ещё долго будете лечить это обезображенное тело"

	return progress_text

/datum/surgery_step/heal/brute/basic
	name = "обработайте ушибы (гемостат)"
	brutehealing = 5
	brute_multiplier = 0.07

/datum/surgery_step/heal/brute/upgraded
	brutehealing = 5
	brute_multiplier = 0.1

/datum/surgery_step/heal/brute/upgraded/femto
	brutehealing = 5
	brute_multiplier = 0.2

/***************************BURN***************************/
/datum/surgery/healing/burn
	name = "Залечить раны (Ожоги)"

/datum/surgery/healing/burn/basic
	name = "Залечить раны (Ожоги, Базово)"
	replaced_by = /datum/surgery/healing/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/burn/basic
	desc = "Хирургическая процедура, обеспечивающая базовое лечение ожогов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/datum/surgery/healing/burn/upgraded
	name = "Залечить раны (Ожоги, Продв.)"
	replaced_by = /datum/surgery/healing/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded
	desc = "Хирургическая процедура, обеспечивающая продвинутое лечение ожогов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/datum/surgery/healing/burn/upgraded/femto
	name = "Залечить раны (Ожоги, Экспер.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded/femto
	desc = "Хирургическое вмешательство, в ходе которого проводится экспериментальное лечение ожогов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!burn_healed)
		return
	var/estimated_remaining_steps = target.getFireLoss() / burn_healed
	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Оставшиеся ожоговые повреждения: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", осталось обработать пару царапин и все"
			if(3 to 6)
				progress_text = ", осталось обработать всего-лишь пару ожогов"
			if(6 to 9)
				progress_text = ", продолжайте работать над обработкой ожогов"
			if(9 to 12)
				progress_text = ", надо подсобраться, ведь операция будет ещё долго идти"
			if(12 to 15)
				progress_text = ", судя по внешнему виду, тело больше напоминает подгоревший стейк, нежели чем человеческое тело"
			if(15 to INFINITY)
				progress_text = ", вам кажется, что вы ещё долго будете лечить это обгоревшее тело"

	return progress_text

/datum/surgery_step/heal/burn/basic
	name = "обработайте ожоги (гемостат)"
	burnhealing = 5
	burn_multiplier = 0.07

/datum/surgery_step/heal/burn/upgraded
	burnhealing = 5
	burn_multiplier = 0.1

/datum/surgery_step/heal/burn/upgraded/femto
	burnhealing = 5
	burn_multiplier = 0.2

/***************************COMBO***************************/
/datum/surgery/healing/combo


/datum/surgery/healing/combo
	name = "Обработайте раны (Смесь, Базово)"
	replaced_by = /datum/surgery/healing/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/combo
	desc = "Хирургическая процедура, обеспечивающая базовое лечение ожогов и ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/datum/surgery/healing/combo/upgraded
	name = "Обработайте раны (Смесь, Продв.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/combo/upgraded
	desc = "Хирургическая процедура, обеспечивающая продвинутое лечение ожогов и ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."


/datum/surgery/healing/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	name = "Обработайте раны (Смесь, Экспер.)"
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/combo/upgraded/femto
	desc = "Хирургическая процедура, которая обеспечивает экспериментальное лечение ожогов и ушибов пациента. Лечение происходит быстрее, если пациент сильно ранен."

/********************COMBO STEPS********************/
/datum/surgery_step/heal/combo/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (target.getBruteLoss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (target.getFireLoss() / burn_healed)) // whichever is higher between brute or burn steps

	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		if(target.getBruteLoss())
			progress_text = ". Оставшиеся ушибы: <font color='#ff3333'>[target.getBruteLoss()]</font>"
		if(target.getFireLoss())
			progress_text += ". Оставшиеся ожоги: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", осталось обработать пару последние следы повреждений"
			if(3 to 6)
				progress_text = ", осталось обработать всего-лишь пару повреждений"
			if(6 to 9)
				progress_text = ", продолжайте работать над обработкой провреждений"
			if(9 to 12)
				progress_text = ", надо подсобраться, ведь операция будет ещё долго идти"
			if(12 to 15)
				progress_text = ", судя по внешнему виду, тело больше напоминает еду для карапузов, нежели чем человеческое тело"
			if(15 to INFINITY)
				progress_text = ", вам кажется, что вы ещё долго будете лечить это обезображенное тело"

	return progress_text

/datum/surgery_step/heal/combo
	name = "обработайте телесные раны (гемостат)"
	brutehealing = 3
	burnhealing = 3
	brute_multiplier = 0.07
	burn_multiplier = 0.07
	time = 1 SECONDS

/datum/surgery_step/heal/combo/upgraded
	brutehealing = 3
	burnhealing = 3
	brute_multiplier = 0.1
	burn_multiplier = 0.1

/datum/surgery_step/heal/combo/upgraded/femto
	brutehealing = 1
	burnhealing = 1
	brute_multiplier = 0.4
	burn_multiplier = 0.4

/datum/surgery_step/heal/combo/upgraded/femto/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("Вы ошибаетесь!"),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] ошибается!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] обрабатывает некоторые раны у [target.declent_ru(GENITIVE)]."),
		target_detailed = TRUE,
	)
	target.take_bodypart_damage(5,5)
