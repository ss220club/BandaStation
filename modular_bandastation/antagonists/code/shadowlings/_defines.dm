#define SPECIES_SHADOWLING "shadow"

#define ORGAN_SLOT_BRAIN_THRALL "brain_thrall_tumor"

#define L_BRIGHT 0.75
#define L_DIM    0.40

#define TIER_T0 0
#define TIER_T1 1
#define TIER_T2 2
#define TIER_T3 3
#define TIER_T4 4
#define TIER_T5 5

#define SHADOWLING_LIGHT_THRESHOLD 0.75
#define SHADOWLING_DIM_THRESHOLD   0.40

#define SHADOWLING_BRIGHT_BURN_PER_LIMB 2     // было 1 → станет больнее на ярком свете
#define SHADOWLING_BRIGHT_BRUTE_PER_LIMB 2
#define SHADOWLING_DARK_HEAL_PER_LIMB_DEEP 4.0 // было 0.5 → быстрее реген в глубокой тьме
#define SHADOWLING_DARK_HEAL_PER_LIMB_DIM  0.75 // лёгкий бонус в полутьме, можно =0.5

#define GET_BODYPART_COEFFICIENT(X) round(X.len / BODYPARTS_DEFAULT_MAXIMUM , 0.1)

// минималка, чтобы всё заработало; дополняй своими спеллами
var/global/list/SHADOWLING_TIER_ABILITIES = list(
	TIER_T0 = list(
		/datum/action/cooldown/shadowling/hive_sync,
	),
	TIER_T1 = list(),
	TIER_T2 = list(),
	TIER_T3 = list(),
	TIER_T4 = list(),
	TIER_T5 = list(),
)

// что давать траллам (обычно — «Взор» и т.п.). Пока пусто.
var/global/list/SHADOWLING_THRALL_ABILITIES = list(
	/datum/action/cooldown/shadowling/hive_sync, // можно и траллам, если хочешь
)
