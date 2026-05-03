/// Appends remaining bag cards to the Status tab, one per line with 8-space indent.
/datum/controller/subsystem/statpanels/proc/get_extra_status_data()
	var/list/data = list()
	if(!SSmap_vote || !length(SSmap_vote.remaining_bag))
		return data
	data += ""
	data += "Оставшиеся карты ([length(SSmap_vote.remaining_bag)]):"
	for(var/map_name in SSmap_vote.remaining_bag)
		var/datum/map_config/mc = config.maplist[map_name]
		data += "- [mc?.map_name || map_name]"
	return data
