/// Radius of a redspace hex in map tiles. The resulting bounding box is roughly 12x12 tiles.
#define REDSPACE_HEX_RADIUS 6
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
#define REDSPACE_SENSOR_UPDATE_INTERVAL (5 SECONDS)
#define REDSPACE_SENSOR_STALE_AFTER (15 SECONDS)
#define REDSPACE_SENSOR_HISTORY_LIMIT 24

#define REDSPACE_PROFILE_DEBUG "debug"
#define REDSPACE_PROFILE_DEMONIC "demonic"
#define REDSPACE_PROFILE_STABILIZER "stabilizer"

/// Event categories. Spawn events use a separate budget from ordinary effects.
#define REDSPACE_EVENT_CATEGORY_EFFECT "effect"
#define REDSPACE_EVENT_CATEGORY_SPAWN "spawn"
#define REDSPACE_EVENT_CATEGORY_TURF_SPAWN "turf_spawn"
#define REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN "object_spawn"
#define REDSPACE_EVENT_CATEGORY_MOB_SPAWN "mob_spawn"

/// Round-start intensity selected by the redspace station trait.
#define REDSPACE_INTENSITY_CALM "calm"
#define REDSPACE_INTENSITY_DISTURBANCE "disturbance"
#define REDSPACE_INTENSITY_STORM "storm"

/// Starting event-budget values for one active hex zone.
#define REDSPACE_EVENT_BUDGET_WINDOW (60 SECONDS)
#define REDSPACE_EVENT_BUDGET_COOLDOWN (10 SECONDS)
#define REDSPACE_EVENT_BUDGET_MAX_POINTS 4
#define REDSPACE_EVENT_BUDGET_MAX_ACTIVE 2
#define REDSPACE_EVENT_BUDGET_MAX_DANGEROUS 1

/// Independent limits for events that leave turfs, objects or mobs in the world.
#define REDSPACE_SPAWN_BUDGET_WINDOW (60 SECONDS)
#define REDSPACE_SPAWN_BUDGET_COOLDOWN (10 SECONDS)
#define REDSPACE_SPAWN_BUDGET_MAX_POINTS 8
#define REDSPACE_SPAWN_BUDGET_MAX_TURF_POINTS 8
#define REDSPACE_SPAWN_BUDGET_MAX_MOB_POINTS 8
#define REDSPACE_SPAWN_BUDGET_MAX_ACTIVE_EVENTS 4
/// A radius-six cell exposes roughly 90-100 candidate turfs; keep about half active.
#define REDSPACE_SPAWN_BUDGET_MAX_TURFS 20
#define REDSPACE_SPAWN_BUDGET_MAX_OBJECTS 6
#define REDSPACE_SPAWN_BUDGET_MAX_MOBS 3
#define REDSPACE_MOB_SPAWN_TELEGRAPH_DURATION (2 SECONDS)

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

#define REDSPACE_ENERGY_ENVIRONMENT_NONE 0
#define REDSPACE_ENERGY_ENVIRONMENT_DRAIN 1
#define REDSPACE_ENERGY_ENVIRONMENT_RECHARGE 2
#define REDSPACE_ENERGY_HUD_KEY "redspace_energy"
