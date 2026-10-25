/// Shadow attacks only suppress the light sources supported by the donor, including carried lights.
/proc/shadow_demon_extinguish(atom/target, overload = FALSE)
	if(QDELETED(target))
		return
	if(isliving(target))
		for(var/atom/contained as anything in target.contents)
			if(contained.light_range > 0 || contained.GetComponent(/datum/component/seclite_attachable) || istype(contained, /obj/item/mod/control) || istype(contained, /obj/item/pai_card))
				shadow_demon_extinguish(contained, overload)
		if(iscyborg(target))
			var/mob/living/silicon/robot/robot = target
			robot.toggle_headlamp(TRUE)
			COOLDOWN_START(robot, disabled_time, 15 SECONDS)
		else if(istype(target, /mob/living/silicon/pai))
			target.set_light_on(FALSE)
		return
	if(isitem(target))
		var/datum/component/seclite_attachable/attachment = target.GetComponent(/datum/component/seclite_attachable)
		if(attachment?.light)
			shadow_demon_extinguish(attachment.light, overload)
			attachment.update_light()
	if(istype(target, /obj/item/mod/control))
		var/obj/item/mod/control/control = target
		for(var/obj/item/mod/module/flashlight/lamp in control.modules)
			shadow_demon_extinguish(lamp, overload)
		return
	if(istype(target, /obj/item/mod/module/flashlight))
		var/obj/item/mod/module/flashlight/lamp = target
		// MOD lamps replace Paradise's helmet lights. Darkness modules remain beneficial.
		if(lamp.active && lamp.light_power > 0 && !istype(lamp, /obj/item/mod/module/flashlight/darkness))
			lamp.deactivate(display_message = FALSE)
		return
	if(istype(target, /obj/item/pai_card))
		var/obj/item/pai_card/card = target
		if(card.pai)
			card.pai.set_light_on(FALSE)
		return
	if(istype(target, /turf/open/floor/light))
		var/turf/open/floor/light/floor_light = target
		floor_light.on = FALSE
		floor_light.update_appearance()
		return
	if(istype(target, /obj/machinery/light))
		target.AddComponent(/datum/component/shadow_demon_blackout)
		return
	if(istype(target, /obj/machinery/power/floodlight))
		var/obj/machinery/power/floodlight/floodlight = target
		floodlight.change_setting(1) // The first native power setting is off.
		return
	if(istype(target, /obj/machinery/computer) || istype(target, /obj/machinery/vending) || istype(target, /obj/machinery/smartfridge) || istype(target, /obj/machinery/door/firedoor))
		target.set_light_range(0)
		if(target.light_system == COMPLEX_LIGHT)
			target.update_light()
		target.underlays.Cut()
		return
	if(istype(target, /obj/structure/glowshroom))
		if(!istype(target, /obj/structure/glowshroom/shadowshroom))
			qdel(target)
		return
	if(istype(target, /obj/item/food/grown))
		var/obj/item/food/grown/produce = target
		if(!produce.seed?.get_gene(/datum/plant_gene/trait/glow/shadow))
			produce.set_light_range(0)
			if(produce.light_system == COMPLEX_LIGHT)
				produce.update_light()
		return
	if(istype(target, /obj/item/grown))
		var/obj/item/grown/produce = target
		if(!produce.seed?.get_gene(/datum/plant_gene/trait/glow/shadow))
			produce.set_light_range(0)
			if(produce.light_system == COMPLEX_LIGHT)
				produce.update_light()
		return
	if(istype(target, /obj/item/flashlight/slime))
		if(overload)
			target.visible_message(span_danger("[target] увядает."))
			qdel(target)
		return
	if(istype(target, /obj/item/flashlight/flare))
		if(overload)
			var/obj/item/flashlight/flare/flare = target
			flare.fuel = 0
			flare.turn_off()
		return
	if(istype(target, /obj/item/flashlight))
		var/obj/item/flashlight/flashlight = target
		flashlight.set_light_on(FALSE)
		flashlight.update_brightness()
		flashlight.update_item_action_buttons()
		return
	if(istype(target, /obj/item/clothing/head/utility/hardhat))
		var/obj/item/clothing/head/utility/hardhat/hat = target
		hat.on = FALSE
		hat.turn_off()
		hat.update_appearance()
		return
	if(istype(target, /obj/item/clothing/head/helmet/space/plasmaman))
		var/obj/item/clothing/head/helmet/space/plasmaman/helmet = target
		helmet.helmet_on = FALSE
		helmet.set_light_on(FALSE)
		helmet.update_appearance()
		helmet.update_item_action_buttons()
		return
	if(istype(target, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = target
		computer.set_light_on(FALSE)
		computer.update_appearance()
		computer.update_item_action_buttons()
		return
	if(!overload)
		return
	if(istype(target, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = target
		welder.reagents.remove_reagent(/datum/reagent/fuel, welder.max_fuel)
		welder.switched_off()
	else if(istype(target, /obj/item/lighter))
		var/obj/item/lighter/lighter = target
		lighter.set_lit(FALSE)
	else if(istype(target, /obj/item/match))
		var/obj/item/match/match = target
		match.matchburnout()
	else if(istype(target, /obj/item/cigarette))
		var/obj/item/cigarette/cigarette = target
		if(cigarette.lit)
			cigarette.put_out()

/// Five-minute fixture suppression survives APC power changes without breaking the bulb.
/datum/component/shadow_demon_blackout
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Preserve whether this particular fixture normally supports emergency lighting.
	var/previous_no_low_power
	/// A repeat grapple or cocoon pulse renews this timer.
	var/restore_timer

/datum/component/shadow_demon_blackout/Initialize()
	if(!istype(parent, /obj/machinery/light))
		return COMPONENT_INCOMPATIBLE
	var/obj/machinery/light/fixture = parent
	previous_no_low_power = fixture.no_low_power
	fixture.no_low_power = TRUE
	fixture.set_on(FALSE)
	fixture.update(FALSE)
	fixture.visible_message(span_danger("[fixture] мерцает и гаснет."))
	renew()

/datum/component/shadow_demon_blackout/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIGHT_FIXTURE_TOGGLED, PROC_REF(on_light_toggled))

/datum/component/shadow_demon_blackout/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIGHT_FIXTURE_TOGGLED)
	var/obj/machinery/light/fixture = parent
	fixture.no_low_power = previous_no_low_power
	if(!QDELETED(fixture))
		fixture.set_on(fixture.has_power())
		fixture.update(FALSE)

/datum/component/shadow_demon_blackout/InheritComponent(datum/component/new_component, i_am_original)
	if(i_am_original)
		renew()

/datum/component/shadow_demon_blackout/Destroy(force)
	if(restore_timer)
		deltimer(restore_timer)
		restore_timer = null
	return ..()

/datum/component/shadow_demon_blackout/proc/renew()
	if(restore_timer)
		deltimer(restore_timer)
	restore_timer = addtimer(CALLBACK(src, PROC_REF(restore_light)), 5 MINUTES, TIMER_STOPPABLE)

/datum/component/shadow_demon_blackout/proc/restore_light()
	restore_timer = null
	qdel(src)

/datum/component/shadow_demon_blackout/proc/on_light_toggled(obj/machinery/light/fixture, new_status)
	SIGNAL_HANDLER
	if(new_status)
		fixture.set_on(FALSE)
