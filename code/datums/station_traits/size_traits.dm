/datum/station_trait/everyone_dwarf
	name = "Протокол «Малыш»"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 100
	show_in_report = TRUE
	report_message = "Из-за ошибки в системе репликации пищевых автоматов, в рацион экипажа попали экспериментальные гормоны. Теперь все на станции немного... компактнее."
	blacklist = list(/datum/station_trait/everyone_giant)

/datum/station_trait/everyone_dwarf/on_round_start()
	. = ..()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind && (H.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			H.dna.add_mutation(/datum/mutation/dwarfism, STATION_TRAIT)

/datum/station_trait/everyone_dwarf/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/everyone_dwarf/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/carbon/human/spawned)
	SIGNAL_HANDLER
	if(!ishuman(spawned))
		return
	spawned.dna.add_mutation(/datum/mutation/dwarfism, STATION_TRAIT)

/datum/station_trait/everyone_giant
	name = "Протокол «Титан»"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 100
	show_in_report = TRUE
	report_message = "Экспериментальная программа по увеличению физических показателей привела к неожиданным побочным эффектам. Экипаж стал значительно выше, чем планировалось."
	blacklist = list(/datum/station_trait/everyone_dwarf)

/datum/station_trait/everyone_giant/on_round_start()
	. = ..()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind && (H.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			H.dna.add_mutation(/datum/mutation/gigantism, STATION_TRAIT)

/datum/station_trait/everyone_giant/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/everyone_giant/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/carbon/human/spawned)
	SIGNAL_HANDLER
	if(!ishuman(spawned))
		return
	spawned.dna.add_mutation(/datum/mutation/gigantism, STATION_TRAIT)
