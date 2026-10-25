#define RADIATION_IMMEDIATE_DAMAGE 10 // BANDASTATION EDIT - Radiation also damages positronic cores.

#define RADIATION_TOX_DAMAGE_PER_INTERVAL 2
#define RADIATION_TOX_INTERVAL (25 SECONDS)

#define RADIATION_BURN_SPLOTCH_DAMAGE 11
#define RADIATION_BURN_INTERVAL_MIN (30 SECONDS)
#define RADIATION_BURN_INTERVAL_MAX (60 SECONDS)

// Showers process on SSmachines
#define RADIATION_CLEAN_IMMUNITY_TIME (SSMACHINES_DT + (1 SECONDS))

/// This atom is irradiated, and will glow green.
/// Humans take toxin damage; IPCs take core damage until their positronic brain is repaired. // BANDASTATION EDIT
/datum/component/irradiated
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/beginning_of_irradiation

	var/burn_splotch_timer_id

	COOLDOWN_DECLARE(clean_cooldown)
	COOLDOWN_DECLARE(last_tox_damage)

/datum/component/irradiated/Initialize()
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	// This isn't incompatible, it's just wrong
	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return

	ADD_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	create_glow()

	beginning_of_irradiation = world.time

	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		// BANDASTATION EDIT START - Toxin immunity must not discard irradiation before the IPC species callback.
		var/is_ipc = is_species(human_parent, /datum/species/ipc)
		if(is_ipc)
			human_parent.adjust_organ_loss(ORGAN_SLOT_BRAIN, RADIATION_IMMEDIATE_DAMAGE)
		else
			human_parent.apply_damage(RADIATION_IMMEDIATE_DAMAGE, TOX)
		// BANDASTATION EDIT END
		START_PROCESSING(SSobj, src)

		COOLDOWN_START(src, last_tox_damage, RADIATION_TOX_INTERVAL)

		start_burn_splotch_timer()

		human_parent.throw_alert(ALERT_IRRADIATED, is_ipc ? /atom/movable/screen/alert/irradiated/ipc : /atom/movable/screen/alert/irradiated) // BANDASTATION EDIT - Correct treatment for a synthetic body.

/datum/component/irradiated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))

/datum/component/irradiated/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
		COMSIG_LIVING_HEALTHSCAN,
	))

/datum/component/irradiated/Destroy(force)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("rad_glow")

	var/mob/living/carbon/human/human_parent = parent
	if (istype(human_parent))
		human_parent.clear_alert(ALERT_IRRADIATED)

	REMOVE_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	deltimer(burn_splotch_timer_id)
	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/component/irradiated/process(seconds_per_tick)
	if (!ishuman(parent))
		return PROCESS_KILL

	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return PROCESS_KILL

	var/mob/living/carbon/human/human_parent = parent
	// BANDASTATION EDIT START - Positronic repair is the synthetic equivalent of clearing radiation's toxin damage.
	var/remaining_damage = is_species(human_parent, /datum/species/ipc) ? human_parent.get_organ_loss(ORGAN_SLOT_BRAIN) : human_parent.get_tox_loss()
	if (!isnull(remaining_damage) && !remaining_damage)
		qdel(src)
		return PROCESS_KILL
	// BANDASTATION EDIT END

	if (should_halt_effects(parent))
		return

	if (human_parent.stat != DEAD)
		human_parent.dna?.species?.handle_radiation(human_parent, world.time - beginning_of_irradiation, seconds_per_tick)

	process_tox_damage(human_parent, seconds_per_tick)

/datum/component/irradiated/proc/should_halt_effects(mob/living/carbon/human/target)
	if (HAS_TRAIT(target, TRAIT_STASIS))
		return TRUE

	if (HAS_TRAIT(target, TRAIT_HALT_RADIATION_EFFECTS))
		return TRUE

	if (!COOLDOWN_FINISHED(src, clean_cooldown))
		return TRUE

	return FALSE

/datum/component/irradiated/proc/process_tox_damage(mob/living/carbon/human/target, seconds_per_tick)
	// BANDASTATION ADDITION START - IPC damage is applied by handle_radiation instead of biological toxin metabolism.
	if(is_species(target, /datum/species/ipc))
		return
	// BANDASTATION ADDITION END
	if (!COOLDOWN_FINISHED(src, last_tox_damage))
		return

	target.apply_damage(RADIATION_TOX_DAMAGE_PER_INTERVAL, TOX)
	COOLDOWN_START(src, last_tox_damage, RADIATION_TOX_INTERVAL)

/datum/component/irradiated/proc/start_burn_splotch_timer()
	addtimer(CALLBACK(src, PROC_REF(give_burn_splotches)), rand(RADIATION_BURN_INTERVAL_MIN, RADIATION_BURN_INTERVAL_MAX), TIMER_STOPPABLE)

