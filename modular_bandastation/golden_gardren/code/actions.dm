/// How far the Golden Ram carries the mech.
#define GOLDEN_RAM_DISTANCE 3
/// Brute damage the Golden Ram deals to everyone it hits.
#define GOLDEN_RAM_DAMAGE 30
/// Energy the Golden Ram drains from the main cell.
#define GOLDEN_RAM_ENERGY (0.1 * STANDARD_CELL_CHARGE)
/// Time between Golden Ram uses.
#define GOLDEN_RAM_COOLDOWN (20 SECONDS)
/// Burn damage the missile strike deals to everyone on the impact turf and the eight around it.
#define GOLDEN_GARDREN_MISSILE_BURN 20
/// Fire stacks the missile strike puts on everyone it burns.
#define GOLDEN_GARDREN_MISSILE_FIRE_STACKS 3

/// Redraws the buttons of [action_type] for everyone in [mech]. The actions read the state they show from the mech themselves.
/proc/golden_gardren_update_buttons(obj/vehicle/sealed/mecha/mech, action_type)
	for(var/mob/occupant as anything in mech.occupants)
		var/datum/action/button = LAZYACCESSASSOC(mech.occupant_actions, occupant, action_type)
		button?.build_all_button_icons()

/// Moves the pilot to the other, free seat of the Golden-Gardren.
/datum/action/vehicle/sealed/mecha/golden_gardren_swap_seat
	name = "Сменить место"
	desc = "Перебраться на свободное место второго пилота."
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/golden_gardren_swap_seat/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/golden_gardren/mech = chassis
	if(!istype(mech) || !(owner in mech.occupants))
		return
	if(mech.occupant_amount() >= mech.max_occupants)
		mech.balloon_alert(owner, "второе место занято!")
		return
	INVOKE_ASYNC(src, PROC_REF(swap_seat), mech)

/datum/action/vehicle/sealed/mecha/golden_gardren_swap_seat/proc/swap_seat(obj/vehicle/sealed/mecha/golden_gardren/mech)
	mech.balloon_alert(owner, "перебираюсь...")
	mech.is_currently_ejecting = TRUE
	var/moved = do_after(owner, mech.has_gravity() ? mech.exit_delay : 0, target = mech)
	mech.is_currently_ejecting = FALSE
	if(!moved)
		mech.balloon_alert(owner, "прервано!")
		return
	// The other pilot may have taken the free seat while we were climbing over.
	if(QDELETED(mech) || !(owner in mech.occupants) || mech.occupant_amount() >= mech.max_occupants)
		return
	var/to_main_seat = !mech.is_driver(owner)
	mech.assign_seat(owner, main_seat = to_main_seat)
	mech.balloon_alert(owner, to_main_seat ? "место пилота" : "место стрелка")

/// Missile strike of the weapons seat. Only the operator's own clicks pick targets, the main pilot keeps punching.
/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren
	name = "Ракетный удар"

/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	if(pilot != owner)
		return
	return ..()

/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	if(pilot != owner)
		return
	. = ..()
	// The click was spent on the missile, so the arm weapon must not fire as well.
	return COMPONENT_CANCEL_EQUIPMENT_CLICK

/// Same as the Savannah-Ivanov strike, but the missile is the Golden-Gardren one: a wider blast that sets the impact area on fire.
/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren/drop_missile(turf/target_turf)
	rockets_left--
	if(rockets_left <= 0)
		end_missile_targeting()
	SEND_SOUND(owner, 'sound/machines/beep/triple_beep.ogg')
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, strike_cooldown_time)
	podspawn(list(
		"target" = target_turf,
		"path" = /obj/structure/closet/supplypod/podspawn/golden_gardren_missile,
		"style" = /datum/pod_style/missile,
		"effectMissile" = TRUE,
		"explosionSize" = list(0, 0, 2, 2),
	))
	button_icon_state = "mech_ivanov_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/vehicle/sealed/mecha/ivanov_strike, reset_button_icon)), strike_cooldown_time)

/**
 * Missile of the Golden-Gardren strike. On top of the blast it sets the impact turf and the eight around it on fire,
 * burns everyone there and leaves the floor broken and scorched.
 */
/obj/structure/closet/supplypod/podspawn/golden_gardren_missile

