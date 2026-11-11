/// signals from globally accessible objects

///from SSJob whenever setup_occupations() is called, all occupations are set
#define COMSIG_OCCUPATIONS_SETUP "occupations_setup"

///from SSJob when divide_occupations() is called
#define COMSIG_OCCUPATIONS_DIVIDED "occupations_divided"

// BANDASTATION ADDITION START - Roundstart Roster signals
#define COMSIG_COLLECT_ROUNDSTART_ASSIGNMENT_CALLBACKS "collect_roundstart_assignment_callbacks"

#define COMSIG_CHECK_JOB_ASSIGNMENT "check_job_assignment"
/// Return 1 to reject the job, or 0/null to leave the decision to other checks.
#define BLOCK_JOB_ASSIGNMENT (1<<0)

#define COMSIG_BYPASS_JOB_PREFERENCES "bypass_job_preferences"
/// Return 1 to bypass job preferences, or 0/null to keep normal checks. Readiness is still required.
#define BYPASS_JOB_PREFERENCES (1<<0)

#define COMSIG_CHECK_ROUNDSTART_ANTAG_CANDIDATE "check_roundstart_antag_candidate"
/// Return 1 to reject the candidate, or 0/null to leave the decision to other eligibility checks.
#define BLOCK_ROUNDSTART_ANTAG_CANDIDATE (1<<0)
// BANDASTATION ADDITION END

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

///from SSsecurity_level when the security level changes : (new_level)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

///from SSshuttle when the supply shuttle starts spawning orders : ()
#define COMSIG_SUPPLY_SHUTTLE_BUY "supply_shuttle_buy"
