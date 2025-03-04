/proc/return_antag_weight(list/candidates)
	. = list()
	for(var/anything in candidates)
		var/client/client_source
		if(ismob(anything))
			var/mob/mob = anything
			client_source = mob.client
		else if(IS_CLIENT_OR_MOCK(anything))
			client_source = anything
		if(QDELETED(client_source) || !client_source.ckey)
			continue
		.[client_source.ckey] = 10

/// Pick a random element from the list and remove it from the list.
/proc/pick_n_take_weighted(list/list_to_pick)
	if(length(list_to_pick))
		var/picked = pick_weight(list_to_pick)
		list_to_pick -= picked
		return picked

/proc/is_late_arrival(mob/living/player)
	var/static/cached_result
	if(!isnull(cached_result))
		return cached_result
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) || (STATION_TIME_PASSED() > 1 MINUTES))
		return cached_result = FALSE
	if(QDELETED(player) || !istype(get_area(player), /area/shuttle/arrival))
		return FALSE
	return TRUE

/mob/living/proc/clear_inventory(include_pockets = TRUE, include_held_items = TRUE)
	var/list/items = get_equipped_items(include_pockets)
	if(include_held_items)
		items |= held_items
	for(var/item in items)
		dropItemToGround(item, force = TRUE, silent = TRUE, invdrop = FALSE)
		qdel(item)
