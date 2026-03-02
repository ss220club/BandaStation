
// /datum/chemical_reaction/slime/slime_meth
// 	reaction_display_name = "Метамфетамин"
// 	results = list(/datum/reagent/drug/methamphetamine = 1)
// 	required_reagents = list(/datum/reagent/phosphorus = 1)
// 	required_container = /obj/item/slime_extract/blue
// 	recipe_category = SLIME_RECIPE_POSITIVE
// 	recipe_variants = list(
// 		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 0),
// 		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/water = 10), 0),
// 	)

/datum/chemical_reaction/slime/slime_vacuum
	reaction_display_name = "Поглощение воздуха"
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/darkblue
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/darkblue, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 280),
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/water = 10), 300),
		list(/obj/item/slime_extract/sepia, list(/datum/reagent/nitrogen = 10), 0),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/silicon = 10), 0),
	)

/datum/chemical_reaction/slime/slime_vacuum/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/open/T = get_turf(holder.my_atom)
	if(istype(T) && T.air)
		T.remove_air(T.air.total_moles())
		T.air_update_turf(FALSE, FALSE)
		T.visible_message(span_danger("Воздух с шипением втягивается в экстракт!"))
	..()

/datum/chemical_reaction/slime/slime_blood_puddle
	reaction_display_name = "Лужа крови"
	required_reagents = list(/datum/reagent/blood = 10)
	required_container = /obj/item/slime_extract/red
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/red, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/blood = 10), 400),
		list(/obj/item/slime_extract/black, list(/datum/reagent/blood = 10), 380),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/iron = 10), 0),
		list(/obj/item/slime_extract/pink, list(/datum/reagent/toxin/mutagen = 10), 0),
	)

/datum/chemical_reaction/slime/slime_blood_puddle/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	new /obj/effect/decal/cleanable/blood/splatter(T)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	T.visible_message(span_danger("Экстракт лопается, выплёскивая лужу крови!"))
	..()

/datum/chemical_reaction/slime/slime_sparks
	reaction_display_name = "Искры"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/yellow
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/metal, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/orange, list(/datum/reagent/toxin/plasma = 10), 450),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/iron = 10), 0),
		list(/obj/item/slime_extract/adamantine, list(/datum/reagent/carbon = 10), 0),
	)

/datum/chemical_reaction/slime/slime_sparks/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	do_sparks(4, TRUE, holder.my_atom)
	..()

/datum/chemical_reaction/slime/slime_drain_nutriment
	reaction_display_name = "Вытягивание питательных веществ"
	required_reagents = list(/datum/reagent/consumable/sugar = 10)
	required_container = /obj/item/slime_extract/green
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/green, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/consumable/nutriment = 10), 300),
		list(/obj/item/slime_extract/black, list(/datum/reagent/consumable/sugar = 10), 350),
	)

/datum/chemical_reaction/slime/slime_drain_nutriment/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/human/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(istype(toucher) && toucher.reagents)
		toucher.adjust_nutrition(-100)
		to_chat(toucher, span_warning("Вы чувствуете как накатывает голод!"))
	..()


/datum/chemical_reaction/slime/slime_drain_blood
	reaction_display_name = "Вытягивание крови"
	required_reagents = list(/datum/reagent/toxin/plasma = 10)
	required_container = /obj/item/slime_extract/red
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 420),
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 400),
	)

/datum/chemical_reaction/slime/slime_drain_blood/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/human/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(istype(toucher) && toucher.get_blood_volume() > 0)
		toucher.adjust_blood_volume(-round(toucher.get_blood_volume() * 0.33))
		to_chat(toucher, span_danger("Вы начинаете бледнеть и чувствовать упадок сил!"))
	..()

GLOBAL_LIST_INIT(slime_random_status_effects, list(
	/datum/status_effect/confusion,
	/datum/status_effect/dizziness,
	/datum/status_effect/drugginess,
	/datum/status_effect/jitter,
	/datum/status_effect/speech/stutter,
))

/datum/chemical_reaction/slime/slime_random_status
	reaction_display_name = "Неизвестная реакция"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/rainbow
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/blood = 10), 360),
		list(/obj/item/slime_extract/green, list(/datum/reagent/blood = 10), 340),
	)

/datum/chemical_reaction/slime/slime_random_status/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(isliving(toucher) && length(GLOB.slime_random_status_effects))
		var/effect_type = pick(GLOB.slime_random_status_effects)
		toucher.apply_status_effect(effect_type)
		toucher.visible_message(span_warning("Экстракт окутывает [toucher] странной аурой!"))
	..()

