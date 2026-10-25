#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Exercise real lumcount calculations with one controlled native lighting corner.
/datum/unit_test/shadow_demon_environment
	var/turf/test_turf
	var/datum/lighting_corner/test_corner
	var/list/old_corners
	var/created_lighting = FALSE

/datum/unit_test/shadow_demon_environment/Destroy()
	if(test_turf && old_corners)
		test_turf.lighting_corner_NE = old_corners[1]
		test_turf.lighting_corner_SE = old_corners[2]
		test_turf.lighting_corner_SW = old_corners[3]
		test_turf.lighting_corner_NW = old_corners[4]
		if(created_lighting)
			test_turf.lighting_clear_overlay()
	test_turf = null
	test_corner = null
	old_corners = null
	return ..()

/datum/unit_test/shadow_demon_environment/proc/set_test_lumcount(value)
	// Keep raw and rendered channels aligned for both lighting implementations.
	test_corner.lum_r = value
	test_corner.lum_g = value
	test_corner.lum_b = value
	test_corner.cache_r = value
	test_corner.cache_g = value
	test_corner.cache_b = value

/datum/unit_test/shadow_demon_environment/Run()
	test_turf = run_loc_floor_bottom_left
	old_corners = list(test_turf.lighting_corner_NE, test_turf.lighting_corner_SE, test_turf.lighting_corner_SW, test_turf.lighting_corner_NW)
	if(isnull(test_turf.lighting_object))
		test_turf.lighting_build_overlay()
		created_lighting = TRUE
	test_corner = allocate(/datum/lighting_corner, 0, 0, 0)
	test_turf.lighting_corner_NE = test_corner
	test_turf.lighting_corner_SE = test_corner
	test_turf.lighting_corner_SW = test_corner
	test_turf.lighting_corner_NW = test_corner
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, test_turf)
	demon.set_brute_loss(100)
	set_test_lumcount(0.2)
	TEST_ASSERT_EQUAL(test_turf.get_lumcount(), 0.2, "Native lighting did not produce the exact threshold.")
	demon.apply_shadow_environment(2)
	TEST_ASSERT_EQUAL(demon.get_brute_loss(), 80, "The exact darkness threshold must heal 20 damage per two seconds.")
	TEST_ASSERT_EQUAL(demon.alpha, 125, "Darkness did not apply the donor's translucency.")
	TEST_ASSERT_EQUAL(demon.speed, 0.5, "Darkness did not apply the donor's movement speed.")
	TEST_ASSERT(!demon.has_alert("shadow_demon_light"), "Darkness retained the light warning.")

	set_test_lumcount(0.21)
	demon.apply_shadow_environment(0.5)
	TEST_ASSERT_EQUAL(demon.get_brute_loss(), 90, "Light damage must scale with elapsed seconds.")
	TEST_ASSERT_EQUAL(demon.alpha, 255, "Light did not reveal the demon.")
	TEST_ASSERT_EQUAL(demon.speed, initial(demon.speed), "Light did not reset movement speed.")
	TEST_ASSERT(demon.has_alert("shadow_demon_light"), "Light did not raise the warning.")
	var/atom/movable/screen/alert/light_warning = demon.alerts["shadow_demon_light"]
	TEST_ASSERT(icon_exists(light_warning.icon, light_warning.icon_state), "The light warning has no matching icon state and would render ERROR.")
	demon.set_brute_loss(20)
	demon.apply_shadow_environment(1)
	demon.apply_shadow_environment(1)
	var/two_short_ticks = demon.get_brute_loss()
	demon.set_brute_loss(20)
	demon.apply_shadow_environment(2)
	TEST_ASSERT_EQUAL(demon.get_brute_loss(), two_short_ticks, "Changing the mob processing interval changed total light damage.")

	var/datum/action/cooldown/spell/jaunt/shadow_demon/crawl = locate() in demon.actions
	TEST_ASSERT_NOTNULL(crawl, "Shadow Crawl was not granted.")
	crawl.enter_jaunt(demon)
	TEST_ASSERT(is_jaunting(demon), "Shadow Crawl did not enter the native jaunt holder.")
	demon.set_brute_loss(20)
	demon.apply_shadow_environment(2)
	TEST_ASSERT_EQUAL(demon.get_brute_loss(), 40, "Phasing did not halve light damage.")
	crawl.exit_jaunt(demon)
	TEST_ASSERT(!is_jaunting(demon), "Shadow Crawl left a phased occupant behind.")

/// Initialization and repeated login must not duplicate role datums or abilities.
/datum/unit_test/shadow_demon_role/Run()
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow)
	demon.mind_initialize()
	demon.mind_initialize()
	TEST_ASSERT(istype(demon.mind.assigned_role, /datum/job/shadow_demon), "The demon inherited the slaughter demon job.")
	var/role_count = 0
	for(var/datum/antagonist/shadow_demon/antag in demon.mind.antag_datums)
		role_count++
	TEST_ASSERT_EQUAL(role_count, 1, "Repeated mind initialization duplicated the antagonist.")
	var/grapple_count = 0
	var/crawl_count = 0
	for(var/datum/action/action as anything in demon.actions)
		if(istype(action, /datum/action/cooldown/spell/shadow_grapple))
			grapple_count++
		if(istype(action, /datum/action/cooldown/spell/jaunt/shadow_demon))
			crawl_count++
	TEST_ASSERT_EQUAL(grapple_count, 1, "The demon does not have exactly one grapple.")
	TEST_ASSERT_EQUAL(crawl_count, 1, "The demon does not have exactly one Shadow Crawl.")
	TEST_ASSERT_NULL(locate(/datum/action/cooldown/spell/jaunt/bloodcrawl) in demon.actions, "The shadow demon inherited bloodcrawl.")
	var/datum/round_event_control/shadow_demon/control = allocate(/datum/round_event_control/shadow_demon)
	TEST_ASSERT(!control.can_spawn_event(100), "The admin-only demon event can run naturally.")

