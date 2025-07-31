/datum/bounty/item/security/recharger
	name = "Зарядник"
	description = "Военная академия Нанотрейзен проводит учения по стрельбе. Они запрашивают зарядник для доставки."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 1
	wanted_types = list(/obj/machinery/recharger = TRUE)

/datum/bounty/item/security/pepperspray
	name = "Перцовые баллончики"
	description = "На станции 76 происходят бунты с печальным исходом. Нам бы пригодилось несколько новых перцовых баллончиков."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 4
	wanted_types = list(/obj/item/reagent_containers/spray/pepper = TRUE)

/datum/bounty/item/security/prison_clothes
	name = "Униформа для заключённых"
	description = "TerraGov не смог получить новую униформу для заключённых, так что если у вас есть запасная, то мы её возьмём с ваших рук."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 4
	wanted_types = list(/obj/item/clothing/under/rank/prisoner = TRUE)

/datum/bounty/item/security/plates
	name = "License Plates"
	description = "В результате ДТП с участием клоунской машины, нам бы пригодились автомобильные номера, созданные вашими заключёнными."
	reward = CARGO_CRATE_VALUE * 2
	required_count = 10
	wanted_types = list(/obj/item/stack/license_plates/filled = TRUE)

/datum/bounty/item/security/earmuffs
	name = "Противошумные наушники"
	description = "Центральное Командование устало от сообщений с вашей станции. Они запросила вас отправить несколько противошумных наушников для уменьшения раздражения."
	reward = CARGO_CRATE_VALUE * 2
	wanted_types = list(/obj/item/clothing/ears/earmuffs = TRUE)

/datum/bounty/item/security/handcuffs
	name = "Наручники"
	description = "Большой поток сбежавших заключённых прибыл на Центральное Командование. Сейчас идеальное время для отправки запасных наручников (или стяжек)."
	reward = CARGO_CRATE_VALUE * 2
	required_count = 5
	wanted_types = list(/obj/item/restraints/handcuffs = TRUE)


///Bounties that require you to perform documentation and inspection of your department to send to centcom.
/datum/bounty/item/security/paperwork
	name = "Routine Security Inspection"
	description = "Проведите рутинную инспекцию безопасности, используя сканнер N-spect в следующей зоне на станции:"
	required_count = 1
	wanted_types = list(/obj/item/paper/report = TRUE)
	reward = CARGO_CRATE_VALUE * 5
	var/area/demanded_area

/datum/bounty/item/security/paperwork/New()
	///list of areas for security to choose from to perform an inspection. Pulls the list and cross references it to the map to make sure the area is on the map before assigning.
	var/static/list/possible_areas
	if(!possible_areas)
		possible_areas = typecacheof(list(\
			/area/station/maintenance,\
			/area/station/commons,\
			/area/station/service,\
			/area/station/hallway/primary,\
			/area/station/security/office,\
			/area/station/security/prison,\
			/area/station/security/range,\
			/area/station/security/checkpoint,\
			/area/station/security/tram,\
			/area/station/security/breakroom,\
			/area/station/security/interrogation))
		for (var/area_type in possible_areas)
			if(GLOB.areas_by_type[area_type])
				continue
			possible_areas -= area_type
	demanded_area = pick(possible_areas)
	name = name + ": [initial(demanded_area.name)]"
	description = initial(description) + " [initial(demanded_area.name)]"

/datum/bounty/item/security/paperwork/applies_to(obj/O)
	. = ..()
	if(!istype(O, /obj/item/paper/report))
		return FALSE
	var/obj/item/paper/report/slip = O
	if(istype(slip.scanned_area, demanded_area))
		return TRUE
	return FALSE

/datum/bounty/item/security/contraband
	name = "Confiscated Contraband"
	description = "The Syndicate is constantly acting to subvert crewmates of Nanotrasen-affiliated stations. Ship us your latest batch of confiscated contraband."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 5
	wanted_types = list(/obj/item = TRUE)

/datum/bounty/item/security/contraband/applies_to(obj/O)
	return HAS_TRAIT(O, TRAIT_CONTRABAND)
