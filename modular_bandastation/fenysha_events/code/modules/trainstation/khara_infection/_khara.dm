#define KHARA_SPREADING_MODIFIER 1.4
#define KHARA_FINAL_EMERGENCE_DELAY (90 SECONDS)
#define KHARA_EMERGENCE_BRUTE_DAMAGE 200
#define KHARA_TUMOR_THRESHOLD_STAGE 5

/datum/disease/khara
	name = "Инфекция Кхара"
	desc = "Неизлечимый, заразный патоген. Кхара развивается в нервной системе и кровотоке носителя, стремительно мутируя клетки. \
			Внешне инфекция напоминает рак. В теле больного появляются множественные быстрорастущие злокачественные опухоли. \
			На первых трёх стадиях некоторые реагенты могут замедлить или частично обратить развитие болезни. \
			На поздних стадиях этот эффект значительно слабее. \
			После полного развития тело носителя будет разрушено новой формой жизни, сформировавшейся внутри него."
	form = "Биоинженерная болезнь"
	agent = "Споры Veral khara"
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	spread_flags = DISEASE_SPREAD_SPECIAL|DISEASE_SPREAD_AIRBORNE|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_BLOOD
	stage_prob = 13
	max_stages = 7
	spread_text = "Споры Veral khara (контакт + миазмы на поздних стадиях)"
	cure_text = "Неизлечимо. Резадон и галоперидол могут замедлить / частично обратить прогрессию. \
				Токсин анацеа крайне эффективно уничтожает споры. Технеций-99 значительно усиливает действие анацеа."
	viable_mobtypes = list(/mob/living/carbon/human)
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_BIOHAZARD
	process_dead = FALSE
	spreading_modifier = KHARA_SPREADING_MODIFIER
	cures = list()

	var/stage_process = 0
	var/base_stage_speed = 0.8

	var/list/inverters = list(
		/datum/reagent/medicine/rezadone = 1,
		/datum/reagent/medicine/haloperidol = 3,
		/datum/reagent/toxin/anacea = 6.5,
	)
	var/invert_catalyst = /datum/reagent/inverse/technetium
	var/thing_emerg = /mob/living/basic/khara_mutant/reaper

	COOLDOWN_DECLARE(stage_process_cd)
	COOLDOWN_DECLARE(organ_failure_cd)
	COOLDOWN_DECLARE(miasma_spread_cd)
	COOLDOWN_DECLARE(tumor_pain_cd)
	COOLDOWN_DECLARE(crack_bones_cd)

	var/list/khara_tumors = list()
	var/emerging = FALSE

/datum/disease/khara/infect(mob/living/infectee, make_copy)
	. = ..()
	stage = 1
	stage_process = 0
	var/obj/item/organ/brain/brain = infectee.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!brain)
		cure(FALSE)
		return
	brain.AddComponent(/datum/component/khara_disease)

/datum/disease/khara/update_stage(new_stage)
	if(stage_process < 100 && new_stage > stage)
		return FALSE
	. = ..()
	if(!.)
		return
	stage_process = 0
	switch(new_stage)
		if(1 to 3)
			visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
			base_stage_speed = 0.8
			process_dead = FALSE
			spreading_modifier = KHARA_SPREADING_MODIFIER
		if(4)
			to_chat(affected_mob, span_userdanger("Что-то тяжёлое и неправильное пульсирует глубоко внутри живота…"))
			spreading_modifier *= 0.6
			base_stage_speed = 1.2
			process_dead = TRUE
			visibility_flags = HIDDEN_PANDEMIC
			spreading_modifier = KHARA_SPREADING_MODIFIER * 1.2
		if(5)
			to_chat(affected_mob, span_userdanger("Кожа вздувается и шевелится — что-то растёт слишком быстро!"))
			base_stage_speed = 1.6
			spreading_modifier = KHARA_SPREADING_MODIFIER * 1.4
		if(6)
			to_chat(affected_mob, span_userdanger("Кости трещат и ломаются под немыслимым внутренним давлением!"))
			visibility_flags = NONE
			base_stage_speed = 1.8
			spreading_modifier = KHARA_SPREADING_MODIFIER * 1.6
		if(7)
			base_stage_speed = 2
			to_chat(affected_mob, span_userdanger("Всё внутри шевелится. Оно хочет наружу."))
			affected_mob.Shake(duration = 2 SECONDS)
			spreading_modifier = KHARA_SPREADING_MODIFIER * 2


