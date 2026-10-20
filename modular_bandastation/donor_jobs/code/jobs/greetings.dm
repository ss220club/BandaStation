#define DONOR_ROLE_RP_NOTICE "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера."

/datum/job
	var/important_information

/datum/job/donor
	var/list/variant_information

/// Keep native assignment and its greeting intact; send only our additional instructions afterwards.
/datum/mind/set_assigned_role_with_greeting(datum/job/new_role, client/incoming_client)
	. = ..()
	if(assigned_role != new_role)
		return
	var/list/information = new_role.get_additional_spawn_information(current)
	if(incoming_client && length(information))
		to_chat(incoming_client, boxed_message(span_infoplain(jointext(information, "\n&bull; "))))

/// Separate from the native role, policy and radio information.
/datum/job/proc/get_additional_spawn_information(mob/spawned)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	return list()

/datum/job/donor/get_additional_spawn_information(mob/spawned)
	. = ..()
	var/information = important_information
	if(ishuman(spawned) && length(variant_information))
		var/mob/living/carbon/human/human = spawned
		// Use the committed outfit; callers without a spawn context still receive the current default.
		var/outfit_type = human.job_variant_context?.outfit_type || resolve_job_variant(null)?.outfit_type
		if(variant_information[outfit_type])
			information = variant_information[outfit_type]
	if(information)
		. += DONOR_ROLE_RP_NOTICE
		. += information

/datum/job/prisoner/get_additional_spawn_information(mob/spawned)
	. = ..()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return
	. += DONOR_ROLE_RP_NOTICE
	. += important_information

/datum/job/cargo_technician/get_additional_spawn_information(mob/spawned)
	. = ..()
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/human = spawned
	var/outfit_type = human.job_variant_context?.outfit_type || resolve_job_variant(null)?.outfit_type
	if(ispath(outfit_type, /datum/outfit/job/cargo_tech/deliverer))
		. += DONOR_ROLE_RP_NOTICE
		. += important_information

#undef DONOR_ROLE_RP_NOTICE
