/datum/config_entry/number/roundstart_security_for_threat
	default = 0
	min_val = 0

/datum/config_entry/number/min_threat_to_roundstart_percent
	default = 0
	min_val = 0
	max_val = 100

/datum/config_entry/number/max_threat_to_roundstart_percent
	default = 0
	min_val = 0
	max_val = 100

/datum/config_entry/number/min_threat_level
	default = 0
	min_val = 0

/// Enable weighted antagonist selection based on recent role history.
/datum/config_entry/flag/antag_weighted_selection
	protection = CONFIG_ENTRY_LOCKED

/// Time window in days for tracking antagonist role history.
/datum/config_entry/number/antag_history_window_days
	protection = CONFIG_ENTRY_LOCKED
	default = 14
	min_val = 0
	max_val = 90

/// Base weight for candidates (100 = normal chance).
/datum/config_entry/number/antag_base_weight
	protection = CONFIG_ENTRY_LOCKED
	default = 100
	min_val = 1
	max_val = 1000

/// Weight penalty per recent antagonist role assignment.
/datum/config_entry/number/antag_weight_penalty
	protection = CONFIG_ENTRY_LOCKED
	default = 20
	min_val = 0
	max_val = 100

/// Minimum weight a candidate can have (prevents complete exclusion).
/datum/config_entry/number/antag_min_weight
	protection = CONFIG_ENTRY_LOCKED
	default = 10
	min_val = 0
	max_val = 100

/// List of antagonist datums that are ignored when calculating weights.
/datum/config_entry/str_list/ignored_antagonists
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_antag_candidate_weight
