/*
 *	# Hide a random object somewhere on the station:
 *
 *	var/turf/targetturf = get_random_station_turf()
 *	var/turf/targetturf = get_safe_random_station_turf()
 */

/datum/objective/bloodsucker
	martyr_compatible = TRUE

// GENERATE
/datum/objective/bloodsucker/New()
	update_explanation_text()
	..()

//////////////////////////////////////////////////////////////////////////////
//	//							 PROCS 									//	//

/// Look at all crew members, and for/loop through.
/datum/objective/bloodsucker/proc/return_possible_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)
			// Check Two: Am Bloodsucker?
			if(IS_BLOODSUCKER(possible_target.current))
				continue
			possible_targets += possible_target

	return possible_targets

/// Check Vassals and get their occupations
/datum/objective/bloodsucker/proc/get_vassal_occupations()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!length(bloodsuckerdatum?.vassals))
		return FALSE
	var/list/all_vassal_jobs = list()
	var/vassal_job
	for(var/datum/antagonist/vassal/bloodsucker_vassals in bloodsuckerdatum.vassals)
		if(!bloodsucker_vassals || !bloodsucker_vassals.owner)	// Must exist somewhere, and as a vassal.
			continue
		// Mind Assigned
		if(bloodsucker_vassals.owner?.assigned_role)
			vassal_job = bloodsucker_vassals.owner.assigned_role
		// Mob Assigned
		else if(bloodsucker_vassals.owner?.current?.job)
			vassal_job = SSjob.get_job(bloodsucker_vassals.owner.current.job)
		// PDA Assigned
		else if(bloodsucker_vassals.owner?.current && ishuman(bloodsucker_vassals.owner.current))
			var/mob/living/carbon/human/vassal = bloodsucker_vassals.owner.current
			vassal_job = SSjob.get_job(vassal.get_assignment())
		if(vassal_job)
			all_vassal_jobs += vassal_job
	return all_vassal_jobs

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////
//    DEFAULT OBJECTIVES    //
//////////////////////////////

/datum/objective/bloodsucker/lair
	name = "claimlair"

// EXPLANATION
/datum/objective/bloodsucker/lair/update_explanation_text()
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."//  Make sure to keep it safe!"

// WIN CONDITIONS?
/datum/objective/bloodsucker/lair/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.claimed_coffin && bloodsuckerdatum.bloodsucker_lair_area)
		return TRUE
	return FALSE

/// Space_Station_13_areas.dm  <--- all the areas

//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/bloodsucker
	name = "bloodsuckersurvive"
	explanation_text = "Survive the entire shift without succumbing to Final Death."

// WIN CONDITIONS?
// Handled by parent

//////////////////////////////////////////////////////////////////////////////////////


/// Vassalize a certain person / people
/datum/objective/bloodsucker/conversion
	name = "vassalization"

/////////////////////////////////

// Vassalize a head of staff
/datum/objective/bloodsucker/conversion/command
	name = "vassalizationcommand"
	target_amount = 1

// EXPLANATION
/datum/objective/bloodsucker/conversion/command/update_explanation_text()
	explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."

// WIN CONDITIONS?
/datum/objective/bloodsucker/conversion/command/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			return TRUE // We only need one, so we stop as soon as we get a match
	return FALSE

/////////////////////////////////

// Vassalize crewmates in a department
/datum/objective/bloodsucker/conversion/department
	name = "vassalize department"

	///The selected department we have to vassalize.
	var/datum/job_department/target_department
	///List of all departments that can be selected for the objective.
	var/static/list/possible_departments = list(
		/datum/job_department/engineering,
		/datum/job_department/medical,
		/datum/job_department/science,
		/datum/job_department/cargo,
		/datum/job_department/service,
	)

	/// Gets how many people are in a department
/datum/objective/bloodsucker/conversion/department/proc/get_department_size(datum/job_department/department)
	var/department_size = 0
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/datum/job/crew_job = crew_mind.assigned_role
		if(!crew_job)
			continue
		if(crew_job.departments_bitflags & department.department_bitflags)
			department_size++
	return department_size

// GENERATE!
/datum/objective/bloodsucker/conversion/department/New()
	// Keep picking departments until we find one that has members
	var/list/temp_departments = possible_departments.Copy()
	while(temp_departments.len > 0)
		target_department = SSjob.get_department_type(pick(temp_departments))
		var/department_size = get_department_size(target_department)
		if(department_size > 0)
			// Scale target amount based on department size
			target_amount = max(1, min(round(department_size/2), department_size))
			return ..()
		temp_departments -= target_department.type

	// If we somehow failed to find any valid departments, pick the first one and set amount to 1
	target_department = SSjob.get_department_type(possible_departments[1])
	target_amount = 1
	return ..()

// EXPLANATION
/datum/objective/bloodsucker/conversion/department/update_explanation_text()
	explanation_text = "Have [target_amount] Vassal[target_amount == 1 ? "" : "s"] in the [target_department.department_name] department."
	return ..()

// WIN CONDITIONS?
/datum/objective/bloodsucker/conversion/department/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	var/converted_count = 0
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments_bitflags & target_department.department_bitflags)
			converted_count++
	if(converted_count >= target_amount)
		return TRUE
	return FALSE

	/**
	 * # IMPORTANT NOTE!!
	 *
	 * Look for Job Values on mobs! This is assigned at the start, but COULD be changed via the HoP
	 * ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
	 * ALSO - registered_account in _vending.dm for banks, and assigning new ones.
	 */
