#define BASIC_DONATOR_LEVEL 0
#define ADMIN_DONATOR_LEVEL 3
#define MAX_DONATOR_LEVEL 5

/client
	/// Call `proc/get_donator_level()` instead to get a value when possible.
	var/donator_level = BASIC_DONATOR_LEVEL
	var/can_save_donator_level = FALSE

// For unit-tests
/datum/client_interface
	var/donator_level = BASIC_DONATOR_LEVEL

/datum/client_interface/proc/get_donator_level()
	return donator_level

/client/proc/get_donator_level()
	return max(donator_level, get_donator_level_from_admin())

/client/proc/get_donator_level_from_admin()
	if(!holder)
		return BASIC_DONATOR_LEVEL
	var/rank_flags = holder.rank_flags()
	if(rank_flags & R_EVERYTHING)
		return MAX_DONATOR_LEVEL
	if(rank_flags & R_ADMIN)
		return ADMIN_DONATOR_LEVEL
	return BASIC_DONATOR_LEVEL
