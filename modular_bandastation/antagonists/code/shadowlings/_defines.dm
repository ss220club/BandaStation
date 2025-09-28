#define ROLE_SHADOWLING "shadowlings"
#define SPECIES_SHADOWLING "shadowling"
#define SPECIES_SHADOWLING_ASCENDED "shadowlingascended"
#define ORGAN_SLOT_BRAIN_THRALL "brain_thrall_tumor"

#define SHADOWLING_LIGHT_THRESHOLD 0.35
#define SHADOWLING_DIM_THRESHOLD   0.1

// Light DAMAGE modifiers
#define SHADOWLING_BRIGHT_BURN_PER_LIMB 2
#define SHADOWLING_BRIGHT_BRUTE_PER_LIMB 2
// Dark HEALING modifiers
#define SHADOWLING_DARK_HEAL_PER_LIMB_DEEP 4.0
#define SHADOWLING_DARK_HEAL_PER_LIMB_DIM  0.75

GLOBAL_VAR_INIT(is_shadowling_roundender_started, FALSE)

#define SHADOWLING_RISEN_MUSIC 'modular_bandastation/antagonists/sound/shadowlings/shadowling_ascend.ogg'

#define isshadowling(A) (is_species(A, /datum/species/shadow/shadowling))
#define isshadowling_ascended(A) (is_species(A, /datum/species/shadow/shadowling/ascended))
#define GET_BODYPART_COEFFICIENT(X) round(X.len / BODYPARTS_DEFAULT_MAXIMUM , 0.1)
/// Percent of thralls from crew needed to ascend
#define SHADOWLING_ASCEND_DEFAULT_PERCENT 25
/// Base health for ascended Shadowling
#define SHADOWLING_ASCENDED_MAX_HEALTH 220

/// Abilities for roundstart Shadowlings
GLOBAL_LIST_INIT(shadowling_base_abilities, list(
	/datum/action/cooldown/shadowling/commune,
	/datum/action/cooldown/shadowling/enthrall,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/glare,
	/datum/action/cooldown/shadowling/cold_wave,
	/datum/action/cooldown/shadowling/shadow_phase,
	/datum/action/cooldown/shadowling/veil,
	/datum/action/cooldown/shadowling/shreek,
	/datum/action/cooldown/shadowling/shadow_smoke,
	/datum/action/cooldown/shadowling/labyrinth,
	/datum/action/cooldown/shadowling/recuperation,
	/datum/action/cooldown/shadowling/election,
	/datum/action/cooldown/shadowling/ascend,
))

/// Abilities for Shadow thralls
GLOBAL_LIST_INIT(shadowling_thrall_abilities, list(
	/datum/action/cooldown/shadowling/hive_sync,
	/datum/action/cooldown/shadowling/commune,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/stealth,
))

/// Abilities for lesser Shadowlings
GLOBAL_LIST_INIT(shadowling_lesser_abilities, list(
	/datum/action/cooldown/shadowling/commune,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/glare,
	/datum/action/cooldown/shadowling/cold_wave,
	/datum/action/cooldown/shadowling/shadow_phase,
	/datum/action/cooldown/shadowling/shreek,
))

/// Abilities for ascended Shadowlings
GLOBAL_LIST_INIT(shadowling_ascended_abilities, list(
	/datum/action/cooldown/shadowling/commune,
	/datum/action/cooldown/shadowling/enthrall,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/glare,
	/datum/action/cooldown/shadowling/root,
	/datum/action/cooldown/shadowling/cold_wave,
	/datum/action/cooldown/shadowling/shadow_phase,
	/datum/action/cooldown/shadowling/veil,
	/datum/action/cooldown/shadowling/shreek,
	/datum/action/cooldown/shadowling/shadow_grab,
	/datum/action/cooldown/shadowling/shadow_strike,
	/datum/action/cooldown/shadowling/shadow_smoke,
	/datum/action/cooldown/shadowling/labyrinth,
	/datum/action/cooldown/shadowling/hook,
	/datum/action/cooldown/shadowling/recuperation,
))