/// Both the final validation and destruction path must protect the captured corpse.
/datum/unit_test/shadow_demon_cocoon/Run()
	var/turf/spawn_turf = run_loc_floor_bottom_left
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, spawn_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, spawn_turf)
	TEST_ASSERT(!demon.cocoon_victim(victim), "A living human was cocooned.")
	victim.death()
	victim.forceMove(run_loc_floor_top_right)
	TEST_ASSERT(!demon.cocoon_victim(victim), "A distant corpse passed completion validation.")
	victim.forceMove(spawn_turf)
	demon.wrapping = TRUE
	TEST_ASSERT(!demon.wrap_victim(victim), "Repeated clicks started a second wrapping channel.")
	demon.wrapping = FALSE
	TEST_ASSERT(demon.cocoon_victim(victim), "A nearby dead human could not be cocooned.")
	var/obj/structure/shadowcocoon/cocoon = victim.loc
	TEST_ASSERT(istype(cocoon), "The victim was not moved into a shadow cocoon.")
	allocated += cocoon
	TEST_ASSERT(!demon.cocoon_victim(victim), "An already captured corpse was wrapped twice.")
	TEST_ASSERT(length(cocoon.examine(demon)) > 0, "Examining an idle cocoon did not return its description.")
	TEST_ASSERT_EQUAL(cocoon.click_alt(demon), CLICK_ACTION_SUCCESS, "The demon could not toggle its cocoon's lure.")
	TEST_ASSERT(!cocoon.silent, "The cocoon toggle did not enable its lure.")
	TEST_ASSERT(length(cocoon.examine(demon)) > 0, "Examining an active cocoon did not return its description.")
	var/mob/living/carbon/human/outsider = allocate(/mob/living/carbon/human/consistent, spawn_turf)
	TEST_ASSERT_EQUAL(cocoon.click_alt(outsider), NONE, "A human could control the demonic lure.")
	TEST_ASSERT(!cocoon.silent, "An unauthorized click changed the cocoon lure.")
	qdel(cocoon)
	TEST_ASSERT_EQUAL(victim.loc, spawn_turf, "Destroying a cocoon deleted or trapped its corpse.")
	TEST_ASSERT(!QDELETED(victim), "Destroying a cocoon deleted the captured human.")

/// An extracted heart owns only its granted action, even after transplantation.
/datum/unit_test/shadow_demon_heart/Run()
	var/mob/living/carbon/human/first_host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/second_host = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/heart/shadow_demon/heart = allocate(/obj/item/organ/heart/shadow_demon)
	var/datum/action/cooldown/spell/shadow_grapple/independent = allocate(/datum/action/cooldown/spell/shadow_grapple)
	independent.Grant(first_host)
	TEST_ASSERT(heart.Insert(first_host, special = TRUE), "The shadow heart could not be implanted.")
	var/datum/action/cooldown/spell/shadow_grapple/first_grapple = heart.grapple
	TEST_ASSERT_EQUAL(first_grapple?.owner, first_host, "The heart did not grant a grapple to its host.")
	TEST_ASSERT_NOTEQUAL(first_grapple, independent, "The heart took ownership of an unrelated action.")
	heart.Remove(first_host, special = TRUE)
	TEST_ASSERT(QDELETED(first_grapple), "Extraction left the heart's grapple behind.")
	TEST_ASSERT_EQUAL(independent.owner, first_host, "Extraction removed an independently granted grapple.")
	TEST_ASSERT_NULL(heart.grapple, "Extraction retained a deleted action reference.")
	TEST_ASSERT(heart.Insert(second_host, special = TRUE), "The shadow heart could not be transplanted.")
	TEST_ASSERT_EQUAL(heart.grapple?.owner, second_host, "Transplantation did not grant a fresh grapple to the new host.")
	TEST_ASSERT_NULL(locate(/datum/action/cooldown/spell/jaunt/bloodcrawl) in second_host.actions, "The shadow heart granted bloodcrawl instead of Shadow Grapple.")
	heart.Remove(second_host, special = TRUE)
	TEST_ASSERT_NULL(heart.grapple, "Second extraction retained the host action.")

/// A prior projectile's completion must never unlock a newer grapple.
/datum/unit_test/shadow_demon_grapple_lock/Run()
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow)
	var/first_generation = demon.block_shadow_crawl()
	var/second_generation = demon.block_shadow_crawl()
	TEST_ASSERT_NOTEQUAL(first_generation, second_generation, "Two grapples reused a lock generation.")
	demon.unblock_shadow_crawl(first_generation)
	TEST_ASSERT(demon.block_shadow_crawl, "An old grapple released a newer crawl lock.")
	demon.check_block_shadow_crawl(first_generation)
	TEST_ASSERT(demon.block_shadow_crawl, "An old timeout released a newer crawl lock.")
	demon.check_block_shadow_crawl(second_generation)
	TEST_ASSERT(!demon.block_shadow_crawl, "The current timeout did not release its own crawl lock.")
	var/obj/projectile/magic/shadow_hand/missed = allocate(/obj/projectile/magic/shadow_hand)
	missed.firer = demon
	missed.grapple_generation = demon.block_shadow_crawl()
	qdel(missed)
	TEST_ASSERT(!demon.block_shadow_crawl, "A missed projectile retained the demon's crawl lock.")

