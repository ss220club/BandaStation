/// Radius of a redspace hex in map tiles. The resulting bounding box is roughly 8x8 tiles.
#define REDSPACE_HEX_RADIUS 4
#define REDSPACE_HEX_SQRT3 1.7320508075688772

#define REDSPACE_DEFAULT_VALUE 0
#define REDSPACE_MAX_NORMAL_VALUE 10
#define REDSPACE_MAX_SOURCE_RADIUS 64

/// Susceptibility coefficient applied to hexes with no special zone rule.
#define REDSPACE_DEFAULT_COEFFICIENT 1
/// MVP exception: the bridge zone is half as susceptible to the ordinary field.
#define REDSPACE_BRIDGE_COEFFICIENT 0.5

#define REDSPACE_PROFILE_DEBUG "debug"
#define REDSPACE_PROFILE_DEMONIC "demonic"

#define REDSPACE_STATE_EBB 1
#define REDSPACE_STATE_CALM 2
#define REDSPACE_STATE_DISTURBANCE 3
#define REDSPACE_STATE_STORM 4
#define REDSPACE_STATE_INVASION 5