/datum/disease/khara/proc/stage_evolution_process(seconds_per_tick)
	var/base = base_stage_speed
	var/has_invert_catalyst = affected_mob.has_reagent(invert_catalyst, 1, TRUE)
	if(has_invert_catalyst || HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE))
		base *= 0.5

	var/healing = 0
	for(var/inverter in inverters)
		if(affected_mob.has_reagent(inverter, 1, TRUE))
			healing += inverters[inverter]

	if(healing > 0 && stage >= 4 && !has_invert_catalyst)
		healing *= 0.5
	if(stage >= 7)
		healing = 0

	var/stage_step = base - healing
	stage_process = min(stage_process + (stage_step * seconds_per_tick), 100)
	if(stage_process <= 0 && stage > 1)
		update_stage(stage - 1)
		stage_process = 0

/datum/disease/khara/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(emerging)
		return

	if(COOLDOWN_FINISHED(src, stage_process_cd))
		stage_evolution_process(seconds_per_tick)
		COOLDOWN_START(src, stage_process_cd, 2 SECONDS)

	switch(stage)
		if(1)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(6, seconds_per_tick))
				to_chat(affected_mob, span_warning("Вы чувствуете странное тепло, распространяющееся под кожей…"))
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_notice("В [pick("запястьях","пальцах","коленях")] будто лёгкое покалывание…"))

		if(2 to 3)
			if(SPT_PROB(5 + stage, seconds_per_tick))
				to_chat(affected_mob, span_warning("Тупая, пульсирующая боль расцветает где-то внутри."))
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_warning("Голова тяжёлая, в висках стучит…"))
				affected_mob.adjust_confusion(4)

			if(SPT_PROB(3, seconds_per_tick))
				affected_mob.adjust_brute_loss(1.2, forced = TRUE)

			if(SPT_PROB(3.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Суставы [pick("ноют","скрипят","будто ржавые")]…"))
				affected_mob.adjust_stamina_loss(6)

		if(4)
			if(SPT_PROB(3, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вы чувствуете, как внутри [pick("грудной клетки", "живота", "бока")] растёт что-то твёрдое и неправильное."))

			if(SPT_PROB(6, seconds_per_tick))
				var/obj/item/bodypart/affecting = affected_mob.get_bodypart(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
				if(affecting)
					to_chat(affected_mob, span_warning("В [affecting.name] вспыхивает резкая боль!"))
					affecting.receive_damage(5, 0, wound_bonus = CANT_WOUND)

			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.adjust_brute_loss(rand(2,5), forced = TRUE)

			// Дрожь в руках → роняние предметов
			if(SPT_PROB(4.5, seconds_per_tick) && affected_mob.get_active_hand())
				to_chat(affected_mob, span_warning("Пальцы внезапно онемели и не слушаются…"))
				affected_mob.dropItemToGround(affected_mob.get_active_held_item())
				affected_mob.emote("gasp")

			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, tumor_pain_cd))
				affected_mob.emote("scream")
				to_chat(affected_mob, span_userdanger("Вы чувствуете как что-то в внутри [pick("грудной клетки", "правой руке", "левой руке")] болезненно пульсирует."))
				affected_mob.adjust_brute_loss(rand(10, 20), forced = TRUE)
				COOLDOWN_START(src, tumor_pain_cd, rand(25, 45) SECONDS)

		if(5)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Плоть чудовищно вздувается — внутри что-то живое!"))
				affected_mob.adjust_brute_loss(rand(5, 10), forced = TRUE)

			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_warning("Голова раскалывается, в глазах мелькают вспышки…"))
				affected_mob.adjust_confusion(6)
				affected_mob.adjust_eye_blur(8)

			if(SPT_PROB(3.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Ноги подкашиваются, суставы будто плавятся…"))
				affected_mob.AdjustKnockdown(rand(15, 30))
				affected_mob.adjust_stamina_loss(10)

			if(SPT_PROB(3, seconds_per_tick))
				damage_random_organ(rand(8, 14))

			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, miasma_spread_cd))
				spread_khara_miasma()
				COOLDOWN_START(src, miasma_spread_cd, rand(20, 45) SECONDS)

		if(6)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_bolddanger("Рёбра стонут и смещаются — что-то раздвигает их!"))

			if(SPT_PROB(6, seconds_per_tick))
				affected_mob.adjust_brute_loss(rand(6,11), forced = TRUE)

			if(SPT_PROB(4.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Руки дрожат так сильно, что невозможно ничего удержать…"))
				if(affected_mob.get_active_held_item())
					affected_mob.dropItemToGround(affected_mob.get_active_held_item(), TRUE)

			if(SPT_PROB(3, seconds_per_tick))
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD|VOMIT_CATEGORY_KNOCKDOWN, lost_nutrition = FALSE)

			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, crack_bones_cd))
				affected_mob.emote("scream")
				affected_mob.adjust_brute_loss(8, forced = TRUE)
				COOLDOWN_START(src, crack_bones_cd, 28 SECONDS)

			if(SPT_PROB(2.5, seconds_per_tick))
				spread_khara_miasma()

		if(7)
			if(!COOLDOWN_FINISHED(src, organ_failure_cd) && stage_process < 100)
				return

			to_chat(affected_mob, span_boldnicegreen("Боль отступает! Всё в порядке."))
			visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC

			emerging = TRUE
			addtimer(CALLBACK(src, PROC_REF(perform_emergence)), KHARA_FINAL_EMERGENCE_DELAY)

