// BANDASTATION ADDITION - Exercise real loadouts, mixed ammunition and seclight attachment.
/datum/unit_test/sec_force_loadout
	var/last_impact_sharpness
	var/last_impact_damage_type

/datum/unit_test/sec_force_loadout/proc/record_impact(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness)
	SIGNAL_HANDLER
	last_impact_sharpness = sharpness
	last_impact_damage_type = damagetype

/datum/unit_test/sec_force_loadout/Run()
	var/obj/item/gun/ballistic/automatic/pistol/sec_force/mk58/mk58 = allocate(/obj/item/gun/ballistic/automatic/pistol/sec_force/mk58)
	var/obj/item/gun/ballistic/automatic/pistol/sec_force/viper/viper = allocate(/obj/item/gun/ballistic/automatic/pistol/sec_force/viper)
	var/obj/item/knife/security_service/knife = allocate(/obj/item/knife/security_service)
	var/obj/item/flashlight/seclite/light = allocate(/obj/item/flashlight/seclite)
	TEST_ASSERT_NULL(knife.embed_type, "The service knife must not inherit combat-knife embedding.")
	for(var/obj/item/gun/ballistic/automatic/pistol/sec_force/pistol as anything in list(mk58, viper))
		TEST_ASSERT(istype(pistol.magazine, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber), "[pistol.type] did not spawn with a shared rubber magazine.")
		TEST_ASSERT(istype(pistol.chambered, /obj/item/ammo_casing/c9x25mm/rubber), "[pistol.type] spawned with a lethal chambered round.")
		TEST_ASSERT_EQUAL(pistol.magazine.ammo_count(), 12, "A spawned pistol should have a full 12-round magazine, in addition to its chambered round.")
		TEST_ASSERT_EQUAL(pistol.magazine.icon_state, "nt9x25-12", "The spawned magazine did not resolve its full numerical icon.")
		TEST_ASSERT(istype(pistol.magazine, pistol.accepted_magazine_type), "The spawned magazine is incompatible with its pistol.")
		TEST_ASSERT(icon_exists(pistol.icon, "[pistol.icon_state]_bolt_locked"), "The open-slide overlay is missing.")
		TEST_ASSERT(icon_exists(pistol.icon, "[pistol.icon_state]_mag"), "The inserted-magazine overlay is missing.")
	var/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/empty/magazine = allocate(/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/empty)
	TEST_ASSERT_EQUAL(magazine.ammo_count(), 0, "An empty test magazine spawned loaded.")
	TEST_ASSERT_EQUAL(magazine.icon_state, "nt9x25-0", "The empty magazine did not show its empty state.")
	for(var/count in 1 to 12)
		var/obj/item/ammo_casing/casing
		if(count % 2)
			casing = allocate(/obj/item/ammo_casing/c9x25mm/rubber)
		else
			casing = allocate(/obj/item/ammo_casing/c9x25mm)
		TEST_ASSERT(magazine.give_round(casing), "The shared magazine rejected compatible mixed 9x25 NT ammunition.")
		magazine.update_appearance()
		TEST_ASSERT_EQUAL(magazine.ammo_count(), count, "Loading a round did not increase the magazine count.")
		TEST_ASSERT_EQUAL(magazine.icon_state, "nt9x25-[count]", "The numerical icon did not follow the actual magazine contents.")
		TEST_ASSERT(icon_exists(magazine.icon, magazine.icon_state), "A magazine count resolved to a missing sprite.")
	var/obj/item/ammo_casing/extra_round = allocate(/obj/item/ammo_casing/c9x25mm)
	TEST_ASSERT(!magazine.give_round(extra_round), "The standard magazine accepted a thirteenth round.")
	for(var/count in 12 to 1 step -1)
		var/obj/item/ammo_casing/casing = magazine.get_round()
		TEST_ASSERT_NOTNULL(casing, "The magazine lost a round before it could be removed.")
		casing.forceMove(run_loc_floor_bottom_left)
		TEST_ASSERT_EQUAL(magazine.ammo_count(), count - 1, "Removing a round did not update the stored ammunition.")
		TEST_ASSERT_EQUAL(magazine.icon_state, "nt9x25-[count - 1]", "Removing a round did not update the numerical icon.")
	var/datum/component/seclite_attachable/mount = mk58.GetComponent(/datum/component/seclite_attachable)
	TEST_ASSERT_NOTNULL(mount, "Mk58 has no seclight mount.")
	mount.add_light(light)
	TEST_ASSERT_EQUAL(light.loc, mk58, "Attaching the seclight did not move it into the pistol.")
	TEST_ASSERT_EQUAL(mount.light, light, "The mount lost its attached seclight.")
	light.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_NULL(mount.light, "Removing the seclight left a stale reference on the mount.")

	TEST_ASSERT_EQUAL(mk58.declent_ru(NOMINATIVE), "МК-58 «Регламент»", "Mk58 did not receive its Russian service name.")
	TEST_ASSERT_EQUAL(viper.declent_ru(NOMINATIVE), "ПС-3 «Гюрза»", "Viper did not receive its Russian service name.")

	// Exercise the real object-damage modifiers: weaker melee must retain useful cutting.
	var/mob/living/carbon/human/consistent/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/structure/spacevine/vine = allocate(/obj/structure/spacevine)
	vine.attacked_by(knife, user, list(), list())
	TEST_ASSERT(QDELETED(vine), "The service knife should still cut an ordinary vine in one hit.")
	var/obj/structure/spider/stickyweb/web = allocate(/obj/structure/spider/stickyweb)
	for(var/hit in 1 to 4)
		web.attacked_by(knife, user, list(), list())
		TEST_ASSERT(!QDELETED(web), "The service knife removed a web faster than the kitchen knife.")
	web.attacked_by(knife, user, list(), list())
	TEST_ASSERT(QDELETED(web), "The service knife should remove an ordinary web on the fifth hit.")
	var/mob/living/carbon/human/consistent/melee_victim = allocate(/mob/living/carbon/human/consistent)
	melee_victim.attacked_by(knife, user, list(), list())
	TEST_ASSERT_EQUAL(melee_victim.get_brute_loss(), 10, "An ordinary service-knife melee hit should match the kitchen knife's ten brute before armour.")
	var/mob/living/carbon/human/consistent/throw_victim = allocate(/mob/living/carbon/human/consistent)
	RegisterSignal(throw_victim, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(record_impact))
	knife.forceMove(run_loc_floor_bottom_left)
	throw_victim.hitby(knife, skipcatch = TRUE, hitpush = FALSE)
	TEST_ASSERT_EQUAL(throw_victim.get_brute_loss(), 5, "An ordinary service-knife throw should deal five brute before armour.")
	TEST_ASSERT_EQUAL(last_impact_sharpness, SHARP_EDGED, "The service knife must retain standard sharp thrown damage.")
	TEST_ASSERT_EQUAL(last_impact_damage_type, BRUTE, "A service-knife throw must still cause brute damage.")
	UnregisterSignal(throw_victim, COMSIG_MOB_APPLY_DAMAGE)
	TEST_ASSERT(findtext(knife.get_throw_hit_message(throw_victim), "но не втыкается"), "The observer message does not explain the intended lack of embedding.")
	TEST_ASSERT(findtext(knife.get_throw_hit_message(throw_victim, victim_message = TRUE), "в вас, но не втыкается"), "The victim message does not explain the intended lack of embedding.")
	var/obj/item/knife/kitchen/kitchen_knife = allocate(/obj/item/knife/kitchen)
	TEST_ASSERT_EQUAL(kitchen_knife.get_throw_hit_message(throw_victim), "[capitalize(kitchen_knife.declent_ru(NOMINATIVE))] врезается в [throw_victim.declent_ru(ACCUSATIVE)]!", "The shared message hook changed another knife's ordinary message.")
	var/mob/living/carbon/human/consistent/catcher = allocate(/mob/living/carbon/human/consistent)
	catcher.throw_mode = TRUE
	knife.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(catcher.hitby(knife, hitpush = FALSE), "A service knife could no longer be caught.")
	TEST_ASSERT_EQUAL(catcher.get_brute_loss(), 0, "A caught service knife still dealt throw damage.")
	TEST_ASSERT_EQUAL(knife.loc, catcher, "The caught knife did not enter the catcher's hands.")
	var/obj/item/knife/security_service/message_probe/message_probe = allocate(/obj/item/knife/security_service/message_probe)
	throw_victim.hitby(message_probe, skipcatch = TRUE, hitpush = FALSE, blocked = TRUE)
	TEST_ASSERT_EQUAL(message_probe.message_calls, 0, "A blocked throw must not display the service knife's hit message.")
	TEST_ASSERT_EQUAL(throw_victim.get_brute_loss(), 5, "A blocked service-knife throw still dealt damage.")
	var/mob/living/carbon/human/consistent/message_catcher = allocate(/mob/living/carbon/human/consistent)
	message_catcher.throw_mode = TRUE
	TEST_ASSERT(message_catcher.hitby(message_probe, hitpush = FALSE), "The message-probe knife could not be caught.")
	TEST_ASSERT_EQUAL(message_probe.message_calls, 0, "A caught throw must not display the service knife's hit message.")
	message_probe.forceMove(run_loc_floor_bottom_left)
	throw_victim.hitby(message_probe, skipcatch = TRUE, hitpush = FALSE)
	TEST_ASSERT_EQUAL(message_probe.message_calls, 2, "An unblocked hit must request one observer message and one victim message.")
	TEST_ASSERT_EQUAL(throw_victim.get_brute_loss(), 10, "The message hook changed standard thrown damage.")

	// Validate both the beacon's cards and the exact cases it delivers.
	var/obj/item/choice_beacon/weapon/security_pistol/beacon = allocate(/obj/item/choice_beacon/weapon/security_pistol)
	var/list/options = beacon.generate_display_names()
	TEST_ASSERT_EQUAL(length(options), 3, "The security beacon should offer two service pistols and a disabler.")
	var/disabler_name = "Энергетический пистолет дизейблер"
	var/disabler_case_type = options[disabler_name]
	TEST_ASSERT_EQUAL(disabler_case_type, /obj/item/storage/toolbox/guncase/ntcase/pistol/disabler, "The beacon should deliver the disabler in a pistol case.")
	var/obj/item/storage/toolbox/guncase/disabler_case = allocate(disabler_case_type)
	TEST_ASSERT_EQUAL(length(disabler_case.contents), 1, "The disabler case must contain a single item.")
	var/obj/item/gun/energy/disabler/delivered_disabler = locate(/obj/item/gun/energy/disabler) in disabler_case.contents
	TEST_ASSERT_NOTNULL(delivered_disabler, "The case does not contain a disabler.")
	var/list/disabler_card = beacon.build_weapon_info(disabler_name, disabler_case_type)
	TEST_ASSERT_NOTNULL(disabler_card, "The beacon failed to build the disabler card.")
	TEST_ASSERT_EQUAL(disabler_card["weapon_type"], "energy", "The disabler card lost its energy weapon type.")
	var/list/service_pistols = list(
		"МК-58 «Регламент»" = /obj/item/gun/ballistic/automatic/pistol/sec_force/mk58,
		"ПС-3 «Гюрза»" = /obj/item/gun/ballistic/automatic/pistol/sec_force/viper,
	)
	for(var/display_name in service_pistols)
		var/case_type = options[display_name]
		TEST_ASSERT(ispath(case_type, /obj/item/storage/toolbox/guncase/ntcase/pistol/sec_force), "The beacon lacks a service-pistol delivery case.")
		var/obj/item/storage/toolbox/guncase/ntcase/pistol/sec_force/gun_case = allocate(case_type)
		TEST_ASSERT_EQUAL(length(gun_case.contents), 3, "A service-pistol case should contain a pistol and two spare magazines.")
		var/obj/item/gun/ballistic/automatic/pistol/sec_force/delivered = locate() in gun_case.contents
		TEST_ASSERT(istype(delivered, service_pistols[display_name]), "The beacon case contains the wrong pistol.")
		TEST_ASSERT(istype(delivered.chambered, /obj/item/ammo_casing/c9x25mm/rubber), "The beacon delivered a lethal chambered round.")
		var/spare_count = 0
		for(var/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber/spare in gun_case.contents)
			TEST_ASSERT_EQUAL(spare.ammo_count(), 12, "A beacon spare magazine is not full.")
			spare_count++
		TEST_ASSERT_EQUAL(spare_count, 2, "The beacon must deliver two shared rubber spare magazines.")
		var/list/card = beacon.build_weapon_info(display_name, case_type)
		TEST_ASSERT_NOTNULL(card, "The beacon failed to build a service-pistol card.")
		TEST_ASSERT_EQUAL(card["name"], display_name, "The beacon card lost the Russian pistol name.")
		TEST_ASSERT_EQUAL(card["magazine_size"], 12, "The beacon card reports the wrong magazine size.")

	// Check the actual issued outfits and the lockers that supply the knife.
	var/list/security_outfits = list(
		/datum/outfit/job/security,
		/datum/outfit/job/warden,
		/datum/outfit/job/hos,
		/datum/outfit/job/blueshield,
		/datum/outfit/job/veteran_advisor,
		/datum/outfit/job/detective,
	)
	for(var/outfit_path in security_outfits)
		var/mob/living/carbon/human/consistent/wearer = allocate(/mob/living/carbon/human/consistent)
		wearer.equipOutfit(outfit_path)
		TEST_ASSERT_NOTNULL(wearer.back, "A security outfit did not provide its starting bag.")
		TEST_ASSERT_NULL(locate(/obj/item/knife/security_service) in wearer.get_contents(), "[outfit_path] issued a service knife at round start.")

	for(var/locker_path in typesof(/obj/structure/closet/secure_closet/security))
		var/obj/structure/closet/secure_closet/security/locker = allocate(locker_path)
		locker.PopulateContents()
		var/knife_count = 0
		for(var/obj/item/knife/security_service/stocked_knife in locker.contents)
			knife_count++
		TEST_ASSERT_EQUAL(knife_count, 1, "[locker_path] must stock one service knife.")

	var/datum/techweb/science/station_research = locate(/datum/techweb/science) in SSresearch.techwebs
	TEST_ASSERT_NOTNULL(station_research, "The station research network is unavailable.")
	var/obj/machinery/rnd/production/techfab/department/security/security_fab = allocate(/obj/machinery/rnd/production/techfab/department/security)
	security_fab.connect_techweb(station_research)
	var/list/fab_data = security_fab.ui_static_data(null)
	var/list/fab_designs = fab_data["designs"]
	TEST_ASSERT_NOTNULL(fab_designs[/datum/design/security_service_knife], "The security techfab did not offer the service knife.")
	TEST_ASSERT_NOTNULL(fab_designs[/datum/design/c9x25mm_rubber_box], "The security techfab did not offer boxed rubber ammunition.")
	var/obj/item/ammo_box/c9x25mm/rubber/rubber_box = allocate(/obj/item/ammo_box/c9x25mm/rubber)
	var/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber/empty/empty_mag = allocate(/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber/empty)
	TEST_ASSERT_EQUAL(length(rubber_box.ammo_list()), 30, "The rubber ammunition box should start with thirty rounds.")
	TEST_ASSERT_EQUAL(empty_mag.try_load(user, rubber_box, silent = TRUE), 12, "The ammunition box could not refill an empty service magazine.")
	TEST_ASSERT_EQUAL(length(rubber_box.ammo_list()), 18, "Refilling a service magazine should consume twelve boxed rounds.")

	// Existing recipe IDs and research gates now produce the shared magazine.
	var/obj/machinery/autolathe/lathe = allocate(/obj/machinery/autolathe)
	for(var/design_path in list(/datum/design/c9x25mm, /datum/design/c9x25mm_rubber))
		TEST_ASSERT(design_path in lathe.stored_research.researched_designs, "A standard 9x25 NT recipe disappeared from the autolathe.")
	var/list/ammo_designs = list(
		/datum/design/c9x25mm = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force,
		/datum/design/c9x25mm/sec = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force,
		/datum/design/c9x25mm_rubber = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber,
		/datum/design/c9x25mm_rubber/sec = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber,
		/datum/design/c9x25mm/ap = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/ap,
		/datum/design/c9x25mm/hp = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/hp,
	)
	var/obj/item/gun/ballistic/automatic/pistol/gp9/legacy_pistol = allocate(/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag)
	for(var/design_path in ammo_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_path]
		TEST_ASSERT_NOTNULL(design, "A standard 9x25 NT production design is missing.")
		TEST_ASSERT_EQUAL(design.build_path, ammo_designs[design_path], "A lathe recipe still produces an incompatible GP-9 magazine.")
		var/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/printed_mag = allocate(design.build_path)
		TEST_ASSERT_EQUAL(printed_mag.ammo_count(), 12, "The printed magazine is not loaded with twelve rounds.")
		TEST_ASSERT(istype(printed_mag, mk58.accepted_magazine_type) && istype(printed_mag, viper.accepted_magazine_type), "The printed magazine is incompatible with a service pistol.")
		TEST_ASSERT(istype(printed_mag, legacy_pistol.accepted_magazine_type), "The shared recipe broke legacy GP-9 compatibility.")

	// A normal knife remains a valid improvised instrument for an incision.
	var/mob/living/carbon/human/consistent/surgery_patient = allocate(/mob/living/carbon/human/consistent)
	surgery_patient.set_body_position(LYING_DOWN)
	var/obj/item/bodypart/chest/chest = surgery_patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/surgery_operation/limb/incise_skin/incision = allocate(/datum/surgery_operation/limb/incise_skin)
	knife.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(user.put_in_hands(knife), "The test surgeon could not hold the service knife.")
	TEST_ASSERT(incision.check_availability(surgery_patient, chest, user, knife, BODY_ZONE_CHEST), "The service knife is not accepted for a basic surgical incision.")

	var/obj/item/sharpener/stone = allocate(/obj/item/sharpener)
	stone.item_interaction(user, knife, list())
	TEST_ASSERT_EQUAL(knife.force, 14, "A normal whetstone did not add four melee damage.")
	TEST_ASSERT_EQUAL(knife.throwforce, 9, "A normal whetstone must add four service-knife throw damage.")
	TEST_ASSERT_NULL(knife.embed_type, "Sharpening re-enabled service-knife embedding.")
	var/mob/living/carbon/human/consistent/sharpened_throw_victim = allocate(/mob/living/carbon/human/consistent)
	RegisterSignal(sharpened_throw_victim, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(record_impact))
	last_impact_sharpness = null
	knife.forceMove(run_loc_floor_bottom_left)
	sharpened_throw_victim.hitby(knife, skipcatch = TRUE, hitpush = FALSE)
	TEST_ASSERT_EQUAL(sharpened_throw_victim.get_brute_loss(), 9, "A sharpened service knife must deal nine thrown brute damage.")
	TEST_ASSERT_EQUAL(last_impact_sharpness, SHARP_EDGED, "Sharpening must preserve standard cutting damage.")
	UnregisterSignal(sharpened_throw_victim, COMSIG_MOB_APPLY_DAMAGE)
	TEST_ASSERT_EQUAL(knife.get_sharpness(), SHARP_EDGED, "The service knife's blade must remain edged.")
	var/obj/item/sharpener/kitchen_stone = allocate(/obj/item/sharpener)
	kitchen_stone.item_interaction(user, kitchen_knife, list())
	TEST_ASSERT_EQUAL(kitchen_knife.force, initial(kitchen_knife.force) + 4, "Ordinary knife melee sharpening was changed.")
	TEST_ASSERT_EQUAL(kitchen_knife.throwforce, initial(kitchen_knife.throwforce) + 4, "Ordinary knife throw sharpening was changed.")
	RegisterSignal(throw_victim, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(record_impact))
	kitchen_knife.forceMove(run_loc_floor_bottom_left)
	throw_victim.hitby(kitchen_knife, skipcatch = TRUE, hitpush = FALSE)
	TEST_ASSERT_EQUAL(last_impact_sharpness, SHARP_EDGED, "Ordinary knives must retain sharp thrown impacts.")
	UnregisterSignal(throw_victim, COMSIG_MOB_APPLY_DAMAGE)

