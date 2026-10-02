/datum/vampire_subclass
	/// Stable identifier used by the specialization UI.
	var/id
	/// The subclass' name. Used for blackbox logging.
	var/name = "накричать на кодербуса"
	/// Short player-facing specialization summary.
	var/description
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

/datum/vampire_subclass/proc/add_subclass_ability(datum/antagonist/vampire/vamp, announce = FALSE)
	for(var/thing in standard_powers)
		if(vamp.bloodtotal >= standard_powers[thing])
			vamp.add_ability(thing, announce)

/datum/vampire_subclass/proc/add_full_power_abilities(datum/antagonist/vampire/vamp, announce = FALSE)
	for(var/thing in fully_powered_abilities)
		vamp.add_ability(thing, announce)

/datum/vampire_subclass/proc/get_ui_data()
	var/list/data = list(
		"id" = id,
		"name" = name,
		"description" = description,
		"powers" = list(),
		"full_powers" = list(),
	)
	for(var/power_type in standard_powers)
		data["powers"] += list(get_power_ui_data(power_type, standard_powers[power_type]))
	for(var/power_type in fully_powered_abilities)
		data["full_powers"] += list(get_power_ui_data(power_type))
	return data

/datum/vampire_subclass/proc/get_power_ui_data(power_type, blood_required)
	var/datum/vampire_passive/passive = new power_type
	var/list/data = list("description" = passive.gain_desc)
	if(!isnull(blood_required))
		data["blood_required"] = blood_required
	if(istype(passive, /datum/vampire_passive/grant_spell))
		var/datum/vampire_passive/grant_spell/grant_spell = passive
		var/datum/action/cooldown/spell/spell = new grant_spell.spell_type
		data["name"] = spell.name
		data["description"] = spell.desc
		qdel(spell)
	qdel(passive)
	return data

/datum/vampire_subclass/umbrae
	id = "umbrae"
	name = "Умбра"
	description = "Специализируется на тьме, скрытности, засадах и мобильности."
	standard_powers = list(/datum/vampire_passive/grant_spell/cloak = 150,
							/datum/vampire_passive/grant_spell/shadow_snare = 250,
							/datum/vampire_passive/grant_spell/soul_anchor = 250,
							/datum/vampire_passive/grant_spell/dark_passage = 400,
							/datum/vampire_passive/grant_spell/extinguish = 600,
							/datum/vampire_passive/grant_spell/shadow_boxing = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/grant_spell/eternal_darkness,
								/datum/vampire_passive/vision/xray)
	unique_objectives = list("Выведите из строя телекоммуникационное оборудование станции. Их крики никто не услышит.",
							"Окутайте %DEPARTMENT тьмой.",
							"Покажите станции, почему боятся темноты.")

/datum/vampire_subclass/hemomancer
	id = "hemomancer"
	name = "Гемомант"
	description = "Специализируется на магии крови и управлении окружающей кровью."
	standard_powers = list(/datum/vampire_passive/grant_spell/vamp_claws = 150,
							/datum/vampire_passive/grant_spell/blood_tendrils = 250,
							/datum/vampire_passive/grant_spell/blood_barrier = 250,
							/datum/vampire_passive/grant_spell/blood_pool = 400,
							/datum/vampire_passive/grant_spell/predator_senses = 600,
							/datum/vampire_passive/grant_spell/blood_eruption = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/grant_spell/blood_spill)
	unique_objectives = list("Лишите медотсек крови. Она не для них.",
							"Окрасьте %DEPARTMENT в красный кровью тех, кто выступит против вас.",
							"Покажите станции, что вы на вершине силы.")

