/obj/item/choice_beacon/security_pistol
	name = "sidearm weapon beacon"
	desc = "Одноразовый маяк для доставки оружия по вашему выбору. Пожалуйста, используйте его только в своем офисе."

/obj/item/choice_beacon/security_pistol/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"GP-9 9x25mm Pistol" = /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec,
		"Disabler Energy Pistol" = /obj/item/gun/energy/disabler,
	)
	return selectable_gun_types

/obj/item/choice_beacon/security_pistol/open_options_menu(mob/living/user)
	ui_interact(user)

/obj/item/choice_beacon/security_pistol/ui_interact(mob/user, datum/tgui/ui)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChoiceBeaconWeapons", name)
		ui.open()

/obj/item/choice_beacon/security_pistol/ui_static_data(mob/user)
	var/static/list/weapon_info_cache
	if(!weapon_info_cache)
		weapon_info_cache = list()
		var/list/options = generate_display_names()
		for(var/display_name in options)
			var/list/info = build_weapon_info(display_name, options[display_name])
			if(info)
				weapon_info_cache += list(info)
	return list("weapons" = weapon_info_cache)

/obj/item/choice_beacon/security_pistol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action != "deliver")
		return
	var/mob/living/user = ui.user
	if(!istype(user) || !can_use_beacon(user))
		return TRUE
	var/list/options = generate_display_names()
	var/choice = params["choice"]
	if(!istext(choice) || isnull(options[choice]))
		return TRUE
	SStgui.close_uis(src)
	consume_use(options[choice], user)
	return TRUE

/obj/item/choice_beacon/security_pistol/proc/build_weapon_info(display_name, obj/item/choice_path)
	var/obj/item/container = new choice_path(null)
	var/obj/item/gun/weapon = istype(container, /obj/item/gun) ? container : (locate(/obj/item/gun) in container)
	if(!weapon)
		qdel(container)
		return null

	var/list/info = list(
		"name" = display_name,
		"desc" = weapon.desc,
		"image" = icon2base64(getFlatIcon(weapon)),
		"weapon_type" = "other",
	)

	var/casing_path
	if(istype(weapon, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic_gun = weapon
		info["weapon_type"] = "ballistic"
		var/obj/item/ammo_box/magazine/mag = ballistic_gun.magazine
		if(mag)
			casing_path = mag.ammo_type
			info["magazine_size"] = mag.max_ammo
	else if(istype(weapon, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = weapon
		info["weapon_type"] = "energy"
		var/shot = LAZYACCESS(energy_gun.ammo_type, 1)
		if(shot)
			casing_path = ispath(shot) ? shot : shot:type
			var/obj/item/ammo_casing/energy/energy_casing = casing_path
			var/e_cost = initial(energy_casing.e_cost)
			var/select_name = initial(energy_casing.select_name)
			info["ammo_name"] = select_name || initial(energy_casing.name)
			var/maxcharge = energy_gun.cell?.maxcharge
			if(maxcharge && e_cost)
				info["energy_cost_percent"] = round(100 * e_cost / maxcharge, 0.1)
				info["shots_per_charge"] = round(maxcharge / e_cost)

	if(casing_path)
		var/obj/item/ammo_casing/casing = casing_path
		var/obj/projectile/proj = initial(casing.projectile_type)
		if(!info["ammo_name"])
			info["ammo_name"] = initial(casing.name)
		info["weak_against_armour"] = !!initial(proj.weak_against_armour)
		var/pellets = max(initial(casing.pellets), 1)
		var/multiplier = weapon.projectile_damage_multiplier
		var/total_damage = initial(proj.damage) * multiplier * pellets
		var/total_stamina = initial(proj.stamina) * multiplier * pellets
		if(initial(proj.damage_type) == STAMINA)
			total_stamina += total_damage
			total_damage = 0
		if(total_damage > 0)
			info["hits_to_neutralize"] = HITS_TO_CRIT(total_damage)
		if(total_stamina > 0)
			info["hits_to_exhaust"] = HITS_TO_CRIT(total_stamina)

	qdel(container)
	return info

/datum/outfit/job/security
	suit_store = null
	backpack_contents = list(
		/obj/item/choice_beacon/security_pistol = 1,
	)
