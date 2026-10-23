/// SS220 uses nutrition as charge: 50 nutrition consumes half a standard power cell.
#define IPC_ENERGY_PER_NUTRITION (STANDARD_CELL_CHARGE * 0.01)
#define IPC_CRITICAL_CHARGE 100
#define IPC_CHARGE_ALERT "ipc_charge"

/// An IPC's removable personality core lives in its chest, independently of its display.
/obj/item/organ/brain/ipc
	parent_type = /obj/item/organ/brain/cybernetic
	name = "positronic brain"
	desc = "A positronic personality core designed for a fully prosthetic chassis."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "posibrain"
	zone = BODY_ZONE_CHEST
	visual = FALSE
	can_smoothen_out = FALSE
	/// Powers the existing brainmob while the core is outside a chassis; never creates a second personality.
	var/obj/item/brain_processor/ipc_core/personal_processor

/obj/item/organ/brain/ipc/Destroy()
	release_processor()
	return ..()

/// Ordinary and deep-rooted organic traumas do not apply to a positronic core; higher resilience retains its rules.
/obj/item/organ/brain/ipc/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	var/effective_resilience = resilience
	if(!effective_resilience)
		effective_resilience = ispath(trauma) ? initial(trauma.resilience) : trauma.resilience
	if(effective_resilience <= TRAUMA_RESILIENCE_LOBOTOMY)
		return FALSE
	return ..()

/obj/item/organ/brain/ipc/transfer_identity(mob/living/person)
	. = ..()
	activate_processor()

/obj/item/organ/brain/ipc/on_mob_insert(mob/living/carbon/brain_owner, special, movement_flags)
	release_processor()
	// Species changes can transfer existing traumas without consulting can_gain_trauma().
	cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	return ..()

/// Neural debugging can also repair ordinary deep-rooted errors left on older positronic cores.
/datum/surgery_operation/organ/repair/brain/mechanic/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	if(istype(organ, /obj/item/organ/brain/ipc))
		organ.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)

/obj/item/organ/brain/ipc/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELING(src))
		return
	if(istype(loc, /obj/item/brain_processor))
		// The MMI will take over brainmob ownership after moving this organ into itself.
		release_processor()
	else if(!owner)
		activate_processor()

/obj/item/organ/brain/ipc/on_begin_failure()
	. = ..()
	brainmob?.death()

/obj/item/organ/brain/ipc/on_failure_recovery()
	. = ..()
	if(!owner)
		activate_processor()

/// Supplies speech and consciousness to an extracted core while preserving the native organ's identity transfer.
/obj/item/organ/brain/ipc/proc/activate_processor()
	if(QDELING(src) || owner || !brainmob || istype(loc, /obj/item/brain_processor))
		return
	if(brainmob.container && brainmob.container != personal_processor)
		return
	if(!personal_processor)
		personal_processor = new(src)
	personal_processor.set_brainmob(brainmob)
	if(brainmob.loc != personal_processor)
		brainmob.forceMove(personal_processor)
		brainmob.reset_perspective()
	if(!suicided && !HAS_TRAIT(brainmob, TRAIT_SUICIDED) && !(organ_flags & ORGAN_FAILING) && brainmob.health > brainmob.dead_threshold)
		var/was_dead = brainmob.stat == DEAD
		brainmob.set_stat(STABLE)
		if(was_dead && brainmob.key && !decoy_override)
			brainmob.notify_revival("Ваш позитронный мозг перешёл на автономное питание.", source = src)

/// The organ retains brainmob ownership; clear the processor's reference before deleting the processor.
/obj/item/organ/brain/ipc/proc/release_processor()
	if(!personal_processor)
		return
	personal_processor.set_brainmob(null)
	if(brainmob && brainmob.loc == personal_processor)
		brainmob.forceMove(src)
		brainmob.reset_perspective()
	QDEL_NULL(personal_processor)

/// A private housing for an organ's existing brainmob, without ghost recruitment or a second identity.
/obj/item/brain_processor/ipc_core
	name = "positronic core interface"
	braintype = "Android"

