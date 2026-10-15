/datum/quirk/pyromania
	name = "Pyromania"
	desc = "Огонь завораживает вас, в его присутствии вы чувствуете себя счастливее, а также получаете повышенную устойчивость к жаре и пламени."
	icon = FA_ICON_FIRE
	value = 6
	gain_text = span_warning("Вас одолевает непреодолимое желание разжигать огонь.")
	lose_text = span_notice("Вы осознали опасность огня.")
	medical_record_text = "Пациент испытывает влечение к огню и навязчивое желание его разжигать."
	medical_symptom_text = "Испытывает неконтролируемое желание устраивать пожары и увлечённость пламенем."
	quirk_flags = QUIRK_PROCESSES|QUIRK_TRAUMALIKE|QUIRK_HUMAN_ONLY
	/// Heat damage reduction
	var/damage_mod = 0.67
	/// Tracks the last fire size to avoid spamming mood events
	VAR_PRIVATE/last_fire_size = -1
	/// CD before we attempt to start a fire with our lighter
	COOLDOWN_DECLARE(start_fire_cd)

/datum/quirk/pyromania/post_add()
	var/pyro_policy = get_policy("[type]") || "Обратите внимание: наличие черты [LOWER_TEXT(name)] не даёт вам никаких дополнительных прав на устраивание поджогов."
	to_chat(quirk_holder, span_info(pyro_policy))

/datum/quirk/pyromania/add(client/client_source)
	. = ..()
	MODIFY_PHYSIOLOGY(quirk_holder, PHYS_COEFF_HEAT, damage_mod)
	RegisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))

/datum/quirk/pyromania/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE)
	if(QDELING(quirk_holder))
		return

	MODIFY_PHYSIOLOGY(quirk_holder, PHYS_COEFF_HEAT, 1 / damage_mod)
	quirk_holder.clear_mood_event("pyromania_fire")

/datum/quirk/pyromania/process(seconds_per_tick)
	var/fire_size = quirk_holder.count_nearby_fire_sources()
	if(fire_size != last_fire_size)
		if(fire_size >= 1)
			quirk_holder.add_mood_event("pyromania_fire", /datum/mood_event/pyromania, round(fire_size))
		else
			quirk_holder.clear_mood_event("pyromania_fire")
	last_fire_size = fire_size

	if(COOLDOWN_FINISHED(src, start_fire_cd) && SPT_PROB((SANITY_NEUTRAL - quirk_holder.mob_mood?.sanity) / 5, seconds_per_tick))
		for(var/obj/item/lighter/lighter as anything in quirk_holder.get_held_items_of_type(/obj/item/lighter))
			if(lighter.lit)
				continue
			to_chat(quirk_holder, span_warning("Вы импульсивно щёлкаете [lighter.declent_ru(INSTRUMENTAL)], пытаясь высечь пламя..."))
			lighter.attack_self(quirk_holder)
			COOLDOWN_START(src, start_fire_cd, 4 SECONDS)
			break

/// Tracks when we're taking damage to temporarily pause attempts to strike up a flame
/datum/quirk/pyromania/proc/damage_taken(datum/source, damage_amount, damage_type, ...)
	SIGNAL_HANDLER
	if(damage_amount >= 5 && (damage_type == BRUTE || damage_type == BURN || damage_type == STAMINA))
		COOLDOWN_START(src, start_fire_cd, 12 SECONDS)

/**
 * Counts how many open flames are nearby, optionally weighted by their intensity (a candle's flame is significantly smaller than a bonfire).
 */
/atom/proc/count_nearby_fire_sources(radius = 5, weighted = FALSE)
	var/fire_size = 0

	for(var/atom/movable/thing in view(radius, src))
		// scales based on fire stacks. also includes the mob itself.
		if(astype(thing, /mob/living)?.on_fire)
			fire_size += weighted ? (astype(thing, /mob/living).fire_stacks / 20) : 1
		// giant pile of fire
		else if(astype(thing, /obj/structure/bonfire)?.burning)
			fire_size += weighted ? 1.0 : 1
		// relatively safe, at least safer than a bonfire
		else if(astype(thing, /obj/structure/fireplace)?.lit)
			fire_size += weighted ? 0.5 : 1
		// various small flames, but elevated if they are being held
		else if(astype(thing, /obj/item/flashlight/flare)?.light_on)
			fire_size += weighted ? (thing.loc == src ? 1.0 : 0.2) : 1
		else if(astype(thing, /obj/item/match)?.lit)
			fire_size += weighted ? (thing.loc == src ? 1.0 : 0.2) : 1
		else if(astype(thing, /obj/item/lighter)?.lit)
			fire_size += weighted ? (thing.loc == src ? 1.0 : 0.2) : 1
		// hotspots are huge walls of fire, but also spammed a lot, so weighted down a bit
		else if(istype(thing, /obj/effect/hotspot))
			fire_size += weighted ? 1.2 : 1
		// any other random item being on fire, these are more uncontrolled, and potentially even being worn
		else if(thing.resistance_flags & ON_FIRE)
			fire_size += weighted ? (thing.loc == src ? 2.0 : 0.2) : 1

	return fire_size

/datum/mood_event/pyromania
	description = "Прекрасный, тёплый огонь..."
	mood_change = 1

/datum/mood_event/pyromania/add_effects(fire_size = 0)
	mood_change = fire_size

/datum/mood_event/pyromania/be_replaced(datum/mood/home, datum/mood_event/new_event, fire_size = 0)
	mood_change = max(mood_change, fire_size)
	return BLOCK_NEW_MOOD
