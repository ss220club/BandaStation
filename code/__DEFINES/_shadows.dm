// compensates displacement map alpha blur
#define SHADOW_PLANES_COLOR_MATRIX list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,2, 0,0,0,0)
// kills half pixel blur from displace
#define SHADOW_PLANES_BLACK_OPAQUE_MATRIX list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,2550, 0,0,0,0)
// helps to reduce low alpha fringe, sub pixel ramps after masks
#define SHADOW_PLANES_POST_SEED_MASK_MATRIX list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,2, 0,0,0,-1)

#define WALLS_FOV_SHADOW_SEED_H "idealh"
#define WALLS_FOV_SHADOW_SEED_V "idealv"
// in byond we are bound to 8 bit per channel with disp filters, and when using the high res displacement maps - the render target accumulates some quantization errors @todo clean this up, these extra steps are not really correct in terms of how the algorithm is supposed to work
// must be rebuilt when 517 is out
#define WALLS_FOV_CASCADE_3A "3a"
#define WALLS_FOV_CASCADE_4A "4a"
#define WALLS_FOV_CASCADE_6A "6a"
#define WALLS_FOV_CASCADE_7A "7a"
#define WALLS_FOV_CASCADE_7B "7b"
#define WALLS_FOV_CASCADE_7C "7c"

//#define DYN_SHADOWS_ENABLED // uncomment for local testing, - see private shadows.dm