/// Launch the real hand and verify its arm is drawn above an opaque native floor.
/datum/unit_test/shadow_demon_grapple_visuals/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/projectile_turf = get_step(get_step(source_turf, EAST), EAST)
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, source_turf)
	var/obj/projectile/magic/shadow_hand/projectile = allocate(/obj/projectile/magic/shadow_hand, projectile_turf)
	projectile.firer = demon
	projectile.fire(90)
	TEST_ASSERT(!QDELETED(projectile), "The hand was deleted before its first rendered flight frame.")
	TEST_ASSERT(icon_exists(projectile.icon, projectile.icon_state), "The hand's projectile sprite is missing.")
	var/floor_plane = PLANE_TO_TRUE(projectile_turf.plane)
	var/hand_plane = PLANE_TO_TRUE(projectile.plane)
	TEST_ASSERT(hand_plane > floor_plane || (hand_plane == floor_plane && projectile.layer > projectile_turf.layer), "The hand is hidden behind its opaque floor.")
	var/datum/beam/arm = projectile.grapple_beam
	TEST_ASSERT_NOTNULL(arm, "Firing the hand did not create its extending arm.")
	TEST_ASSERT_NOTNULL(arm.visuals, "The arm has no shared visual appearance.")
	TEST_ASSERT(icon_exists(arm.visuals.icon, arm.visuals.icon_state), "The extending arm's sprite is missing.")
	TEST_ASSERT(length(arm.elements), "The extending arm did not create any visible segments.")
	var/list/segments = arm.elements.Copy()
	for(var/obj/effect/ebeam/segment as anything in segments)
		var/turf/segment_turf = get_turf(segment)
		var/segment_plane = PLANE_TO_TRUE(segment.plane)
		var/segment_floor_plane = PLANE_TO_TRUE(segment_turf.plane)
		TEST_ASSERT(segment_plane > segment_floor_plane || (segment_plane == segment_floor_plane && segment.layer > segment_turf.layer), "An arm segment is hidden behind its opaque floor.")
		TEST_ASSERT(segment.icon || (arm.visuals in segment.vis_contents), "An arm segment has neither its sprite nor its shared visual.")
	var/obj/effect/ebeam/visuals = arm.visuals
	qdel(projectile)
	TEST_ASSERT(QDELETED(arm) && QDELETED(visuals), "Deleting the hand retained its arm or its visual.")
	for(var/obj/effect/ebeam/segment as anything in segments)
		TEST_ASSERT(QDELETED(segment), "Deleting the hand retained an arm segment.")

/// Hitting twice through reentrant throw callbacks must not duplicate damage.
/datum/unit_test/shadow_demon_grapple_hit/Run()
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/projectile/magic/shadow_hand/projectile = allocate(/obj/projectile/magic/shadow_hand, get_turf(victim))
	projectile.firer = demon
	projectile.grapple_generation = demon.block_shadow_crawl()
	projectile.on_hit(victim)
	TEST_ASSERT_EQUAL(victim.get_brute_loss(), 40, "Shadow Grapple did not deal its one 40-brute hit.")
	TEST_ASSERT(victim.IsImmobilized(), "Shadow Grapple did not immobilize its victim.")
	TEST_ASSERT_EQUAL(victim.AmountImmobilized(), 2 SECONDS, "Shadow Grapple used the wrong immobilization duration.")
	TEST_ASSERT(!demon.block_shadow_crawl, "Hitting a living victim retained the crawl lock.")
	projectile.on_hit(victim)
	TEST_ASSERT_EQUAL(victim.get_brute_loss(), 40, "Reentering the grapple hit duplicated damage.")

/// Extinguish carried equipment without removing the donor's special light counters.
/datum/unit_test/shadow_demon_carried_lights/Run()
	var/mob/living/carbon/human/carrier = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/flashlight/flashlight = allocate(/obj/item/flashlight)
	carrier.put_in_active_hand(flashlight)
	flashlight.set_light_on(TRUE)
	shadow_demon_extinguish(carrier)
	TEST_ASSERT(!flashlight.light_on, "A held light was not extinguished when its carrier was hit.")
	var/obj/item/flashlight/flare/flare = allocate(/obj/item/flashlight/flare)
	flare.set_light_on(TRUE)
	shadow_demon_extinguish(flare)
	TEST_ASSERT(flare.light_on, "An ordinary shadow touch extinguished a flare.")
	shadow_demon_extinguish(flare, TRUE)
	TEST_ASSERT_EQUAL(flare.fuel, 0, "Shadow Grapple did not exhaust a flare.")
	TEST_ASSERT(!flare.light_on, "An exhausted flare stayed lit.")
	var/obj/item/flashlight/slime/slime = allocate(/obj/item/flashlight/slime)
	shadow_demon_extinguish(slime)
	TEST_ASSERT(!QDELETED(slime), "An ordinary shadow touch destroyed a slime light.")
	shadow_demon_extinguish(slime, TRUE)
	TEST_ASSERT(QDELETED(slime), "Shadow Grapple did not destroy a slime light.")

	var/obj/item/mod/control/control = allocate(/obj/item/mod/control)
	var/obj/item/mod/module/flashlight/lamp = allocate(/obj/item/mod/module/flashlight, control)
	control.install(lamp)
	TEST_ASSERT_EQUAL(lamp.mod, control, "The ordinary MOD lamp was not installed into a native control.")
	lamp.active = TRUE
	lamp.set_light_on(TRUE)
	shadow_demon_extinguish(control)
	TEST_ASSERT(!lamp.active, "A lit ordinary MOD lamp remained active after a shadow hit.")
	TEST_ASSERT(!lamp.light_on, "Deactivating an ordinary MOD lamp left its light on.")
	var/obj/item/mod/control/dark_control = allocate(/obj/item/mod/control)
	var/obj/item/mod/module/flashlight/darkness/dark_lamp = allocate(/obj/item/mod/module/flashlight/darkness, dark_control)
	dark_control.install(dark_lamp)
	TEST_ASSERT_EQUAL(dark_lamp.mod, dark_control, "The MOD darkness lamp was not installed into a native control.")
	dark_lamp.active = TRUE
	dark_lamp.set_light_on(TRUE)
	shadow_demon_extinguish(dark_control)
	TEST_ASSERT(dark_lamp.active, "A shadow hit deactivated the beneficial MOD darkness module.")
	TEST_ASSERT(dark_lamp.light_on, "A shadow hit stopped the MOD darkness module's effect.")

/// APC toggles must respect temporary darkness, and removal must restore fixture settings.
/datum/unit_test/shadow_demon_fixture_blackout/Run()
	var/obj/machinery/light/fixture = allocate(/obj/machinery/light)
	var/previous_no_low_power = fixture.no_low_power
	shadow_demon_extinguish(fixture)
	var/datum/component/shadow_demon_blackout/blackout = fixture.GetComponent(/datum/component/shadow_demon_blackout)
	TEST_ASSERT_NOTNULL(blackout, "The fixture did not acquire temporary blackout state.")
	TEST_ASSERT(!fixture.on, "A shadowed fixture stayed on.")
	TEST_ASSERT(fixture.no_low_power, "A shadowed fixture could still use emergency lighting.")
	fixture.set_on(TRUE)
	TEST_ASSERT(!fixture.on, "An APC toggle bypassed the blackout.")
	shadow_demon_extinguish(fixture)
	TEST_ASSERT_EQUAL(fixture.GetComponent(/datum/component/shadow_demon_blackout), blackout, "Repeated pulses stacked blackout components.")
	qdel(blackout)
	TEST_ASSERT_EQUAL(fixture.no_low_power, previous_no_low_power, "Ending the blackout lost the fixture's emergency-light setting.")

