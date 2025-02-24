/datum/antagonist/ert/deathsquad/on_gain() // Give deathsquad nuke code when ERT is summoned
	. = ..()
	var/datum/objective/missionobj = new()
	var/nuke_code
	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in SSmachines.get_machines_by_type(/obj/machinery/nuclearbomb/selfdestruct)
	nuke_code = random_nukecode()
	if(nuke.r_code == NUKE_CODE_UNSET) // Create code for a nuclear bomb if it doesn't exist for some reason
		nuke.r_code = nuke_code
	else
		nuke_code = nuke.r_code
	missionobj.owner = owner
	missionobj.explanation_text = "Запустите механизм самоуничтожения на [station_name()], коды активации: [nuke.r_code]"
	missionobj.completed = TRUE
	objectives |= missionobj
