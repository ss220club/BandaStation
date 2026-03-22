// default alpha for cascade mask in normal LOS mode
#define LOS_CASCADE_MASK_ALPHA_DEFAULT 255
// reduced alpha for cascade mask when SEE_THRU/SEE_MOBS is active
#define LOS_CASCADE_MASK_ALPHA_SEETHRU 100

// compensates displacement map alpha blur
#define SHADOW_PLANES_COLOR_MATRIX list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,2, 0,0,0,0)
// kills half pixel blur from displace
#define SHADOW_PLANES_BLACK_OPAQUE_MATRIX list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,2550, 0,0,0,0)

#define SHADOW_ANIM_DOOR 0
#define SHADOW_ANIM_FALSE_WALL 1

// Line of Sight effect switch
// see private los.dm
//#define LOS_ENABLED // local testing only, actual LOS_ENABLED defined in the HeadInclude.dm
