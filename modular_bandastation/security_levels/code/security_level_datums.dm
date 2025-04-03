/datum/config_entry/string/alert_gamma
	default = "Центральным Командованием был установлен Код Гамма.\
	 Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."

/datum/config_entry/string/alert_epsilon
	default = "Центральным командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."

/datum/security_level
	/// Delay before this security level is set
	var/set_delay = 0

/// Called before setting or planning to set the security level
/datum/security_level/proc/pre_set_security_level()
	return

/// Called after setting security level, just before sending `COMSIG_SECURITY_LEVEL_CHANGED`
/datum/security_level/proc/post_set_security_level()
	return

/**
 * Gamma
 *
 * Station major hostile threats
 */
/datum/security_level/gamma
	name = "gamma"
	announcement_color = "orange"
	sound = 'modular_bandastation/security_levels/sound/new_siren.ogg'
	status_display_icon_state = "gammaalert"
	fire_alarm_light_color = LIGHT_COLOR_ORANGE
	announcement_color = "orange"
	name_shortform = "Γ"
	number_level = SEC_LEVEL_GAMMA
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * Epsilon
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */
/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "purple"
	sound = 'modular_bandastation/security_levels/sound/epsilon.ogg'
	number_level = SEC_LEVEL_EPSILON
	status_display_icon_state = "epsilonalert"
	fire_alarm_light_color = LIGHT_COLOR_BLOOD_MAGIC
	announcement_color = "red"
	name_shortform = "Ε"
	lowering_to_configuration_key = /datum/config_entry/string/alert_epsilon
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = 10
	set_delay = 15 SECONDS

/datum/security_level/epsilon/pre_set_security_level()
	power_fail(set_delay, set_delay)

/datum/security_level/epsilon/post_set_security_level()
	for(var/obj/machinery/light/light_to_update as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
		if(is_station_level(light_to_update.z))
			light_to_update.set_major_emergency_light()

		CHECK_TICK

	for(var/obj/machinery/power/apc/current_apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!current_apc.cell || !SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue

		var/area/apc_area = current_apc.area
		if(is_type_in_typecache(apc_area, GLOB.typecache_powerfailure_safe_areas))
			continue

		current_apc.reboot()
		CHECK_TICK


