#define CYBORG_ICON_ENG 'modular_bandastation/borgs/icons/robots_eng.dmi'
#define CYBORG_ICON_MED 'modular_bandastation/borgs/icons/robots_med.dmi'
#define CYBORG_ICON_MINING 'modular_bandastation/borgs/icons/robots_mine.dmi'
#define CYBORG_ICON_SERVICE 'modular_bandastation/borgs/icons/robots_serv.dmi'
#define CYBORG_ICON_JANI 'modular_bandastation/borgs/icons/robots_jani.dmi'
#define CYBORG_ICON_PEACEKEEPER 'modular_bandastation/borgs/icons/robots_pk.dmi'

///ENGINEERING
/obj/item/robot_model/engineering
	borg_skins = list(
		"Default" = list(SKIN_ICON_STATE = "engineer"),
		"Standard" = list(SKIN_ICON_STATE = "standard", SKIN_ICON = CYBORG_ICON_ENG),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_engi", SKIN_ICON = CYBORG_ICON_ENG, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"Default - Treads" = list(SKIN_ICON_STATE = "engi-tread", SKIN_LIGHT_KEY = "engineer", SKIN_ICON = CYBORG_ICON_ENG),
		"Handy" = list(SKIN_ICON_STATE = "handyeng", SKIN_ICON = CYBORG_ICON_ENG),
		"Can" = list(SKIN_ICON_STATE = "caneng", SKIN_ICON = CYBORG_ICON_ENG, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Spider" = list(SKIN_ICON_STATE = "spidereng", SKIN_ICON = CYBORG_ICON_ENG)
	)

///MEDICAL
/obj/item/robot_model/medical
	borg_skins = list(
		"Machinified Doctor" = list(SKIN_ICON_STATE = "medical", SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(-1, 3), "west" = list(1, 3))),
		"Qualified Doctor" = list(SKIN_ICON_STATE = "qualified_doctor", SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(1, 3), "west" = list(-1, 3))),
		"Standard" = list(SKIN_ICON_STATE = "standard", SKIN_ICON = CYBORG_ICON_MED),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_med", SKIN_ICON = CYBORG_ICON_MED, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"Droid" = list(SKIN_ICON = CYBORG_ICON_MED, SKIN_ICON_STATE = "medical", SKIN_HAT_OFFSET = list("north" = list(0, 4), "south" = list(0, 4), "east" = list(0, 4), "west" = list(0, 4)))
	)

///JANITOR
/obj/item/robot_model/janitor
	borg_skins = list(
		"Default" = list(SKIN_ICON_STATE = "janitor", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(-4, -1), "west" = list(4, -1))),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_jani", SKIN_ICON = CYBORG_ICON_JANI, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"Standard" = list(SKIN_ICON_STATE = "standard", SKIN_ICON = CYBORG_ICON_JANI),
		"Can" = list(SKIN_ICON_STATE = "canjan", SKIN_ICON = CYBORG_ICON_JANI, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Spider" = list(SKIN_ICON_STATE = "spidersci", SKIN_ICON = CYBORG_ICON_JANI)
	)

///PEACEKEEPER
/obj/item/robot_model/peacekeeper
	borg_skins = list(
		"Default" = list(SKIN_ICON_STATE = "peace"),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_peace", SKIN_ICON = CYBORG_ICON_PEACEKEEPER, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"ARACHNE" = list(SKIN_ICON_STATE = "arachne_peacekeeper", SKIN_ICON = CYBORG_ICON_PEACEKEEPER),
		"Spider" = list(SKIN_ICON_STATE = "whitespider", SKIN_ICON = CYBORG_ICON_PEACEKEEPER),
		"Omni" = list(SKIN_ICON_STATE = "omoikane", SKIN_ICON = CYBORG_ICON_PEACEKEEPER)
	)

///MINING
/obj/item/robot_model/miner
	special_light_key = null
	borg_skins = list(
		/// 32x32 Skins
		"Lavaland" = list(SKIN_ICON_STATE = "miner", SKIN_LIGHT_KEY = "miner"),
		"Asteroid" = list(SKIN_ICON_STATE = "minerOLD", SKIN_LIGHT_KEY = "miner"),
		"Drone" = list(SKIN_ICON_STATE = "miningdrone", SKIN_ICON = CYBORG_ICON_MINING),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_miner", SKIN_ICON = CYBORG_ICON_MINING, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"Spider Miner" = list(SKIN_ICON_STATE = "spidermin", SKIN_LIGHT_KEY = "miner"),
		"Standard" = list(SKIN_ICON_STATE = "standard", SKIN_ICON = CYBORG_ICON_MINING),
		"Can" = list(SKIN_ICON_STATE = "canmin", SKIN_ICON = CYBORG_ICON_MINING, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Spider" = list(SKIN_ICON_STATE = "spidermin", SKIN_ICON = CYBORG_ICON_MINING)
	)

///SERVICE
/obj/item/robot_model/service
	special_light_key = null
	borg_skins = list(
		/// 32x32 Skins
		"Waitress" = list(SKIN_ICON_STATE = "service_f", SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Butler" = list(SKIN_ICON_STATE = "service_m", SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Bro" = list(SKIN_ICON_STATE = "brobot", SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Tophat" = list(SKIN_ICON_STATE = "tophat", SKIN_HAT_OFFSET = INFINITY),
		"Heavy" = list(SKIN_ICON_STATE = "heavyserv", SKIN_ICON = CYBORG_ICON_SERVICE, SKIN_HAT_OFFSET = list("north" = list(0, 0), "south" = list(-5, -1), "east" = list(0, 0), "west" = list(0, 0))),
		"Kent" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Can" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_green", SKIN_ICON = CYBORG_ICON_SERVICE, SKIN_HAT_OFFSET = list("north" = list(0, -13), "south" = list(0, -13), "east" = list(0, -13), "west" = list(0, -13))),
		"ARACHNE" = list(SKIN_ICON_STATE = "arachne_service", SKIN_ICON = CYBORG_ICON_SERVICE),
		"Handy" = list(SKIN_ICON_STATE = "handy-service", SKIN_ICON = CYBORG_ICON_SERVICE)
	)