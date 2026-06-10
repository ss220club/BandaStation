// ========================
// CLOCK CULT DEFINES
// Ported from Monkestation2.0
// ========================

// --- Spell types ---
#define SPELLTYPE_ABSTRACT "Abstract"
#define SPELLTYPE_SERVITUDE "Servitude"
#define SPELLTYPE_PRESERVATION "Preservation"
#define SPELLTYPE_STRUCTURES "Structures"

// --- Power / sigil ---
#define SIGIL_TRANSMISSION_RANGE 4
#define CLOCK_PASSIVE_POWER_PER_COG 3
#define CLOCK_MAX_POWER_PER_COG STANDARD_CELL_CHARGE * 0.05
#define MAX_CLOCK_VITALITY 400

// --- Ark states ---
/// Base state the ark is created in
#define ARK_STATE_BASE 0
/// Grace period after enough members + active anchoring crystals
#define ARK_STATE_CHARGING 1
/// After cult has been announced, portals preparing
#define ARK_STATE_GRACE 2
/// First half of the assault
#define ARK_STATE_ACTIVE 3
/// Halfway point of ark activation
#define ARK_STATE_SUMMONING 4
/// Ark has finished opening or been destroyed
#define ARK_STATE_FINAL 5

// --- Structure damage ---
#define MAX_IMPORTANT_CLOCK_DAMAGE 30

// --- Anchoring ---
#define ANCHORING_CRYSTALS_TO_SUMMON 2
#define ANCHORING_CRYSTAL_CHARGE_DURATION 360 SECONDS
#define ANCHORING_CRYSTAL_COOLDOWN ANCHORING_CRYSTAL_CHARGE_DURATION + 1 MINUTES

// --- Map ---
#define REEBE_MAP_PATH "_maps/modular_bandastation/templates/reebe.dmm"

// --- Misc ---
#define ARK_TURF_DESTRUCTION_BLOCK_RANGE 10
#define MAXIMUM_REEBE_AIRLOCKS 50
#define MAXIMUM_COGSCARABS 6

// --- Faction ---
#define FACTION_CLOCK "clock"

// --- Role ---
#define ROLE_CLOCK_CULTIST "Clock Cultist"

// --- Type checks ---
#define IS_CLOCK(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist) || (FACTION_CLOCK in mob.faction))
#define iscogscarab(checked) (istype(checked, /mob/living/basic/drone/cogscarab))
#define iseminence(checked) (istype(checked, /mob/living/eminence))

// --- Span macros ---
#define span_ratvar(str) ("<span class='ratvar'>" + str + "</span>")
#define span_brass(str) ("<span class='brass'>" + str + "</span>")
#define span_bigbrass(str) ("<span class='big_brass'>" + str + "</span>")
#define span_clockyellow(str) ("<span class='clockyellow'>" + str + "</span>")

// --- Antag datum compatibility (Monkestation vars not in BandaStation base) ---
/// Antag cap counts the team as one unit, not individual members
#define FLAG_ANTAG_CAP_TEAM (1 << 3)
/// Antag ignores the antag cap entirely
#define FLAG_ANTAG_CAP_IGNORE (1 << 2)
/// Antag ignores the humanity check in antag cap
#define FLAG_ANTAG_CAP_IGNORE_HUMANITY (1 << 5)

// --- Inventory slot compatibility ---
/// BandaStation uses ITEM_SLOT_BACK; alias for Monkestation code
#define ITEM_SLOT_BACKPACK ITEM_SLOT_BACK

// --- Bot panel flags ---
#define BOT_MAINTS_PANEL_OPEN BOT_COVER_MAINTS_OPEN
#define BOT_CONTROL_PANEL_OPEN BOT_COVER_LOCKED

// --- Area flags ---
/// BandaStation has no abductor proofed areas; evaluates to 0 so the check always fails harmlessly
#define ABDUCTOR_PROOF 0

// --- Mecha cooldown IDs ---
#define COOLDOWN_MECHA_JUDICIAL_MARK "mecha_judicial_mark"
#define COOLDOWN_MECHA_STEAM_DISCHARGE "mecha_steam_discharge"

// --- Time ---
#define ROUND_TIME_TICKS (world.time - SSticker.round_start_time)

// --- Weakref macro ---
/// Set weakref_var to null if it fails to resolve, resolver should be the var looking to resolve the weakref
#define WEAKREF_NULL_IF_UNRESOLVED(weakref_var, resolver) weakref_var?.resolve();\
	if(!##resolver) { \
		##weakref_var = null;\
	}

