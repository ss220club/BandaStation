/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1

/datum/hallucination/station_message/start()
	qdel(src) // To be implemented by subtypes, call parent for easy cleanup
	return TRUE

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/start()
	priority_announce("Вспышка биологической угрозы 5-го уровня зафиксирована на борту [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!", \
		"Биологическая угроза", ANNOUNCER_OUTBREAK5, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/start()
	priority_announce(
					text = "[SSshuttle.emergency] совершил стыковку со станцией. У вас есть [DisplayTimeText(SSshuttle.emergency_dock_time)], чтобы добраться до эвакуационного шаттла.",
					title = "Прибытие эвакуационного шаттла",
					sound = ANNOUNCER_SHUTTLEDOCK,
					sender_override = "Система оповещения эвакуационного шаттла",
					players = list(hallucinator),
					color_override = "orange",
				)
	return ..()

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/start()
	if(!(locate(/mob/living/silicon/ai) in GLOB.silicon_mobs))
		return FALSE

	priority_announce("Во всех системах станций обнаружены вредоносные процессы. Пожалуйста, уничтожьте свой ИИ, чтобы предотвратить возможный ущерб его моральному ядру.", \
		"Обнаружена аномалия", ANNOUNCER_AIMALF, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/heretic
	/// This is gross and will probably easily be outdated in some time but c'est la vie.
	/// Maybe if someone datumizes heretic paths or something this can be improved
	var/static/list/ascension_bodies = list(
		list(
			"text" = "Бойтесь пламени, ибо Пепельный Лорд %FAKENAME% вознесся! Пламя поглотит всех!",
			"sound" = 'sound/music/antag/heretic/ascend_blade.ogg',
		),
		list(
			"text" = "Мастер клинков %FAKENAME%, ученик Чемпиона Растерзаний, вознесся! Их сталь — та, что рассечет реальность в серебряном шторме!",
			"sound" = 'sound/music/antag/heretic/ascend_blade.ogg',
		),
		list(
			"text" = "Вечно бушующий вихрь. Реальность раскрылась. РУКИ ПРОТЯНУТЫ, ВЛАДЫКА НОЧИ %FAKENAME% ВОЗНЕССЯ! Бойтесь непрестанно извивающейся руки!",
			"sound" = 'sound/music/antag/heretic/ascend_flesh.ogg',
		),
		list(
			"text" = "Бойтесь разложения, ибо Предводитель Ржавчины, %FAKENAME%, вознесся! Никто не уйдет от коррозии!",
			"sound" = 'sound/music/antag/heretic/ascend_rust.ogg',
		),
		list(
			"text" = "Аристократ пустоты %FAKENAME% ступил в Вальс, завершающий миры!",
			"sound" = 'sound/music/antag/heretic/ascend_void.ogg',
		)
	)

/datum/hallucination/station_message/heretic/start()
	// Unfortunately, this will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_heretic = random_non_sec_crewmember()
	if(!totally_real_heretic)
		return FALSE

	var/list/fake_ascension = pick(ascension_bodies)
	var/announcement_text = replacetext(fake_ascension["text"], "%FAKENAME%", totally_real_heretic.real_name)
	priority_announce(
		text = "[generate_heretic_text()] [announcement_text] [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = fake_ascension["sound"],
		players = list(hallucinator),
		color_override = "pink",
	)
	return ..()

/datum/hallucination/station_message/cult_summon

/datum/hallucination/station_message/cult_summon/start()
	// Same, will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_cult_leader = random_non_sec_crewmember()
	if(!totally_real_cult_leader)
		return FALSE

	// Get a fake area that the summoning is happening in
	var/area/hallucinator_area = get_area(hallucinator)
	var/area/fake_summon_area_type = pick(GLOB.the_station_areas - hallucinator_area.type)
	var/area/fake_summon_area = GLOB.areas_by_type[fake_summon_area_type]

	priority_announce(
		text = "Зафиксирован призыв древнего божества в [fake_summon_area], культист-призыватель - [totally_real_cult_leader.real_name]. Прервите ритуал любой ценой!",
		title = "[command_name()]: Отдел паранормальных явлений",
		sound = 'sound/music/antag/bloodcult/bloodcult_scribe.ogg',
		has_important_message = TRUE,
		players = list(hallucinator),
	)
	return ..()

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/start()
	priority_announce("Зафиксировано движение астероидов на встречном со станцией курсе.", "Астероиды", ANNOUNCER_METEORS, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/supermatter_delam

/datum/hallucination/station_message/supermatter_delam/start()
	SEND_SOUND(hallucinator, 'sound/effects/magic/charge.ogg')
	to_chat(hallucinator, span_bolddanger("You feel reality distort for a moment..."))
	return ..()

/datum/hallucination/station_message/clock_cult_ark
	// Clock cult's long gone, but this stays for posterity.
	random_hallucination_weight = 0

/datum/hallucination/station_message/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)
	return TRUE // does not call parent to finish up the sound in a few seconds

/datum/hallucination/station_message/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/explosion/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
	qdel(src)