/datum/chemical_reaction/slime/slime_heart_attack
	reaction_display_name = "Сердечный приступ"
	required_reagents = list(/datum/reagent/blood = 5)
	required_container = /obj/item/slime_extract/bluespace
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/blood = 5), 0),
	)

/datum/chemical_reaction/slime/slime_heart_attack/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(istype(toucher) && toucher.can_heartattack())
		toucher.set_heartattack(TRUE)
		to_chat(toucher, span_danger("Вы чувствуете, как в груди что-то сильно защемило!"))
		message_admins("У [toucher] случился сердечный приступ из-за реакции слайма!")
		log_admin("[toucher] got heart attack with slime reaction")
	..()

/datum/chemical_reaction/slime/slime_supermatter_sound
	reaction_display_name = "Неизвестная реакция"
	required_reagents = list(/datum/reagent/toxin/plasma = 5)
	required_container = /obj/item/slime_extract/bluespace
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/toxin/plasma = 5), 0),
		list(/obj/item/slime_extract/yellow, list(/datum/reagent/toxin/plasma = 5), 500),
		list(/obj/item/slime_extract/adamantine, list(/datum/reagent/toxin/plasma = 5), 550),
	)

/datum/chemical_reaction/slime/slime_supermatter_sound/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	playsound(T, 'sound/machines/sm/supermatter1.ogg', 60, TRUE)
	..()

/datum/chemical_reaction/slime/slime_vomit_radius
	reaction_display_name = "Синтез рвотных реагентов"
	required_reagents = list(/datum/reagent/consumable/ethanol = 1)
	required_container = /obj/item/slime_extract/oil
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/oil, list(/datum/reagent/consumable/nutraslop = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/consumable/nutriment = 10), 0),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/consumable/ethanol = 10), 300),
		list(/obj/item/slime_extract/green, list(/datum/reagent/consumable/ethanol = 10), 320),
	)

/datum/chemical_reaction/slime/slime_vomit_radius/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/near in range(2, T))
		for(var/mob/living/carbon/human/H in near)
			if(H.has_quirk(/datum/quirk/item_quirk/anosmia))
				continue
			H.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 10)
	T.visible_message(span_danger("Экстракт испускает тошнотворные пары!"))
	..()

/datum/chemical_reaction/slime/slime_give_blood
	reaction_display_name = "Насыщение кровью"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/pink
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 420),
		list(/obj/item/slime_extract/black, list(/datum/reagent/toxin/plasma = 10), 400),
	)

/datum/chemical_reaction/slime/slime_give_blood/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/human/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(istype(toucher) && toucher.blood_volume < BLOOD_VOLUME_NORMAL)
		toucher.blood_volume = min(BLOOD_VOLUME_NORMAL, toucher.blood_volume + 100)
		to_chat(toucher, span_notice("Вы чувствуете как что-то тёплое и свежее разливается по телу!"))
	..()

/datum/chemical_reaction/slime/slime_give_nutriment
	reaction_display_name = "Питательные вещества"
	required_reagents = list(/datum/reagent/consumable/nutriment = 1)
	required_container = /obj/item/slime_extract/green
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/green, list(/datum/reagent/blood = 10), 0),
		list(/obj/item/slime_extract/grey, list(/datum/reagent/consumable/nutriment = 10), 300),
		list(/obj/item/slime_extract/silver, list(/datum/reagent/consumable/nutriment = 10), 320),
		list(/obj/item/slime_extract/silver, list(/datum/reagent/blood = 10), 320),
	)

/datum/chemical_reaction/slime/slime_give_nutriment/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/toucher = get_mob_by_key(holder.my_atom?.fingerprintslast)
	if(istype(toucher) && toucher.reagents)
		toucher.adjust_nutrition(15)
		var/random_disease = pick_weight(GLOB.floor_diseases)
		toucher.ForceContractDisease(new random_disease, FALSE, TRUE)
		to_chat(toucher, span_notice("Вы чувствуете внезапное насыщение!"))
	..()

/datum/chemical_reaction/slime/slime_wet_tiles
	reaction_display_name = "Пузырь воды"
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/blue
	recipe_category = SLIME_RECIPE_POSITIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/blue, list(/datum/reagent/water = 10), 0),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/water = 10), 280),
		list(/obj/item/slime_extract/lightpink, list(/datum/reagent/water = 10), 300),
	)

/datum/chemical_reaction/slime/slime_wet_tiles/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/open/near in range(1, T))
		near.MakeSlippery(TURF_WET_WATER, 10 SECONDS, 80)
	T.visible_message(span_danger("Экстракт лопается, выплёскивая из себя воду!"))
	..()

