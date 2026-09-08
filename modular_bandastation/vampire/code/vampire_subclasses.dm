/datum/vampire_subclass
	/// The subclass' name. Used for blackbox logging.
	var/name = "yell at coderbus"
	/// A list of powers that a vampire unlocks. The value of the list entry is equal to the blood total required for the vampire to unlock it.
	var/list/standard_powers
	/// A list of the powers a vampire unlocks when it reaches full power.
	var/list/fully_powered_abilities
	/// Whether or not a vampire heals more based on damage taken.
	var/improved_rejuv_healing = FALSE
	/// maximun number of thralls a vampire may have at a time. incremented as they grow stronger, up to a cap at full power.
	var/thrall_cap = 1
	/// If true, lets the vampire have access to their full power abilities without meeting the blood requirement, or needing a certain number of drained humans.
	var/full_power_override = FALSE
	/// The subclass' potential unique objectives.
	var/list/unique_objectives

/datum/vampire_subclass/proc/add_subclass_ability(datum/antagonist/vampire/vamp)
	for(var/thing in standard_powers)
		if(vamp.bloodtotal >= standard_powers[thing])
			vamp.add_ability(thing)

/datum/vampire_subclass/proc/add_full_power_abilities(datum/antagonist/vampire/vamp)
	for(var/thing in fully_powered_abilities)
		vamp.add_ability(thing)

/datum/vampire_subclass/umbrae
	name = "umbrae"
	standard_powers = list(/datum/action/cooldown/spell/vampire/self/cloak = 150,
							/datum/action/cooldown/spell/vampire/shadow_snare = 250,
							/datum/action/cooldown/spell/vampire/soul_anchor = 250,
							/datum/action/cooldown/spell/vampire/dark_passage = 400,
							/datum/action/cooldown/spell/vampire/vamp_extinguish = 600,
							/datum/action/cooldown/spell/vampire/shadow_boxing = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/action/cooldown/spell/vampire/self/eternal_darkness,
								/datum/vampire_passive/vision/xray)
	unique_objectives = list("Silence the station's telecommunications equipment. Their screams will fall on deaf ears.",
							"Shroud %DEPARTMENT in darkness.",
							"Show the station why they fear the dark.")

/datum/vampire_subclass/hemomancer
	name = "hemomancer"
	standard_powers = list(/datum/action/cooldown/spell/vampire/self/vamp_claws = 150,
							/datum/action/cooldown/spell/vampire/blood_tendrils = 250,
							/datum/action/cooldown/spell/vampire/blood_barrier = 250,
							/datum/spell/ethereal_jaunt/blood_pool = 400,
							/datum/action/cooldown/spell/vampire/predator_senses = 600,
							/datum/action/cooldown/spell/vampire/blood_eruption = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/action/cooldown/spell/vampire/self/blood_spill)
	unique_objectives = list("Deprive the medical bay of blood. It's not theirs to use.",
							"Paint %DEPARTMENT red with the blood of those who would oppose you.",
							"Show the station that you stand at the peak of strength.")

/datum/vampire_subclass/gargantua
	name = "gargantua"
	standard_powers = list(/datum/action/cooldown/spell/vampire/self/blood_swell = 150,
							/datum/action/cooldown/spell/vampire/self/blood_rush = 250,
							/datum/action/cooldown/spell/vampire/self/stomp = 250,
							/datum/vampire_passive/blood_swell_upgrade = 400,
							/datum/action/cooldown/spell/vampire/self/overwhelming_force = 600,
							/datum/action/cooldown/spell/vampire/charge = 800,
							/datum/spell/fireball/demonic_grasp = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/action/cooldown/spell/vampire/arena)
	improved_rejuv_healing = TRUE
	unique_objectives = list("Destroy Research's servers. Technology is no substitute for strength.",
							"Vandalize %DEPARTMENT. They've grown complacent.",
							"Show the station that you stand at the peak of strength.") // I think multiple vampires competing would be cool

/datum/vampire_subclass/dantalion
	name = "dantalion"
	standard_powers = list(/datum/action/cooldown/spell/vampire/enthrall = 150,
							/datum/action/cooldown/spell/vampire/thrall_commune = 150,
							/datum/action/cooldown/spell/vampire/pacify = 250,
							/datum/action/cooldown/spell/vampire/switch_places = 250,
							/datum/action/cooldown/spell/vampire/self/decoy = 400,
							/datum/vampire_passive/increment_thrall_cap = 400,
							/datum/action/cooldown/spell/vampire/rally_thralls = 600,
							/datum/vampire_passive/increment_thrall_cap/two = 600,
							/datum/action/cooldown/spell/vampire/self/share_damage = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/action/cooldown/spell/vampire/hysteria,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/increment_thrall_cap/three)
	unique_objectives = list("Enthrall a member of security. Their potential is wasted in Nanotrasen's ranks.",
							"Enthrall only members of %DEPARTMENT. Their experience will assist your lord.",
							"Control the station from the shadows.")

/datum/vampire_subclass/ancient
	name = "ancient"
	standard_powers = list(/datum/action/cooldown/spell/vampire/self/vamp_claws,
							/datum/action/cooldown/spell/vampire/self/blood_swell,
							/datum/action/cooldown/spell/vampire/self/cloak,
							/datum/action/cooldown/spell/vampire/enthrall,
							/datum/action/cooldown/spell/vampire/thrall_commune,
							/datum/action/cooldown/spell/vampire/blood_tendrils,
							/datum/action/cooldown/spell/vampire/blood_barrier,
							/datum/action/cooldown/spell/vampire/self/blood_rush,
							/datum/action/cooldown/spell/vampire/self/stomp,
							/datum/action/cooldown/spell/vampire/charge,
							/datum/action/cooldown/spell/vampire/shadow_snare,
							/datum/action/cooldown/spell/vampire/soul_anchor,
							/datum/action/cooldown/spell/vampire/pacify,
							/datum/action/cooldown/spell/vampire/switch_places,
							/datum/spell/ethereal_jaunt/blood_pool,
							/datum/vampire_passive/blood_swell_upgrade,
							/datum/action/cooldown/spell/vampire/dark_passage,
							/datum/action/cooldown/spell/vampire/self/decoy,
							/datum/action/cooldown/spell/vampire/blood_eruption,
							/datum/action/cooldown/spell/vampire/predator_senses,
							/datum/action/cooldown/spell/vampire/self/overwhelming_force,
							/datum/action/cooldown/spell/vampire/vamp_extinguish,
							/datum/action/cooldown/spell/vampire/rally_thralls,
							/datum/action/cooldown/spell/vampire/self/share_damage,
							/datum/spell/fireball/demonic_grasp,
							/datum/action/cooldown/spell/vampire/shadow_boxing,
							/datum/vampire_passive/full,
							/datum/vampire_passive/vision/full,
							/datum/action/cooldown/spell/vampire/self/blood_spill,
							/datum/action/cooldown/spell/vampire/arena,
							/datum/action/cooldown/spell/vampire/self/eternal_darkness,
							/datum/action/cooldown/spell/vampire/hysteria,
							/datum/action/cooldown/spell/vampire/raise_vampires,
							/datum/vampire_passive/vision/xray)
	improved_rejuv_healing = TRUE
	thrall_cap = 150 // can thrall high pop
	unique_objectives = list("Your ranks grow thin. Ensure your thralls remain in good health.") //idk
