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
	name = "Bridge"
	icon_state = "bridge"

/area/station/command/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_suite
	name = "Corporate Guest Suite"
	icon_state = "command"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/emergency_closet
	name = "Corporate Emergency Closet"
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
	name = "Vault"
	icon_state = "nuke_storage" // someone should change this, not me though
	motion_monitored = TRUE

/*
* Command Head Areas
*/

/area/station/command/heads_quarters
	icon_state = "heads_quarters"

/area/station/command/heads_quarters/captain
	name = "Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/captain/private
	name = "Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/ce
	name = "Chief Engineer's Office"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "Head of Personnel's Office"
	icon_state = "hop_office"

/area/station/command/heads_quarters/hos
	name = "Head of Security's Office"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "Research Director's Office"
	icon_state = "rd_office"

/area/station/command/heads_quarters/qm
	name = "Quartermaster's Office"
	icon_state = "qm_office"

/*
* Command - Teleporter
*/

/area/station/command/teleporter
	name = "Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/station/command/gateway
	name = "Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

/*
* Command - Misc
*/

/area/station/command/corporate_dock
	name = "Corporate Private Dock"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
