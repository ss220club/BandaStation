/datum/antagonist/ninja/proc/addObjectives()
	var/objective_limit = 4
	var/objective_count = length(objectives)
	// Взлом серверов РнД
	var/datum/objective/research_secrets/sabotage_research = new /datum/objective/research_secrets()
	sabotage_research.owner = owner
	objectives += sabotage_research
	// Взлом боргов
	var/datum/objective/hijack = new /datum/objective/cyborg_hijack()
	objectives += hijack
	// Взлом консоли СБух
	var/datum/objective/securityobjective = new /datum/objective/security_scramble()
	objectives += securityobjective

	for(var/i in objective_count to objective_limit - 1)
		var/pick_objectives = rand(1,4)
		switch(pick_objectives)
			if(1)
				var/datum/objective/steal/steal_objective = new /datum/objective/steal()
				steal_objective.owner = owner
				steal_objective.find_target()
				objectives += steal_objective
			if(2)
				var/datum/objective/assassinate/kill_objective = new /datum/objective/assassinate()
				kill_objective.owner = owner
				kill_objective.find_target()
				objectives += kill_objective
			if(3)
				var/datum/objective/protect/protection_objective = new /datum/objective/protect()
				protection_objective.owner = owner
				protection_objective.find_target()
				objectives += protection_objective
			if(4)
				var/datum/objective/debrain/debrain_objective = new /datum/objective/debrain()
				debrain_objective.owner = owner
				debrain_objective.find_target()
				objectives += debrain_objective

	var/datum/objective/survival = new /datum/objective/survive()
	survival.owner = owner
	objectives += survival
