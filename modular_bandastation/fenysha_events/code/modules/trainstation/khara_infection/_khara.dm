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
	visibility_flags = NONE
	spread_flags = DISEASE_SPREAD_SPECIAL
	stage_prob = 12
	max_stages = 7
	spread_text = "Споры Veral khara (контакт + миазмы на поздних стадиях)"
	cure_text = "Неизлечимо. Резадон и галоперидол могут замедлить / частично обратить прогрессию. \
				Токсин анацеа крайне эффективно уничтожает споры. Технеций-99 значительно усиливает действие анацеа."
	viable_mobtypes = list(/mob/living/carbon/human)
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_UNCURABLE
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


/datum/disease/khara/update_stage(new_stage)
	if(stage_process < 100 && new_stage > stage)
		return FALSE
	. = ..()
	if(!.)
		return
	stage_process = 0
	switch(new_stage)
		if(4)
			to_chat(affected_mob, span_userdanger("Что-то тяжёлое и неправильное пульсирует глубоко внутри живота…"))
			spreading_modifier *= 0.6
			process_dead = TRUE
		if(5)
			visibility_flags = NONE
			to_chat(affected_mob, span_userdanger("Кожа вздувается и шевелится — что-то растёт слишком быстро!"))
		if(6)
			to_chat(affected_mob, span_bolddanger("Кости трещат и ломаются под немыслимым внутренним давлением!"))
		if(7)
			to_chat(affected_mob, span_bolddanger("Всё внутри шевелится. Оно хочет наружу."))


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
		COOLDOWN_START(src, stage_process_cd, 3 SECONDS)

	switch(stage)
		if(1)
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Вы чувствуете странное тепло, распространяющееся под кожей…"))

		if(2 to 3)
			if(SPT_PROB(5 + stage, seconds_per_tick))
				to_chat(affected_mob, span_warning("Тупая, пульсирующая боль расцветает где-то внутри."))
			if(SPT_PROB(3, seconds_per_tick))
				affected_mob.adjust_tox_loss(1.2, forced = TRUE)

		if(4)
			if(SPT_PROB(3, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вы чувствуете, как внутри [pick("грудной клетки", "живота", "бока")] растёт что-то твёрдое и неправильное."))
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.adjust_brute_loss(rand(2,5), forced = TRUE)

			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, tumor_pain_cd))
				affected_mob.emote("scream")
				affected_mob.adjust_brute_loss(rand(10, 20), forced = TRUE)
				COOLDOWN_START(src, tumor_pain_cd, 25 SECONDS)

		if(5)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Плоть grotesquely вздувается — внутри что-то живое!"))
			if(SPT_PROB(3, seconds_per_tick))
				damage_random_organ(rand(8, 14))
			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, miasma_spread_cd))
				spread_khara_miasma()
				COOLDOWN_START(src, miasma_spread_cd, 35 SECONDS)

		if(6)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_bolddanger("Рёбра стонут и смещаются — что-то раздвигает их!"))
			if(SPT_PROB(5, seconds_per_tick))
				affected_mob.adjust_brute_loss(rand(6,11), forced = TRUE)
			if(SPT_PROB(3, seconds_per_tick))
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD|VOMIT_CATEGORY_KNOCKDOWN, lost_nutrition = FALSE)
			if(SPT_PROB(5, seconds_per_tick) && COOLDOWN_FINISHED(src, crack_bones_cd))
				affected_mob.emote("scream")
				affected_mob.adjust_brute_loss(8, forced = TRUE)
				COOLDOWN_START(src, crack_bones_cd, 28 SECONDS)

			if(SPT_PROB(2, seconds_per_tick))
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
	stage = 1
	process_dead = FALSE

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
