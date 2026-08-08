/datum/weather/rad_storm/eftk
	name = "аномальный радиационный шторм"
	telegraph_duration = 15 SECONDS
	weather_message = span_userdanger("<b>Начался радиационный шторм!</b>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 1 MINUTES
	end_duration = 10 SECONDS
	target_trait = ZTRAIT_STATION
	weather_sound = 'modular_bandastation/voyaker_events/sounds/desert.ogg'
	protected_areas = list(
	/area/new_sydney/building,
	/area/new_sydney/mine,
	/area/new_sydney/bunker,
	/area/new_sydney/dark_forest/building,
)

/datum/weather/rad_storm/eftk/telegraph()
	..()

	priority_announce(
		"Погодные датчики зафиксировали приближение радиационного шторма. Всем кто находится снаружи — срочно найти укрытие.",
		"Система наблюдения АСБ Ковчег"
	)

/datum/weather/rad_storm/eftk/status_alarm(active)
	return

/datum/weather/rad_storm/eftk/end()
	status_alarm(FALSE)

	priority_announce(
		"Угроза радиационного шторма миновала. Можете покинуть своё убежище.",
		"Система наблюдения АСБ Ковчег"
	)

	return ..()

/datum/weather/rad_storm/eftk/weather_act_mob(mob/living/living)
	if(!ishuman(living) || HAS_TRAIT(living, TRAIT_GODMODE))
		return
	var/mob/living/carbon/human/H = living
	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		return
	if(SSradiation.wearing_rad_protected_clothing(H))
		return
	radiation_pulse(H, max_range = 1, threshold = 0.1, chance = 70)
	if(prob(10))
		H.random_mutate_unique_identity()
		H.random_mutate_unique_features()
		if(prob(10))
			do_mutate(H)

	return ..()
