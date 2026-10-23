#define IPC_APC_CHARGE_RATE 50
#define IPC_APC_ENERGY_PER_NUTRITION (STANDARD_CELL_CHARGE * 0.01)

/// The IPC's extendable connector. Charging is interrupted by movement, removal, or power failure.
/obj/item/ipc_power_cord
	name = "power cable"
	desc = "A retractable power connector. Plug it into an APC to recharge your microbattery."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	/// Locked before starting the asynchronous loop so parallel clicks cannot multiply charging.
	var/drawing_power = FALSE

/obj/item/ipc_power_cord/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/power/apc) || !iscarbon(user))
		return NONE
	if(drawing_power)
		balloon_alert(user, "уже заряжается!")
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/power/apc/apc = interacting_with
	var/mob/living/carbon/carbon_user = user
	if(!can_charge(apc, carbon_user))
		return ITEM_INTERACT_BLOCKING
	drawing_power = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge_from_apc), apc, carbon_user)
	return ITEM_INTERACT_SUCCESS

/// Revalidates the actual held connector, battery, and APC each time before transferring energy.
/obj/item/ipc_power_cord/proc/can_charge(obj/machinery/power/apc/apc, mob/living/carbon/user)
	if(QDELETED(apc) || QDELETED(user) || !user.is_holding(src) || !user.can_perform_action(apc, FORBID_TELEKINESIS_REACH))
		return FALSE
	var/obj/item/organ/heart/ipc/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(battery) || (battery.organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		balloon_alert(user, "нет рабочей микробатареи!")
		return FALSE
	if((apc.obj_flags & EMAGGED) || (apc.machine_stat & BROKEN))
		do_sparks(3, TRUE, apc)
		user.adjust_fire_loss(10)
		to_chat(user, span_userdanger("Неисправный ЛКП повредил корпус скачком напряжения!"))
		return FALSE
	if(QDELETED(apc.cell) || apc.cell.charge() <= 0)
		balloon_alert(user, "в ЛКП нет заряда!")
		return FALSE
	if(user.nutrition >= NUTRITION_LEVEL_WELL_FED)
		balloon_alert(user, "зарядка завершена")
		return FALSE
	return TRUE

/// Transfers a bounded amount of real APC energy once per completed charging interval.
/obj/item/ipc_power_cord/proc/charge_from_apc(obj/machinery/power/apc/apc, mob/living/carbon/user)
	user.visible_message(span_notice("[user] подключает кабель питания к [apc]."), span_notice("Вы подключаете кабель питания к [apc]."))
	while(!QDELETED(src) && !QDELETED(apc) && !QDELETED(user) && do_after(user, 1 SECONDS, target = apc))
		if(!can_charge(apc, user))
			break
		var/obj/item/organ/heart/ipc/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
		var/requested_nutrition = min(IPC_APC_CHARGE_RATE, NUTRITION_LEVEL_WELL_FED - user.nutrition)
		var/energy_received = apc.cell.use(requested_nutrition * IPC_APC_ENERGY_PER_NUTRITION, force = TRUE)
		if(QDELETED(battery) || !energy_received)
			break
		battery.adjust_charge(energy_received / IPC_APC_ENERGY_PER_NUTRITION)
		apc.charging = APC_CHARGING
		apc.update_appearance()
	if(!QDELETED(user))
		to_chat(user, span_notice("Вы отключаете кабель питания."))
	drawing_power = FALSE

#undef IPC_APC_CHARGE_RATE
#undef IPC_APC_ENERGY_PER_NUTRITION