// --- Signals ---
/// Sent from /obj/item/clockwork_slab when it is used; source = slab
#define COMSIG_CLOCKWORK_SLAB_USED "clockwork_slab_used"
/// Sent to atoms that receive a clockwork signal
#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clock_received"
/// Sent to atoms affected by Rat'var's direct action
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
/// Sent to atoms affected by the Eminence
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"
/// Sent to check whether a turf counts as clockwork
#define COMSIG_CHECK_TURF_CLOCKWORK "check_turf_clockwork"
/// Sent when an anchoring crystal finishes charging
#define COMSIG_ANCHORING_CRYSTAL_CHARGED "anchoring_crystal_charged"
/// Sent when an anchoring crystal is first created
#define COMSIG_ANCHORING_CRYSTAL_CREATED "anchoring_crystal_created"

// --- Species ---
/// Species ID for clockwork golems (Monkestation DNA.dm)
#define SPECIES_GOLEM_CLOCKWORK "clock_golem"

// --- Traits (Monkestation-specific) ---
/// Grants faster invocation time on slab scriptures
#define TRAIT_FASTER_SLAB_INVOKE "faster_slab_invoke"
/// Prevents a mob from using the clockwork slab
#define TRAIT_NO_SLAB_INVOKE "no_slab_invoke"
/// Source trait for Vanguard scripture active effect
#define VANGUARD_TRAIT "vanguard"
/// Prevents movement speed penalty from damage
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"

// --- Colors ---
/// Brass/clockwork gold color used for Ratvar effects
#define LIGHT_COLOR_CLOCKWORK "#BE8700"

// --- Wall deconstruction states ---
#define COVER_COG_REMOVED 1
#define TRANSMISSION_COGS_REMOVED 2
#define GEARS_UNBOLTED 3
#define INNER_PANEL_REMOVED 4
#define GEARS_UNWOUND 5

// --- Security levels ---
/// Ratvar endgame alert; maps to the highest level BandaStation has (DELTA)
#define SEC_LEVEL_LAMBDA SEC_LEVEL_DELTA

// --- Damage types ---
/// Clone damage (Monkestation extension to base combat.dm)
#define CLONE "clone"

// --- Z-level traits ---
/// Z-level trait identifying the Reebe pocket dimension
#define ZTRAIT_REEBE "reebe"
/// Check if a given Z coordinate belongs to the Reebe dimension
#define is_reebe_level(z) SSmapping.level_trait(z, ZTRAIT_REEBE)
/// Passed to add_new_zlevel() as the traits list for the Reebe Z-level
#define ZTRAITS_REEBE list(ZTRAIT_REEBE = TRUE, \
						ZTRAIT_NOPHASE = TRUE, \
						ZTRAIT_BOMBCAP_MULTIPLIER = 0.5, \
						ZTRAIT_RESERVED = TRUE, \
						ZTRAIT_BASETURF = /turf/open/indestructible/reebe_flooring)

// --- Supply pod styles ---
/// Centcom-style supply pod (used by send_station_support_package)
#define STYLE_CENTCOM /datum/pod_style/centcom

// --- Click cooldowns ---
/// Attack speed for large two-handed weapons (maps to CLICK_CD_SLOW in BandaStation)
#define CLICK_CD_LARGE_WEAPON CLICK_CD_SLOW

// --- Turf checker component ---
/// Signal return flag when item is on a valid (brass) turf; component not in BandaStation so check_turf() always returns 0
#define COMPONENT_CHECKER_VALID_TURF (1<<0)

// --- Span macros ---
/// Gray clockwork text used for goggles/visor messages
#define span_clockgray(str) ("<span class='clockgray'>" + str + "</span>")

// --- Access levels ---
/// Custom access for clock cult airlocks; value chosen to not conflict with existing BandaStation access levels
#define ACCESS_CLOCKCULT 201

// --- Clothing flags ---
/// Stub: BandaStation does not have a plasmaman survival system; evaluates to 0 so the flag is inert
#define PLASMAMAN_HELMET_EXEMPT 0

// --- Audio mixer channels ---
/// Stub: BandaStation has no mixer channel system; use as null in playsound calls
#define CHANNEL_SOUND_EFFECTS null

// --- Layer ---
/// Layer for sigil/pressure-sensor traps (on the floor, below objects)
#define SIGIL_LAYER BELOW_OBJ_LAYER

// --- Stargazer traits ---
#define STARGAZER_TRAIT "stargazer"
#define TRAIT_STARGAZED "clockwork_stargazed"

// --- Additional span macros ---
#define span_clockred(str) ("<span class='clockred'>" + str + "</span>")

// --- Ghost notify (NOTIFY_PLAY not in BandaStation; ignored) ---
#define NOTIFY_PLAY null

// --- Status effect shorthand (BandaStation uses type paths directly) ---
#define STATUS_EFFECT_INTERDICTION /datum/status_effect/interdiction

// --- Atom flags compat ---
/// NODECONSTRUCT_1 not defined in BandaStation; using 0 so the check always permits deconstruct logic
#define NODECONSTRUCT_1 0

// --- Traits (BandaStation stubs) ---
/// Trait preventing a mob from being turned into a borg; stubbed - trait never set so check is always false
#define TRAIT_UNBORGABLE "unborgable"
