/datum/surgery_operation/limb/bioware
	abstract_type = /datum/surgery_operation/limb/bioware
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED
	required_bodytype = ~BODYTYPE_ROBOTIC
	time = 12.5 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_ORGANS_CUT
	/// What status effect is gained when the surgery is successful?
	/// Used to check against other bioware types to prevent stacking.
	var/datum/status_effect/status_effect_gained = /datum/status_effect/bioware
	/// Zone to operate on for this bioware
	var/required_zone = BODY_ZONE_CHEST

/datum/surgery_operation/limb/bioware/get_default_radial_image()
	return image('icons/hud/implants.dmi', "lighting_bolt")

/datum/surgery_operation/limb/bioware/all_required_strings()
	return list("операция на [parse_zone(required_zone)] (цель [parse_zone(required_zone)])") + ..()

/datum/surgery_operation/limb/bioware/all_blocked_strings()
	var/list/incompatible_surgeries = list()
	for(var/datum/surgery_operation/limb/bioware/other_bioware as anything in subtypesof(/datum/surgery_operation/limb/bioware))
		if(other_bioware::status_effect_gained::id != status_effect_gained::id)
			continue
		if(other_bioware::required_bodytype != required_bodytype)
			continue
		incompatible_surgeries += (other_bioware.rnd_name || other_bioware.name)

	return ..() + list("пациент ранее не должен был проходить [english_list(incompatible_surgeries, and_text = " OR ")]")

/datum/surgery_operation/limb/bioware/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != required_zone)
		return FALSE
	if(limb.owner.has_status_effect(status_effect_gained))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/bioware/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.owner.apply_status_effect(status_effect_gained)
	if(limb.owner.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, status_effect_gained)

