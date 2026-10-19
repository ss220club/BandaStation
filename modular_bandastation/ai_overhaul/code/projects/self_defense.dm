/** Открывает заряжаемую электрическую защиту физических ядер. */
/datum/ai_project/shock_defense
	name = "Shock Defense"
	description = "Позволяет ударить током людей в радиусе двух клеток от любого вашего ядра ИИ."
	research_cost = 3000
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	can_be_run = FALSE

	category = AI_PROJECT_INDUCTION

	ability_path = /datum/action/innate/ai/shock_defense
	ability_recharge_cost = 2000

/datum/ai_project/shock_defense/finish()
	add_ability(/datum/action/innate/ai/shock_defense)

/** Расходует заряд на электрический импульс у доступных ядер своей сети. */
/datum/action/innate/ai/shock_defense
	name = "Электрическая защита"
	desc = "Удар током по всем в радиусе двух клеток от ваших ядер ИИ."
	button_icon_state = "emergency_lights"
	uses = 2
	max_uses = 2

/datum/action/innate/ai/shock_defense/Activate()
	for(var/obj/machinery/ai/data_core/core as anything in owner_AI.controllable_data_cores())
		tesla_zap(core, 2, (8 KILO JOULES), (ZAP_MOB_STUN|ZAP_MOB_DAMAGE))
		core.use_energy(core.idle_power_usage)

/datum/action/innate/ai/shock_defense/adjust_uses(amt, silent)
	uses = clamp(uses + amt, 0, max_uses)
	build_all_button_icons()

/datum/action/innate/ai/shock_defense/IsAvailable(feedback = FALSE)
	return uses > 0 && ..() && length(owner_AI.controllable_data_cores())