/obj/item/brain_processor/ipc_core/Destroy()
	// Brain gibbing can delete its container directly, independently of the organ's cleanup.
	var/obj/item/organ/brain/ipc/core = loc
	if(istype(core) && core.personal_processor == src)
		core.personal_processor = null
		if(core.brainmob == brainmob)
			core.brainmob = null
	return ..()


/// The vital IPC power controller. The owner's nutrition is the single source of stored charge.
/obj/item/organ/heart/ipc
	name = "microbattery"
	desc = "A compact power controller and battery for a fully prosthetic chassis."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"
	organ_flags = ORGAN_ROBOTIC | ORGAN_VITAL
	organ_traits = list(TRAIT_NOHUNGER, TRAIT_STABLEHEART)
	maxHealth = 60
	low_threshold = 6
	high_threshold = 27
	decay_factor = 0
	healing_factor = 0
	blood_regeneration_multiplier = 0
	low_threshold_passed = span_warning("Диагностика: повреждение микробатареи.")
	high_threshold_passed = span_warning("Диагностика: критическое повреждение микробатареи!")
	now_failing = span_userdanger("Ошибка питания: микробатарея вышла из строя!")
	now_fixed = span_notice("Микробатарея снова функционирует.")
	high_threshold_cleared = span_notice("Повреждение микробатареи больше не является критическим.")
	failing_desc = "is burnt out."
	/// Adapter required by the cyborg charger's cell API; synchronized only while receiving power.
	var/obj/item/stock_parts/power_store/cell/ipc_charging_buffer/charging_buffer
	/// Avoid rebuilding unchanged HUD text on every metabolism tick.
	var/displayed_charge

/obj/item/organ/heart/ipc/Destroy()
	QDEL_NULL(charging_buffer)
	return ..()

/obj/item/organ/heart/ipc/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/item/organ/heart/ipc/on_mob_insert(mob/living/carbon/battery_owner, special, movement_flags)
	. = ..()
	RegisterSignal(battery_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_charger))
	displayed_charge = null
	update_charge_alert()