/datum/component/irradiated/proc/give_burn_splotches()
	// This shouldn't be possible, but just in case.
	if (QDELETED(src))
		return

	start_burn_splotch_timer()

	var/mob/living/carbon/human/human_parent = parent

	if (should_halt_effects(parent))
		return

	var/obj/item/bodypart/affected_limb = human_parent.get_bodypart(human_parent.get_random_valid_zone())
	// BANDASTATION EDIT START - Radiation burns electronic circuitry rather than blistering a metal chassis.
	if(is_species(human_parent, /datum/species/ipc))
		human_parent.visible_message(
			span_boldwarning("Из [human_parent.declent_ru(GENITIVE)] с треском вырывается сноп искр!"),
			span_boldwarning("Радиация повреждает электронику: перегрев цепей в [affected_limb.plaintext_zone]!"),
		)
	else
		human_parent.visible_message(
			span_boldwarning("[human_parent]'s [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
			span_boldwarning("Your [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
		)

		if(human_parent.is_blind())
			to_chat(human_parent, span_boldwarning("Your [affected_limb.plaintext_zone] feels like it's bubbling, then burns like hell!"))
	// BANDASTATION EDIT END

	human_parent.apply_damage(RADIATION_BURN_SPLOTCH_DAMAGE, BURN, affected_limb, wound_clothing = FALSE)
	playsound(
		human_parent,
		SFX_SIZZLE,
		50,
		vary = TRUE,
	)

/datum/component/irradiated/proc/create_glow()
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return

	parent_movable.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop), parent_movable), rand(0.1 SECONDS, 1.9 SECONDS)) // Things should look uneven

/datum/component/irradiated/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/datum/component/irradiated/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if (!(clean_types & CLEAN_TYPE_RADIATION))
		return NONE

	if (isitem(parent))
		qdel(src)
		return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

	COOLDOWN_START(src, clean_cooldown, RADIATION_CLEAN_IMMUNITY_TIME)

/datum/component/irradiated/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER

	if (isliving(source))
		var/mob/living/living_source = source
		// BANDASTATION EDIT START - Synthetic contamination is tracked by core damage, not toxins.
		if(is_species(living_source, /datum/species/ipc))
			to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Обнаружено облучение КПБ. Время с начала заражения: [DisplayTimeText(world.time - beginning_of_irradiation, 5)]. Повреждение позитронного мозга: [living_source.get_organ_loss(ORGAN_SLOT_BRAIN)]."))
		else
			to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Subject is irradiated. Contamination traces back to roughly [DisplayTimeText(world.time - beginning_of_irradiation, 5)] ago. Current toxin levels: [living_source.get_tox_loss()]."))
		// BANDASTATION EDIT END
	else
		// In case the green wasn't obvious enough...
		to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Target is irradiated."))

	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL

/datum/component/irradiated/proc/on_healthscan(datum/source, list/render_list, scanpower, mob/user, mode, tochat)
	SIGNAL_HANDLER

	render_list += "<span class='alert ml-1'>"
	// BANDASTATION EDIT START - Antitoxin cannot repair an irradiated positronic brain.
	if(is_species(source, /datum/species/ipc))
		render_list += conditional_tooltip("Облучение электроники КПБ.", "Нанопаста снимает облучение, сохраняя полученные повреждения. Полный ремонт позитронного мозга нейронной отладкой или мультитулом после извлечения также прекращает облучение. Душ приостанавливает его действие.", tochat)
	else
		render_list += conditional_tooltip("Subject is irradiated.", "Supply antiradiation or antitoxin, such as [/datum/reagent/medicine/potass_iodide::name] or [/datum/reagent/medicine/pen_acid::name].", tochat)
	// BANDASTATION EDIT END
	render_list += "</span><br>"

/atom/movable/screen/alert/irradiated
	name = "Irradiated"
	desc = "You're irradiated! Heal your toxins quick, and stand under a shower to halt the incoming damage."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "irradiated"

// BANDASTATION ADDITION START - Radiation warning for a synthetic body.
/atom/movable/screen/alert/irradiated/ipc
	name = "Облучение электроники"
	desc = "Ионизирующее излучение повреждает позитронный мозг и цепи корпуса. Покиньте опасную зону. Нанопаста снимает облучение, сохраняя полученные повреждения; полный ремонт мозга также прекращает эффект. Душ приостанавливает повреждение."
// BANDASTATION ADDITION END

#undef RADIATION_BURN_SPLOTCH_DAMAGE
#undef RADIATION_BURN_INTERVAL_MIN
#undef RADIATION_BURN_INTERVAL_MAX
#undef RADIATION_CLEAN_IMMUNITY_TIME
#undef RADIATION_IMMEDIATE_DAMAGE
#undef RADIATION_TOX_INTERVAL
#undef RADIATION_TOX_DAMAGE_PER_INTERVAL