/// Deleting a holder must rescue its passenger and remove all phase-only traits.
/datum/unit_test/shadow_demon_phase_destruction/Run()
	var/turf/spawn_turf = run_loc_floor_bottom_left
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, spawn_turf)
	var/datum/action/cooldown/spell/jaunt/shadow_demon/crawl = locate() in demon.actions
	TEST_ASSERT_NOTNULL(crawl, "The demon did not receive Shadow Crawl.")
	var/obj/effect/dummy/phased_mob/holder = crawl.enter_jaunt(demon)
	TEST_ASSERT_EQUAL(demon.loc, holder, "The jaunt did not contain its passenger.")
	TEST_ASSERT(HAS_TRAIT(demon, TRAIT_MAGICALLY_PHASED), "Entering the jaunt did not apply phase protection.")
	qdel(holder)
	TEST_ASSERT(!QDELETED(demon), "Deleting a jaunt holder deleted the demon.")
	TEST_ASSERT_EQUAL(demon.loc, spawn_turf, "Deleting a jaunt holder did not restore its passenger to the turf.")
	TEST_ASSERT(!HAS_TRAIT(demon, TRAIT_MAGICALLY_PHASED), "Deleting the holder retained phase protection.")
	TEST_ASSERT(!HAS_TRAIT(demon, TRAIT_RUNECHAT_HIDDEN), "Deleting the holder retained hidden runechat.")
	TEST_ASSERT(!HAS_TRAIT(demon, TRAIT_WEATHER_IMMUNE), "Deleting the holder retained phase weather protection.")

/// Run the actual channel, then verify movement cancels the next attempt.
/datum/unit_test/shadow_demon_wrapping_channel/Run()
	var/turf/spawn_turf = run_loc_floor_bottom_left
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, spawn_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, spawn_turf)
	victim.death()
	INVOKE_ASYNC(demon, TYPE_PROC_REF(/mob/living/basic/demon/shadow, wrap_victim), victim)
	TEST_ASSERT(demon.wrapping, "The real wrapping channel did not start.")
	TEST_ASSERT(!demon.wrap_victim(victim), "A second channel started while the first was pending.")
	sleep(4.2 SECONDS)
	var/obj/structure/shadowcocoon/cocoon = victim.loc
	TEST_ASSERT(istype(cocoon), "The completed four-second channel did not cocoon its victim.")
	allocated += cocoon
	TEST_ASSERT(!demon.wrapping, "A completed channel retained the wrapping lock.")
	qdel(cocoon)

	INVOKE_ASYNC(demon, TYPE_PROC_REF(/mob/living/basic/demon/shadow, wrap_victim), victim)
	TEST_ASSERT(demon.wrapping, "A second wrapping attempt could not start after completion.")
	victim.forceMove(run_loc_floor_top_right)
	sleep(0.5 SECONDS)
	TEST_ASSERT(!demon.wrapping, "Moving the victim did not cancel the channel.")
	TEST_ASSERT_EQUAL(victim.loc, run_loc_floor_top_right, "A cancelled channel captured the moved corpse.")

/// The death path must leave the transferable shadow heart, without the slaughter heart.
/datum/unit_test/shadow_demon_death_loot/Run()
	var/turf/spawn_turf = run_loc_floor_bottom_left
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, spawn_turf)
	demon.death()
	TEST_ASSERT(QDELETED(demon), "The dead shadow demon did not dissipate.")
	var/obj/item/organ/heart/shadow_demon/heart = locate() in spawn_turf
	TEST_ASSERT_NOTNULL(heart, "The demon did not drop a shadow heart.")
	allocated += heart
	TEST_ASSERT_NULL(locate(/obj/item/organ/heart/demon) in spawn_turf, "The shadow demon also dropped a bloodcrawl heart.")

