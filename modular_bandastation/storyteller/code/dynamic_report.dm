/// Generate the advisory level depending on the shown threat level.
/datum/controller/subsystem/dynamic/generate_advisory_level()
	var/advisory_string = ""
	var/list/green_nebula_storytellers = list(/datum/storyteller/extended, /datum/storyteller/chill) //list for calmer storytellers for a greenshift
	var/list/midnight_sun_storytellers = list(/datum/storyteller/jester, /datum/storyteller/clown)
	var/list/orange_star_storytellers = list(/datum/storyteller/default, /datum/storyteller/fragile, /datum/storyteller/mystic)
	var/list/red_moon_storytellers  = list(/datum/storyteller/bomb, /datum/storyteller/gamer, /datum/storyteller/operative)
	var/list/black_orbit_storytellers = list(/datum/storyteller/black_orbit, /datum/storyteller/pups) //list for the more chaotic storytellers for black sun
	if(SSgamemode.selected_storyteller in green_nebula_storytellers)
		advisory_string += "Advisory Level: <b>Green Nebula</b></center><BR>"
		advisory_string += "Your sector's advisory level is Green Nebula. Surveillance information shows no credible threats to Nanotrasen assets within the Spinward Sector at this time. As always, the Department advises maintaining vigilance against potential threats, regardless of a lack of known threats."
	if(SSgamemode.selected_storyteller in midnight_sun_storytellers)
		advisory_string += "Advisory Level: <b>Midnight Sun</b></center><BR>"
		advisory_string += "Your sector's advisory level is Midnight Sun. Credible information passed to us by GDI suggests that the Syndicate is preparing to mount a major concerted offensive on Nanotrasen assets in the Spinward Sector to cripple our foothold there. All stations should remain on high alert and prepared to defend themselves."
	if(SSgamemode.selected_storyteller in orange_star_storytellers)
		advisory_string += "Advisory Level: <b>Orange Star</b></center><BR>"
		advisory_string += "Your sector's advisory level is Orange Star. Upon reviewing your sector's intelligence, the Department has determined that the risk of enemy activity is moderate to severe. At this advisory, we recommend maintaining a higher degree of security and alertness, and vigilance against threats that may (or will) arise."
	if(SSgamemode.selected_storyteller in red_moon_storytellers)
		advisory_string += "Advisory Level: <b>Red Moon</b></center><BR>"
		advisory_string += "Your sector's advisory level is Red Moon. Upon reviewing your sector's intelligence, the Department has determined that the risk of enemy activity is moderate to severe. At this advisory, we recommend maintaining a higher degree of security and alertness, and vigilance against threats that may (or will) arise."
	if(SSgamemode.selected_storyteller in black_orbit_storytellers)
		advisory_string += "Advisory Level: <b>Black Orbit</b></center><BR>"
		advisory_string += "Your sector's advisory level is Black Orbit. Central Command has determined that the risk of enemy activity is high. Central Command abandon you and crew. Now only god can help you."

	return advisory_string
