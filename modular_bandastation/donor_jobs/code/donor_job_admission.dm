/datum/job/donor/get_join_lock_reason(client/player)
	return ..() || donor_lock_reason(player)

/datum/job/prisoner/get_join_lock_reason(client/player)
	return ..() || donor_lock_reason(player)
