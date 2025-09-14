
/////BONE FIXING SURGERIES//////

///// Repair Hairline Fracture (Severe)
/datum/surgery/repair_bone_hairline
	name = "Сращивание перелома (трещины) кости"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/severe
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/repair_bone_hairline,
		/datum/surgery_step/close,
	)

///// Repair Compound Fracture (Critical)
/datum/surgery/repair_bone_compound
	name = "Сращивание открытого перелома кости"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/critical
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/reset_compound_fracture,
		/datum/surgery_step/repair_bone_compound,
		/datum/surgery_step/close,
	)

//SURGERY STEPS

///// Repair Hairline Fracture (Severe)
/datum/surgery_step/repair_bone_hairline
	name = "Устраните закрытый перелом кости (костоправ/костный гель/хирургическая лента)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/medical/bone_gel = 100,
		/obj/item/stack/sticky_tape/surgical = 100,
		/obj/item/stack/sticky_tape/super = 50,
		/obj/item/stack/sticky_tape = 30)
	time = 4 SECONDS

/datum/surgery_step/repair_bone_hairline/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы приступаете к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Ваша [target.parse_zone_with_bodypart(user.zone_selected)] испытывает сильную боль!")
	else
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ищет у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]."), span_notice("Вы ищете у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]..."))

/datum/surgery_step/repair_bone_hairline/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно устраняете перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно устраняет перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно устраняет перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
		)
		log_combat(user, target, "repaired a hairline fracture in", addition="COMBAT_MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет в [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] перелома!"))
	return ..()

/datum/surgery_step/repair_bone_hairline/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)



///// Reset Compound Fracture (Crticial)
/datum/surgery_step/reset_compound_fracture
	name = "восстановите кость (костоправ)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/sticky_tape/surgical = 60,
		/obj/item/stack/sticky_tape/super = 40,
		/obj/item/stack/sticky_tape = 20)
	time = 4 SECONDS

/datum/surgery_step/reset_compound_fracture/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы начинаете восстанавливать кость в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать кость в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает восстанавливать кость в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Острая боль в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] просто невыносима!")
	else
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ищет у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]."), span_notice("Вы ищете у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]..."))

/datum/surgery_step/reset_compound_fracture/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно восстанавливаете кость в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает кость в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает кость в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
		)
		log_combat(user, target, "reset a compound fracture in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
	else
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет в [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] открытого перелома!"))
	return ..()

/datum/surgery_step/reset_compound_fracture/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

#define IMPLEMENTS_THAT_FIX_BONES list( \
	/obj/item/stack/medical/bone_gel = 100, \
	/obj/item/stack/sticky_tape/surgical = 100, \
	/obj/item/stack/sticky_tape/super = 50, \
	/obj/item/stack/sticky_tape = 30, \
)


///// Repair Compound Fracture (Crticial)
/datum/surgery_step/repair_bone_compound
	name = "Устраните открытый перелом кости (костный гель/хирургическая лента)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 4 SECONDS

/datum/surgery_step/repair_bone_compound/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("Вы приступаете к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к устранению перелома в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Острая боль в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)] просто невыносима!")
	else
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ищет у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]."), span_notice("Вы ищете у [target.declent_ru(GENITIVE)] в [target.parse_zone_with_bodypart(user.zone_selected, declent = PREPOSITIONAL)]..."))

/datum/surgery_step/repair_bone_compound/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("Вы успешно устраняете перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно устраняет перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно устраняет перелом в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]!"),
		)
		log_combat(user, target, "repaired a compound fracture in", addition="COMBAT_MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет в [target.ru_p_theirs()] [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] открытого перелома!"))
	return ..()

/datum/surgery_step/repair_bone_compound/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

/// Surgery to repair cranial fissures
/datum/surgery/cranial_reconstruction
	name = "Восстановление черепа"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/cranial_fissure
	possible_locs = list(
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/clamp_bleeders/discard_skull_debris,
		/datum/surgery_step/repair_skull
	)

/datum/surgery_step/clamp_bleeders/discard_skull_debris
	name = "избавьтесь от обломков черепа (гемостат)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_WIRECUTTER = 40,
		TOOL_SCREWDRIVER = 40,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/discard_skull_debris/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете избавляться от мелких обломков черепа в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает избавляться от мелких обломков черепа в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает копошиться в [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]..."),
	)

	display_pain(target, "Ваш мозг словно пронзают мелкие осколки стекла!")

/datum/surgery_step/repair_skull
	name = "восстановите череп (костный гель/хирургическая лента)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 4 SECONDS

/datum/surgery_step/repair_skull/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	ASSERT(surgery.operated_wound, "Восстановление черепа без ран")

	display_results(
		user,
		target,
		span_notice("Вы приступаете к восстановлению черепа у [target.declent_ru(GENITIVE)], как только можете..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к восстановлению черепа у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] приступает к восстановлению черепа у [target.declent_ru(GENITIVE)]."),
	)

	display_pain(target, "Вы чувствуете, как части черепа трутся о ваш мозг.!")

/datum/surgery_step/repair_skull/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if (isnull(surgery.operated_wound))
		to_chat(user, span_warning("Череп [target.declent_ru(GENITIVE)] в порядке!"))
		return ..()


	if (isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

	display_results(
		user,
		target,
		span_notice("Вы успешно восстанавливаете череп у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает череп у [target.declent_ru(GENITIVE)] при помощи [tool.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает череп у [target.declent_ru(GENITIVE)].")
	)

	qdel(surgery.operated_wound)

	return ..()

#undef IMPLEMENTS_THAT_FIX_BONES
