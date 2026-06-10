//not technically a mob but ehh, close enough
/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = SPECIES_GOLEM_CLOCKWORK
	meat = /obj/item/stack/sheet/bronze
	fixed_mut_color = rgb(190, 135, 0)
	examine_limb_id = SPECIES_GOLEM
	// Monkestation-specific display vars; declared locally as they don't exist on base BandaStation golem species
	var/info_text = "As a <span class='bigbrass'>Clockwork Golem</span>, most scriptures will take less time for you to invoke. You are also faster than most golems."
	var/prefix = "Clockwork"
	var/special_names = null
	var/armor = 70

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/our_mob, datum/species/old_species, pref_load)
	. = ..()
	ADD_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	// turf_healing component not available in BandaStation; healing on brass/reebe turfs skipped

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/our_mob, datum/species/new_species, pref_load)
	REMOVE_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	. = ..()