/obj/structure/closet/supplypod/podspawn/golden_gardren_missile/pre_open()
	// The missile is deleted by the landing itself, so the impact turf is taken first.
	var/turf/impact = get_turf(src)
	. = ..()
	if(!impact)
		return
	for(var/turf/scorched in range(1, impact))
		if(isopenturf(scorched) && !isspaceturf(scorched))
			if(scorched == impact || prob(50))
				scorched.break_tile()
			else
				scorched.burn_tile()
			if(!(locate(/obj/effect/hotspot) in scorched))
				new /obj/effect/hotspot(scorched)
		for(var/mob/living/victim in scorched)
			victim.apply_damage(GOLDEN_GARDREN_MISSILE_BURN, BURN, spread_damage = TRUE)
			victim.adjust_fire_stacks(GOLDEN_GARDREN_MISSILE_FIRE_STACKS)
			victim.ignite_mob()

/// Golden Ram: a short dash forward that knocks down and throws everyone in the way. Main seat only.
/datum/action/vehicle/sealed/mecha/golden_gardren_ram
	name = "Золотой таран"
	desc = "Рывок на три клетки вперёд, сбивающий с ног всех на пути. Тратит много энергии."
	button_icon = 'modular_bandastation/golden_gardren/icons/actions.dmi'
	button_icon_state = "ram"
	/// Whether a dash is in progress.
	var/charging = FALSE

/datum/action/vehicle/sealed/mecha/golden_gardren_ram/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !chassis.is_driver(owner) || charging)
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_GOLDEN_GARDREN_RAM))
		chassis.balloon_alert(owner, "таран перезаряжается!")
		return
	if(chassis.completely_disabled || chassis.is_currently_ejecting || !isturf(chassis.loc))
		return
	if(!chassis.has_charge(GOLDEN_RAM_ENERGY))
		chassis.balloon_alert(owner, "мало энергии!")
		return
	chassis.use_energy(GOLDEN_RAM_ENERGY)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_GOLDEN_GARDREN_RAM, GOLDEN_RAM_COOLDOWN)
	INVOKE_ASYNC(src, PROC_REF(charge))

/datum/action/vehicle/sealed/mecha/golden_gardren_ram/proc/charge()
	charging = TRUE
	var/obj/vehicle/sealed/mecha/mech = chassis
	mech.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] бросается вперёд!"))
	playsound(mech, 'sound/vehicles/mecha/mechmove03.ogg', 75, TRUE)
	for(var/i in 1 to GOLDEN_RAM_DISTANCE)
		// Every step re-checks the mech and the pilot: either may be gone after the previous one.
		if(QDELETED(mech) || QDELETED(owner) || !mech.is_driver(owner) || mech.completely_disabled || !isturf(mech.loc))
			break
		var/turf/next_turf = get_step(mech, mech.dir)
		if(!next_turf)
			break
		var/hit_someone = FALSE
		for(var/mob/living/victim in next_turf)
			ram_hit(mech, victim)
			hit_someone = TRUE
		if(hit_someone || !step(mech, mech.dir))
			playsound(mech, 'sound/effects/meteorimpact.ogg', 60, TRUE)
			break
		sleep(1)
	charging = FALSE

/datum/action/vehicle/sealed/mecha/golden_gardren_ram/proc/ram_hit(obj/vehicle/sealed/mecha/mech, mob/living/victim)
	if(HAS_TRAIT(owner, TRAIT_PACIFISM))
		return
	log_combat(owner, victim, "rammed", mech)
	victim.visible_message(span_danger("[mech.declent_ru(NOMINATIVE)] сносит [victim.declent_ru(ACCUSATIVE)]!"), span_userdanger("[mech.declent_ru(NOMINATIVE)] сносит вас!"))
	victim.apply_damage(GOLDEN_RAM_DAMAGE, BRUTE, BODY_ZONE_CHEST, victim.run_armor_check(BODY_ZONE_CHEST, MELEE))
	victim.Knockdown(2 SECONDS)
	victim.throw_at(get_edge_target_turf(victim, mech.dir), GOLDEN_RAM_DISTANCE, 2, mech)

#undef GOLDEN_RAM_DISTANCE
#undef GOLDEN_RAM_DAMAGE
#undef GOLDEN_RAM_ENERGY
#undef GOLDEN_RAM_COOLDOWN
#undef GOLDEN_GARDREN_MISSILE_BURN
#undef GOLDEN_GARDREN_MISSILE_FIRE_STACKS