/obj/item/organ/heart/ipc/on_mob_remove(mob/living/carbon/battery_owner, special, movement_flags)
	UnregisterSignal(battery_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	battery_owner.clear_alert(IPC_CHARGE_ALERT)
	displayed_charge = null
	return ..()

/obj/item/organ/heart/ipc/on_life(seconds_per_tick)
	. = ..()
	if(!owner || owner.stat == DEAD || (organ_flags & ORGAN_FAILING))
		return
	// Paradise does not punish disconnected players for running out of power.
	if(!owner.client)
		return
	adjust_charge(-HUNGER_FACTOR * seconds_per_tick)
	if(owner.nutrition >= IPC_CRITICAL_CHARGE)
		return
	if(SPT_PROB(3, seconds_per_tick))
		to_chat(owner, span_warning("Ошибка 74: микробатарея повреждена из-за продолжительного недостатка питания."))
		apply_organ_damage(4)
	else if(SPT_PROB(2, seconds_per_tick))
		owner.Paralyze(6 SECONDS)
		owner.set_stutter_if_lower(20 SECONDS)
		to_chat(owner, span_warning("Критический уровень заряда. Отключение второстепенных систем."))
		apply_organ_damage(2)
	else if(SPT_PROB(2, seconds_per_tick))
		owner.adjust_staggered_up_to(15 SECONDS, 32 SECONDS)
		to_chat(owner, span_warning("Перенаправление энергии сервоприводов на жизненно важные компоненты."))

/obj/item/organ/heart/ipc/organ_failure(seconds_per_tick)
	. = ..()
	owner.death()

/obj/item/organ/heart/ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(severity == EMP_HEAVY ? 20 : 7)

/// Changes nutrition-based charge and returns the amount accepted; failed batteries cannot charge.
/obj/item/organ/heart/ipc/proc/adjust_charge(amount)
	if(!owner || (organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		return 0
	var/accepted = clamp(amount, -owner.nutrition, NUTRITION_LEVEL_FULL - owner.nutrition)
	owner.adjust_nutrition(accepted, forced = TRUE)
	update_charge_alert()
	return accepted

/// Uses the station's callback so power availability, upgraded parts, and actual energy costs still apply.
/obj/item/organ/heart/ipc/proc/on_charger(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER
	if(!owner || (organ_flags & (ORGAN_FAILING | ORGAN_EMP)) || owner.nutrition >= NUTRITION_LEVEL_FULL)
		return
	if(!charging_buffer)
		charging_buffer = new(src)
	charging_buffer.charge = clamp(owner.nutrition, 0, NUTRITION_LEVEL_FULL) * IPC_ENERGY_PER_NUTRITION
	var/energy_received = charge_cell.Invoke(charging_buffer, seconds_per_tick)
	adjust_charge(energy_received / IPC_ENERGY_PER_NUTRITION)
	charging_buffer.charge = 0

/// A persistent battery indicator replaces the hunger display suppressed by TRAIT_NOHUNGER.
/obj/item/organ/heart/ipc/proc/update_charge_alert()
	if(QDELETED(owner))
		return
	var/percentage = round(clamp(owner.nutrition / NUTRITION_LEVEL_FULL, 0, 1) * 100)
	if(percentage == displayed_charge && owner.alerts[IPC_CHARGE_ALERT])
		return
	displayed_charge = percentage
	var/atom/movable/screen/alert/ipc_charge/charge_alert = owner.throw_alert(IPC_CHARGE_ALERT, /atom/movable/screen/alert/ipc_charge)
	charge_alert.maptext = MAPTEXT("[percentage]%")
	charge_alert.desc = "Заряд микробатареи: [percentage]%. Для зарядки подключите кабель к ЛКП или войдите в станцию зарядки киборгов."

/// An internal transport buffer, never used to store an independent charge balance.
/obj/item/stock_parts/power_store/cell/ipc_charging_buffer
	name = "IPC charging interface"
	maxcharge = NUTRITION_LEVEL_FULL * IPC_ENERGY_PER_NUTRITION
	empty = TRUE
	ratingdesc = FALSE
	custom_materials = null
	charge_light_type = null

/// Shows IPC charge without sharing the cyborg, MODsuit, or ethereal alert category.
/atom/movable/screen/alert/ipc_charge
	name = "Заряд микробатареи"
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"

/// Standard IPC cameras retain normal vision, without buying upgraded robotic eye abilities.
/obj/item/organ/eyes/robotic/ipc
	name = "optical sensor"
	desc = "A camera assembly for a fully prosthetic chassis."
	iris_overlay = null

/obj/item/organ/eyes/robotic/ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(severity == EMP_HEAVY ? 20 : 7)

/// IPC microphones use the target's ordinary robotic hearing and surgical interfaces.
/obj/item/organ/ears/cybernetic/ipc
	name = "microphone"
	desc = "A microphone assembly for a fully prosthetic chassis."
	damage_multiplier = 1
	organ_traits = null

/// The native robotic voicebox provides synthetic speech and local encoded audio language.
/obj/item/organ/tongue/robot/ipc
	sense_of_taste = FALSE

/// An extendable charging connector uses the established arm toolkit lifecycle and action.
/obj/item/organ/cyberimp/arm/power_cord/ipc
	parent_type = /obj/item/organ/cyberimp/arm/toolkit
	name = "APC-compatible power adapter"
	desc = "A retractable power connector for recharging a fully prosthetic chassis from an APC."
	items_to_create = list(/obj/item/ipc_power_cord)
	hand_state = FALSE

/obj/item/organ/cyberimp/arm/power_cord/ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	// Paradise's charging adapter shuts down after an EMP until its circuitry is repaired.
	apply_organ_damage(maxHealth)
	Retract()

/obj/item/organ/cyberimp/arm/power_cord/ipc/examine(mob/user)
	. = ..()
	if(damage)
		. += span_notice("Извлечённый адаптер можно восстановить отвёрткой.")

/obj/item/organ/cyberimp/arm/power_cord/ipc/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. || owner || !damage)
		return .
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || owner || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return ITEM_INTERACT_BLOCKING
	set_organ_damage(0)
	organ_flags &= ~ORGAN_EMP
	to_chat(user, span_notice("Вы восстанавливаете контакты адаптера питания."))
	return ITEM_INTERACT_SUCCESS

#undef IPC_ENERGY_PER_NUTRITION
#undef IPC_CRITICAL_CHARGE
#undef IPC_CHARGE_ALERT
