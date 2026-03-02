#define COMSIG_STOMACH_WEAPON_ATTACK "stomach_weapon_attack"

/// An alien organ that allows the owner to build resin structures.
/obj/item/organ/alien/resinspinner_banda
	name = "resin spinner"
	desc = "An organ that secretes resin for constructing alien structures."
	icon_state = "spinner-x"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_RESINSPINNER
	actions_types = list(
		/datum/action/cooldown/alien/select_resin_structure,
		/datum/action/cooldown/alien/build_resin_structure
	)

/// An alien stomach organ that can hold and digest contents, preventing attacks from within.
/obj/item/organ/stomach/alien_banda
	name = "alien stomach"
	desc = "A robust stomach capable of holding and digesting various contents."
	icon_state = "stomach-x"
	w_class = WEIGHT_CLASS_BULKY
	actions_types = list(/datum/action/cooldown/alien/regurgitate_banda)
	organ_traits = list(TRAIT_STRONG_STOMACH)

	/// Tracks when each mob in the stomach started resisting (world.time).
	var/list/resist_times = list()

/// Returns the acid damage dealt to contents (none in this case).
/obj/item/organ/stomach/alien_banda/stomach_acid_power(atom/movable/nomnom)
	return 0 // No acid damage

/// Handles consumption of an atom, applying effects and signals for living contents.
/obj/item/organ/stomach/alien_banda/consume_thing(atom/movable/thing)
	. = ..()
	if (!.)
		return
	if (isliving(thing))
		var/mob/living/victim = thing
		RegisterSignal(victim, COMSIG_LIVING_DEATH, PROC_REF(content_died), override = TRUE)
		RegisterSignal(victim, COMSIG_MOB_CLICKON, PROC_REF(block_attack_from_inside), override = TRUE)
		RegisterSignal(victim, COMSIG_MOB_ITEM_ATTACK, PROC_REF(block_attack_from_inside), override = TRUE)
		RegisterSignal(victim, COMSIG_MOB_ATTACK_RANGED, PROC_REF(block_attack_from_inside), override = TRUE)
		RegisterSignal(victim, COMSIG_MOB_ATTACK_HAND, PROC_REF(block_attack_from_inside), override = TRUE)
		RegisterSignal(victim, COMSIG_STOMACH_WEAPON_ATTACK, PROC_REF(handle_stomach_weapon_attack), override = TRUE)
		victim.apply_status_effect(/datum/status_effect/temporary_blindness, STATUS_EFFECT_PERMANENT, "alien_stomach")
		victim.forceMove(src) // Move to stomach

/// Handles movement of contents, cleaning up signals and effects when moved out.
/obj/item/organ/stomach/alien_banda/content_moved(atom/movable/source)
	. = ..()
	if (source.loc == src || source.loc == owner)
		return
	if (isliving(source))
		var/mob/living/victim = source
		UnregisterSignal(victim, list(
			COMSIG_LIVING_DEATH,
			COMSIG_MOB_CLICKON,
			COMSIG_MOB_ITEM_ATTACK,
			COMSIG_MOB_ATTACK_RANGED,
			COMSIG_MOB_ATTACK_HAND,
			COMSIG_STOMACH_WEAPON_ATTACK
		))
		victim.remove_status_effect(/datum/status_effect/temporary_blindness, "alien_stomach")
		resist_times -= victim

/// Handles the death of a mob inside the stomach, digesting corpses.
/obj/item/organ/stomach/alien_banda/proc/content_died(mob/living/source)
	SIGNAL_HANDLER
	if (QDELETED(src))
		return
	// Can fully digest corpses
	resist_times -= source
	UnregisterSignal(source, list(
		COMSIG_LIVING_DEATH,
		COMSIG_MOB_CLICKON,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_ATTACK_RANGED,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_STOMACH_WEAPON_ATTACK
	))
	source.remove_status_effect(/datum/status_effect/temporary_blindness, "alien_stomach")
	qdel(source)

/// Registers signals when the stomach is inserted into a mob.
/obj/item/organ/stomach/alien_banda/on_mob_insert(mob/living/carbon/stomach_owner, special, movement_flags)
	. = ..()
	RegisterSignal(stomach_owner, COMSIG_ATOM_RELAYMOVE, PROC_REF(something_moved), override = TRUE)
	RegisterSignal(stomach_owner, COMSIG_LIVING_DEATH, PROC_REF(owner_died), override = TRUE)

