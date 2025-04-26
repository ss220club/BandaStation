/// 220 RUB | 2.85 USD
#define DONATOR_TIER_1 1
/// 440 RUB | 5.7 USD
#define DONATOR_TIER_2 2
/// 1000 RUB | 13 USD
#define DONATOR_TIER_3 3
/// 2200 RUB | 28.8 USD
#define DONATOR_TIER_4 4
/// 10000 RUB | 130 USD
#define DONATOR_TIER_5 5

#define BASIC_DONATOR_LEVEL 0
#define ADMIN_DONATOR_LEVEL DONATOR_TIER_3
#define MAX_DONATOR_LEVEL DONATOR_TIER_5

/client
	/// Call `proc/get_donator_level()` instead to get a value when possible.
	var/donator_level = BASIC_DONATOR_LEVEL

// For unit-tests
/datum/client_interface
	var/donator_level = BASIC_DONATOR_LEVEL

/datum/client_interface/proc/get_donator_level()
	return donator_level

/client/proc/get_donator_level()
	return max(donator_level, get_donator_level_from_admin())

/client/proc/get_donator_level_from_admin()
	var/rank_flags = get_player_admin_flags(src)
	if(!rank_flags)
		return BASIC_DONATOR_LEVEL
	if(rank_flags & R_EVERYTHING)
		return MAX_DONATOR_LEVEL
	if(rank_flags & R_ADMIN)
		return ADMIN_DONATOR_LEVEL
	return BASIC_DONATOR_LEVEL
