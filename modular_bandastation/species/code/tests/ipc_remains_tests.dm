/// Supermatter uses forced dusting; the delayed remains must follow the chassis rather than its human mob type.
/datum/unit_test/ipc_supermatter_remains/Run()
	var/obj/item/stack/sheet/iron/crystal_proxy = allocate(/obj/item/stack/sheet/iron)
	var/datum/component/supermatter_crystal/crystal = crystal_proxy.AddComponent(/datum/component/supermatter_crystal)
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent)
	ipc.set_species(/datum/species/ipc)
	var/turf/dust_turf = get_turf(ipc)
	crystal.consume(crystal_proxy, ipc)
	wait_for_dust(ipc)
	TEST_ASSERT(QDELETED(ipc), "Supermatter consumption did not destroy the IPC.")
	var/obj/effect/decal/remains/robot/remains = locate() in dust_turf
	TEST_ASSERT_NOTNULL(remains, "Supermatter left no robotic IPC remains.")
	TEST_ASSERT_NULL(locate(/obj/effect/decal/remains/human) in dust_turf, "Supermatter left human bones from an IPC.")
	TEST_ASSERT_NULL(locate(/obj/effect/decal/remains/plasma) in dust_turf, "Supermatter left plasmaman bones from an IPC.")
	TEST_ASSERT_NULL(locate(/obj/item/organ/brain/ipc) in dust_turf, "Dusting ejected a reusable IPC brain.")

/datum/unit_test/ipc_supermatter_remains/proc/wait_for_dust(mob/living/victim)
	var/deadline = world.time + 5 SECONDS
	while(!QDELETED(victim) && world.time < deadline)
		stoplag()

/// Species-specific debris must not change ordinary human/plasmaman remains or explicit ash-only destruction.
/datum/unit_test/ipc_remains_regression/Run()
	var/list/cases = list(
		list("species" = /datum/species/human, "remains" = /obj/effect/decal/remains/human),
		list("species" = /datum/species/plasmaman, "remains" = /obj/effect/decal/remains/plasma),
	)
	var/index = 0
	for(var/list/remains_case as anything in cases)
		var/turf/dust_turf = locate(run_loc_floor_bottom_left.x + index, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
		index++
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, dust_turf)
		human.set_species(remains_case["species"])
		human.spawn_dust(FALSE)
		TEST_ASSERT_NOTNULL(locate(remains_case["remains"]) in dust_turf, "Dusting changed the remains of [remains_case["species"]].")
		TEST_ASSERT_NULL(locate(/obj/effect/decal/remains/robot) in dust_turf, "An organic species produced IPC debris.")

	var/turf/ash_turf = get_step(run_loc_floor_bottom_left, NORTH)
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/consistent, ash_turf)
	ipc.set_species(/datum/species/ipc)
	ipc.spawn_dust(TRUE)
	TEST_ASSERT_NOTNULL(locate(/obj/effect/decal/cleanable/ash) in ash_turf, "Ash-only IPC destruction stopped producing ash.")
	TEST_ASSERT_NULL(locate(/obj/effect/decal/remains) in ash_turf, "Ash-only IPC destruction also produced chassis remains.")