/datum/chemical_reaction/slime/slime_vines
	reaction_display_name = "Лоза"
	required_reagents = list(/datum/reagent/toxin/plasma = 5)
	required_container = /obj/item/slime_extract/green
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/green, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/cerulean, list(/datum/reagent/toxin/plasma = 10), 380),
	)

/datum/chemical_reaction/slime/slime_vines/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(isturf(T))
		new /obj/structure/spacevine(T)
	T.visible_message(span_danger("Из экстракта начинают выползать лианы!"))
	..()

/datum/chemical_reaction/slime/slime_thermite
	reaction_display_name = "Термитная реакция"
	required_reagents = list(/datum/reagent/toxin/plasma = 10)
	required_container = /obj/item/slime_extract/orange
	recipe_category = SLIME_RECIPE_NEGATIVE
	deletes_extract = FALSE
	results = list(/datum/reagent/thermite = 25)
	recipe_variants = list(
		list(/obj/item/slime_extract/orange, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 500),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/plasma = 10), 480),
	)

/datum/chemical_reaction/slime/slime_thermite/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/reaction_turf = get_turf(holder.my_atom)
	reaction_turf.visible_message(span_danger("Экстракт лопается со странными, металлическими брызгами!"))
	playsound(reaction_turf, 'sound/effects/fire_puff.ogg', 50, TRUE)
	slime_thermite_apply(reaction_turf, 20)
	..()

/proc/slime_thermite_apply(turf/reaction_turf, amount)
	if(!isturf(reaction_turf))
		return
	var/turf/target = null
	for(var/radius in 1 to 3)
		for(var/turf/candidate in range(radius, reaction_turf))
			if(get_dist(reaction_turf, candidate) != radius)
				continue
			if(istype(candidate, /turf/closed))
				target = candidate
				break
		if(target)
			break
	if(!target)
		target = reaction_turf
	target.AddComponent(/datum/component/thermite, amount)

GLOBAL_LIST_INIT(slime_random_diseases, list(
	/datum/disease/cold9,
	/datum/disease/flu,
	/datum/disease/beesease,
	/datum/disease/fluspanish,
	/datum/disease/gastrolosis,
))

/datum/chemical_reaction/slime/slime_virus
	reaction_display_name = "Инкубация вируса"
	required_reagents = list(/datum/reagent/toxin/mutagen = 1)
	required_container = /obj/item/slime_extract/green
	recipe_category = SLIME_RECIPE_NEGATIVE
	recipe_variants = list(
		list(/obj/item/slime_extract/green, list(/datum/reagent/toxin/mutagen = 10), 0),
		list(/obj/item/slime_extract/black, list(/datum/reagent/blood = 10), 350),
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/blood = 10), 380),
		list(/obj/item/slime_extract/purple, list(/datum/reagent/toxin/mutagen = 10), 0),
		list(/obj/item/slime_extract/red, list(/datum/reagent/toxin/mutagen = 10), 0),
	)

/datum/chemical_reaction/slime/slime_virus/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(length(GLOB.slime_random_diseases))
		for(var/mob/living/carbon/C in range(2, T))
			var/disease_type = pick(GLOB.slime_random_diseases)
			var/datum/disease/D = new disease_type()
			if(C.ForceContractDisease(D, FALSE, TRUE))
				break
	..()

GLOBAL_LIST_INIT(slime_other_reaction_types, list(
	/datum/chemical_reaction/soapification,
	/datum/chemical_reaction/candlefication,
	/datum/chemical_reaction/meatification,
	/datum/chemical_reaction/plasma_solidification,
	/datum/chemical_reaction/gold_solidification,
	/datum/chemical_reaction/uranium_solidification,
))

/datum/chemical_reaction/slime/slime_random_other
	reaction_display_name = "Неизвестная реакция"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/rainbow
	recipe_category = SLIME_RECIPE_FUN
	recipe_variants = list(
		list(/obj/item/slime_extract/rainbow, list(/datum/reagent/toxin/plasma = 10), 0),
		list(/obj/item/slime_extract/gold, list(/datum/reagent/toxin/plasma = 10), 400),
		list(/obj/item/slime_extract/bluespace, list(/datum/reagent/blood = 10), 420),
		list(/obj/item/slime_extract/oil, list(/datum/reagent/toxin/plasma = 10), 450),
	)

/datum/chemical_reaction/slime/slime_random_other/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	if(!length(GLOB.slime_other_reaction_types))
		return ..()
	var/reaction_type = pick(GLOB.slime_other_reaction_types)
	var/datum/chemical_reaction/R = new reaction_type()
	R.on_reaction(holder, null, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_notice("Экстракт начинает нестабильно реагировать!"))
	..()