/datum/disease/khara/proc/perform_emergence()
	if(QDELETED(affected_mob))
		return
	visibility_flags = NONE
	affected_mob.visible_message(span_userdanger("Тело [affected_mob] бьётся в страшных судорогах — что-то рвётся наружу!"), span_userdanger("Всё кончено."))
	affected_mob.Paralyze(8 SECONDS)
	affected_mob.Knockdown(12 SECONDS)
	for(var/i = 1 to rand(5, 8))
		affected_mob.spray_blood(rand(GLOB.cardinals), rand(2, 3))
		sleep(1.5 SECONDS)
		affected_mob.apply_damage(KHARA_EMERGENCE_BRUTE_DAMAGE/10, BRUTE, wound_bonus = 70, spread_damage = TRUE)
		affected_mob.Shake()

	affected_mob.visible_message(
		span_userdanger("Грудная клетка [affected_mob] разрывается фонтаном крови и чёрной жижи, наружу вырывается уродливое существо!"),
		span_userdanger("Ваше тело взрывается изнутри — вас больше нет.")
	)

	affected_mob.apply_damage(KHARA_EMERGENCE_BRUTE_DAMAGE, BRUTE, wound_bonus = 70, spread_damage = TRUE)
	affected_mob.spill_organs(DROP_ORGANS)
	if(thing_emerg)
		new thing_emerg(get_turf(affected_mob))
	update_stage(1)

	log_virus("[key_name(affected_mob)] был поглощён и разорван Кхара в [loc_name(affected_mob)]")
	affected_mob.investigate_log("погиб от инфекции Кхара (поглощён и разорван).", INVESTIGATE_DEATHS)


/datum/disease/khara/proc/spread_khara_miasma()
	var/obj/item/organ/lungs/l = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!l || !(l.organ_flags & ORGAN_ORGANIC))
		return FALSE

	var/datum/reagents/R = new(12)
	R.my_atom = affected_mob
	R.add_reagent(/datum/reagent/toxin/khara, 12)

	var/datum/effect_system/fluid_spread/smoke/chem/S = new(get_turf(affected_mob), range = 3, holder = R)
	S.start()

	affected_mob.emote("cough")
	return TRUE


/datum/disease/khara/proc/damage_random_organ(dmg)
	if(affected_mob.stat == DEAD)
		return
	var/obj/item/organ/O = pick(affected_mob.organs)
	if(!O || !(O.organ_flags & ORGAN_ORGANIC))
		return
	O.apply_organ_damage(dmg)
	if(O.organ_flags & ORGAN_FAILING)
		to_chat(affected_mob, span_userdanger("Ваш [O.name] будто раздавливают изнутри!"))

#undef KHARA_SPREADING_MODIFIER
#undef KHARA_FINAL_EMERGENCE_DELAY
#undef KHARA_EMERGENCE_BRUTE_DAMAGE
#undef KHARA_TUMOR_THRESHOLD_STAGE



/datum/component/khara_disease
	VAR_PRIVATE/mob/living/carbon/current_mob = null
	VAR_PRIVATE/obj/item/organ/brain/brain_parent = null

/datum/component/khara_disease/Initialize()
	if(!istype(parent, /obj/item/organ/brain))
		return COMPONENT_INCOMPATIBLE
	brain_parent = parent
	if(!brain_parent.owner || !iscarbon(brain_parent.owner))
		return COMPONENT_INCOMPATIBLE
	register_to_mob(current_mob)