/// Records message requests without replacing the normal hit or catch pipeline.
/obj/item/knife/security_service/message_probe
	var/message_calls = 0

/obj/item/knife/security_service/message_probe/get_throw_hit_message(mob/living/victim, victim_message = FALSE)
	message_calls++
	return ..()

/datum/unit_test/sec_force_legacy_magazines/Run()
	var/mob/living/carbon/human/consistent/user = allocate(/mob/living/carbon/human/consistent)
	var/list/magazine_types = list(
		/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/ap,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/hp,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/empty,
		/obj/item/ammo_box/magazine/c9x25mm_pistol,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/starts_empty,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/starts_empty,
	)
	for(var/pistol_type in list(/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag, /obj/item/gun/ballistic/automatic/pistol/gp9/spec/no_mag))
		var/obj/item/gun/ballistic/automatic/pistol/gp9/pistol = allocate(pistol_type)
		var/datum/component/reskinable_item/reskins
		for(var/datum/component/reskinable_item/component as anything in pistol.GetComponents(/datum/component/reskinable_item))
			var/list/skin_options = component.get_skins_by_name()
			if(skin_options["Default"] == /datum/atom_skin/gp9/default)
				reskins = component
				break
		TEST_ASSERT_NOTNULL(reskins, "A legacy pistol lost its reskin component.")
		var/list/skin_names = list(null)
		for(var/skin_name in reskins.get_skins_by_name())
			skin_names += skin_name
		for(var/magazine_type in magazine_types)
			var/obj/item/ammo_box/magazine/test_magazine = allocate(magazine_type)
			TEST_ASSERT(user.put_in_hands(test_magazine), "The user could not hold a test magazine.")
			TEST_ASSERT(pistol.insert_magazine(user, test_magazine, display_message = FALSE), "A legacy pistol rejected a compatible magazine.")
			for(var/skin_index in 1 to length(skin_names))
				var/skin_name = skin_names[skin_index]
				reskins.set_skin_by_name(skin_name)
				var/magazine_icon = initial(test_magazine.icon_state)
				if(istype(test_magazine, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force))
					magazine_icon = /obj/item/ammo_box/magazine/c9x25mm_pistol::icon_state
				var/expected_overlay = "[pistol.icon_state]_mag_[magazine_icon]"
				var/list/rendered_overlays = pistol.update_overlays()
				TEST_ASSERT(expected_overlay in rendered_overlays, "[pistol.type] with skin [skin_name] lost its inserted-magazine layer.")
				TEST_ASSERT(icon_exists(pistol.icon, expected_overlay), "A legacy pistol requested a missing magazine sprite: [expected_overlay].")
				TEST_ASSERT(!("[pistol.icon_state]_mag_nt9x25" in rendered_overlays), "The invalid shared-magazine overlay remains on a legacy pistol.")
				if(pistol.mag_display_ammo && !test_magazine.ammo_count())
					TEST_ASSERT("[pistol.icon_state]_mag_empty" in rendered_overlays, "The legacy empty-magazine indicator disappeared.")
			pistol.eject_magazine(user, display_message = FALSE)
			TEST_ASSERT_NULL(pistol.magazine, "A legacy pistol retained an ejected magazine.")
			test_magazine.forceMove(run_loc_floor_bottom_left)
		reskins.set_skin_by_name(null)
		TEST_ASSERT_EQUAL(pistol.icon_state, initial(pistol.icon_state), "Removing a reskin failed to restore the original pistol appearance.")
		var/list/empty_overlays = pistol.update_overlays()
		for(var/layer in empty_overlays)
			if(istext(layer))
				TEST_ASSERT(!findtext(layer, "[pistol.icon_state]_mag_"), "A pistol without a magazine still displays a magazine layer.")

