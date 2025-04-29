/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Podperson"
	plural_form = "Podpeople"
	id = SPECIES_PODPERSON
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_PLANT_SAFE,
	)
	mutant_organs = list(
		/obj/item/organ/pod_hair = "None",
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)

	heatmod = 1.5
	payday_modifier = 1.0
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water
	exotic_bloodtype = BLOOD_TYPE_H2O
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant

	mutantappendix = /obj/item/organ/appendix/pod
	mutantbrain = /obj/item/organ/brain/pod
	mutantears = /obj/item/organ/ears/pod
	mutanteyes = /obj/item/organ/eyes/pod
	mutantheart = /obj/item/organ/heart/pod
	mutantliver = /obj/item/organ/liver/pod
	mutantlungs = /obj/item/organ/lungs/pod
	mutantstomach = /obj/item/organ/stomach/pod
	mutanttongue = /obj/item/organ/tongue/pod

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pod,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pod,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pod,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pod,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pod,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pod,
	)

/datum/species/pod/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(chem.type == /datum/reagent/toxin/plantbgone)
		affected.adjustToxLoss(3 * REM * seconds_per_tick)

/datum/species/pod/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = "#886600"
	human.dna.features["pod_hair"] = "Rose"
	human.update_body(is_creating = TRUE)

/datum/species/pod/get_physical_attributes()
	return "Podpeople are in many ways the inverse of shadows, healing in light and starving with the dark. \
		Their bodies are like tinder and easy to char."

/datum/species/pod/get_species_description()
	return "Podpeople are largely peaceful plant based lifeforms, resembling a humanoid figure made of leaves, flowers, and vines."

/datum/species/pod/get_species_lore()
	return list(
		"Not much is known about the origins of the Podpeople. \
		Many assume them to be the result of a long forgotten botanical experiment, slowly mutating for years on years until they became the beings they are today. \
		Ever since they were uncovered long ago, their kind have been found on board stations and planets across the galaxy, \
		often working in hydroponics bays, kitchens, or science departments, working with plants and other botanical lifeforms.",
	)

// BANDASTATION ADD START Podman-Emotion-Add
/datum/species/pod/get_scream_sound(mob/living/carbon/human/pod)
    if(pod.physique == MALE)
        return pick(
            'sound/mobs/humanoids/human/scream/malescream_1.ogg',
            'sound/mobs/humanoids/human/scream/malescream_2.ogg',
            'sound/mobs/humanoids/human/scream/malescream_3.ogg',
            'sound/mobs/humanoids/human/scream/malescream_4.ogg',
            'sound/mobs/humanoids/human/scream/malescream_5.ogg',
            'sound/mobs/humanoids/human/scream/malescream_6.ogg',
        )

    return pick(
        'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
        'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
        'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
        'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
        'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
    )

/datum/species/pod/get_cough_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return pick(
            'sound/mobs/humanoids/human/cough/female_cough1.ogg',
            'sound/mobs/humanoids/human/cough/female_cough2.ogg',
            'sound/mobs/humanoids/human/cough/female_cough3.ogg',
            'sound/mobs/humanoids/human/cough/female_cough4.ogg',
            'sound/mobs/humanoids/human/cough/female_cough5.ogg',
            'sound/mobs/humanoids/human/cough/female_cough6.ogg',
        )
    return pick(
        'sound/mobs/humanoids/human/cough/male_cough1.ogg',
        'sound/mobs/humanoids/human/cough/male_cough2.ogg',
        'sound/mobs/humanoids/human/cough/male_cough3.ogg',
        'sound/mobs/humanoids/human/cough/male_cough4.ogg',
        'sound/mobs/humanoids/human/cough/male_cough5.ogg',
        'sound/mobs/humanoids/human/cough/male_cough6.ogg',
    )

/datum/species/pod/get_cry_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return pick(
            'sound/mobs/humanoids/human/cry/female_cry1.ogg',
            'sound/mobs/humanoids/human/cry/female_cry2.ogg',
        )
    return pick(
        'sound/mobs/humanoids/human/cry/male_cry1.ogg',
        'sound/mobs/humanoids/human/cry/male_cry2.ogg',
        'sound/mobs/humanoids/human/cry/male_cry3.ogg',
    )

/datum/species/pod/get_laugh_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return pick(
            'sound/mobs/humanoids/human/laugh/womanlaugh.ogg',
        )
    return pick(
        'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
        'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
    )

/datum/species/pod/get_sneeze_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
    return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/pod/get_sniff_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
    return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/pod/get_sigh_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return SFX_FEMALE_SIGH
    return SFX_MALE_SIGH

/datum/species/pod/get_snore_sound(mob/living/carbon/human/pod)
    if(pod.physique == FEMALE)
        return SFX_SNORE_FEMALE
    return SFX_SNORE_MALE

/datum/species/pod/get_hiss_sound(mob/living/carbon/human/pod)
    return 'sound/mobs/humanoids/human/hiss/human_hiss.ogg'
// BANDASTATION ADD END Podman-Emotion-Add

/datum/species/pod/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "lightbulb",
		SPECIES_PERK_NAME = "Photosynthetic",
		SPECIES_PERK_DESC = "As long as you are conscious, and within a well-lit area, you will slowly heal brute, burn, toxin and oxygen damage and gain nutrition - and never get fat! \
		However, if you are LOW on nutrition, you will progressively take brute damage until you die or enter the light once more."
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Weedkiller Susceptability",
		SPECIES_PERK_DESC = "Being a floral life form, you are susceptable to anti-florals and will take extra toxin damage from it!"
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "briefcase-medical",
		SPECIES_PERK_NAME = "Semi-Complex Biology",
		SPECIES_PERK_DESC = "Your biology is extremely complex, making ordinary health scanners unable to scan you. Make sure the doctor treating you either has a \
		plant analyzer or a advanced health scanner!"
	))

	return to_add