/// Unregisters signals and cleans up contents when the stomach is removed.
/obj/item/organ/stomach/alien_banda/on_mob_remove(mob/living/carbon/stomach_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(stomach_owner, list(
		COMSIG_ATOM_RELAYMOVE,
		COMSIG_LIVING_DEATH
	))
	for (var/mob/living/victim in stomach_contents)
		UnregisterSignal(victim, list(
			COMSIG_LIVING_DEATH,
			COMSIG_MOB_CLICKON,
			COMSIG_MOB_ITEM_ATTACK,
			COMSIG_MOB_ATTACK_RANGED,
			COMSIG_MOB_ATTACK_HAND,
			COMSIG_STOMACH_WEAPON_ATTACK
		))
		victim.remove_status_effect(/datum/status_effect/temporary_blindness, "alien_stomach")
		resist_times -= victim

/// Handles the owner's death, ejecting all stomach contents.
/obj/item/organ/stomach/alien_banda/proc/owner_died(mob/living/carbon/stomach_owner)
	SIGNAL_HANDLER
	if (QDELETED(src))
		return
	empty_contents(chance = 100)

/// Handles movement attempts by contents, triggering resistance.
/obj/item/organ/stomach/alien_banda/proc/something_moved(mob/living/source, mob/living/user, direction)
	SIGNAL_HANDLER
	spawn(0) // Asynchronous call to avoid must_not_sleep
		relaymove(user, direction)
	return COMSIG_BLOCK_RELAYMOVE

/// Blocks attacks from inside the stomach unless marked as from stomach.
/obj/item/organ/stomach/alien_banda/proc/block_attack_from_inside(datum/source, atom/target, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if (QDELETED(src))
		return
	var/mob/living/attacker = ismob(source) ? source : user
	if (!attacker)
		return
	if (attacker.loc == src && target == owner && !modifiers?["from_stomach"])
		to_chat(attacker, span_warning("You cannot attack the xenomorph from inside its stomach! Use WASD to try resit !"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Handles weapon attacks from inside the stomach.
/obj/item/organ/stomach/alien_banda/proc/handle_stomach_weapon_attack(mob/living/source, obj/item/weapon, mob/living/attacker)
	SIGNAL_HANDLER
	if (QDELETED(src) || !weapon.hitsound)
		return // Skip if no hitsound
	var/damage = weapon.force * (1 - owner.getarmor() / 100) // Account for armor
	owner.adjust_brute_loss(damage)
	owner.do_attack_animation(attacker)
	playsound(owner, weapon.hitsound, 50, TRUE)

/// Processes resistance attempts by contents, potentially ejecting them.
/obj/item/organ/stomach/alien_banda/relaymove(mob/living/user, direction)
	if (!(user in stomach_contents))
		return

	// Track resistance start time
	if (!resist_times[user])
		resist_times[user] = world.time

	// Check for gun
	var/obj/item/pokie = user.get_active_held_item()
	if (pokie && isgun(pokie))
		to_chat(user, span_warning("You cannot use firearms inside the stomach!"))
		return

	if (!prob(20))
		return

	var/atom/play_from = owner || src
	var/stomach_text = owner ? "желудка [owner.declent_ru(GENITIVE)]" : "[declent_ru(GENITIVE)]"

	// Slow down the victim's movement
	if (user.client)
		user.client.move_delay = world.time + 1.5 SECONDS

	// Handle resistance
	var/attack_name = ""
	var/attack_verb = ""
	if (pokie)
		attack_name = pokie.declent_ru(GENITIVE)
		var/list/attack_verbs = pokie.attack_verb_continuous
		attack_verb = length(attack_verbs) ? "[pick(attack_verbs)]" : "атакует"
		SEND_SIGNAL(user, COMSIG_STOMACH_WEAPON_ATTACK, pokie, user) // Send custom signal
	else
		// Resistance with fists
		attack_name = "кулаков"
		attack_verb = "бьёт"
		owner.attack_hand(user) // Trigger fist attack

	// Notify players
	play_from.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] [attack_verb] стенки [stomach_text] с помощью [attack_name]!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] [attack_verb] стенки вашего желудка с помощью [attack_name]!"))

	// Check if 90 seconds have passed since resistance started
	if (resist_times[user] && world.time >= resist_times[user] + 90 SECONDS)
		play_from.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] заставляет [stomach_text] извергнуть содержимое!"), \
			span_userdanger("Your struggle forces the xenomorph's stomach to eject you!"))
		eject_stomach(border_diamond_range_turfs(play_from, 3), 3, 1, 1, 4)

/// Ejects all stomach contents with a specified chance.
/obj/item/organ/stomach/alien_banda/empty_contents(chance = 100, damaging = FALSE, min_amount = 0)
	return eject_stomach(border_diamond_range_turfs(get_turf(src), 3), 3, 1, 1, 4)

/// Ejects contents when the owner vomits.
/obj/item/organ/stomach/alien_banda/on_vomit(mob/living/carbon/vomiter, distance, force)
	empty_contents(chance = 100)

/// Ejects stomach contents with acid particles to nearby turfs.
/obj/item/organ/stomach/alien_banda/proc/eject_stomach(list/turf/targets, spit_range, content_speed, particle_delay, particle_count = 4)
	var/atom/spit_as = owner || src
	var/ejected = length(stomach_contents)
	for (var/atom/movable/thing as anything in stomach_contents)
		thing.forceMove(spit_as.drop_location())
		if (isliving(thing))
			var/mob/living/victim = thing
			UnregisterSignal(victim, list(
				COMSIG_LIVING_DEATH,
				COMSIG_MOB_CLICKON,
				COMSIG_MOB_ITEM_ATTACK,
				COMSIG_MOB_ATTACK_RANGED,
				COMSIG_MOB_ATTACK_HAND,
				COMSIG_STOMACH_WEAPON_ATTACK
			))
			victim.remove_status_effect(/datum/status_effect/temporary_blindness, "alien_stomach")
			resist_times -= victim
		if (length(targets))
			thing.throw_at(pick(targets), spit_range, content_speed, thrower = spit_as, spin = TRUE)

	for (var/a in 1 to particle_count)
		if (!length(targets))
			break
		var/obj/effect/particle_effect/water/extinguisher/stomach_acid/acid = new(get_turf(spit_as))
		var/turf/my_target = pick_n_take(targets)
		var/datum/reagents/acid_reagents = new /datum/reagents(5)
		acid.reagents = acid_reagents
		acid_reagents.my_atom = acid
		acid_reagents.add_reagent(/datum/reagent/toxin/acid, 30)
		acid.move_at(my_target, particle_delay, spit_range)

	return ejected

/// An action that allows the alien to regurgitate stomach contents.
/datum/action/cooldown/alien/regurgitate_banda
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	button_icon_state = "alien_barf"
	/// Angle range for ejecting contents (degrees).
	var/angle_delta = 45
	/// Speed at which mobs are thrown.
	var/mob_speed = 1.5
	/// Speed at which particles are thrown.
	var/spit_speed = 1

/// Triggers regurgitation, ejecting stomach contents in a cone.
/datum/action/cooldown/alien/regurgitate_banda/Activate(atom/target)
	if (!iscarbon(owner))
		return
	var/mob/living/carbon/alien/adult/alieninated_owner = owner
	var/obj/item/organ/stomach/alien_banda/melting_pot = alieninated_owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if (!melting_pot)
		owner.visible_message(span_clown("[alieninated_owner] gags, and spits up a bit of purple liquid. Ewwww."), \
			span_alien("You feel a pain in your... chest? There's nothing there there's nothing there no no n-"))
		return

	if (!length(melting_pot.stomach_contents))
		to_chat(owner, span_alien("There's nothing in your stomach, what exactly do you plan on spitting up?"))
		return
	owner.visible_message(span_danger("[owner] hurls out the contents of their stomach!"))
	var/dir_angle = dir2angle(owner.dir)

	playsound(owner, 'sound/mobs/non-humanoids/alien/alien_york.ogg', 100)
	melting_pot.eject_stomach(slice_off_turfs(owner, border_diamond_range_turfs(owner, 9), dir_angle - angle_delta, dir_angle + angle_delta), 4, mob_speed, spit_speed)
