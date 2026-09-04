/area/station/command
	name = "Command"
	icon_state = "command"
	ambientsounds = list(
		'sound/ambience/misc/signal.ogg',
		)
	airlock_wires = /datum/wires/airlock/command
	sound_environment = SOUND_AREA_STANDARD_STATION
	tacmap_color = TACMAP_AREA_COMMAND

/area/station/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/station/command/bsa_east
	name = "\improper Bluespace Artillery East"
	icon_state = "bsa east"

/area/station/command/bsa_west
	name = "\improper Bluespace Artillery West"
	icon_state = "bsa west"

/area/station/command/bsa_eone
	name = "\improper Bluespace Artillery East 1"
	icon_state = "bsa 1"

/area/station/command/bsa_etwo
	name = "\improper Bluespace Artillery East 2"
	icon_state = "bsa 2"

/area/station/command/bsa_ethree
	name = "\improper Bluespace Artillery East 3"
	icon_state = "bsa 3"

/area/station/command/bsa_efour
	name = "\improper Bluespace Artillery East 4"
	icon_state = "bsa 4"

/area/station/command/bsa_efive
	name = "\improper Bluespace Artillery East 5"
	icon_state = "bsa 5"

/area/station/command/bsa_wsix
	name = "\improper Bluespace Artillery West 6"
	icon_state = "bsa 6"

/area/station/command/bsa_wseven
	name = "\improper Bluespace Artillery West 7"
	icon_state = "bsa 7"

/area/station/command/bsa_weight
	name = "\improper Bluespace Artillery West 8"
	icon_state = "bsa 8"

/area/station/command/bsa_wnine
	name = "\improper Bluespace Artillery West 9"
	icon_state = "bsa 9"

/area/station/command/bsa_wten
	name = "\improper Bluespace Artillery West 10"
	icon_state = "bsa 10"

/area/station/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_suite
	name = "\improper Corporate Guest Suite"
	icon_state = "command"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/emergency_closet
	name = "\improper Corporate Emergency Closet"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// Monitored areas

/area/station/command/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER
	motion_monitored = TRUE

/area/station/command/eva/upper
	name = "Upper EVA Storage"

/area/station/command/vault
	name = "\improper Vault"
	icon_state = "nuke_storage" // someone should change this, not me though
	motion_monitored = TRUE

/*
* Command Head Areas
*/

/area/station/command/heads_quarters
	icon_state = "heads_quarters"

/area/station/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"

/area/station/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

/area/station/command/heads_quarters/qm
	name = "\improper Quartermaster's Office"
	icon_state = "qm_office"

/*
* Command - Teleporter
*/

/area/station/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/station/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

/*
* Command - Misc
*/

/area/station/command/corporate_dock
	name = "\improper Corporate Private Dock"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
