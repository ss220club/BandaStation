/datum/techweb_node/medbay_equip
	id = TECHWEB_NODE_MEDBAY_EQUIP
	starting_node = TRUE
	display_name = "Оборудование медицинского отдела"
	description = "Базовый комплект медицинского оборудования для оказания неотложной помощи при сохранении функциональности медотдела."
	design_ids = list(
		"operating",
		"medicalbed",
		"defibmountdefault",
		"surgical_drapes",
		"scalpel",
		"retractor",
		"hemostat",
		"cautery",
		"circular_saw",
		"surgicaldrill",
		"bonesetter",
		"blood_filter",
		"surgical_tape",
		"penlight",
		"penlight_paramedic",
		"stethoscope",
		"beaker",
		"large_beaker",
		"chem_pack",
		"blood_pack",
		"syringe",
		"dropper",
		"pillbottle",
		"xlarge_beaker",
		"organ_jar",
		"jerrycan",
		"reflex_hammer",
		"blood_scanner",
		"suit_sensor",
	)
	experiments_to_unlock = list(
		/datum/experiment/autopsy/human,
		/datum/experiment/autopsy/nonhuman,
		/datum/experiment/autopsy/xenomorph,
		/datum/experiment/scanning/reagent/haloperidol,
		/datum/experiment/scanning/reagent/cryostylane,
	)

/datum/techweb_node/chem_synthesis
	id = TECHWEB_NODE_CHEM_SYNTHESIS
	display_name = "Химический синтез"
	description = "Технология синтеза сложных химических соединений с использованием электричества и газовых сред."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"med_spray_bottle",
		"inhaler",
		"inhaler_canister",
		"medigel",
		"medipen_refiller",
		"soda_dispenser",
		"beer_dispenser",
		"chem_dispenser",
		"portable_chem_mixer",
		"chem_heater",
		"w-recycler",
		"meta_beaker",
		"plumbing_rcd",
		"plumbing_rcd_service",
		"plunger",
		"fluid_ducts",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/medbay_equip_adv
	id = TECHWEB_NODE_MEDBAY_EQUIP_ADV
	display_name = "Продвинутое оборудование медицинского отдела"
	description = "Современное медицинское оборудование для поддержания жизнеспособности экипажа с минимальными физическими повреждениями."
	prereq_ids = list(TECHWEB_NODE_CHEM_SYNTHESIS)
	design_ids = list(
		"smoke_machine",
		"chem_mass_spec",
		"healthanalyzer_advanced",
		"mod_health_analyzer",
		"crewpinpointer",
		"defibmount",
		"medicalbed_emergency",
		"piercesyringe",
		// "diode_disk_healing", // BANDASTATION REMOVAL - Healing beam design removal
		"diode_disk_sanity",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/reagent/haloperidol)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cryostasis
	id = TECHWEB_NODE_CRYOSTASIS
	display_name = "Криостазис"
	description = "Технология криогенной консервации экипажа, разработанная на основе случайного химического воздействия и адаптированная для безопасного применения."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP_ADV, TECHWEB_NODE_FUSION)
	design_ids = list(
		"cryotube",
		"mech_sleeper",
		"stasis",
		"cryo_grenade",
		"splitbeaker",
		"stasisbodybag", // BANDASTATION ADDITION - PERMA-DEATH
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/reagent/cryostylane = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