/datum/surgery_operation/limb/bioware/vein_threading
	name = "Венозная нить"
	rnd_name = "Симваскулодез (венозная нить)" // "together vessel fusion"
	desc = "Сплетите вены пациента в усиленную сетку, уменьшая кровопотерю при травмах."
	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery_operation/limb/bioware/vein_threading/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете плести кровеносную систему [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает плести кровеносную систему [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать кровеносной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Всё ваше тело горит в агонии!")

/datum/surgery_operation/limb/bioware/vein_threading/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы сплетаете кровеносную систему [limb.owner.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[surgeon] сплетает кровеносную систему [limb.owner.declent_ru(GENITIVE)] в прочную сеть!"),
		span_notice("[surgeon] завершает манипуляцию кровеносной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы можете почувствовать, как кровь движется по усиленным венам!")

/datum/surgery_operation/limb/bioware/vein_threading/mechanic
	rnd_name = "Оптимизация маршрутизации гидравлики (венозная нить)"
	desc = "Оптимизируйте работу гидравлической системы роботизированного пациента, снижая потери жидкости из-за утечек."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/muscled_veins
	name = "Мышечная мембрана вены"
	rnd_name = "Миоваскулопластика (мышечная мембрана вены)" // "muscle vessel reshaping"
	desc = "Добавьте мышечную оболочку к венам пациента, что позволит ему перекачивать кровь без участия сердца."
	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery_operation/limb/bioware/muscled_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете обматывать мышцами кровеносные сосуды [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает обматывать мышцами кровеносные сосуды [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать кровеносной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Всё ваше тело горит в агонии!")

/datum/surgery_operation/limb/bioware/muscled_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы изменяете форму кровеносных сосудов [limb.owner.declent_ru(GENITIVE)], добавляя мышечную оболочку!"),
		span_notice("[surgeon] изменяет форму кровеносных сосудов  [limb.owner.declent_ru(GENITIVE)], добавляя мышечную оболочку!"),
		span_notice("[surgeon] завершает манипуляцию кровеносной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы можете чувствовать, как мощные удары вашего сердца разносятся по всему телу!")

/datum/surgery_operation/limb/bioware/muscled_veins/mechanic
	rnd_name = "Hydraulics Redundancy Subroutine (Muscled Veins)"
	desc = "Add redundancies to a robotic patient's hydraulic system, allowing it to pump fluids without an engine or pump."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_splicing
	name = "Сращивание нервов"
	rnd_name = "Симневродез (сращивание нервов)" // "together nerve fusion"
	desc = "Соедините нервы пациента вместе, чтобы сделать их более устойчивыми к оглушению."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery_operation/limb/bioware/nerve_splicing/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете соединять нервы  [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает соединять нервы [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать нервной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Все ваше тело немеет!")

/datum/surgery_operation/limb/bioware/nerve_splicing/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно сращиваете нервную систему [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно сращивает нервную систему [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает манипулирование нервной системой[limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы вновь обретаете чувствительность в своем теле; вам кажется, что всё происходит вокруг вас в замедлении!")

/datum/surgery_operation/limb/bioware/nerve_splicing/mechanic
	rnd_name = "Подпрограмма автоматического сброса системы (сращивание нервов)"
	desc = "Модернизируйте автоматические системы роботизированного пациента, чтобы он мог лучше противостоять оглушению."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_grounding
	name = "Заземление нервов"
	rnd_name = "Ксантоневропластика (заземление нервов)" // "yellow nerve reshaping". see: yellow gloves
	desc = "Reroute a patient's nerves to act as grounding rods, protecting them from electrical shocks."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/grounded

/datum/surgery_operation/limb/bioware/nerve_grounding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете перенаправлять нервы [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает перенаправлять нервы [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать нервной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Все ваше тело немеет!")

/datum/surgery_operation/limb/bioware/nerve_grounding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно перенаправляете нервную систему [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно перенаправляет нервы [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает манипулирование нервной системой [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы возвращаете своему телу ощущение свежести! Вы чувствуете прилив сил!")

/datum/surgery_operation/limb/bioware/nerve_grounding/mechanic
	rnd_name = "Система гашения ударов (заземление нервов)"
	desc = "Установите заземляющие стержни в нервную систему роботизированного пациента, защищая её от поражения электрическим током."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_hook
	name = "Изменение формы связок"
	rnd_name = "Артропластика (крюк для связок)" // "joint reshaping"
	desc = "Измените форму связок пациента, чтобы в случае отсоединения конечности её можно было прикрепить вручную, за счет облегчения отсоединения конечностей."
	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery_operation/limb/bioware/ligament_hook/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете придавать связкам [limb.owner.declent_ru(GENITIVE)] форму крючка."),
		span_notice("[surgeon] начинает перестраивать связки [limb.owner.declent_ru(GENITIVE)], придавая им форму крючка."),
		span_notice("[surgeon] начинает манипулировать связками [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности горят от сильной боли!")

/datum/surgery_operation/limb/bioware/ligament_hook/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы придаете связкам [limb.owner.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[surgeon] придает связкам [limb.owner.declent_ru(GENITIVE)] форму крючка!"),
		span_notice("[surgeon] заканчивает манипулирование связками [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности кажутся... странно свободными.")

/datum/surgery_operation/limb/bioware/ligament_hook/mechanic
	rnd_name = "Защелкивающиеся точки крепления (крюк для связок)"
	desc = "Преобразуйте суставы конечностей роботизированного пациента таким образом, чтобы обеспечить быструю фиксацию и возможность повторного прикрепления конечностей вручную в случае их отсоединения - \
		за счет того, что конечности легче отсоединить."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_reinforcement
	name = "Укрепление связок"
	rnd_name = "Артрорафия (укрепление связок)" // "joint strengthening" / "joint stitching"
	desc = "Укрепляет связки пациента, чтобы затруднить расчленение за счет облегчения прерывания нервных связей."
	status_effect_gained = /datum/status_effect/bioware/ligaments/reinforced

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете укреплять связки [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает укреплять связки [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает манипулировать связками [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности горят от сильной боли!")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы укрепляете связки [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] укрепляет связки [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] заканчивает манипулирование связками [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваши конечности чувствуют себя более защищенными, но также более хрупкими.")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic
	rnd_name = "Укрепление опорной точки (укрепление связок)"
	desc = "Укрепите суставы конечностей роботизированного пациента, чтобы предотвратить расчленение, за счет облегчения разрыва нервных связей."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_folding
	name = "Складывание коры"
	rnd_name = "Энцефалофрактопластика (складывание коры)" // it's a stretch - "brain fractal reshaping"
	desc = "Биологическая модернизация, которая преобразует кору головного мозга пациента во фрактальный узор, повышая плотность и гибкость нейронов."
	status_effect_gained = /datum/status_effect/bioware/cortex/folded
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_folding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете складывать внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор."),
		span_notice("[surgeon] начинает складывать внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор."),
		span_notice("[surgeon] начинает проводить операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы складываете внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор!"),
		span_notice("[surgeon] складывает внешнюю кору головного мозга у [limb.owner.declent_ru(NOMINATIVE)] во фрактальный узор!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваш мозг становится сильнее... более гибким!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы ошибаетесь, повреждая мозг!"),
		span_warning("[surgeon] ошибается, нанеся повреждения мозгу!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(NOMINATIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от мучительной боли!")
	limb.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_folding/mechanic
	rnd_name = "Лабиринтное программирование Wetware OS (складывание коры)"
	desc = "Перепрограммируйте нейронную сеть роботизированного пациента на совершенно необычном языке программирования, предоставив пространство для нестандартных нейронных паттернов."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_imprint
	name = "Отпечаток коры"
	rnd_name = "Энцефалопластика (отпечаток коры)" // it's a stretch - "brain print reshaping"
	desc = "Биологическая модернизация, которая формирует самозапечатлевающийся узор на коре головного мозга пациента, увеличивая плотность и устойчивость нервных клеток."
	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_imprint/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете вырезать на внешней коре головного мозга [limb.owner.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[surgeon] начинает вырезать на внешней коре головного мозга [limb.owner.declent_ru(GENITIVE)] самопечатающийся шаблон."),
		span_notice("[surgeon]  начинает проводить операцию на мозге [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваша голова раскалывается от ужасной боли, с ней почти невозможно справиться!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы преобразуете внешнюю кору головного мозга [limb.owner.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[surgeon] перестраивает внешнюю кору головного мозга [limb.owner.declent_ru(GENITIVE)] в самопечатающийся шаблон!"),
		span_notice("[surgeon] завершает операцию на мозге у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваш мозг становится сильнее... более устойчивым!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы ошибаетесь, повреждая мозг!"),
		span_warning("[surgeon] ошибается, нанеся повреждения мозгу!"),
		span_notice("[surgeon] завершает операцию на мозге [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Голова раскалывается от ужасной боли; от одной мысли об этом уже начинает болеть голова!")
	limb.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_imprint/mechanic
	rnd_name = "Wetware OS Версия 2.0 (отпечаток коры)"
	desc = "Обновите операционную систему роботизированного пациента до 'новой версии', повысив общую производительность и надежность. \
		Жаль, что все это рекламное ПО."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
