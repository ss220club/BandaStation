/// Paradise IPC upgrades use TG organ slots, damage, physiology and limb attachment.
/obj/item/organ/cyberimp/chest/ipc_upgrade
	name = "IPC chassis upgrade"
	desc = "An upgrade designed exclusively for an integrated positronic chassis."
	abstract_type = /obj/item/organ/cyberimp/chest/ipc_upgrade
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6.25, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 6, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 1.25, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5)

/obj/item/organ/cyberimp/chest/ipc_upgrade/can_insert_into(mob/living/carbon/receiver, special, movement_flags)
	return ..() && is_species(receiver, /datum/species/ipc)

/obj/item/organ/cyberimp/chest/ipc_upgrade/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_SPECIES_LOSS, PROC_REF(on_species_loss))

/obj/item/organ/cyberimp/chest/ipc_upgrade/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	UnregisterSignal(organ_owner, COMSIG_SPECIES_LOSS)
	return ..()

/// Changing species must remove the upgrade's effects before the organic body is regenerated.
/obj/item/organ/cyberimp/chest/ipc_upgrade/proc/on_species_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	Remove(source, special = TRUE)
	forceMove(source.drop_location())

/obj/item/organ/cyberimp/chest/ipc_upgrade/proc/is_operational()
	return owner && is_species(owner, /datum/species/ipc) && !(organ_flags & (ORGAN_FAILING | ORGAN_EMP))

/obj/item/organ/cyberimp/chest/ipc_upgrade/repair
	name = "reactive repair implant"
	desc = "Repairs a positronic chassis using battery power. Continuous monitoring also consumes a small amount of charge."
	icon_state = "reviver_implant"
	slot = ORGAN_SLOT_STOMACH_AID
	/// Preserve sub-precision work when a life interval is split into shorter ticks.
	var/repair_remainder = 0
	COOLDOWN_DECLARE(emp_cooldown)

/obj/item/organ/cyberimp/chest/ipc_upgrade/repair/on_life(seconds_per_tick)
	. = ..()
	if(!is_operational() || !COOLDOWN_FINISHED(src, emp_cooldown))
		return
	var/obj/item/organ/heart/ipc/battery = owner.get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(battery) || (battery.organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		return
	var/needs_repair = owner.get_brute_loss_for_type(BODYTYPE_ROBOTIC) || owner.get_fire_loss_for_type(BODYTYPE_ROBOTIC)
	// Paradise's on_life rates are per two-second life tick.
	var/power_cost = (needs_repair ? 1 : 0.125) * seconds_per_tick
	if(owner.nutrition < power_cost)
		return
	battery.adjust_charge(-power_cost)
	if(needs_repair)
		repair_remainder += 0.25 * seconds_per_tick
		var/healing_amount = round(repair_remainder, DAMAGE_PRECISION)
		repair_remainder -= healing_amount
		owner.heal_overall_damage(brute = healing_amount, burn = healing_amount, required_bodytype = BODYTYPE_ROBOTIC)
	else
		repair_remainder = 0

/obj/item/organ/cyberimp/chest/ipc_upgrade/repair/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	COOLDOWN_START(src, emp_cooldown, 30 SECONDS / severity)

/// Whole-frame joint systems share the native spinal implant slot and cannot stack.
/obj/item/organ/cyberimp/chest/ipc_upgrade/joints
	name = "IPC joint implant"
	abstract_type = /obj/item/organ/cyberimp/chest/ipc_upgrade/joints
	icon_state = "herculean_implant"
	slot = ORGAN_SLOT_SPINE

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/magnetic
	name = "magnetic joints implant"
	desc = "Magnetic joints allow robotic limbs to be snapped back into place by hand. An EMP disconnects them."
	organ_traits = list(TRAIT_LIMBATTACHMENT)

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/magnetic/emp_act(severity)
	. = ..()
	if(!is_operational() || (. & EMP_PROTECT_SELF))
		return
	to_chat(owner, span_userdanger("Магнитные крепления обесточены!"))
	// Dropping a head or arm changes the owner's bodypart list while it is iterated.
	var/list/limbs = owner.get_bodyparts().Copy()
	for(var/obj/item/bodypart/limb as anything in limbs)
		if(limb.body_zone != BODY_ZONE_CHEST && IS_ROBOTIC_LIMB(limb))
			limb.drop_limb()

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/sealed
	name = "sealed joints implant"
	desc = "Reinforced joint seals prevent dismemberment but increase stamina damage by 15%. An EMP locks the joints."
	organ_traits = list(TRAIT_NODISMEMBER)

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/sealed/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	MODIFY_PHYSIOLOGY(organ_owner, STAMINA, 1.15)

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/sealed/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	MODIFY_PHYSIOLOGY(organ_owner, STAMINA, 1 / 1.15)
	return ..()

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/sealed/emp_act(severity)
	. = ..()
	if(!is_operational() || (. & EMP_PROTECT_SELF))
		return
	owner.Paralyze(severity == EMP_HEAVY ? 20 SECONDS : 10 SECONDS)
	to_chat(owner, span_warning("Герметичные суставы заблокированы электромагнитным импульсом!"))

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/emp_shield
	name = "electromagnetic shielding implant"
	desc = "Conductive chassis shielding reduces the severity of EMPs without making the chassis immune."

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/emp_shield/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	organ_owner.emp_protection += EMP_PROTECTION_MODERATE

/obj/item/organ/cyberimp/chest/ipc_upgrade/joints/emp_shield/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	organ_owner.emp_protection -= EMP_PROTECTION_MODERATE
	return ..()

/// A taste processor accepts food as waste, preserving the chassis' immunity and electrical power economy.
/obj/item/organ/stomach/ipc_culinary
	name = "culinary processing implant"
	desc = "A robotic food processor that lets a positronic chassis eat and experience flavor. Food does not recharge its battery."
	icon_state = "stomach-c"
	organ_flags = ORGAN_ROBOTIC
	healing_factor = 0
	decay_factor = 0
	food_reagents = null
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT / 2, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT / 2, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT / 2)
	/// The current tongue's own taste configuration must survive removal or replacement.
	var/obj/item/organ/tongue/flavor_tongue
	var/previous_taste
	var/previous_ageusia

