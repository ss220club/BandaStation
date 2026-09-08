///Uses the parent limb's drawcolor value.
#define ORGAN_COLOR_INHERIT (1<<0)
///Uses /organ/external/proc/override_color()'s return value
#define ORGAN_COLOR_OVERRIDE (1<<1)
///Uses the parent's haircolor
#define ORGAN_COLOR_HAIR (1<<2)

/// BANDASTATION ADDITION START - Species
///Uses feature by `dna_color_feature_key`
#define ORGAN_COLOR_FEATURE (1<<3)
/// BANDASTATION ADDITION END - Species

///Tail wagging
#define WAG_ABLE (1<<0)
#define WAG_WAGGING (1<<1)

/// Tail spine defines
#define SPINE_KEY_LIZARD "lizard"

//wing flight defines
///can't generate lift, will only fly in 0G, while atmos is present
#define WINGS_FLIGHTLESS 1
///can generate lift and fly if atmos is present
#define WINGS_AIRWORTHY 2
///can fly regardless of atmos
#define WINGS_MAGIC 3
