/// Syndicate hardware creates this mob instead of changing the ordinary pAI at runtime.
/mob/living/silicon/pai/syndicate
	ram = 150
	var/chemical_reserve = 30
	var/chemical_recharge_running = FALSE
	COOLDOWN_DECLARE(chemical_injection)
	var/thermal_active = FALSE
	var/obj/machinery/computer/camera_advanced/syndicate_pai/camera_console
	var/obj/machinery/computer/records/security/syndicate_pai/records_console
	COOLDOWN_DECLARE(remote_machinery_action)
	var/obj/machinery/power/apc/active_remote_apc
	var/list/syndicate_software = list(
		"Thermal Vision" = 35,
		"Medical Injector" = 60,
		"Camera Network" = 30,
		"Remote Machinery" = 60,
		"Security Records" = 25,
		"Syndicate Radio" = 5,
	)

/mob/living/silicon/pai/syndicate/Initialize(mapload)
	. = ..()
	available_software += syndicate_software

/mob/living/silicon/pai/syndicate/Destroy()
	QDEL_NULL(camera_console)
	QDEL_NULL(records_console)
	return ..()

/// The Syndicate's built-in key stays in the internal radio when a carrier removes their chip.
/obj/item/radio/headset/silicon/pai/remove_keys(mob/living/user)
	if(istype(keyslot2, /obj/item/encryptionkey/syndicate))
		. = list()
		if(!keyslot)
			return
		. += keyslot
		user.put_in_hands(keyslot)
		return
	return ..()
