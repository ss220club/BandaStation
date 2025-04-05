#define WHITELISTFILE "[global.config.directory]/whitelist.txt"

GLOBAL_LIST(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in world.file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.whitelist += ckey(line)

	// BADNASTATION EDIT
	// if(!GLOB.whitelist.len)
	// 	GLOB.whitelist = null

/proc/check_whitelist(ckey)
	// BANDASTATION EDIT - SSCentral
	return SScentral.is_player_whitelisted(ckey)

#undef WHITELISTFILE