/obj/item/organ/stomach/ipc_culinary/can_insert_into(mob/living/carbon/receiver, special, movement_flags)
	return ..() && is_species(receiver, /datum/species/ipc)

/obj/item/organ/stomach/ipc_culinary/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignals(organ_owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN), PROC_REF(on_organs_changed))
	RegisterSignal(organ_owner, COMSIG_SPECIES_LOSS, PROC_REF(on_species_loss))
	update_taste()

/obj/item/organ/stomach/ipc_culinary/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	restore_taste()
	UnregisterSignal(organ_owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN, COMSIG_SPECIES_LOSS))
	return ..()

/obj/item/organ/stomach/ipc_culinary/proc/on_species_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	Remove(source, special = TRUE)
	forceMove(source.drop_location())

/obj/item/organ/stomach/ipc_culinary/proc/on_organs_changed(mob/living/carbon/source, obj/item/organ/changed_organ)
	SIGNAL_HANDLER
	if(changed_organ.slot == ORGAN_SLOT_TONGUE)
		update_taste()

/obj/item/organ/stomach/ipc_culinary/proc/is_operational()
	return owner && is_species(owner, /datum/species/ipc) && !(organ_flags & (ORGAN_FAILING | ORGAN_EMP))

/obj/item/organ/stomach/ipc_culinary/proc/update_taste()
	var/obj/item/organ/tongue/current_tongue = owner?.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!is_operational())
		restore_taste()
		return
	if(current_tongue == flavor_tongue)
		return
	restore_taste()
	if(!current_tongue)
		return
	flavor_tongue = current_tongue
	previous_taste = flavor_tongue.sense_of_taste
	previous_ageusia = TRAIT_AGEUSIA in flavor_tongue.organ_traits
	flavor_tongue.sense_of_taste = TRUE
	if(!(flavor_tongue.organ_flags & ORGAN_FAILING))
		flavor_tongue.remove_organ_trait(TRAIT_AGEUSIA)