/// Shadow and blood bottles must purchase and refund through their own native entries.
/datum/unit_test/shadow_demon_spellbook/Run()
	var/mob/living/carbon/human/wizard = allocate(/mob/living/carbon/human/consistent)
	wizard.mind_initialize()
	var/obj/item/spellbook/book = allocate(/obj/item/spellbook)
	wizard.put_in_active_hand(book, forced = TRUE)
	var/datum/spellbook_entry/item/shadowbottle/shadow_entry = locate() in book.entries
	var/datum/spellbook_entry/item/bloodbottle/blood_entry = locate() in book.entries
	TEST_ASSERT_NOTNULL(shadow_entry, "The native spellbook did not include Bottle of Shadows.")
	TEST_ASSERT_NOTNULL(blood_entry, "Adding Bottle of Shadows removed Bottle of Blood.")
	TEST_ASSERT_EQUAL(shadow_entry.item_path, /obj/item/antag_spawner/slaughter_demon/shadow, "The shadow entry summons the wrong vial type.")
	TEST_ASSERT_EQUAL(shadow_entry.cost, 1, "The shadow vial must cost one spell point.")
	var/initial_points = book.uses
	TEST_ASSERT(book.purchase_entry(shadow_entry, wizard), "The native book could not purchase a shadow vial.")
	TEST_ASSERT_EQUAL(book.uses, initial_points - 1, "Purchasing a shadow vial spent the wrong amount.")
	TEST_ASSERT_EQUAL(shadow_entry.times, 1, "The shadow purchase was not tracked.")
	TEST_ASSERT_EQUAL(blood_entry.times, 0, "A shadow purchase changed the blood entry.")
	var/obj/item/antag_spawner/slaughter_demon/shadow/shadow_vial = locate() in wizard.contents
	TEST_ASSERT_NOTNULL(shadow_vial, "The purchased shadow vial did not reach the wizard's hands.")
	allocated += shadow_vial
	TEST_ASSERT(shadow_entry.can_refund(wizard, book, shadow_vial), "An unused purchased shadow vial was not refundable.")
	TEST_ASSERT(!blood_entry.can_refund(wizard, book, shadow_vial), "A shadow vial could refund the more expensive blood entry.")
	shadow_vial.used = TRUE
	TEST_ASSERT(!shadow_entry.can_refund(wizard, book, shadow_vial), "A used shadow vial was refundable.")
	shadow_vial.used = FALSE
	shadow_vial.summoning = TRUE
	TEST_ASSERT(!shadow_entry.can_refund(wizard, book, shadow_vial), "A shadow vial with an active ghost poll was refundable.")
	shadow_vial.summoning = FALSE
	TEST_ASSERT_EQUAL(book.item_interaction(wizard, shadow_vial, list()), ITEM_INTERACT_SUCCESS, "Returning a shadow vial did not select its own refund entry.")
	TEST_ASSERT(QDELETED(shadow_vial), "A refunded shadow vial remained usable.")
	TEST_ASSERT_EQUAL(book.uses, initial_points, "Refunding a shadow vial did not return exactly one point.")
	TEST_ASSERT_EQUAL(shadow_entry.times, 0, "The shadow refund did not reset its purchase count.")
	TEST_ASSERT_EQUAL(blood_entry.times, 0, "The shadow refund decremented the blood entry.")

	TEST_ASSERT(book.purchase_entry(blood_entry, wizard), "The native blood vial could no longer be purchased.")
	TEST_ASSERT_EQUAL(book.uses, initial_points - blood_entry.cost, "The native blood purchase cost changed.")
	var/obj/item/antag_spawner/slaughter_demon/blood_vial = locate() in wizard.contents
	TEST_ASSERT_NOTNULL(blood_vial, "The native blood purchase did not create a vial.")
	allocated += blood_vial
	TEST_ASSERT_EQUAL(blood_vial.type, /obj/item/antag_spawner/slaughter_demon, "The blood entry now creates a shadow vial.")
	TEST_ASSERT(!shadow_entry.can_refund(wizard, book, blood_vial), "A blood vial could refund the shadow entry.")
	TEST_ASSERT(blood_entry.can_refund(wizard, book, blood_vial), "An unused blood vial stopped being refundable.")
	TEST_ASSERT_EQUAL(book.item_interaction(wizard, blood_vial, list()), ITEM_INTERACT_SUCCESS, "The native blood vial refund branch regressed.")
	TEST_ASSERT_EQUAL(book.uses, initial_points, "The native blood vial no longer returns its full purchase cost.")
	TEST_ASSERT_EQUAL(blood_entry.times, 0, "The native blood refund did not reset its purchase count.")
	TEST_ASSERT_EQUAL(shadow_entry.times, 0, "The native blood refund changed the shadow entry.")

/// Targeting must keep the donor's living-mind filter in both physical and phased forms.
/datum/unit_test/shadow_demon_whisper_targets/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/target_turf = get_step(get_step(source_turf, EAST), EAST)
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, source_turf)
	demon.mind_initialize()
	var/datum/action/innate/shadow_demon_whisper/whisper = locate() in demon.actions
	TEST_ASSERT_NOTNULL(whisper, "The demon did not receive its whisper action.")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, target_turf)
	victim.mind_initialize()
	var/mob/living/carbon/human/mindless = allocate(/mob/living/carbon/human/consistent, target_turf)
	TEST_ASSERT_NULL(mindless.mind, "The mindless target fixture unexpectedly has a mind.")
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human/consistent, target_turf)
	corpse.mind_initialize()
	corpse.death()
	var/list/targets = whisper.get_whisper_targets()
	TEST_ASSERT(victim in targets, "A nearby living mind was absent from the whisper target list.")
	TEST_ASSERT(!(mindless in targets), "An empty body was offered as a whisper target.")
	TEST_ASSERT(!(corpse in targets), "A dead mind was offered as a whisper target.")
	TEST_ASSERT(!(demon in targets), "The demon was offered its own mind as a target.")
	var/datum/action/cooldown/spell/jaunt/shadow_demon/crawl = locate() in demon.actions
	TEST_ASSERT_NOTNULL(crawl, "The demon did not receive Shadow Crawl.")
	crawl.enter_jaunt(demon)
	TEST_ASSERT(is_jaunting(demon), "The whisper fixture did not enter its real phased holder.")
	TEST_ASSERT(victim in whisper.get_whisper_targets(), "A phased demon lost the nearby mind outside its holder.")
	crawl.exit_jaunt(demon)
	demon.moveToNullspace()
	TEST_ASSERT_EQUAL(length(whisper.get_whisper_targets()), 0, "A demon outside the world retained visible whisper targets.")

/// Client light masks do not change BYOND's mob-centred vision; Paradise uses an unbiased turf view.
/datum/unit_test/shadow_demon_whisper_vision/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/target_turf = get_step(get_step(source_turf, EAST), EAST)
	var/mob/living/basic/demon/shadow/demon = allocate(/mob/living/basic/demon/shadow, source_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, target_turf)
	victim.mind_initialize()
	var/datum/action/innate/shadow_demon_whisper/whisper = locate() in demon.actions
	TEST_ASSERT_NOTNULL(whisper, "The demon did not receive its whisper action.")
	demon.sight = BLIND
	TEST_ASSERT(!(victim in view(demon)), "The vision regression fixture did not exclude the victim from mob-centred view.")
	TEST_ASSERT(victim in whisper.get_whisper_targets(), "Whisper targeting inherited the engine eye restrictions instead of using the donor's turf view.")
	var/obj/effect/forcefield/obstacle = allocate(/obj/effect/forcefield, get_step(source_turf, EAST))
	obstacle.set_opacity(TRUE)
	TEST_ASSERT(!(victim in whisper.get_whisper_targets()), "Turf-centred whisper targeting saw through an opaque obstacle.")

/// Observe the message at the real logging boundary without replacing the chat subsystem.
/mob/living/basic/demon/shadow/whisper_test
	var/last_whisper_message
	var/whisper_log_count = 0

