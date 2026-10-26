//MARK: Main code
/obj/item/choice_beacon/weapon
	name = "sidearm weapon beacon"
	desc = "Одноразовый маяк для доставки оружия по вашему выбору. Пожалуйста, используйте его только в своем офисе."
	var/static/list/selectable_gun_types = list()

/obj/item/choice_beacon/weapon/ui_interact(mob/user, datum/tgui/ui)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChoiceBeaconWeapons", name)
		ui.open()

/obj/item/choice_beacon/weapon/open_options_menu(mob/living/user)
	ui_interact(user)

/obj/item/choice_beacon/weapon/ui_interact(mob/user, datum/tgui/ui)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChoiceBeaconWeapons", name)
		ui.open()

/obj/item/choice_beacon/weapon/ui_static_data(mob/user)
	var/static/list/weapon_info_cache
	if(!weapon_info_cache)
		weapon_info_cache = list()
		var/list/options = generate_display_names()
		for(var/display_name in options)
			var/list/info = build_weapon_info(display_name, options[display_name])
			if(info)
				weapon_info_cache += list(info)
	return list("weapons" = weapon_info_cache)

/obj/item/choice_beacon/weapon/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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

/obj/item/choice_beacon/weapon/proc/build_weapon_info(display_name, obj/item/choice_path)
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

	var/list/casing_paths = list()
	var/maxcharge
	if(istype(weapon, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic_gun = weapon
		info["weapon_type"] = "ballistic"
		var/obj/item/ammo_box/magazine/mag = ballistic_gun.magazine
		if(mag)
			casing_paths += mag.ammo_type
			info["magazine_size"] = mag.max_ammo
	else if(istype(weapon, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = weapon
		info["weapon_type"] = "energy"
		maxcharge = energy_gun.cell?.maxcharge
		for(var/shot in energy_gun.ammo_type)
			casing_paths += ispath(shot) ? shot : shot:type

	var/list/modes = list()
	for(var/casing_path in casing_paths)
		modes += list(build_mode_info(casing_path, weapon, maxcharge))
	info["modes"] = modes

	qdel(container)
	return info

/obj/item/choice_beacon/weapon/proc/build_mode_info(casing_path, obj/item/gun/weapon, maxcharge)
	var/obj/item/ammo_casing/casing = casing_path
	var/obj/projectile/proj = initial(casing.projectile_type)
	var/list/mode = list(
		"ammo_name" = initial(casing.name),
		"weak_against_armour" = !!initial(proj.weak_against_armour),
	)

	if(ispath(casing_path, /obj/item/ammo_casing/energy))
		var/obj/item/ammo_casing/energy/energy_casing = casing_path
		mode["ammo_name"] = initial(energy_casing.select_name) || initial(energy_casing.name)
		var/e_cost = initial(energy_casing.e_cost)
		if(maxcharge && e_cost)
			mode["energy_cost_percent"] = round(100 * e_cost / maxcharge, 0.1)
			mode["shots_per_charge"] = round(maxcharge / e_cost)

	var/pellets = max(initial(casing.pellets), 1)
	var/multiplier = weapon.projectile_damage_multiplier
	var/total_damage = initial(proj.damage) * multiplier * pellets
	var/total_stamina = initial(proj.stamina) * multiplier * pellets
	if(initial(proj.damage_type) == STAMINA)
		total_stamina += total_damage
		total_damage = 0
	if(total_damage > 0)
		mode["hits_to_neutralize"] = HITS_TO_CRIT(total_damage)
	if(total_stamina > 0)
		mode["hits_to_exhaust"] = HITS_TO_CRIT(total_stamina)
	return mode

//MARK: Beacons types
/obj/item/choice_beacon/weapon/security_pistol
	name = "security sidearm weapon beacon"

/obj/item/choice_beacon/weapon/security_pistol/generate_display_names()
	selectable_gun_types = list(
		"Пистолет GP-9 9x25мм" = /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec,
		"Энергетический пистолет дизейблер" = /obj/item/gun/energy/disabler,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/blueshield
	name = "blueshield sidearm weapon beacon"

/obj/item/choice_beacon/weapon/blueshield/generate_display_names()
	selectable_gun_types = list(
		"Энергетический пистолет EG-14" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/eg_14,
		"Термально-нанитовый пистолет TNG-3" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/tng_3,
		"Пистолет GP-38 калибра .38" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp38,
		"PDH-A1-M 'Ladon'" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/ladon,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/hos
	name = "HoS sidearm weapon beacon"

/obj/item/choice_beacon/weapon/hos/generate_display_names()
	selectable_gun_types = list(
		"Мультифазовый энергетический пистолет X-01" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_laser,
		"Лазерный пистолет X-02" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_laser2,
		"Пистолет GP-45M калибра .45" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_gp45,
		"PDH-A2-NR 'Osprey'" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_pdh,
	)
	return selectable_gun_types

//MARK: Job`s contents
/obj/structure/closet/secure_closet/hos/PopulateContents()
	. = ..()
	new /obj/item/clothing/accessory/holster(src)

/datum/outfit/job/security
	suit_store = null
	backpack_contents = list(
		/obj/item/choice_beacon/weapon/security_pistol = 1,
	)

/datum/objective_item/steal/hoslaser
	targetitem = /obj/item/choice_beacon/weapon/hos
	exists_on_map = FALSE
	altitems = list(/obj/item/gun/ballistic/automatic/pistol/pdh/hos, /obj/item/gun/ballistic/automatic/pistol/cm70/hos, /obj/item/gun/ballistic/automatic/laser/pistol, /obj/item/gun/energy/e_gun/hos)