/obj/item/organ/stomach/ipc_culinary/proc/restore_taste()
	if(!QDELETED(flavor_tongue))
		flavor_tongue.sense_of_taste = previous_taste
		if(previous_ageusia || (flavor_tongue.organ_flags & ORGAN_FAILING))
			flavor_tongue.add_organ_trait(TRAIT_AGEUSIA)
	flavor_tongue = null

/obj/item/organ/stomach/ipc_culinary/on_life(seconds_per_tick)
	// Never move food chemicals to a synthetic bloodstream or convert nutriment into electrical charge.
	reagents.clear_reagents()
	. = ..()
	update_taste()

/// Chemical immunity rejects the normal reagent transfer; consume the bite after the native taste/mood checks.
/obj/item/organ/stomach/ipc_culinary/after_eat(atom/edible, mob/living/feeder)
	. = ..()
	if(QDELETED(edible))
		return
	var/datum/component/edible/food = edible.GetComponent(/datum/component/edible)
	if(!food || !consume_flavor(edible, food.bite_consumption))
		return
	if(!edible.reagents.total_volume)
		food.On_Consume(owner, feeder)

/// Oral intake keeps taste and source consumption, without creating or exposing any chemicals in the body.
/obj/item/organ/stomach/ipc_culinary/proc/consume_flavor(atom/source, amount)
	if(!is_operational() || !HAS_TRAIT(owner, TRAIT_REAGENT_IMMUNE) || QDELETED(source) || !source.reagents?.total_volume)
		return 0
	var/consumed = clamp(amount, 0, source.reagents.total_volume)
	if(!consumed)
		return 0
	owner.taste_container(source.reagents)
	return source.reagents.remove_all(consumed)

/obj/item/organ/stomach/ipc_culinary/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(severity == EMP_HEAVY ? 20 : 7)
	update_taste()

/obj/item/organ/stomach/ipc_culinary/on_begin_failure()
	. = ..()
	restore_taste()

/obj/item/organ/stomach/ipc_culinary/on_failure_recovery()
	. = ..()
	update_taste()

/datum/design/ipc_upgrade_repair
	name = "IPC Reactive Repair Implant"
	build_type = MECHFAB
	build_path = /obj/item/organ/cyberimp/chest/ipc_upgrade/repair
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6.25, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 6, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 1.25, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_UTILITY)
	research_icon = 'icons/obj/medical/organs/organs.dmi'
	research_icon_state = "reviver_implant"

/datum/design/ipc_upgrade_magnetic
	parent_type = /datum/design/ipc_upgrade_repair
	name = "IPC Magnetic Joints Implant"
	build_path = /obj/item/organ/cyberimp/chest/ipc_upgrade/joints/magnetic
	research_icon_state = "herculean_implant"

/datum/design/ipc_upgrade_sealed
	parent_type = /datum/design/ipc_upgrade_repair
	name = "IPC Sealed Joints Implant"
	build_path = /obj/item/organ/cyberimp/chest/ipc_upgrade/joints/sealed
	research_icon_state = "herculean_implant"

/datum/design/ipc_upgrade_emp_shield
	parent_type = /datum/design/ipc_upgrade_repair
	name = "IPC Electromagnetic Shielding Implant"
	build_path = /obj/item/organ/cyberimp/chest/ipc_upgrade/joints/emp_shield
	research_icon_state = "herculean_implant"

/datum/design/ipc_upgrade_culinary
	name = "IPC Culinary Processing Implant"
	build_type = MECHFAB
	build_path = /obj/item/organ/stomach/ipc_culinary
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT / 2, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT / 2, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT / 2)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_UTILITY)
	research_icon = 'icons/obj/medical/organs/organs.dmi'
	research_icon_state = "stomach-c"

/datum/techweb_node/cyber/ipc_upgrades
	display_name = "Улучшения КПБ"
	description = "Специализированные системы ремонта, защиты и обработки пищи для позитронных шасси."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(
		/datum/design/ipc_upgrade_repair,
		/datum/design/ipc_upgrade_magnetic,
		/datum/design/ipc_upgrade_sealed,
		/datum/design/ipc_upgrade_emp_shield,
		/datum/design/ipc_upgrade_culinary,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
