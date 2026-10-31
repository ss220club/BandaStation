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
