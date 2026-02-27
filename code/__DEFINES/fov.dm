/// Field of vision defines.
#define FOV_90_DEGREES 90
#define FOV_180_DEGREES 180
#define FOV_270_DEGREES 270
#define FOV_REVERSE_90_DEGREES -90
#define FOV_REVERSE_180_DEGREES -180
#define FOV_REVERSE_270_DEGREES -270
#define FOV_145_DEGREES 145 // BANDASTATION ADDITION: FOV
#define FOV_REVERSE_145_DEGREES -145 // BANDASTATION ADDITION: FOV

/// Base mask dimensions. They're like a client's view, only change them if you modify the mask to different dimensions.
#define BASE_FOV_MASK_X_DIMENSION 15
#define BASE_FOV_MASK_Y_DIMENSION 15

/// Range at which FOV effects treat nearsightness as blind and play
#define NEARSIGHTNESS_FOV_BLINDNESS 2

// BANDASTATION ADDITION START: FOV
#define FOV_MASK_PIVOT_OFFSET_X 65
#define FOV_MASK_PIVOT_OFFSET_Y 0

#define FOV_MASK_SCALE 1.2
/// cardinal texture offsets for interpolation (angle 0=S, 90=W, 180=N, 270=E)
#define FOV_MASK_CARDINAL_SOUTH_X 15
#define FOV_MASK_CARDINAL_SOUTH_Y 25
#define FOV_MASK_CARDINAL_WEST_X 20
#define FOV_MASK_CARDINAL_WEST_Y 15
#define FOV_MASK_CARDINAL_NORTH_X 15
#define FOV_MASK_CARDINAL_NORTH_Y 0
#define FOV_MASK_CARDINAL_EAST_X 10
#define FOV_MASK_CARDINAL_EAST_Y 15
/// combat cursor-follow: smoothing factor (1 = instant), update interval in ds
#define FOV_MASK_ANGLE_SMOOTHING_FACTOR 1
#define FOV_MASK_CURSOR_UPDATE_DS 0.2

#define FOV_MASK_ANIMATE_TIME 0.05
// BANDASTATION ADDITION END: FOV

//Fullscreen overlay resolution in tiles for the clients view.
/// The fullscreen overlay in tiles for x axis
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
/// The fullscreen overlay in tiles for y axis
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15
