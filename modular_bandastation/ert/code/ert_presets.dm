/datum/antagonist/ert/security
	outfit = /datum/outfit/centcom/ert/security

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/centcom/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/centcom/ert/engineer/alert

/datum/antagonist/ert/medic
	role = "Medical Officer"
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/centcom/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/centcom/ert/commander/alert

/datum/antagonist/ert/janitor
	role = "Janitor"
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/commander/gamma
	outfit = /datum/outfit/centcom/ert/commander/gamma

/datum/antagonist/ert/commander/epsilon
	outfit = /datum/outfit/centcom/ert/commander/epsilon

/datum/ert/gamma
	leader_role = /datum/antagonist/ert/commander/gamma
	roles = list(/datum/antagonist/ert/security/gamma, /datum/antagonist/ert/medic/gamma, /datum/antagonist/ert/engineer/gamma)
	code = "Gamma"

/datum/ert/epsilon
	leader_role = /datum/antagonist/ert/commander/epsilon
	roles = list(/datum/antagonist/ert/security/epslion, /datum/antagonist/ert/medic/epslion, /datum/antagonist/ert/engineer/epslion)
	code = "Epsilon"

/obj/effect/landmark/ert_brief_spawn
	name = "ertbriefspawn"
	icon_state = "ert_brief_spawn"