/mob/living/basic/demon/shadow/whisper_test/log_talk(message, message_type, tag = null, log_globally = TRUE, forced_by = null, custom_say_emote = null)
	if(findtext(tag, "shadow demon whisper to ") == 1)
		last_whisper_message = message
		whisper_log_count++
	return ..()

/// Sending rechecks the actor and target after dialogs and escapes player text exactly once.
/datum/unit_test/shadow_demon_whisper_delivery/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/target_turf = get_step(get_step(source_turf, EAST), EAST)
	var/mob/living/basic/demon/shadow/whisper_test/demon = allocate(/mob/living/basic/demon/shadow/whisper_test, source_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent, target_turf)
	victim.mind_initialize()
	var/datum/action/innate/shadow_demon_whisper/whisper = locate() in demon.actions
	TEST_ASSERT_NOTNULL(whisper, "The demon did not receive its whisper action.")
	TEST_ASSERT(whisper.send_whisper(demon, victim, "  <b>&  "), "A valid nearby mind did not receive the whisper send path.")
	TEST_ASSERT_EQUAL(demon.last_whisper_message, "&lt;b&gt;&amp;", "Whisper text was not escaped exactly once before logging and delivery.")
	TEST_ASSERT_EQUAL(demon.whisper_log_count, 1, "One whisper was logged more than once.")
	var/datum/action/cooldown/spell/jaunt/shadow_demon/crawl = locate() in demon.actions
	TEST_ASSERT_NOTNULL(crawl, "The demon did not receive Shadow Crawl.")
	crawl.enter_jaunt(demon)
	TEST_ASSERT(whisper.send_whisper(demon, victim, "from the shadows"), "A valid whisper could not be sent from the real phased holder.")
	crawl.exit_jaunt(demon)
	TEST_ASSERT_EQUAL(demon.whisper_log_count, 2, "The phased whisper did not reach the send path once.")
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "   "), "A whitespace-only whisper was sent.")
	TEST_ASSERT(!whisper.send_whisper(demon, victim, 123), "A non-text whisper was sent.")
	TEST_ASSERT(!whisper.send_whisper(victim, victim, "wrong actor"), "A stale actor could send another mob's action.")
	TEST_ASSERT(!whisper.send_whisper(demon, demon, "self"), "The demon could whisper to itself.")
	whisper.action_disabled = TRUE
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "disabled"), "An unavailable action sent a whisper.")
	whisper.action_disabled = FALSE
	victim.moveToNullspace()
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "moved target"), "A target leaving view during input could still receive a whisper.")
	victim.forceMove(target_turf)
	var/datum/mind/victim_mind = victim.mind
	victim.mind = null
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "empty body"), "A target losing its mind during input could still receive a whisper.")
	victim.mind = victim_mind
	victim.death()
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "dead target"), "A target dying during input could still receive a whisper.")
	qdel(victim)
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "deleted target"), "A deleted target could receive a whisper.")
	whisper.Remove(demon)
	TEST_ASSERT(!whisper.send_whisper(demon, victim, "removed action"), "An action removed from its owner could still send a whisper.")
	TEST_ASSERT_EQUAL(demon.whisper_log_count, 2, "A rejected whisper reached the delivery log.")

/// Keep the native candidate filter, supplying only the account-age method absent from its client mock.
/datum/client_interface/shadow_demon_candidate
	var/days_remaining = 0

/datum/client_interface/shadow_demon_candidate/proc/get_remaining_days(days_needed)
	return days_remaining

/datum/client_interface/shadow_demon_candidate/Destroy()
	if(mob)
		mob.mock_client = null
		mob.key = null
	mob = null
	prefs = null
	return ..()

/// The preferences panel must expose a separate opt-in key with its real preview asset.
/datum/unit_test/shadow_demon_preferences/Run()
	var/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/shadow_demon
	var/role_flag = initial(ruleset_type.pref_flag)
	TEST_ASSERT_EQUAL(role_flag, "Shadow Demon", "The shadow demon has no distinct preference flag.")
	TEST_ASSERT(role_flag in get_all_antag_flags(), "The native antagonist preference registry omitted the shadow demon.")
	TEST_ASSERT_EQUAL(serialize_antag_name(role_flag), "shadowdemon", "The backend preference key does not match the TGUI entry.")
	var/datum/client_interface/shadow_demon_candidate/mock_client = allocate(/datum/client_interface/shadow_demon_candidate)
	mock_client.ban_cache = list()
	var/datum/preferences/preferences = allocate(/datum/preferences, mock_client)
	mock_client.prefs = preferences
	preferences.be_special = list(ROLE_SENTIENCE)
	var/datum/preference_middleware/antags/middleware = locate() in preferences.middleware
	TEST_ASSERT_NOTNULL(middleware, "Native preferences did not create the antagonist middleware.")
	var/list/serialized_antags = middleware.get_serialized_antags()
	TEST_ASSERT_EQUAL(serialized_antags["shadowdemon"], role_flag, "The middleware cannot resolve the shadow demon toggle.")
	middleware.set_antags(list("antags" = list("shadowdemon", "unknown_shadow_role"), "toggled" = TRUE))
	TEST_ASSERT(role_flag in preferences.be_special, "Enabling the shadow demon toggle did not opt the player in.")
	TEST_ASSERT_EQUAL(length(preferences.be_special), 2, "The middleware accepted an unknown role or duplicated the existing preference.")
	middleware.set_antags(list("antags" = list("shadowdemon"), "toggled" = FALSE))
	TEST_ASSERT(!(role_flag in preferences.be_special), "Disabling the shadow demon toggle left the player opted in.")
	TEST_ASSERT(ROLE_SENTIENCE in preferences.be_special, "The independent shadow demon toggle removed the sentience preference.")
	var/datum/antagonist/shadow_demon/antagonist = allocate(/datum/antagonist/shadow_demon)
	TEST_ASSERT_EQUAL(antagonist.pref_flag, role_flag, "The antagonist and dynamic ruleset use different preference flags.")
	TEST_ASSERT_NOTNULL(antagonist.get_preview_icon(), "The shadow demon has no antagonist panel preview.")
	var/datum/asset/spritesheet_batched/antagonists/antag_assets = get_asset_datum(/datum/asset/spritesheet_batched/antagonists)
	TEST_ASSERT_NOTNULL(antag_assets.antag_icons["shadowdemon"], "The native antagonist spritesheet omitted the shadow demon preview.")

