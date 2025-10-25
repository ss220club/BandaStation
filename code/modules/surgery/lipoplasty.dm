/datum/surgery/lipoplasty
	name = "Липосакция"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/cut_fat,
		/datum/surgery_step/remove_fat,
		/datum/surgery_step/close,
	)

/datum/surgery/lipoplasty/mechanic
	name = "Удаление резерва нутриментов"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/cut_fat/mechanic,
		/datum/surgery_step/remove_fat/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/lipoplasty/can_start(mob/user, mob/living/carbon/target)
	if(!HAS_TRAIT_FROM(target, TRAIT_FAT, OBESITY) || target.nutrition < NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()


//cut fat
/datum/surgery_step/cut_fat
	name = "срежьте лишний жир (циркулярная пила)"
	implements = list(
		TOOL_SAW = 100,
		/obj/item/shovel/serrated = 75,
		/obj/item/hatchet = 35,
		/obj/item/knife/butcher = 25,
	)
	time = 6.4 SECONDS
	surgery_effects_mood = TRUE
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)

/datum/surgery_step/cut_fat/mechanic
	name = "откройте ёмкости жира (ключ или монтировка)"
	implements = list(
		TOOL_WRENCH = 95,
		TOOL_CROWBAR = 95,
		TOOL_SAW = 65,
		/obj/item/melee/energy/sword = 65,
		/obj/item/knife = 45,
		/obj/item/shard = 35,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/cut_fat/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает отрезать лишний жир у [target.declent_ru(GENITIVE)]."), span_notice("Вы начинаете отрезать лишний жир у [target.declent_ru(GENITIVE)]..."))
	display_results(
		user,
		target,
		span_notice("Вы начинаете отрезать лишний жир у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает отрезать лишний жир у [target.declent_ru(GENITIVE)]"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает отрезать что-то из [ru_parse_zone(target_zone, declent = GENITIVE)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете резкую боль в вашей [ru_parse_zone(target_zone, declent = PREPOSITIONAL)]!")

/datum/surgery_step/cut_fat/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(
		user,
		target,
		span_notice("Вы отрезали лишний жир у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] отрезал лишний жир у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает разрез на [ru_parse_zone(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Жир в вашей [ru_parse_zone(target_zone, declent = PREPOSITIONAL)] ослабевает, свисает и болит, как черт знает что!")
	return TRUE

//remove fat
/datum/surgery_step/remove_fat
	name = "удалите жировые отложения (ретрактор)"
	implements = list(
		TOOL_RETRACTOR = 100,
		TOOL_SCREWDRIVER = 45,
		TOOL_WIRECUTTER = 35,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'

/datum/surgery_step/remove_fat/mechanic
	name = "включите клапан очистки (отвертка или ключ)" //gross
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_WRENCH = 100,
		TOOL_WIRECUTTER = 35,
		TOOL_RETRACTOR = 35,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_step/remove_fat/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете извлекать лишний жир у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает извлекать лишний жир у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает извлекать что-то у [target.declent_ru(GENITIVE)] из [ru_parse_zone(target_zone, declent = PREPOSITIONAL)]."),
	)
	display_pain(target, "Вы чувствуете странное безболезненное потягивание за лишний жир!")

/datum/surgery_step/remove_fat/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("Вы извлекли жир у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] извлек жир у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] извлек жир у [target.declent_ru(GENITIVE)]!"),
	)
	target.overeatduration = 0 //patient is unfatted
	var/removednutriment = target.nutrition
	target.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	removednutriment -= NUTRITION_LEVEL_WELL_FED //whatever was removed goes into the meat
	var/mob/living/carbon/human/human = target
	var/typeofmeat = /obj/item/food/meat/slab/human

	if(target.flags_1 & HOLOGRAM_1)
		typeofmeat = null
	else if(human.dna && human.dna.species)
		typeofmeat = human.dna.species.meat

	if(typeofmeat)
		var/obj/item/food/meat/slab/human/newmeat = new typeofmeat
		newmeat.name = "жирное мясо"
		newmeat.desc = "Очень толстая жировая ткань, взятая у пациента."
		newmeat.subjectname = human.real_name
		newmeat.subjectjob = human.job
		newmeat.reagents.add_reagent (/datum/reagent/consumable/nutriment, (removednutriment / 15)) //To balance with nutriment_factor of nutriment
		newmeat.forceMove(target.loc)
	return ..()
