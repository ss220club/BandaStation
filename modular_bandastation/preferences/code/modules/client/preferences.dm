#define BASE_LOADOUT_POINTS 5
#define LOADOUT_POINTS_PER_DONATION_LEVEL 3

/datum/preferences
	max_save_slots = 5
	var/loadout_points_spent = 0

/datum/preferences/proc/get_loadout_max_points()
	return BASE_LOADOUT_POINTS + parent.get_donator_level() * LOADOUT_POINTS_PER_DONATION_LEVEL

#undef BASE_LOADOUT_POINTS
#undef LOADOUT_POINTS_PER_DONATION_LEVEL
