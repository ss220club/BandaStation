/mob/living/carbon/human
	var/datum/job_variant_context/job_variant_context

/// Snapshot this body's crime and outfit before native appearance checks can yield.
/mob/living/carbon/human/apply_prefs_job(client/player_client, datum/job/job)
	if(!player_client)
		return
	job.prepare_spawn_character(src, player_client.prefs)
	return ..()

/datum/job_variant_context
	var/job_type
	var/outfit_type
	var/public_title
	var/identity_applied = FALSE
	var/record_registered = FALSE

/datum/job_variant_context/New(datum/job/job, variant_choice)
	job_type = job.type
	var/datum/job_variant/variant = job.resolve_job_variant(variant_choice)
	outfit_type = variant?.outfit_type || job.get_outfit(FALSE)
	public_title = variant?.public_title || job.title
	return ..()

/// Capture the chosen variant before preference application, appearance checks and the greeting; must not yield.
/datum/job/proc/prepare_spawn_character(mob/living/spawned, datum/preferences/preferences)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(!length(job_variant_specs) || !ishuman(spawned) || !length(get_job_variants()))
		return
	var/mob/living/carbon/human/body = spawned
	var/list/variants = preferences.read_preference(/datum/preference/job_outfit_variants)
	QDEL_NULL(body.job_variant_context)
	body.job_variant_context = new(src, variants?[title])
	body.job_variant_context.RegisterSignal(body, COMSIG_HUMAN_INITIAL_CREW_RECORD, TYPE_PROC_REF(/datum/job_variant_context, register_crew_record))
	body.job_variant_context.RegisterSignal(body, COMSIG_QDELETING, TYPE_PROC_REF(/datum/job_variant_context, on_body_deleted))

/datum/job_variant_context/proc/on_body_deleted(mob/living/carbon/human/body)
	SIGNAL_HANDLER
	if(body.job_variant_context == src)
		body.job_variant_context = null
	qdel(src)

/datum/job_variant_context/proc/belongs_to(datum/job/job)
	return job && job.type == job_type

/// Adapt the native outfit argument before the single native outfit/loadout operation.
/// Its jobtype identifies the actual requested job, including previews without a mind.
/mob/living/carbon/human/equip_outfit_and_loadout(datum/outfit/outfit = /datum/outfit, datum/preferences/preference_source, visuals_only = FALSE)
	if(ispath(outfit, /datum/outfit/job))
		var/datum/outfit/job/job_outfit = outfit
		var/datum/job/job = SSjob.get_job_type(initial(job_outfit.jobtype))
		if(job && length(job.job_variant_specs))
			if(!visuals_only && job_variant_context?.belongs_to(job))
				outfit = job_variant_context.outfit_type
			else if(visuals_only && preference_source)
				var/list/selections = preference_source.read_preference(/datum/preference/job_outfit_variants)
				var/datum/job_variant/variant = job.resolve_job_variant(selections?[job.title])
				outfit = variant?.outfit_type || outfit
	return ..(outfit, preference_source, visuals_only)

/datum/job_variant_context/proc/apply_identity(mob/living/carbon/human/body)
	if(identity_applied)
		return
	identity_applied = TRUE
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	if(card)
		card.assignment = public_title
		card.update_label()
		body.update_ID_card()
	var/datum/outfit/job/outfit_path = outfit_type
	var/pda_slot = initial(outfit_path.pda_slot)
	if(!pda_slot)
		return
	var/obj/item/slot_item = body.get_item_by_slot(pda_slot)
	var/obj/item/modular_computer/pda/pda
	if(istype(slot_item, /obj/item/modular_computer/pda))
		pda = slot_item
	else if(slot_item)
		pda = locate(/obj/item/modular_computer/pda) in slot_item
	if(pda)
		pda.imprint_id(body.real_name, public_title)
		pda.UpdateDisplay()

/datum/job/proc/apply_job_variant_identity(mob/living/spawned)
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/body = spawned
	var/datum/job_variant_context/context = body.job_variant_context
	if(!context?.belongs_to(src))
		return
	context.apply_identity(body)

/datum/job_variant_context/proc/register_crew_record(mob/living/carbon/human/body, datum/job/job, datum/record/crew/record)
	SIGNAL_HANDLER
	if(record_registered || !belongs_to(job))
		return FALSE
	record_registered = TRUE
	record.rank = public_title
	return TRUE
