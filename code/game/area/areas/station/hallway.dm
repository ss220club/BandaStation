/area/station/hallway
	icon_state = "hall"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/hallway/primary
	name = "Primary Hallway"
	icon_state = "primaryhall"

/area/station/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "afthall"

/area/station/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "forehall"

/area/station/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/station/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "porthall"

/area/station/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/central/fore
	name = "Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/station/hallway/primary/central/aft
	name = "Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/station/hallway/primary/upper
	name = "Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/station/hallway/primary/tram
	name = "Primary Tram"

/area/station/hallway/primary/tram/left
	name = "Port Tram Dock"
	icon_state = "halltramL"

/area/station/hallway/primary/tram/center
	name = "Central Tram Dock"
	icon_state = "halltramM"

/area/station/hallway/primary/tram/right
	name = "Starboard Tram Dock"
	icon_state = "halltramR"

// This shouldn't be used, but it gives an icon for the enviornment tree in the map editor
/area/station/hallway/secondary
	icon_state = "secondaryhall"

/area/station/hallway/secondary/command
	name = "Command Hallway"
	icon_state = "bridge_hallway"

/area/station/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"

/area/station/hallway/secondary/construction/engineering
	name = "Engineering Hallway"

/area/station/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/exit/escape_pod
	name = "Escape Pod Bay"
	icon_state = "escape_pods"

/area/station/hallway/secondary/exit/departure_lounge
	name = "Departure Lounge"
	icon_state = "escape_lounge"

/area/station/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"
	area_flags = EVENT_PROTECTED

/area/station/hallway/secondary/dock
	name = "Secondary Station Dock Hallway"
	icon_state = "hall"

/area/station/hallway/secondary/service
	name = "Service Hallway"
	icon_state = "hall_service"
	tacmap_color = TACMAP_AREA_SERVICE

/area/station/hallway/secondary/spacebridge
	name = "Space Bridge"
	icon_state = "hall"

/area/station/hallway/secondary/recreation
	name = "Recreation Hallway"
	icon_state = "hall"

/*
* Station Specific Areas
* If another station gets added, and you make specific areas for it
* Please make its own section in this file
* The areas below belong to North Star's Hallways
*/

//1
/area/station/hallway/floor1
	name = "First Floor Hallway"

/area/station/hallway/floor1/aft
	name = "First Floor Aft Hallway"
	icon_state = "1_aft"

/area/station/hallway/floor1/fore
	name = "First Floor Fore Hallway"
	icon_state = "1_fore"
//2
/area/station/hallway/floor2
	name = "Second Floor Hallway"

/area/station/hallway/floor2/aft
	name = "Second Floor Aft Hallway"
	icon_state = "2_aft"

/area/station/hallway/floor2/fore
	name = "Second Floor Fore Hallway"
	icon_state = "2_fore"
//3
/area/station/hallway/floor3
	name = "Third Floor Hallway"

/area/station/hallway/floor3/aft
	name = "Third Floor Aft Hallway"
	icon_state = "3_aft"

/area/station/hallway/floor3/fore
	name = "Third Floor Fore Hallway"
	icon_state = "3_fore"
//4
/area/station/hallway/floor4
	name = "Fourth Floor Hallway"

/area/station/hallway/floor4/aft
	name = "Fourth Floor Aft Hallway"
	icon_state = "4_aft"

/area/station/hallway/floor4/fore
	name = "Fourth Floor Fore Hallway"
	icon_state = "4_fore"
