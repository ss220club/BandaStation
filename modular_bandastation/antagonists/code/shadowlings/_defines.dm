#define ROLE_SHADOWLING "shadowlings"
#define SPECIES_SHADOWLING "shadowling"
#define SPECIES_SHADOWLING_ASCENDED "shadowlingascended"
#define ORGAN_SLOT_BRAIN_THRALL "brain_thrall_tumor"

#define SHADOWLING_LIGHT_THRESHOLD 0.55
#define SHADOWLING_DIM_THRESHOLD   0.20

#define SHADOWLING_BRIGHT_BURN_PER_LIMB 2     // модификаторы получения урона на свету
#define SHADOWLING_BRIGHT_BRUTE_PER_LIMB 2
#define SHADOWLING_DARK_HEAL_PER_LIMB_DEEP 4.0 // модификатор отхила если темно
#define SHADOWLING_DARK_HEAL_PER_LIMB_DIM  0.75 // модификатор отхила в полутьме

#define isshadowling(A) (is_species(A, /datum/species/shadow/shadowling))

#define GET_BODYPART_COEFFICIENT(X) round(X.len / BODYPARTS_DEFAULT_MAXIMUM , 0.1)

//Абилки для раундстарт линга
var/global/list/SHADOWLING_BASE_ABILITIES = list(
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
	/datum/action/cooldown/shadowling/recuperation,
	/datum/action/cooldown/shadowling/election,
	/datum/action/cooldown/shadowling/hook,
	/datum/action/cooldown/shadowling/ascend
)

//Абилки для тралла
var/global/list/SHADOWLING_THRALL_ABILITIES = list(
	/datum/action/cooldown/shadowling/hive_sync,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/stealth
)

//Абилки для тралла-линга
var/global/list/SHADOWLING_MINOR_ABILITIES = list(
	/datum/action/cooldown/shadowling/hive_sync,
	/datum/action/cooldown/shadowling/toggle_night_vision,
	/datum/action/cooldown/shadowling/root,
	/datum/action/cooldown/shadowling/cold_wave,
	/datum/action/cooldown/shadowling/shadow_phase,
	/datum/action/cooldown/shadowling/veil,
	/datum/action/cooldown/shadowling/shreek,
	/datum/action/cooldown/shadowling/shadow_grab,
	/datum/action/cooldown/shadowling/shadow_smoke,
	/datum/action/cooldown/shadowling/labyrinth
)

//Абилки для возвышенного
var/global/list/SHADOWLING_ASCENDED_ABILITIES = list(
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
	/datum/action/cooldown/shadowling/recuperation
)
