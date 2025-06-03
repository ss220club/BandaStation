// General
/datum/lazy_template/nukie_base
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "syndie_cc"
	key = LAZY_TEMPLATE_KEY_NUKIEBASE

// Shuttles
/datum/map_template/shuttle/sit
	port_id = "sit"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sit/basic
	suffix = "basic"
	name = "basic syndicate sit shuttle"
	description = "Base SIT shuttle, spawned by default for syndicate infiltration team to use."

/datum/map_template/shuttle/sst
	port_id = "sst"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/sst/basic
	suffix = "basic"
	name = "basic syndicate sst shuttle"
	description = "Base SST shuttle, spawned by default for syndicate strike team to use."

/datum/map_template/shuttle/argos
	port_id = "argos"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/argos/basic
	suffix = "basic"
	name = "basic argos shuttle"
	description = "Base Argos shuttle."

/datum/map_template/shuttle/specops
	port_id = "specops"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/specops/basic
	suffix = "basic"
	name = "basic specops shuttle"
	description = "Base Specops shuttle."

// Shuttles Overrides
/datum/map_template/shuttle/infiltrator/basic
	prefix = "_maps/shuttles/ss220/"

// Deathmatch
/datum/lazy_template/deathmatch/underground_thunderdome
	name = "Underground Thunderdome"
	map_dir = "_maps/deathmatch/ss220"
	map_name = "underground_arena_big"
	key = "underground_arena_big"

// Distress Signal - Shuttles
/datum/map_template/shuttle/distress
	prefix = "_maps/shuttles/ss220"
	who_can_purchase = null

/datum/map_template/shuttle/distress/tsf
	port_id = "tsf"
	suffix = "patrol"
	name = "Патрульный корабль ТСФ"

/obj/docking_port/mobile/tsf_patrol
	name = "Патрульный корабль ТСФ"
	shuttle_id = "tsf_patrol"
	movement_force = list("KNOCKDOWN" = 2, "THROW" = 2)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = WEST

/obj/docking_port/stationary/tsf_patrol
	name = "TSF patrol ship Bay"
	shuttle_id = "SBC_corvette_bay"
	roundstart_template = /datum/map_template/shuttle/distress/tsf
	hidden = TRUE
	width = 14 // check
	height = 7 // check
	dwidth = 7 // check
	dir = NORTH // check

// Distress Signal - Bases
/datum/lazy_template/tsf_base
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "tsf_base"
	key = LAZY_TEMPLATE_KEY_TSF_BASE
