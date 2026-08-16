/// Radius of a redspace hex in map tiles. The resulting bounding box is roughly 8x8 tiles.
#define REDSPACE_HEX_RADIUS 4
#define REDSPACE_HEX_SQRT3 1.7320508075688772

#define REDSPACE_DEFAULT_VALUE 0
#define REDSPACE_MAX_NORMAL_VALUE 10
#define REDSPACE_EVENT_MIN_VALUE 10.1
#define REDSPACE_MAX_SOURCE_RADIUS 64

/// Hysteresis thresholds for cached gameplay ranges.
#define REDSPACE_DISTURBANCE_ENTER_VALUE 4
#define REDSPACE_DISTURBANCE_EXIT_VALUE 3
#define REDSPACE_STORM_ENTER_VALUE 7
#define REDSPACE_STORM_EXIT_VALUE 6
#define REDSPACE_EBB_EXIT_VALUE 1

/// Number of range transitions retained for diagnostics.
#define REDSPACE_TRANSITION_LOG_LIMIT 128

/// Susceptibility coefficient applied to hexes with no special zone rule.
#define REDSPACE_DEFAULT_COEFFICIENT 1
/// MVP exception: the bridge zone is half as susceptible to the ordinary field.
#define REDSPACE_BRIDGE_COEFFICIENT 0.5

/// Sampling and history limits for stationary redspace sensors.
#define REDSPACE_SENSOR_UPDATE_INTERVAL (2 SECONDS)
#define REDSPACE_SENSOR_STALE_AFTER (6 SECONDS)
#define REDSPACE_SENSOR_HISTORY_LIMIT 24

#define REDSPACE_PROFILE_DEBUG "debug"
#define REDSPACE_PROFILE_DEMONIC "demonic"
#define REDSPACE_PROFILE_STABILIZER "stabilizer"

/// Starting event-budget values for one active hex zone.
#define REDSPACE_EVENT_BUDGET_WINDOW (60 SECONDS)
#define REDSPACE_EVENT_BUDGET_COOLDOWN (10 SECONDS)
#define REDSPACE_EVENT_BUDGET_MAX_POINTS 4
#define REDSPACE_EVENT_BUDGET_MAX_ACTIVE 2
#define REDSPACE_EVENT_BUDGET_MAX_DANGEROUS 1

/// Stabilizers regulate the ordinary field toward the top of the calm range.
#define REDSPACE_STABILIZER_TARGET_VALUE 3
#define REDSPACE_STABILIZER_DEFAULT_RADIUS 8
#define REDSPACE_STABILIZER_SERVICE_INTERVAL (30 SECONDS)
#define REDSPACE_STABILIZER_HEAT_WARNING 70
#define REDSPACE_STABILIZER_HEAT_CRITICAL_WARNING 90
#define REDSPACE_STABILIZER_MAX_HEAT 100
#define REDSPACE_STABILIZER_RESOURCE_WARNING_PERCENT 25

#define REDSPACE_STATE_EBB 1
#define REDSPACE_STATE_CALM 2
#define REDSPACE_STATE_DISTURBANCE 3
#define REDSPACE_STATE_STORM 4
#define REDSPACE_STATE_INVASION 5