/// Use the real ruleset with an isolated maintenance pool and native lighting/atmosphere checks.
/datum/unit_test/shadow_demon_dynamic
	abstract_type = /datum/unit_test/shadow_demon_dynamic
	normal_floor_required = TRUE
	var/turf/test_turf
	var/datum/lighting_corner/test_corner
	var/list/old_corners
	var/created_lighting = FALSE
	var/list/old_maintenance_landmarks
	var/old_ghost_role_flags
	var/list/old_executed_rulesets
	var/list/old_disabled_rulesets
	var/fixture_ready = FALSE

/datum/unit_test/shadow_demon_dynamic/proc/set_up_spawn()
	old_maintenance_landmarks = GLOB.generic_maintenance_landmarks
	old_ghost_role_flags = GLOB.ghost_role_flags
	old_executed_rulesets = SSdynamic.executed_rulesets
	old_disabled_rulesets = SSdynamic.admin_disabled_rulesets
	fixture_ready = TRUE
	SSdynamic.executed_rulesets = list()
	SSdynamic.admin_disabled_rulesets = list()
	GLOB.ghost_role_flags |= GHOSTROLE_MIDROUND_EVENT
	test_turf = run_loc_floor_bottom_left
	GLOB.generic_maintenance_landmarks = list(test_turf)
	restore_atmos()
	old_corners = list(test_turf.lighting_corner_NE, test_turf.lighting_corner_SE, test_turf.lighting_corner_SW, test_turf.lighting_corner_NW)
	if(isnull(test_turf.lighting_object))
		test_turf.lighting_build_overlay()
		created_lighting = TRUE
	test_corner = allocate(/datum/lighting_corner, 0, 0, 0)
	test_turf.lighting_corner_NE = test_corner
	test_turf.lighting_corner_SE = test_corner
	test_turf.lighting_corner_SW = test_corner
	test_turf.lighting_corner_NW = test_corner
	set_spawn_lumcount(0)

/datum/unit_test/shadow_demon_dynamic/proc/set_spawn_lumcount(value)
	// The PR and local integration use different native lighting implementations.
	test_corner.lum_r = value
	test_corner.lum_g = value
	test_corner.lum_b = value
	test_corner.cache_r = value
	test_corner.cache_g = value
	test_corner.cache_b = value

/datum/unit_test/shadow_demon_dynamic/Destroy()
	if(fixture_ready)
		GLOB.generic_maintenance_landmarks = old_maintenance_landmarks
		GLOB.ghost_role_flags = old_ghost_role_flags
		SSdynamic.executed_rulesets = old_executed_rulesets
		SSdynamic.admin_disabled_rulesets = old_disabled_rulesets
		if(test_turf && old_corners)
			test_turf.lighting_corner_NE = old_corners[1]
			test_turf.lighting_corner_SE = old_corners[2]
			test_turf.lighting_corner_SW = old_corners[3]
			test_turf.lighting_corner_NW = old_corners[4]
			if(created_lighting)
				test_turf.lighting_clear_overlay()
		restore_atmos()
	test_turf = null
	test_corner = null
	old_corners = null
	old_maintenance_landmarks = null
	old_executed_rulesets = null
	old_disabled_rulesets = null
	return ..()

/// Natural selection must respect population, the ghost-role switch and a safe dark spawn.
/datum/unit_test/shadow_demon_dynamic/selection/Run()
	set_up_spawn()
	TEST_ASSERT(is_safe_turf(test_turf), "The maintenance fixture is not safe for native ghost-role spawning.")
	var/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/ruleset = allocate(/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon)
	TEST_ASSERT_EQUAL(ruleset.midround_type, HEAVY_MIDROUND, "The shadow demon is outside the heavy midround pool.")
	TEST_ASSERT_EQUAL(ruleset.get_antag_cap(100, ruleset.min_antag_cap), 1, "The ruleset requires more than one volunteer.")
	TEST_ASSERT_EQUAL(ruleset.get_antag_cap(100, ruleset.max_antag_cap), 1, "The ruleset can create more than one shadow demon.")
	TEST_ASSERT_EQUAL(ruleset.get_weight(19), 0, "The ruleset can roll below its population threshold.")
	TEST_ASSERT_EQUAL(ruleset.get_weight(20), 1, "The eligible shadow demon has no natural selection weight.")
	GLOB.ghost_role_flags &= ~GHOSTROLE_MIDROUND_EVENT
	TEST_ASSERT_EQUAL(ruleset.get_weight(20), 0, "Disabling midround ghost roles did not exclude the shadow demon.")
	GLOB.ghost_role_flags |= GHOSTROLE_MIDROUND_EVENT
	set_spawn_lumcount(0.21)
	TEST_ASSERT_EQUAL(ruleset.get_weight(20), 0, "The ruleset can roll with only a lit maintenance spawn.")
	TEST_ASSERT_NULL(ruleset.create_ruleset_body(), "A lit maintenance spawn still created a shadow demon.")
	set_spawn_lumcount(0)
	var/turf/open/spawn_turf = test_turf
	var/datum/gas_mixture/spawn_air = spawn_turf.return_air()
	var/old_temperature = spawn_air.temperature
	spawn_air.temperature = 0
	TEST_ASSERT(!ruleset.can_be_selected(), "The ruleset accepted a dark maintenance spawn with unsafe atmosphere.")
	TEST_ASSERT_NULL(ruleset.create_ruleset_body(), "Unsafe maintenance atmosphere still created a shadow demon.")
	spawn_air.temperature = old_temperature
	GLOB.generic_maintenance_landmarks = list()
	TEST_ASSERT(!ruleset.can_be_selected(), "The ruleset can run without any maintenance spawns.")
	TEST_ASSERT_NULL(ruleset.create_ruleset_body(), "An empty maintenance pool created a body in nullspace.")
	GLOB.generic_maintenance_landmarks = list(test_turf)
	var/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/previous = allocate(/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon)
	SSdynamic.executed_rulesets += previous
	TEST_ASSERT_EQUAL(ruleset.get_weight(20), 0, "The non-repeatable shadow demon can roll twice in one round.")