/datum/component/khara_disease/RegisterWithParent()
	RegisterSignals(brain_parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED), PROC_REF(on_brain_removed))
	RegisterSignal(brain_parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_brain_implanted))

/datum/component/khara_disease/UnregisterFromParent()
	UnregisterSignal(brain_parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED, COMSIG_ORGAN_IMPLANTED))

/datum/component/khara_disease/proc/register_to_mob(mob/living/carbon/new_host)
	if(!new_host || !iscarbon(new_host))
		return

	current_mob = new_host
	new_host.ForceContractDisease(new /datum/disease/khara(), del_on_fail = TRUE)
	RegisterSignal(current_mob, COMSIG_LIVING_REVIVE, PROC_REF(on_host_revived))

/datum/component/khara_disease/proc/unregister_from_host(mob/living/carbon/old_host)
	UnregisterSignal(old_host, COMSIG_LIVING_REVIVE)
	current_mob = null

/datum/component/khara_disease/proc/on_host_revived(mob/living/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	current_mob.ForceContractDisease(new /datum/disease/khara(), del_on_fail = TRUE)

/datum/component/khara_disease/proc/on_brain_removed()
	SIGNAL_HANDLER

	if(!current_mob)
		return

	current_mob.visible_message(span_userdanger("Это была плохая идея!"))
	current_mob.apply_damage(500, BRUTE, forced = TRUE, spread_damage = TRUE, wound_bonus = 100)
	var/datum/disease/khara/khara = null
	for(var/datum/disease/D in current_mob.diseases)
		if(istype(D, /datum/disease/khara))
			khara = D
			break
	khara.emerging = TRUE
	khara.stage = 7
	khara.stage_process = 100
	ASYNC
		khara.perform_emergence()
	unregister_from_host(current_mob)

/datum/component/khara_disease/proc/on_brain_implanted()
	SIGNAL_HANDLER
	register_to_mob(brain_parent.owner)


/datum/weather/khara_infection
	name = "Туман Кхара"
	desc = "Густой туман, наполненный спорами Кхара…"

	telegraph_message = span_userdanger("С неба опускается туман, наполненный спорами Кхара!")
	telegraph_duration = 30 SECONDS

	weather_message = span_userdanger("Густой едкий туман опускается с неба. Пора переходить на внутренний запас воздуха!")
	weather_overlay = "dust_med"
	weather_color = COLOR_MAROON

	end_message = span_userdanger("Туман рассеивается!")
	end_duration = 0 SECONDS

	area_type = /area
	protected_areas = list(/area/space)
	target_trait = ZTRAIT_STATION

	use_glow = FALSE
	weather_flags = (WEATHER_MOBS | WEATHER_ENDLESS)


/datum/weather/khara_infection/New(z_levels, list/weather_data)
	. = ..()
	weather_reagent_holder = new(null)
	weather_reagent_holder.create_reagents(WEATHER_REAGENT_VOLUME, NO_REACT)
	weather_reagent_holder.reagents.add_reagent(/datum/reagent/toxin/khara, WEATHER_REAGENT_VOLUME)
	weather_reagent_holder.reagents.set_temperature(weather_temperature)

/datum/weather/khara_infection/weather_act_mob(mob/living/victim)
	if(!ishuman(victim))
		return
	var/mob/living/carbon/human/human = victim
	if(human.stat == DEAD)
		return

	var/does_breath = FALSE
	if(human.external && human.external.breathing_mob == human)
		does_breath = FALSE
	else if(human.internal && human.internal.breathing_mob == human)
		does_breath = FALSE
	else if(HAS_TRAIT(human, TRAIT_NOBREATH))
		does_breath = FALSE
	else
		var/obj/item/organ/lungs/lungs = human.get_organ_slot(ORGAN_SLOT_LUNGS)
		if(lungs && (lungs.organ_flags & ORGAN_ORGANIC))
			does_breath = TRUE

	var/obj/item/clothing/suit = human.is_mouth_covered(ITEM_SLOT_OCLOTHING)
	var/obj/item/clothing/mask = human.is_mouth_covered(ITEM_SLOT_MASK)
	var/total_prot = (suit?.get_armor_rating(BIO) + mask?.get_armor_rating(BIO))
	if(!does_breath && total_prot >= 50)
		return
	if(human.has_reagent(/datum/reagent/toxin/khara, 10))
		return // уже достаточно

	weather_reagent_holder.reagents.expose(human, VAPOR, show_message = TRUE)
