/// banda MODULE banda_XENO_REDO

/datum/action/cooldown/alien/larva_evolve/Activate(atom/target)
	var/static/list/caste_options
	if(!caste_options)
		caste_options = list()

		// This --can probably-- (will not) be genericized in the future.
		make_xeno_caste_entry(
		caste_name = "Runner",
		caste_image = image(icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi', icon_state = "preview_runner"),
		caste_info = span_info("Бегуны — самая подвижная каста. Их низкий рост и передвижение на четырёх \
		лапах дают им высокую скорость, способность уклоняться от снарядов \
		и возможность сбивать врагов с ног при броске и клике. \
		Со временем бегуны могут эволюционировать в устрашающего разрушителя, \
		если улей позволит это."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Sentinel",
		caste_image = image(icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi', icon_state = "preview_sentinel"),
		caste_info = span_info("Стражи — каста, по форме похожая на дронов, но жертвующая возможностью \
		стать королевской особой ради способности плеваться кислотой или мощным \
		нейротоксином. В ближнем бою они слабее других каст, но со временем могут \
		эволюционировать в более опасную форму кислотного плевальщика, \
		если у улья будет достаточно ресурсов."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Defender",
		caste_image  = image(icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi', icon_state = "preview_defender"),
		caste_info = span_info("Медленный, выносливый и мощно атакующий, защитник полностью оправдывает своё имя. \
		Его толстая броня позволяет выдерживать больше ударов, чем другие касты, а смертельная \
		булава на хвосте и способность совершать короткие рывки делают его грозным бойцом. \
		Со временем защитник может эволюционировать в устрашающего крушителя — \
		разрушителя стационарных объектов, если у улья будет достаточно ресурсов."),
		caste_options = caste_options,
		)

		make_xeno_caste_entry(
		caste_name = "Drone",
		caste_image  = image(icon = 'modular_bandastation/xeno_rework/icons/xeno_actions.dmi', icon_state = "preview_drone"),
		caste_info = span_info("Дроны — это относительно слабая, но довольно быстрая каста, выполняющая \
		в улье в основном вспомогательную роль. Они обладают большей вместимостью \
		плазмы по сравнению с большинством первых стадий эволюции, а также \
		способностью создавать исцеляющую ауру для ближайших ксеноморфов. \
		Дроны — единственная каста, способная эволюционировать как в преторианцев, \
		так и в королеву, хотя в любой момент времени может существовать \
		только одна королева и один преторианец."),
		caste_options = caste_options,
		)

	var/alien_caste = show_radial_menu(owner, owner, caste_options, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE) || isnull(alien_caste))
		return

	spawn_new_xeno(alien_caste)

	return TRUE

/// Generates a new entry to the
/datum/action/cooldown/alien/larva_evolve/proc/make_xeno_caste_entry(caste_name, caste_image, caste_info, list/caste_options)
	var/datum/radial_menu_choice/caste_option = new()

	caste_option.name = caste_name
	caste_option.image = caste_image
	caste_option.info = caste_info

	caste_options[caste_name] = caste_option

/datum/action/cooldown/alien/larva_evolve/proc/spawn_new_xeno(alien_caste)
	var/mob/living/carbon/alien/adult/banda/new_xeno
	var/mob/living/carbon/alien/larva/larva = owner

	switch(alien_caste)
		if("Runner")
			new_xeno = new /mob/living/carbon/alien/adult/banda/runner(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/adult/banda/sentinel(larva.loc)
		if("Defender")
			new_xeno = new /mob/living/carbon/alien/adult/banda/defender(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/adult/banda/drone(larva.loc)
		else
			CRASH("Alien evolve was given an invalid / incorrect alien cast type. Got: [alien_caste]")

	new_xeno.has_just_evolved()
	larva.alien_evolve(new_xeno)
