///Smoke coming from cigarettes and fires
/datum/pollutant/smoke //and mirrors
	name = "Smoke"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_BREATHE_ACT

///From smoking weed
/datum/pollutant/smoke/cannabis
	name = "Cannabis"

/datum/pollutant/smoke/vape
	name = "Vape Cloud"
	thickness = 2

///Sulphur coming from igniting matches
/datum/pollutant/smoke/sulphur
	name = "Sulphur"

///Dust for events or future
/datum/pollutant/dust
	name = "Dust"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_BREATHE_ACT
	thickness = 2
	color = "#ffed9c"