/// Use native preference and ban filtering, rather than opting every sentience volunteer into this role.
/datum/unit_test/shadow_demon_candidates/Run()
	var/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/ruleset = allocate(/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon)
	var/datum/client_interface/shadow_demon_candidate/mock_client = allocate(/datum/client_interface/shadow_demon_candidate)
	mock_client.ban_cache = list()
	var/datum/preferences/preferences = allocate(/datum/preferences, mock_client)
	mock_client.prefs = preferences
	var/mob/dead/observer/candidate = allocate(/mob/dead/observer)
	candidate.key = mock_client.key
	candidate.mock_client = mock_client
	mock_client.mob = candidate
	TEST_ASSERT_EQUAL(candidate.ckey, mock_client.ckey, "The native ghost candidate did not retain its mock account key.")
	preferences.be_special = list(ROLE_SENTIENCE)
	TEST_ASSERT_EQUAL(length(ruleset.trim_candidates(list(candidate))), 0, "Sentience preference alone opted the ghost into shadow demon.")
	preferences.be_special = list(ruleset.pref_flag)
	TEST_ASSERT(candidate in ruleset.trim_candidates(list(candidate)), "A separately opted-in ghost was rejected by native candidate selection.")
	var/mob/living/carbon/human/living_candidate = allocate(/mob/living/carbon/human/consistent)
	living_candidate.mind_initialize()
	candidate.key = null
	candidate.mock_client = null
	living_candidate.key = mock_client.key
	living_candidate.mock_client = mock_client
	mock_client.mob = living_candidate
	TEST_ASSERT_EQUAL(living_candidate.ckey, mock_client.ckey, "The revived candidate did not receive the same opted-in mock account.")
	TEST_ASSERT_EQUAL(length(ruleset.trim_candidates(list(living_candidate))), 0, "A volunteer who returned to a living body remained eligible for the ghost role.")
	living_candidate.death()
	TEST_ASSERT_EQUAL(living_candidate.ckey, mock_client.ckey, "The dead body fixture lost its opted-in mock account.")
	TEST_ASSERT(living_candidate in ruleset.trim_candidates(list(living_candidate)), "A dead volunteer still in a living mob type was excluded from the native ghost-role pool.")
	living_candidate.key = null
	living_candidate.mock_client = null
	candidate.key = mock_client.key
	candidate.mock_client = mock_client
	mock_client.mob = candidate
	TEST_ASSERT(candidate in ruleset.trim_candidates(list(candidate)), "Returning the account to its observer did not restore ghost-role eligibility.")
	for(var/banned_role in list(ruleset.pref_flag, ROLE_SYNDICATE, ROLE_SENTIENCE))
		mock_client.ban_cache = list(banned_role)
		TEST_ASSERT_EQUAL(length(ruleset.trim_candidates(list(candidate))), 0, "A ghost banned from [banned_role] could become a shadow demon.")
	mock_client.ban_cache = list()
	mock_client.days_remaining = 1
	TEST_ASSERT_EQUAL(length(ruleset.trim_candidates(list(candidate))), 0, "The native account-age check was bypassed.")
	mock_client.days_remaining = 0
	candidate.mock_client = null
	TEST_ASSERT_EQUAL(length(ruleset.trim_candidates(list(candidate))), 0, "A disconnected ghost remained a valid candidate.")

/// Ghost transfers without Login still receive one correct job/antagonist; stale bodies receive neither.
/datum/unit_test/shadow_demon_dynamic/body/Destroy()
	// Antagonist deletion nulls its owner's lazy list; remove it before the native mind's QDEL_LIST cleanup.
	for(var/datum/mind/candidate in allocated)
		candidate.remove_all_antag_datums()
	return ..()

/datum/unit_test/shadow_demon_dynamic/body/Run()
	set_up_spawn()
	TEST_ASSERT(is_safe_turf(test_turf), "The maintenance fixture is not safe for native ghost-role spawning.")
	var/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/ruleset = allocate(/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon)
	var/mob/living/basic/demon/shadow/body = ruleset.create_ruleset_body()
	TEST_ASSERT(istype(body), "The ruleset did not create its real shadow demon body.")
	allocated += body
	TEST_ASSERT_EQUAL(get_turf(body), test_turf, "The ruleset body did not use the safe dark maintenance spawn.")
	var/datum/mind/candidate = allocate(/datum/mind)
	candidate.transfer_to(body)
	TEST_ASSERT(!candidate.has_antag_datum(/datum/antagonist/shadow_demon), "The transfer fixture unexpectedly initialized through Login.")
	ruleset.selected_minds += candidate
	ruleset.execute()
	TEST_ASSERT(istype(candidate.assigned_role, /datum/job/shadow_demon), "Dynamic execution did not assign the shadow demon job.")
	TEST_ASSERT(candidate.has_antag_datum(/datum/antagonist/shadow_demon), "Dynamic execution without Login did not assign the antagonist.")
	body.mind_initialize()
	ruleset.execute()
	var/antag_count = 0
	for(var/datum/antagonist/shadow_demon/antagonist in candidate.antag_datums)
		antag_count++
	TEST_ASSERT_EQUAL(antag_count, 1, "Login and repeated ruleset execution duplicated the antagonist.")
	var/mob/living/carbon/human/wrong_body = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	wrong_body.mind_initialize()
	var/datum/job/old_job = wrong_body.mind.assigned_role
	var/datum/mind/bodyless_candidate = allocate(/datum/mind)
	ruleset.selected_minds.Cut()
	ruleset.selected_minds += wrong_body.mind
	ruleset.selected_minds += bodyless_candidate
	ruleset.execute()
	TEST_ASSERT(!wrong_body.mind.has_antag_datum(/datum/antagonist/shadow_demon), "A stale non-demon body received the antagonist.")
	TEST_ASSERT_EQUAL(wrong_body.mind.assigned_role, old_job, "A stale non-demon body received the shadow demon job.")
	TEST_ASSERT(!bodyless_candidate.has_antag_datum(/datum/antagonist/shadow_demon), "A candidate without a spawned body received the antagonist.")

#endif
