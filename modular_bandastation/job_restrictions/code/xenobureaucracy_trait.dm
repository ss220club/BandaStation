/datum/station_trait/xenobureaucracyerror
	name = "Ксеноглавы"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_processes = FALSE
	weight = 10
	cost = STATION_TRAIT_COST_MINIMAL
	show_in_report = TRUE
	report_message = "Из-за бюрократической ошибки в отделе кадров НаноТрейзен - ксено-ограничение на подбор командования было отменено."
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	sign_up_button = TRUE // only because with this flag our trait will be added to lobby_station_traits (which is sucks)
	public_in_lobby = TRUE