/datum/unit_test/sec_force_supply/Run()
	var/list/shipments = list(
		/datum/supply_pack/security/gp9_ammo = list(/obj/item/ammo_casing/c9x25mm = 2, /obj/item/ammo_casing/c9x25mm/rubber = 2),
		/datum/supply_pack/security/gp9_ammospecial = list(/obj/item/ammo_casing/c9x25mm/ap = 2, /obj/item/ammo_casing/c9x25mm/hp = 2),
	)
	for(var/pack_path in shipments)
		var/datum/supply_pack/pack = allocate(pack_path)
		var/obj/structure/closet/crate/shipment = pack.generate(run_loc_floor_bottom_left)
		allocated += shipment
		TEST_ASSERT_EQUAL(length(shipment.contents), 6, "A 9x25 NT shipment lost magazines or ammunition boxes.")
		var/list/ammo_counts = list()
		for(var/obj/item/ammo_box/magazine/received in shipment.contents)
			TEST_ASSERT(istype(received, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force), "Cargo still delivered an incompatible standard magazine.")
			TEST_ASSERT_EQUAL(received.ammo_count(), 12, "Cargo delivered a magazine without twelve rounds.")
			ammo_counts[received.ammo_type] += 1
		var/list/expected_counts = shipments[pack_path]
		for(var/ammo_path in expected_counts)
			TEST_ASSERT_EQUAL(ammo_counts[ammo_path], expected_counts[ammo_path], "A 9x25 NT shipment contains the wrong ammunition mix.")
	var/obj/item/storage/toolbox/ammobox/c9x25mm_mags/magazine_box = allocate(/obj/item/storage/toolbox/ammobox/c9x25mm_mags)
	TEST_ASSERT_EQUAL(length(magazine_box.contents), 6, "The magazine box should contain six magazines.")
	for(var/obj/item/ammo_box/magazine/received in magazine_box.contents)
		TEST_ASSERT(istype(received, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force), "The standard magazine box still contains legacy-only magazines.")
	var/obj/machinery/vending/nta/light/vendor = allocate(/obj/machinery/vending/nta/light)
	var/list/expected_stock = list(/obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force = 5, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber = 10)
	var/checked_products = 0
	for(var/datum/data/vending_product/product as anything in vendor.product_records)
		if(!(product.product_path in expected_stock))
			continue
		TEST_ASSERT_EQUAL(product.amount, expected_stock[product.product_path], "The ammunition vendor's standard stock count changed.")
		var/obj/item/ammo_box/magazine/vended = vendor.dispense(product, run_loc_floor_bottom_left, silent = TRUE)
		allocated += vended
		TEST_ASSERT(istype(vended, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force), "The vendor dispensed an incompatible magazine.")
		TEST_ASSERT_EQUAL(vended.ammo_count(), 12, "The vendor dispensed a magazine without twelve rounds.")
		checked_products++
	TEST_ASSERT_EQUAL(checked_products, 2, "The ammunition vendor is missing one shared-magazine product.")
	for(var/case_type in list(/obj/item/storage/toolbox/guncase/ntcase/pistol/gp9, /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec, /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/no_ammo))
		var/obj/item/storage/toolbox/guncase/gun_case = allocate(case_type)
		var/spare_count = 0
		for(var/obj/item/ammo_box/magazine/spare in gun_case.contents)
			TEST_ASSERT(istype(spare, /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force), "A standard GP-9 case still delivers incompatible spare magazines.")
			spare_count++
		TEST_ASSERT_EQUAL(spare_count, 2, "A GP-9 case lost a spare magazine.")

/datum/unit_test/sec_force_belt/Run()
	for(var/belt_type in list(/obj/item/storage/belt/security, /obj/item/storage/belt/security/webbing))
		var/obj/item/storage/belt/security/belt = allocate(belt_type)
		var/obj/item/knife/security_service/knife = allocate(/obj/item/knife/security_service)
		TEST_ASSERT(belt.atom_storage.attempt_insert(knife, messages = FALSE), "A security belt rejected the service knife.")
		TEST_ASSERT_EQUAL(knife.loc, belt, "The service knife did not enter the security belt.")
		var/obj/item/knife/kitchen/kitchen_knife = allocate(/obj/item/knife/kitchen)
		TEST_ASSERT(!belt.atom_storage.attempt_insert(kitchen_knife, messages = FALSE), "Allowing the service knife unexpectedly allowed kitchen knives too.")
