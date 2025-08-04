// MARK: Accesses
/obj/effect/mapping_helpers/airlock/access/all/syndicate/command/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SYNDICATE_COMMAND
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/syndicate/command/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_SYNDICATE_COMMAND)
	return access_list

// MARK: Windoor Access Helpers
/obj/effect/mapping_helpers/windoor/access
	layer = DOOR_ACCESS_HELPER_LAYER
	icon = 'modular_bandastation/mapping/icons/landmarks/access_helpers.dmi'
	icon_state = "access_helper"
	var/list/access = list()
	return access

/obj/effect/mapping_helpers/windoor/proc/payload(obj/machinery/door/window/window)
	if(window.dir != dir)
		return TRUE
	return FALSE

/obj/effect/mapping_helpers/windoor/access/proc/get_access()
	var/list/access = list()
	return access

/obj/effect/mapping_helpers/windoor/access/Initialize()
	. = ..()
	var/found_any
	for(var/obj/machinery/door/window/window in loc)
		payload(window)
		found_any = TRUE
	if(!found_any)
		log_mapping("[src] at [AREACOORD(src)] couldn't find a windoor at its location!")

/obj/effect/mapping_helpers/windoor/access/any/payload(obj/machinery/door/window/window)
	if(..()) return
	if(window.req_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		window.req_one_access += access_list

/obj/effect/mapping_helpers/windoor/access/all/payload(obj/machinery/door/window/window)
	if(..()) return
	if(window.req_one_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		window.req_access += access_list

// COMMAND
#define WINDOOR_ACCESS_HELPER_COM(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/command/##type { \
		icon_state = "access_helper_com"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/command/##type { \
		icon_state = "access_helper_com"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_COM(general, ACCESS_COMMAND)
WINDOOR_ACCESS_HELPER_COM(ai_upload, ACCESS_AI_UPLOAD)
WINDOOR_ACCESS_HELPER_COM(teleporter, ACCESS_TELEPORTER)
WINDOOR_ACCESS_HELPER_COM(eva, ACCESS_EVA)
WINDOOR_ACCESS_HELPER_COM(minisat, ACCESS_MINISAT)
WINDOOR_ACCESS_HELPER_COM(gateway, ACCESS_GATEWAY)
WINDOOR_ACCESS_HELPER_COM(hop, ACCESS_HOP)
WINDOOR_ACCESS_HELPER_COM(captain, ACCESS_CAPTAIN)
WINDOOR_ACCESS_HELPER_COM(maintenance, list(ACCESS_COMMAND, ACCESS_MAINT_TUNNELS))

#undef WINDOOR_ACCESS_HELPER_COM

// ENGINEERING
#define WINDOOR_ACCESS_HELPER_ENG(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/engineering/##type { \
		icon_state = "access_helper_eng"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/engineering/##type { \
		icon_state = "access_helper_eng"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_ENG(general, ACCESS_ENGINEERING)
WINDOOR_ACCESS_HELPER_ENG(engine_equipment, ACCESS_ENGINE_EQUIP)
WINDOOR_ACCESS_HELPER_ENG(construction, ACCESS_CONSTRUCTION)
WINDOOR_ACCESS_HELPER_ENG(aux_base, ACCESS_AUX_BASE)
WINDOOR_ACCESS_HELPER_ENG(maintenance, ACCESS_MAINT_TUNNELS)
WINDOOR_ACCESS_HELPER_ENG(maintenance/departamental, list(ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS))
WINDOOR_ACCESS_HELPER_ENG(external, ACCESS_EXTERNAL_AIRLOCKS)
WINDOOR_ACCESS_HELPER_ENG(tech_storage, ACCESS_TECH_STORAGE)
WINDOOR_ACCESS_HELPER_ENG(atmos, ACCESS_ATMOSPHERICS)
WINDOOR_ACCESS_HELPER_ENG(tcoms, ACCESS_TCOMMS)
WINDOOR_ACCESS_HELPER_ENG(ce, ACCESS_CE)

#undef WINDOOR_ACCESS_HELPER_ENG

// MEDICAL
#define WINDOOR_ACCESS_HELPER_MED(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/medical/##type { \
		icon_state = "access_helper_med"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/medical/##type { \
		icon_state = "access_helper_med"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_MED(general, ACCESS_MEDICAL)
WINDOOR_ACCESS_HELPER_MED(morgue, ACCESS_MORGUE)
WINDOOR_ACCESS_HELPER_MED(coroner, ACCESS_MORGUE_SECURE)
WINDOOR_ACCESS_HELPER_MED(chemistry, ACCESS_PLUMBING)
WINDOOR_ACCESS_HELPER_MED(virology, ACCESS_VIROLOGY)
WINDOOR_ACCESS_HELPER_MED(surgery, ACCESS_SURGERY)
WINDOOR_ACCESS_HELPER_MED(cmo, ACCESS_CMO)
WINDOOR_ACCESS_HELPER_MED(pharmacy, ACCESS_PHARMACY)
WINDOOR_ACCESS_HELPER_MED(psychology, ACCESS_PSYCHOLOGY)
WINDOOR_ACCESS_HELPER_MED(maintenance, list(ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS))

#undef WINDOOR_ACCESS_HELPER_MED

// RESEARCH
#define WINDOOR_ACCESS_HELPER_SCI(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/science/##type { \
		icon_state = "access_helper_sci"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/science/##type { \
		icon_state = "access_helper_sci"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_SCI(general, ACCESS_SCIENCE)
WINDOOR_ACCESS_HELPER_SCI(research, ACCESS_RESEARCH)
WINDOOR_ACCESS_HELPER_SCI(ordnance, ACCESS_ORDNANCE)
WINDOOR_ACCESS_HELPER_SCI(ordnance_storage, ACCESS_ORDNANCE_STORAGE)
WINDOOR_ACCESS_HELPER_SCI(genetics, ACCESS_GENETICS)
WINDOOR_ACCESS_HELPER_SCI(robotics, ACCESS_ROBOTICS)
WINDOOR_ACCESS_HELPER_SCI(xenobio, ACCESS_XENOBIOLOGY)
WINDOOR_ACCESS_HELPER_SCI(minisat, ACCESS_MINISAT)
WINDOOR_ACCESS_HELPER_SCI(rd, ACCESS_RD)
WINDOOR_ACCESS_HELPER_SCI(maintenance, list(ACCESS_SCIENCE, ACCESS_MAINT_TUNNELS))

#undef WINDOOR_ACCESS_HELPER_SCI

// SECURITY
#define WINDOOR_ACCESS_HELPER_SEC(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/security/##type { \
		icon_state = "access_helper_sec"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/security/##type { \
		icon_state = "access_helper_sec"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_SEC(general, ACCESS_SECURITY)
WINDOOR_ACCESS_HELPER_SEC(entrance, ACCESS_BRIG_ENTRANCE)
WINDOOR_ACCESS_HELPER_SEC(brig, ACCESS_BRIG)
WINDOOR_ACCESS_HELPER_SEC(armory, ACCESS_ARMORY)
WINDOOR_ACCESS_HELPER_SEC(detective, ACCESS_DETECTIVE)
WINDOOR_ACCESS_HELPER_SEC(court, ACCESS_COURT)
WINDOOR_ACCESS_HELPER_SEC(hos, ACCESS_HOS)
WINDOOR_ACCESS_HELPER_SEC(maintenance, list(ACCESS_SECURITY, ACCESS_MAINT_TUNNELS))

#undef WINDOOR_ACCESS_HELPER_SEC

// SERVICE
#define WINDOOR_ACCESS_HELPER_SRV(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/service/##type { \
		icon_state = "access_helper_serv"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/service/##type { \
		icon_state = "access_helper_serv"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_SRV(general, ACCESS_SERVICE)
WINDOOR_ACCESS_HELPER_SRV(kitchen, ACCESS_KITCHEN)
WINDOOR_ACCESS_HELPER_SRV(bar, ACCESS_BAR)
WINDOOR_ACCESS_HELPER_SRV(hydroponics, ACCESS_HYDROPONICS)
WINDOOR_ACCESS_HELPER_SRV(janitor, ACCESS_JANITOR)
WINDOOR_ACCESS_HELPER_SRV(chapel_office, ACCESS_CHAPEL_OFFICE)
WINDOOR_ACCESS_HELPER_SRV(crematorium, ACCESS_CREMATORIUM)
WINDOOR_ACCESS_HELPER_SRV(library, ACCESS_LIBRARY)
WINDOOR_ACCESS_HELPER_SRV(theatre, ACCESS_THEATRE)
WINDOOR_ACCESS_HELPER_SRV(lawyer, ACCESS_LAWYER)
WINDOOR_ACCESS_HELPER_SRV(maintenance, list(ACCESS_SERVICE, ACCESS_MAINT_TUNNELS))

#undef WINDOOR_ACCESS_HELPER_SRV

// SUPPLY
#define WINDOOR_ACCESS_HELPER_SUP(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/supply/##type { \
		icon_state = "access_helper_sup"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/supply/##type { \
		icon_state = "access_helper_sup"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_SUP(general, ACCESS_CARGO)
WINDOOR_ACCESS_HELPER_SUP(shipping, ACCESS_SHIPPING)
WINDOOR_ACCESS_HELPER_SUP(mining, ACCESS_MINING)
WINDOOR_ACCESS_HELPER_SUP(mining_station, ACCESS_MINING_STATION)
WINDOOR_ACCESS_HELPER_SUP(mineral_storage, ACCESS_MINERAL_STOREROOM)
WINDOOR_ACCESS_HELPER_SUP(qm, ACCESS_QM)
WINDOOR_ACCESS_HELPER_SUP(vault, ACCESS_VAULT)
WINDOOR_ACCESS_HELPER_SUP(maintenance, list(ACCESS_CARGO, ACCESS_MAINT_TUNNELS))
WINDOOR_ACCESS_HELPER_SUP(bit_den, ACCESS_BIT_DEN)

#undef WINDOOR_ACCESS_HELPER_SUP

// SYNDICATE
#define WINDOOR_ACCESS_HELPER_SYN(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/syndicate/##type { \
		icon_state = "access_helper_syn"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/syndicate/##type { \
		icon_state = "access_helper_syn"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_SYN(general, ACCESS_SYNDICATE)
WINDOOR_ACCESS_HELPER_SYN(leader, ACCESS_SYNDICATE_LEADER)

// BOUNTY HUNTER
#define WINDOOR_ACCESS_HELPER_HUNT(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/hunter/##type { \
		icon_state = "access_helper_hunt"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/hunter/##type { \
		icon_state = "access_helper_hunt"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_HUNT(general, ACCESS_HUNTER)

#undef WINDOOR_ACCESS_HELPER_HUNT

// AWAY
#define WINDOOR_ACCESS_HELPER_AWAY(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/away/##type { \
		icon_state = "access_helper_awy"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/away/##type { \
		icon_state = "access_helper_awy"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_AWAY(general, ACCESS_AWAY_GENERAL)
WINDOOR_ACCESS_HELPER_AWAY(command, ACCESS_AWAY_COMMAND)
WINDOOR_ACCESS_HELPER_AWAY(security, ACCESS_AWAY_SEC)
WINDOOR_ACCESS_HELPER_AWAY(engineering, ACCESS_AWAY_ENGINEERING)
WINDOOR_ACCESS_HELPER_AWAY(medical, ACCESS_AWAY_MEDICAL)
WINDOOR_ACCESS_HELPER_AWAY(supply, ACCESS_AWAY_SUPPLY)
WINDOOR_ACCESS_HELPER_AWAY(science, ACCESS_AWAY_SCIENCE)
WINDOOR_ACCESS_HELPER_AWAY(maintenance, ACCESS_AWAY_MAINTENANCE)
WINDOOR_ACCESS_HELPER_AWAY(generic1, ACCESS_AWAY_GENERIC1)
WINDOOR_ACCESS_HELPER_AWAY(generic2, ACCESS_AWAY_GENERIC2)
WINDOOR_ACCESS_HELPER_AWAY(generic3, ACCESS_AWAY_GENERIC3)
WINDOOR_ACCESS_HELPER_AWAY(generic4, ACCESS_AWAY_GENERIC4)

#undef WINDOOR_ACCESS_HELPER_AWAY

// ADMIN
#define WINDOOR_ACCESS_HELPER_ADM(type, access) \
	/obj/effect/mapping_helpers/windoor/access/any/admin/##type { \
		icon_state = "access_helper_adm"; \
		access_list += access; \
	} \
	/obj/effect/mapping_helpers/windoor/access/all/admin/##type { \
		icon_state = "access_helper_adm"; \
		access_list += access; \
	}

WINDOOR_ACCESS_HELPER_ADM(general, ACCESS_CENT_GENERAL)
WINDOOR_ACCESS_HELPER_ADM(thunderdome, ACCESS_CENT_THUNDER)
WINDOOR_ACCESS_HELPER_ADM(medical, ACCESS_CENT_MEDICAL)
WINDOOR_ACCESS_HELPER_ADM(living, ACCESS_CENT_LIVING)
WINDOOR_ACCESS_HELPER_ADM(storage, ACCESS_CENT_STORAGE)
WINDOOR_ACCESS_HELPER_ADM(teleporter, ACCESS_CENT_TELEPORTER)
WINDOOR_ACCESS_HELPER_ADM(captain, ACCESS_CENT_CAPTAIN)
WINDOOR_ACCESS_HELPER_ADM(bar, ACCESS_CENT_BAR)

#undef WINDOOR_ACCESS_HELPER_ADM
