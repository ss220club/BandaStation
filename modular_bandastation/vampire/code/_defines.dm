#define SUBCLASS_HEMOMANCER /datum/vampire_subclass/hemomancer
#define SUBCLASS_GARGANTUA /datum/vampire_subclass/gargantua
#define SUBCLASS_UMBRAE /datum/vampire_subclass/umbrae
#define SUBCLASS_DANTALION /datum/vampire_subclass/dantalion
#define SUBCLASS_ANCIENT /datum/vampire_subclass/ancient

#define BLOOD_DRAIN_LIMIT 200 // the amount of blood a vampire can drain from a person.
#define FULLPOWER_DRAINED_REQUIREMENT 8 // the number of people you need to suck to become full powered.
#define FULLPOWER_BLOODTOTAL_REQUIREMENT 1000 // the amount of blood you need to suck to get full power.

#define VAMPIRE_NULLIFICATION_CAP 120 // the maximum amount a vampire can be nullified naturally.
#define VAMPIRE_COMPLETE_NULLIFICATION 100 // the point of nullification where vampires can no longer use abilities.

#define ROLE_VAMPIRE "Vampire"
#define HUD_MOB_VAMPIRE_BLOOD "mob_vampire_blood"

/// Sent to a vampire spell to deduct its configured blood cost.
#define COMSIG_VAMPIRE_ABILITY_DEDUCT_BLOOD "vampire_ability_deduct_blood"
/// Requests a vampire spell consume blood: (blood_amount)
#define COMSIG_VAMPIRE_ABILITY_CONSUME_BLOOD "vampire_ability_consume_blood"
	#define COMPONENT_VAMPIRE_ABILITY_BLOOD_CONSUMED (1<<0)
/// Requests the owner's rejuvenation multiplier: (pointer/multiplier_ref), written synchronously through the pointer.
#define COMSIG_VAMPIRE_ABILITY_GET_REJUV_MULT "vampire_ability_get_rejuv_mult"
/// Toggles a vampire passive: (passive_type)
#define COMSIG_VAMPIRE_ABILITY_TOGGLE_PASSIVE "vampire_ability_toggle_passive"
/// Marks the vampire's lair and removes the spell which created it.
#define COMSIG_VAMPIRE_ABILITY_COMPLETE_LAIR "vampire_ability_complete_lair"
/// Checks whether the vampire can enthrall another target.
#define COMSIG_VAMPIRE_ABILITY_CAN_ENTHRALL "vampire_ability_can_enthrall"
	#define COMPONENT_VAMPIRE_ABILITY_CAN_ENTHRALL (1<<1)
/// Makes a target into the vampire's thrall: (mob/living/carbon/human/target)
#define COMSIG_VAMPIRE_ABILITY_ENTHRALL "vampire_ability_enthrall"
	#define COMPONENT_VAMPIRE_ABILITY_ENTHRALLED (1<<2)
/// Adds the vampire's thralls in range to a target list: (atom/center, range, list/targets)
#define COMSIG_VAMPIRE_ABILITY_GET_THRALLS_IN_RANGE "vampire_ability_get_thralls_in_range"
/// Toggles the blood bond status effect on the spell owner.
#define COMSIG_VAMPIRE_ABILITY_TOGGLE_THRALL_NET "vampire_ability_toggle_thrall_net"
/// Toggles cloak state on the vampire.
#define COMSIG_VAMPIRE_ABILITY_TOGGLE_CLOAK "vampire_ability_toggle_cloak"
	#define COMPONENT_VAMPIRE_ABILITY_CLOAK_TOGGLED (1<<3)
	#define COMPONENT_VAMPIRE_ABILITY_CLOAK_ENABLED (1<<4)
/// Disables cloak state on the vampire.
#define COMSIG_VAMPIRE_ABILITY_DISABLE_CLOAK "vampire_ability_disable_cloak"
/// Updates the vampire cloak in response to its owner being ignited: (mob/living/user)
#define COMSIG_VAMPIRE_ABILITY_UPDATE_CLOAK "vampire_ability_update_cloak"
/// Toggles Blood Spill on a vampire owner.
#define COMSIG_VAMPIRE_OWNER_TOGGLE_BLOOD_SPILL "vampire_owner_toggle_blood_spill"
/// Toggles Eternal Darkness on a vampire owner.
#define COMSIG_VAMPIRE_OWNER_TOGGLE_ETERNAL_DARKNESS "vampire_owner_toggle_eternal_darkness"
/// Adds the vampire network members visible to this owner to a recipient list: (list/recipients)
#define COMSIG_VAMPIRE_NETWORK_GET_RECIPIENTS "vampire_network_get_recipients"
/// From /datum/status_effect/incapacitating/sleeping/tick(): (seconds_between_ticks)
#define COMSIG_LIVING_STATUS_SLEEP_TICK "living_sleeping_tick"
