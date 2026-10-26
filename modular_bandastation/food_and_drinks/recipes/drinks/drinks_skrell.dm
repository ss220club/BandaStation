// MARK 49. Tears of Fyrsskar

/datum/chemical_reaction/drink/fyrsskar_tears
	results = list(/datum/reagent/consumable/ethanol/fyrsskar_tears = 3)
	required_reagents = list(
		/datum/reagent/consumable/triple_citrus = 1,
		/datum/reagent/oxygen = 1,
		/datum/reagent/toxin/plasma = 1
	)
	mix_sound = 'sound/effects/chemistry/bufferadd.ogg'

/datum/reagent/consumable/ethanol/fyrsskar_tears
	name = "Слёзы Фирсскара"
	description = "Алкогольный напиток на основе фарона, который употребляли древние жители родной планеты скреллов"
	color = "#C300AE"
	quality = DRINK_VERYGOOD
	nutriment_factor = 1
	boozepwr = 25
	taste_description = "нотки цитрусовых, согревающий алкоголь и металлическая горчинка"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/fyrsskar_tears/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(isskrell(drinker))
		var/obj/item/organ/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver)
			liver.apply_organ_damage(-2 * metabolization_ratio * seconds_per_tick)

		if(drinker.reagents)
			var/purged_amount = 0
			var/max_purge = 5 * metabolization_ratio * seconds_per_tick

			for(var/datum/reagent/toxin/reagent_to_remove in drinker.reagents.reagent_list.Copy())
				if(reagent_to_remove == src)
					continue

				var/remove_val = min(reagent_to_remove.volume, max_purge - purged_amount)
				drinker.reagents.remove_reagent(reagent_to_remove.type, remove_val)
				purged_amount += remove_val

				if(purged_amount >= max_purge)
					break
	else
		drinker.adjust_disgust(5 * metabolization_ratio * seconds_per_tick)
		if(drinker.adjust_tox_loss(0.75 * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/glass_style/drinking_glass/fyrsskar_tears
	required_drink_type = /datum/reagent/consumable/ethanol/fyrsskar_tears
	name = "Слёзы Фирсскара"
	desc = "Искрящийся фиолетово-голубой напиток с ярко выраженным ароматом цитрусовых и озона."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "fyrsskartears"


// MARK 50. Qerrbalak Amanita Tincture

/datum/chemical_reaction/drink/qerrbalak_amanita_tincture
	results = list(/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture = 30)
	required_reagents = list(
		/datum/reagent/toxin/amatoxin = 5,
		/datum/reagent/consumable/ethanol = 10,
		/datum/reagent/consumable/grenadine = 15
	)
	mix_sound = 'sound/effects/chemistry/catalyst.ogg'

/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture
	name = "Настойка из мухомора «Керрбалак»"
	description = "Вязкая, ало-красная грибная жидкость, богатая сильными аматоксинами и подслащенная рубиновым гренадином. Восстанавливающий силы священный эликсир для скреллов, но смертельно опасный для других видов."
	color = "#8A0303"
	quality = DRINK_VERYGOOD
	nutriment_factor = 1
	boozepwr = 45
	taste_description = "сладкий гранат, сильное алкогольное жжение и ошеломляющий грибной землистый привкус"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture/on_mob_metabolize(mob/living/drinker)
	. = ..()
	if(isskrell(drinker))
		drinker.add_mood_event("amanita_tincture_high", /datum/mood_event/narcotic_heavy)
		if(drinker.hud_used)
			var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
			if(game_plane_master_controller)
				game_plane_master_controller.add_filter("amanita_wave", 1, list("type" = "wave", "size" = 2, "x" = 32, "y" = 32))
				for(var/filter in game_plane_master_controller.get_filters("amanita_wave"))
					animate(filter, time = 48 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.clear_mood_event("amanita_tincture_high")
	if(drinker.hud_used)
		var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		if(game_plane_master_controller)
			game_plane_master_controller.remove_filter("amanita_wave")

/datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(isskrell(drinker))
		var/obj/item/organ/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver)
			liver.apply_organ_damage(-1.5 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_stamina_loss(-3 * metabolization_ratio * seconds_per_tick)
		drinker.AdjustAllImmobility(-15 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_drugginess(30 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_hallucinations(20 SECONDS * metabolization_ratio * seconds_per_tick)
		if(SPT_PROB(5, seconds_per_tick))
			drinker.emote(pick("twitch", "giggle", "smile"))
	else
		drinker.adjust_disgust(8 * metabolization_ratio * seconds_per_tick)
		if(drinker.adjust_tox_loss(1.5 * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/glass_style/drinking_glass/qerrbalak_amanita_tincture
	required_drink_type = /datum/reagent/consumable/ethanol/qerrbalak_amanita_tincture
	name = "Настойка из мухомора «Керрбалак»"
	desc = "Напиток глубокого рубиново-красного цвета, в котором плавают белые споры грибка."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "amanita_tincture"

// MARK 51. Glow-Seraka Tonic

/datum/chemical_reaction/drink/glow_seraka_tonic
	results = list(/datum/reagent/consumable/glow_seraka_tonic = 30)
	required_reagents = list(
		/datum/reagent/medicine/coagulant/seraka_extract = 5,
		/datum/reagent/uranium/radium = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/water = 15
	)
	mix_sound = 'sound/effects/liquid_pour/liquid_pour3.ogg'

/datum/reagent/consumable/glow_seraka_tonic
	name = "Тоник «Глоу-Серака»"
	description = "Мерцающий тоник огненно-янтарного цвета, приготовленный из экстремофильных грибов Лаваландии и огненных цветов. Согревает шахтеров и придает им биолюминесценцию в кромешной тьме."
	color = "#FF8C00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 2
	taste_description = "вулканическое тепло, пряный цветочный аромат и покалывающий запах фосфора"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/glow_seraka_tonic/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	drinker.set_light(3, 2, "#FFA500")
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/atom, set_light), 0), 4 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	if(isskrell(drinker))
		drinker.remove_status_effect(/datum/status_effect/jitter)
		drinker.adjust_brute_loss(-0.2 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_stamina_loss(-2 * metabolization_ratio * seconds_per_tick)

/datum/glass_style/drinking_glass/glow_seraka_tonic
	required_drink_type = /datum/reagent/consumable/glow_seraka_tonic
	name = "Тоник «Глоу-Серака"
	desc = "Теплый коктейль ярко-оранжевого цвета, который слабо освещает окружающее пространство."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "glow_seraka"

// MARK 52. Aliose Velvet Cordial

/datum/chemical_reaction/drink/aliose_velvet_cordial
	results = list(/datum/reagent/consumable/ethanol/aliose_velvet_cordial = 30)
	required_reagents = list(
		/datum/reagent/consumable/soymilk = 10,
		/datum/reagent/consumable/cherryjelly = 10,
		/datum/reagent/consumable/ethanol/vermouth = 5,
		/datum/reagent/consumable/sugar = 5
	)
	mix_sound = 'sound/effects/liquid_pour/liquid_pour2.ogg'

/datum/reagent/consumable/ethanol/aliose_velvet_cordial
	name = "Алиосский Бархат"
	description = "Бархатистый десертный ликёр пастельно-розового цвета, сочетающий в себе сливочное соевое молоко, игристую вишнёвую газировку и изысканный вермут. Исключительно щадящий для скреллианского организма."
	color = "#D1526D"
	quality = DRINK_VERYGOOD
	nutriment_factor = 2
	boozepwr = 15
	taste_description = "мягкий сладкий крем, засахаренные вишни и нежные травы вермута"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/aliose_velvet_cordial/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	drinker.adjust_disgust(-5 * metabolization_ratio * seconds_per_tick)
	drinker.remove_status_effect(/datum/status_effect/jitter)
	drinker.remove_status_effect(/datum/status_effect/confusion)

	if(isskrell(drinker) && SPT_PROB(2, seconds_per_tick))
		to_chat(drinker, span_notice(pick("Вы чувствуете мягкое умиротворение.", "Бархатный вкус приятно согревает ваши четалы.")))

/datum/glass_style/drinking_glass/aliose_velvet_cordial
	required_drink_type = /datum/reagent/consumable/ethanol/aliose_velvet_cordial
	name = "Алиосский Бархат"
	desc = "Высокий, изящный бокал, наполненный кремообразным ликером пастельно-розового цвета, украшенный тёмной вишней."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "aliose_velvet"

// MARK 53. Qerrbalak Umami Tonic

/datum/chemical_reaction/drink/qerrbalak_umami_tonic
	results = list(/datum/reagent/consumable/qerrbalak_umami_tonic = 35)
	required_reagents = list(
		/datum/reagent/consumable/soysauce = 10,
		/datum/reagent/consumable/soy_latte = 15,
		/datum/reagent/water = 5,
		/datum/reagent/toxin/plasma = 5
	)
	mix_sound = 'sound/effects/chemistry/bufferadd.ogg'

/datum/reagent/consumable/qerrbalak_umami_tonic
	name = "Тоник «Керрбалак Умами»"
	description = "Насыщенный, пикантно-умами изотонический бульон, приготовленный на основе соевых экстрактов, крепкого кофе и плазмы. Повышает нервную проводимость головы и щупалец."
	color = "#D84C00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 3
	taste_description = "насыщенный бульон с нотками умами, аромат жареного темного кофе и яркое покалывание"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/qerrbalak_umami_tonic/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker?.mind?.experience_multiplier_reasons[type] = null
	drinker?.mind?.experience_multiplier_reasons -= type

/datum/reagent/consumable/qerrbalak_umami_tonic/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(isskrell(drinker))
		drinker.remove_status_effect(/datum/status_effect/confusion)
		drinker.remove_status_effect(/datum/status_effect/jitter)
		drinker.adjust_stamina_loss(-2 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_drowsiness(-3 * metabolization_ratio * seconds_per_tick)

		drinker?.mind?.experience_multiplier_reasons |= type
		drinker?.mind?.experience_multiplier_reasons[type] = 1.25 * metabolization_ratio * seconds_per_tick
	else
		drinker.adjust_disgust(5 * metabolization_ratio * seconds_per_tick)
		if(drinker.adjust_tox_loss(0.75 * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/glass_style/drinking_glass/qerrbalak_umami_tonic
	required_drink_type = /datum/reagent/consumable/qerrbalak_umami_tonic
	name = "Тоник «Керрбалак Умами»"
	desc = "Керамическая чашка с пикантным тоником И ароматным запахом жареного."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "umami_tonic"


// MARK 54. Heart of Qerrbalak

/datum/chemical_reaction/drink/heart_of_qerrbalak
	results = list(/datum/reagent/consumable/heart_of_qerrbalak = 40)
	required_reagents = list(
		/datum/reagent/toxin/bungotoxin = 10,
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/datum/reagent/drug/space_drugs = 5,
		/datum/reagent/consumable/lemon_lime = 10,
		/datum/reagent/consumable/triple_citrus = 10
	)
	mix_sound = 'sound/effects/chemistry/catalyst.ogg'

/datum/reagent/consumable/heart_of_qerrbalak
	name = "Сердце Керрбалака"
	description = "Светящаяся психоделическая смесь, насыщенная смертоносными токсинами и игристыми цитрусовыми нотками. Вызывает у Скрелла трансцендентное умиротворение."
	color = "#68B0A8"
	quality = DRINK_VERYGOOD
	nutriment_factor = 1
	overdose_threshold = 25
	taste_description = "игристый лайм, пикантные цитрусовые и ошеломляющий тропический яд"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/heart_of_qerrbalak/on_mob_metabolize(mob/living/drinker)
	. = ..()
	if(isskrell(drinker))
		ADD_TRAIT(drinker, TRAIT_ANALGESIA, type)
		ADD_TRAIT(drinker, TRAIT_FEARLESS, type)
		drinker.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
		drinker.add_mood_event("heart_of_qerrbalak", /datum/mood_event/high)

		if(drinker.hud_used)
			var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
			if(game_plane_master_controller)
				var/list/col_filter_tint = list(0.3,0,0,0, 0,1.2,0,0, 0,0,0.8,0, 0,0,0,1, 0.1,0.2,0,0)
				game_plane_master_controller.add_filter("heart_tint", 10, color_matrix_filter(col_filter_tint, FILTER_COLOR_RGB))

				game_plane_master_controller.add_filter("heart_wave", 1, list("type" = "wave", "size" = 3, "x" = 24, "y" = 24))
				for(var/filter in game_plane_master_controller.get_filters("heart_wave"))
					animate(filter, time = 24 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/consumable/heart_of_qerrbalak/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	REMOVE_TRAIT(drinker, TRAIT_ANALGESIA, type)
	REMOVE_TRAIT(drinker, TRAIT_FEARLESS, type)
	if(drinker.sound_environment_override == SOUND_ENVIRONMENT_PSYCHOTIC)
		drinker.sound_environment_override = NONE
	drinker.clear_mood_event("heart_of_qerrbalak")

	if(drinker.hud_used)
		var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		if(game_plane_master_controller)
			game_plane_master_controller.remove_filter("heart_tint")
			game_plane_master_controller.remove_filter("heart_wave")

/datum/reagent/consumable/heart_of_qerrbalak/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(isskrell(drinker))
		drinker.apply_status_effect(/datum/status_effect/stoned)
		drinker.set_slurring_if_lower(15 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_drugginess(40 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_hallucinations(30 SECONDS * metabolization_ratio * seconds_per_tick)

		if(SPT_PROB(3, seconds_per_tick))
			var/trip_message = pick(
				"Ваши хвосты вибрируют на неощутимой частоте древнего океана...",
				"Тело кажется невероятно лёгким, словно гравитация исчезла...",
				"Теплые био-волны размывают границы окружающего пространства...",
				"Вы слышите мягкий шёпот первозданных глубин Кверрбалака...",
			)
			to_chat(drinker, span_notice("[trip_message]"))

		if(isturf(drinker.loc) && !isspaceturf(drinker.loc) && !HAS_TRAIT(drinker, TRAIT_IMMOBILIZED) && SPT_PROB(4, seconds_per_tick))
			step(drinker, pick(GLOB.cardinals))

		if(SPT_PROB(5, seconds_per_tick))
			drinker.emote(pick("smile", "giggle", "drool"))

	else
		drinker.adjust_oxy_loss(1.5 * metabolization_ratio * seconds_per_tick)
		drinker.set_slurring_if_lower(10 SECONDS)
		if(SPT_PROB(25, seconds_per_tick))
			drinker.losebreath++
		if(SPT_PROB(15, seconds_per_tick))
			drinker.Paralyze(3 SECONDS)
			to_chat(drinker, span_danger("Ваши мышцы внезапно сковывает паралич, дышать становится невозможно!"))

/datum/reagent/consumable/heart_of_qerrbalak/overdose_process(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(isskrell(drinker))
		if(SPT_PROB(10, seconds_per_tick))
			drinker.drop_all_held_items()
			drinker.Paralyze(4 SECONDS)
			to_chat(drinker, span_notice("Ваше сознание полностью покидает тело, растворяясь в чистом потоке образов!"))
	else
		drinker.adjust_oxy_loss(4 * metabolization_ratio * seconds_per_tick)
		drinker.Paralyze(4 SECONDS)

/datum/glass_style/drinking_glass/heart_of_qerrbalak
	required_drink_type = /datum/reagent/consumable/heart_of_qerrbalak
	name = "Сердце Керрбалака"
	desc = "Светящаяся психоделическая смесь, насыщенная смертоносными токсинами и игристыми цитрусовыми нотками. Вызывает у Скрелла трансцендентное умиротворение."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "heart_qerrbalak"

// MARK 55. Omega-Glow Cocktail

/datum/chemical_reaction/drink/omega_glow_cocktail
	results = list(/datum/reagent/consumable/ethanol/omega_glow_cocktail = 30)
	required_reagents = list(
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/uranium/radium = 5,
		/datum/reagent/consumable/ethanol/absinthe = 10,
		/datum/reagent/consumable/tonic = 10
	)
	mix_sound = 'sound/effects/chemistry/bufferadd.ogg'

/datum/reagent/consumable/ethanol/omega_glow_cocktail
	name = "Коктейль «Омега-Глоу»"
	description = "Завораживающий калейдоскопический коктейль, состоящий из горького абсента, игристого тоника и биолюминесцентных растительных экстрактов."
	color = "#7B68EE"
	quality = DRINK_FANTASTIC
	nutriment_factor = 2
	boozepwr = 35
	taste_description = "жгучий анисовый ликёр, игристый хинин и сияющая небесная амброзия"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/omega_glow_cocktail/on_mob_metabolize(mob/living/drinker)
	. = ..()
	drinker.add_mood_event("omega_glow_trip", /datum/mood_event/high)
	if(!drinker.client || !drinker.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(game_plane_master_controller)
		var/list/col_filter_identity = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.000,0,0,0)
		var/list/col_filter_shift_once = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.333,0,0,0)
		var/list/col_filter_shift_twice = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.666,0,0,0)
		var/list/col_filter_reset = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 1.000,0,0,0)

		game_plane_master_controller.add_filter("omega_rainbow", 10, color_matrix_filter(col_filter_reset, FILTER_COLOR_HSL))
		for(var/filter in game_plane_master_controller.get_filters("omega_rainbow"))
			animate(filter, color = col_filter_identity, time = 0 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
			animate(color = col_filter_shift_once, time = 4 SECONDS)
			animate(color = col_filter_shift_twice, time = 4 SECONDS)
			animate(color = col_filter_reset, time = 4 SECONDS)

		game_plane_master_controller.add_filter("omega_wave", 1, list("type" = "wave", "size" = 2, "x" = 32, "y" = 32))
		for(var/filter in game_plane_master_controller.get_filters("omega_wave"))
			animate(filter, time = 64 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/consumable/ethanol/omega_glow_cocktail/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.clear_mood_event("omega_glow_trip")
	if(!drinker.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = drinker.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(game_plane_master_controller)
		game_plane_master_controller.remove_filter("omega_rainbow")
		game_plane_master_controller.remove_filter("omega_wave")

/datum/reagent/consumable/ethanol/omega_glow_cocktail/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	drinker.set_light(2, 2, "#7B68EE")
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/atom, set_light), 0), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	if(isskrell(drinker))
		drinker.adjust_drugginess(40 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_hallucinations(30 SECONDS * metabolization_ratio * seconds_per_tick)

		drinker.adjust_brute_loss(-0.25 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_fire_loss(-0.25 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_tox_loss(-0.25 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_oxy_loss(-0.25 * metabolization_ratio * seconds_per_tick)
	else
		drinker.adjust_drugginess(25 SECONDS * metabolization_ratio * seconds_per_tick)
		drinker.adjust_hallucinations(15 SECONDS * metabolization_ratio * seconds_per_tick)

		drinker.adjust_brute_loss(-0.15 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_fire_loss(-0.15 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_tox_loss(-0.15 * metabolization_ratio * seconds_per_tick)
		drinker.adjust_oxy_loss(-0.15 * metabolization_ratio * seconds_per_tick)

/datum/glass_style/drinking_glass/omega_glow_cocktail
	required_drink_type = /datum/reagent/consumable/ethanol/omega_glow_cocktail
	name = "Коктейль «Омега-Глоу»"
	desc = "Коктейль, переливающийся призмами, с меняющимися фиолетового и изумрудного цвета."
	icon = 'modular_bandastation/food_and_drinks/icons/drinks/skrell.dmi'
	icon_state = "omega_glow"


// MARK Другие реагенты

/datum/reagent/consumable/qerr_primordial_nectar
	name = "Первозданный нектар Керрбалака"
	description = "Священная эссенция, воссоздающая состав реликтовых геотермальных ванн одного из чудес света скреллов. Исцеляет глубокие повреждения разума, восстанавливает органы и гармонизирует биологические ритмы любого существа."
	color = "#40E0D0"
	quality = FOOD_AMAZING
	nutriment_factor = 4
	metabolization_rate = 0.33 * REAGENTS_METABOLISM
	taste_description = "термальная родниковая вода, сладкая амброзия и успокаивающий озон"
	chemical_flags = NONE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM

/datum/reagent/consumable/qerr_primordial_nectar/on_mob_add(mob/living/L, amount)
	. = ..()
	RegisterSignal(L, COMSIG_MOB_REAGENT_TICK, PROC_REF(block_toxins), override = TRUE)

/datum/reagent/consumable/qerr_primordial_nectar/on_mob_metabolize(mob/living/drinker)
	. = ..()
	drinker.add_mood_event("qerr_harmony", /datum/mood_event/high)
	RegisterSignal(drinker, COMSIG_MOB_REAGENT_TICK, PROC_REF(block_toxins), override = TRUE)

/datum/reagent/consumable/qerr_primordial_nectar/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	UnregisterSignal(drinker, COMSIG_MOB_REAGENT_TICK)
	drinker.clear_mood_event("qerr_harmony")
	drinker?.mind?.experience_multiplier_reasons[type] = null
	drinker?.mind?.experience_multiplier_reasons -= type

/datum/reagent/consumable/qerr_primordial_nectar/on_mob_delete(mob/living/L)
	UnregisterSignal(L, COMSIG_MOB_REAGENT_TICK)
	return ..()

/// Блокирует тики всех токсинов в организме любой расы, пока действует нектар
/datum/reagent/consumable/qerr_primordial_nectar/proc/block_toxins(datum/source, datum/reagent/chem, seconds_per_tick, metabolization_rate)
	SIGNAL_HANDLER
	if(istype(chem, /datum/reagent/toxin))
		return COMSIG_MOB_STOP_REAGENT_TICK
	return NONE

/datum/reagent/consumable/qerr_primordial_nectar/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, metabolization_ratio)
	. = ..()
	// Мягкое бирюзовое сияние
	drinker.set_light(2, 2, "#40E0D0")
	addtimer(CALLBACK(drinker, TYPE_PROC_REF(/atom, set_light), 0), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	// Активное подавление чужеродных токсинов (защищает от аматоксинов в блюде)
	if(drinker.reagents)
		for(var/datum/reagent/toxin/toxic_chem in drinker.reagents.reagent_list.Copy())
			drinker.reagents.remove_reagent(toxic_chem.type, 1.5 * metabolization_ratio * seconds_per_tick)

	// Базовое исцеление повреждений тела для всех существ
	drinker.adjust_brute_loss(-0.5 * metabolization_ratio * seconds_per_tick)
	drinker.adjust_fire_loss(-0.5 * metabolization_ratio * seconds_per_tick)
	drinker.adjust_oxy_loss(-0.5 * metabolization_ratio * seconds_per_tick)
	drinker.adjust_tox_loss(-0.5 * metabolization_ratio * seconds_per_tick)

	// СПЕЦИФИКА ДЛЯ СКРЕЛЛОВ: глубокое исцеление разума и органов
	if(isskrell(drinker))
		// Полное восстановление численных повреждений мозга
		drinker.adjust_organ_loss(ORGAN_SLOT_BRAIN, -2 * metabolization_ratio * seconds_per_tick)

		// Исцеление даже продвинутых травм мозга (хирургического уровня)
		if(SPT_PROB(8, seconds_per_tick))
			var/cured = drinker.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
			if(cured)
				to_chat(drinker, span_nicegreen("Теплые био-волны источников омывают ваши четалы, полностью восстанавливая поврежденные нейронные узлы!"))

		// Регенерация всех внутренних органов (сердце, печень, легкие, глаза)
		for(var/obj/item/organ/internal_organ as anything in drinker.organs)
			internal_organ.apply_organ_damage(-1 * metabolization_ratio * seconds_per_tick)

		// Ускорение концентрации и обучаемости
		drinker?.mind?.experience_multiplier_reasons |= type
		drinker?.mind?.experience_multiplier_reasons[type] = 1.5 * metabolization_ratio * seconds_per_tick

		// Снятие стресса, дрожи и дезориентации
		drinker.remove_status_effect(/datum/status_effect/jitter)
		drinker.remove_status_effect(/datum/status_effect/confusion)
		drinker.adjust_drowsiness(-5 * metabolization_ratio * seconds_per_tick)

	// ДЛЯ ДРУГИХ РАС: мягкая регенерация печени и защита от летального исхода при действии токсинов в блюде
	else
		var/obj/item/organ/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver)
			liver.apply_organ_damage(-1 * metabolization_ratio * seconds_per_tick)
		if(SPT_PROB(2, seconds_per_tick))
			to_chat(drinker, span_notice("Вы ощущаете, как теплые целебные воды скрелльского чуда света омывают каждую клетку вашего тела..."))
