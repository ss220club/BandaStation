/// signals from globally accessible objects

///from SSJob whenever setup_occupations() is called, all occupations are set
#define COMSIG_OCCUPATIONS_SETUP "occupations_setup"

///from SSJob when divide_occupations() is called
#define COMSIG_OCCUPATIONS_DIVIDED "occupations_divided"

// SS220 ADDITION START - Roundstart Roster
/// Assign jobs selected by admins to ready players before standard job distribution.
/// Arguments: ().
#define COMSIG_ROUNDSTART_ROSTER_APPLY "roundstart_roster_apply"
/// Block conflicting or repeated job assignments for players selected by admins.
/// Arguments: (player, job, reject_already_assigned = TRUE).
/// Dynamic passes FALSE to check job compatibility without attempting another assignment.
#define COMSIG_ROUNDSTART_ROSTER_VALIDATE_ASSIGNMENT "roundstart_roster_validate_assignment"
#define ROUNDSTART_ROSTER_BLOCK_ASSIGNMENT (1<<0)
/// Allow players with admin-selected jobs to enter distribution with empty job preferences.
/// Arguments: (player).
#define COMSIG_ROUNDSTART_ROSTER_BYPASS_PREFS "roundstart_roster_bypass_prefs"
#define ROUNDSTART_ROSTER_BYPASS_PREFS (1<<0)
/// Block antagonist selection that conflicts with a player's admin-selected job.
/// Arguments: (ruleset, candidate).
#define COMSIG_ROUNDSTART_ROSTER_VALIDATE_ANTAG "roundstart_roster_validate_antag"
#define ROUNDSTART_ROSTER_BLOCK_ANTAG (1<<0)
// SS220 ADDITION END

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

///from SSsecurity_level when the security level changes : (new_level)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

///from SSshuttle when the supply shuttle starts spawning orders : ()
#define COMSIG_SUPPLY_SHUTTLE_BUY "supply_shuttle_buy"
