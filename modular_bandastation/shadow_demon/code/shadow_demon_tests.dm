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
	// Native lumcount averages twelve corner colour channels.
	test_corner.lum_r = value * 12

/datum/unit_test/shadow_demon_environment/Run()
	test_turf = run_loc_floor_bottom_left
	old_corners = list(test_turf.lighting_corner_NE, test_turf.lighting_corner_SE, test_turf.lighting_corner_SW, test_turf.lighting_corner_NW)
	if(isnull(test_turf.lighting_object))
		test_turf.lighting_build_overlay()
		created_lighting = TRUE
	test_corner = allocate(/datum/lighting_corner, 0, 0, 0)
	test_turf.lighting_corner_NE = test_corner
	test_turf.lighting_corner_SE = null
	test_turf.lighting_corner_SW = null
	test_turf.lighting_corner_NW = null
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

#endif
