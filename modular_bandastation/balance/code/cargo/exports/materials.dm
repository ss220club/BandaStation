// MARK: EXPORT MATERIAL PRICES
/datum/export/material/plasma
	cost = CARGO_CRATE_VALUE * 0.1

/datum/export/material/bananium
	cost = CARGO_CRATE_VALUE * 0.5

/datum/export/material/adamantine // For whatever reason, adamantine doesn't truly exist in export list
	cost = CARGO_CRATE_VALUE * 0.7
	material_id = /datum/material/adamantine
	message = "cm3 of adamantine"

/datum/export/material/mythril
	cost = CARGO_CRATE_VALUE * 0.75

/datum/export/material/plastic
	cost = CARGO_CRATE_VALUE * 0.0125

/datum/export/material/runite
	cost = CARGO_CRATE_VALUE * 0.3

/datum/export/material/diamond
	cost = CARGO_CRATE_VALUE * 0.7
	material_id = /datum/material/diamond // For whatever reason, in original there is adamantine instead of diamond
	message = "cm3 of diamond"

/datum/export/material/uranium
	cost = CARGO_CRATE_VALUE * 0.4

/datum/export/material/gold
	cost = CARGO_CRATE_VALUE * 0.5

/datum/export/material/silver
	cost = CARGO_CRATE_VALUE * 0.2

/datum/export/material/titanium
	cost = CARGO_CRATE_VALUE * 0.5

/datum/export/material/bscrystal
	cost = CARGO_CRATE_VALUE * 0.7
