// Global storage for all created digital warrants
GLOBAL_LIST_EMPTY_TYPED(all_warrants, /datum/digital_warrant)

/datum/digital_warrant
	var/namewarrant = "Unknown"
	var/jobwarrant = "N/A"
	var/charges = "No charges present"
	var/auth = "Unauthorized"
	var/idauth = "Unauthorized"
	var/list/access = list()
	var/arrestsearch = "arrest"
	var/archived = FALSE
