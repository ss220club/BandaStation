/// Disk containing info for doing advanced plastic surgery. Spawns in maint and available as a role-restricted item in traitor uplinks.
/obj/item/disk/surgery/advanced_plastic_surgery
	name = "Advanced Plastic Surgery Disk"
	desc = "На диске содержатся инструкции по проведению продвинутой пластической операции, которая позволяет полностью изменить лицо другого человека. При условии, что в момент изменения лица у него под рукой будет его фотография. С развитием генетических технологий эта операция давно устарела. Этот предмет стал антиквариатом для многих коллекционеров, и только более дешевая и простая базовая форма пластической хирургии остается в использовании в большинстве мест."
	surgeries = list(/datum/surgery/plastic_surgery/advanced)

/datum/surgery/plastic_surgery
	name = "Пластическая операция"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/reshape_face,
		/datum/surgery_step/close,
	)

/datum/surgery/plastic_surgery/advanced
	name = "Продвинутая пластическая операция"
	desc =  "Операция позволяет полностью переделать лицо другого человека. При условии, что во время изменения формы лица в руке будет его фотография."
	requires_tech = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/insert_plastic,
		/datum/surgery_step/reshape_face,
		/datum/surgery_step/close,
	)

//Insert plastic step, It ain't called plastic surgery for nothing! :)
/datum/surgery_step/insert_plastic
	name = "вставьте пластик (пластик)"
	implements = list(
		/obj/item/stack/sheet/plastic = 100,
		/obj/item/stack/sheet/meat = 100)
	time = 3.2 SECONDS
	preop_sound = 'sound/effects/blob/blobattack.ogg'
	success_sound = 'sound/effects/blob/attackblob.ogg'
	failure_sound = 'sound/effects/blob/blobattack.ogg'

/datum/surgery_step/insert_plastic/preop(mob/user, mob/living/target, target_zone, obj/item/stack/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете вставлять [tool.declent_ru(ACCUSATIVE)] в разрезе на [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)] ..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вставлять [tool.declent_ru(ACCUSATIVE)] в разрезе на [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает вставлять [tool.declent_ru(ACCUSATIVE)] в разрезе на [target.parse_zone_with_bodypart(target_zone, declent = PREPOSITIONAL)] у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете, как что-то вставили вам под кожу в [target.parse_zone_with_bodypart(target_zone, declent = ACCUSATIVE)].")

/datum/surgery_step/insert_plastic/success(mob/user, mob/living/target, target_zone, obj/item/stack/tool, datum/surgery/surgery, default_display_results)
	. = ..()
	tool.use(1)

//reshape_face
/datum/surgery_step/reshape_face
	name = "измените форму лица (скальпель)"
	implements = list(
		TOOL_SCALPEL = 100,
		/obj/item/knife = 50,
		TOOL_WIRECUTTER = 35)
	time = 6.4 SECONDS
	surgery_effects_mood = TRUE

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает изменять внешний вид у [target.declent_ru(GENITIVE)]."), span_notice("Вы начинаете изменять внешний вид у [target.declent_ru(GENITIVE)]..."))
	display_results(
		user,
		target,
		span_notice("Вы начинаете изменять внешний вид у [target.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает изменять внешний вид у [target.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает делать надрез на лице у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете острую боль на лице!")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(HAS_TRAIT_FROM(target, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(
			user,
			target,
			span_notice("Вы успешно восстанавливаете внешний вид лица у [target.declent_ru(GENITIVE)]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] успешно восстанавливает внешний вид лица у [target.declent_ru(GENITIVE)]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает проводить операцию на лице у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Боль исчезает, лицо вновь становится нормальным!")
	else
		var/list/names = list()
		if(!isabductor(user))
			var/obj/item/offhand = user.get_inactive_held_item()
			if(istype(offhand, /obj/item/photo) && istype(surgery, /datum/surgery/plastic_surgery/advanced))
				var/obj/item/photo/disguises = offhand
				for(var/namelist as anything in disguises.picture?.names_seen)
					names += namelist
			else
				user.visible_message(span_warning("У вас нет фотографии, на которую можно было бы опираться, и вы возвращаетесь к случайному списку внешности."))
				for(var/i in 1 to 10)
					names += target.generate_random_mob_name(TRUE)
		else
			for(var/j in 1 to 9)
				names += "Subject [target.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
			names += target.generate_random_mob_name(TRUE) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = tgui_input_list(user, "New name to assign", "Plastic Surgery", names)
		if(isnull(chosen_name))
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name //something about how the code handles names required that I use this instead of target.real_name
		display_results(
			user,
			target,
			span_notice("Вы полностью изменяете внешность у [oldname], [target.ru_p_they()] теперь [newname]."),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] полностью изменяет внешность у [oldname], [target.ru_p_they()] теперь [newname]!"),
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает проводить операцию на лице у [target.declent_ru(GENITIVE)]."),
		)
		display_pain(target, "Боль проходит, а ваше лицо кажется новым и непривычным!")
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.update_ID_card()
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user))
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)
	return ..()

/datum/surgery_step/reshape_face/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("Вы ошибаетесь, сделав обезображенное лицо у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] ошибается, сделав обезображенное лицо у [target.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] заканчивает проводить операцию на лице у [target.declent_ru(GENITIVE)]."),
	)
	display_pain(target, "Вы чувствуете, что теперь ваше лицо изуродовано и обезображено!")
	ADD_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
	return FALSE
