// default alpha for cascade mask in normal LOS mode
#define LOS_CASCADE_MASK_ALPHA_DEFAULT 255
// reduced alpha for cascade mask when SEE_THRU/SEE_MOBS is active
#define LOS_CASCADE_MASK_ALPHA_SEETHRU 0

// compensates displacement map alpha blur
#define SHADOW_PLANES_COLOR_MATRIX list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,2, 0,0,0,0)
// kills half pixel blur from displace
#define SHADOW_PLANES_BLACK_OPAQUE_MATRIX list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,2550, 0,0,0,0)

#define SHADOW_ANIM_DOOR 0
#define SHADOW_ANIM_FALSE_WALL 1

#define LOS_PROXY_INIT_BLOCK_TYPES list( \
	/obj/item, \
	/obj/effect, \
	/obj/machinery/power/supermatter_crystal, \
)

#define LOS_PROXY_NO_OVERLAY_MIRROR_TYPES list( \
	/obj/machinery, \
	/obj/structure/mineral_door, \
	/obj/structure/fence/door, \
)

#define LOS_PROXY_INIT_ALLOW_TYPES list( \
)

// Line of Sight effect switch
// see private los.dm
//#define LOS_ENABLED // local testing only, actual LOS_ENABLED defined in the HeadInclude.dm
