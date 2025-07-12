// MARK: General
/datum/lazy_template/nukie_base
	map_dir = "_maps/templates/lazy_templates/ss220"
	map_name = "syndie_cc"
	key = LAZY_TEMPLATE_KEY_NUKIEBASE

// MARK: Shuttles
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

// Gamma
/datum/map_template/shuttle/gamma
	port_id = "gamma"
	who_can_purchase = null
	prefix = "_maps/shuttles/ss220/"

/datum/map_template/shuttle/gamma/basic
	suffix = "basic"
	name = "Standard Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/clown
	suffix = "clown"
	name = "Clown Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/destroyed
	suffix = "destroyed"
	name = "Destroyed Gamma Armory Shuttle"

/datum/map_template/shuttle/gamma/empty
	suffix = "empty"
	name = "Empty Gamma Armory Shuttle"

// MARK: Shuttles Overrides
/datum/map_template/shuttle/infiltrator/basic
	prefix = "_maps/shuttles/ss220/"

// MARK: Deathmatch
/datum/lazy_template/deathmatch/underground_thunderdome
	name = "Underground Thunderdome"
	map_dir = "_maps/deathmatch/ss220"
	map_name = "underground_arena_big"
	key = "underground_arena_big"