/datum/vampire_subclass/gargantua
	id = "gargantua"
	name = "Гаргантюа"
	description = "Специализируется на стойкости и уроне в ближнем бою."
	standard_powers = list(/datum/vampire_passive/grant_spell/blood_swell = 150,
							/datum/vampire_passive/grant_spell/blood_rush = 250,
							/datum/vampire_passive/grant_spell/stomp = 250,
							/datum/vampire_passive/blood_swell_upgrade = 400,
							/datum/vampire_passive/grant_spell/overwhelming_force = 600,
							/datum/vampire_passive/grant_spell/charge = 800,
							/datum/vampire_passive/grant_spell/demonic_grasp = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/grant_spell/arena)
	improved_rejuv_healing = TRUE
	unique_objectives = list("Уничтожьте серверы научного отдела. Технологии не заменят силу.",
							"Разгромите %DEPARTMENT. Они стали слишком самоуверенными.",
							"Покажите станции, что вы на вершине силы.") // I think multiple vampires competing would be cool

/datum/vampire_subclass/dantalion
	id = "dantalion"
	name = "Данталион"
	description = "Специализируется на порабощении и иллюзиях."
	standard_powers = list(/datum/vampire_passive/grant_spell/enthrall = 150,
							/datum/vampire_passive/grant_spell/commune = 150,
							/datum/vampire_passive/grant_spell/pacify = 250,
							/datum/vampire_passive/grant_spell/switch_places = 250,
							/datum/vampire_passive/grant_spell/decoy = 400,
							/datum/vampire_passive/increment_thrall_cap = 400,
							/datum/vampire_passive/grant_spell/rally_thralls = 600,
							/datum/vampire_passive/increment_thrall_cap/two = 600,
							/datum/vampire_passive/grant_spell/blood_bond = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/grant_spell/hysteria,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/increment_thrall_cap/three)
	unique_objectives = list("Подчините сотрудника службы безопасности. Его потенциал растрачивается в рядах Нанотрейзен.",
							"Подчиняйте только сотрудников %DEPARTMENT. Их опыт поможет вашему повелителю.",
							"Управляйте станцией из теней.")

/datum/vampire_subclass/ancient
	name = "Древний"
	standard_powers = list(/datum/vampire_passive/grant_spell/vamp_claws,
							/datum/vampire_passive/grant_spell/blood_swell,
							/datum/vampire_passive/grant_spell/cloak,
							/datum/vampire_passive/grant_spell/enthrall,
							/datum/vampire_passive/grant_spell/commune,
							/datum/vampire_passive/grant_spell/blood_tendrils,
							/datum/vampire_passive/grant_spell/blood_barrier,
							/datum/vampire_passive/grant_spell/blood_rush,
							/datum/vampire_passive/grant_spell/stomp,
							/datum/vampire_passive/grant_spell/charge,
							/datum/vampire_passive/grant_spell/shadow_snare,
							/datum/vampire_passive/grant_spell/soul_anchor,
							/datum/vampire_passive/grant_spell/pacify,
							/datum/vampire_passive/grant_spell/switch_places,
							/datum/vampire_passive/grant_spell/blood_pool,
							/datum/vampire_passive/blood_swell_upgrade,
							/datum/vampire_passive/grant_spell/dark_passage,
							/datum/vampire_passive/grant_spell/decoy,
							/datum/vampire_passive/grant_spell/blood_eruption,
							/datum/vampire_passive/grant_spell/predator_senses,
							/datum/vampire_passive/grant_spell/overwhelming_force,
							/datum/vampire_passive/grant_spell/extinguish,
							/datum/vampire_passive/grant_spell/rally_thralls,
							/datum/vampire_passive/grant_spell/blood_bond,
							/datum/vampire_passive/grant_spell/demonic_grasp,
							/datum/vampire_passive/grant_spell/shadow_boxing,
							/datum/vampire_passive/full,
							/datum/vampire_passive/vision/full,
							/datum/vampire_passive/grant_spell/blood_spill,
							/datum/vampire_passive/grant_spell/arena,
							/datum/vampire_passive/grant_spell/eternal_darkness,
							/datum/vampire_passive/grant_spell/hysteria,
							/datum/vampire_passive/grant_spell/raise_vampires,
							/datum/vampire_passive/vision/xray)
	improved_rejuv_healing = TRUE
	thrall_cap = 150 // can thrall high pop
	unique_objectives = list("Ваши ряды редеют. Позаботьтесь, чтобы ваши рабы оставались здоровы.") //idk
