/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	name = "Void Blast"
	desc = "Выпускает перед собой конус ледяной пустоты, замораживая все на своем пути. \
		Попавшие под конус враги получают незначительные повреждения, замедление и охлаждение. \
		Кроме того, объекты будут заморожены и смогут быть разбиты, а земля превратится в скользкий лёд - \
		хоть она сможет быстро оттаять, если использовать при комнатной температуре."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "icebeam"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "FR'ZE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	// In room temperature, the ice won't last very long
	// ...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_ICE
	unfreeze_turf_duration = 1 MINUTES
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 30 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 30 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()
