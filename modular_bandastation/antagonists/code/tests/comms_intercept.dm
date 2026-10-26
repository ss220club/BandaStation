/datum/unit_test/comms_intercept_threshold

/datum/unit_test/comms_intercept_threshold/Run()
	TEST_ASSERT_EQUAL(comms_intercept_threshold(0), 40, "Threshold must not go below 40")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(15), 40, "Minimal crew should hit the lower bound")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(30), 60, "Threshold should be 2 packets per crew member")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(80), 100, "Threshold must not go above 100")

/datum/unit_test/comms_intercept_garble

/datum/unit_test/comms_intercept_garble/Run()
	var/datum/objective/comms_intercept/objective = allocate(/datum/objective/comms_intercept)
	objective.target_amount = 20
	objective.messages_collected = 14
	TEST_ASSERT_EQUAL(objective.get_garble_chance(), 0, "Channels must stay clean below 75%")
	objective.messages_collected = 15
	TEST_ASSERT_EQUAL(objective.get_garble_chance(), 10, "Garbling should start at 10% on 75%")
	objective.messages_collected = 18
	TEST_ASSERT_EQUAL(objective.get_garble_chance(), 52, "Garbling should ramp up linearly towards 80%")
	objective.messages_collected = 20
	TEST_ASSERT_EQUAL(objective.get_garble_chance(), 100, "Channels must be fully garbled during the transmission")

/datum/unit_test/comms_intercept_direction

/datum/unit_test/comms_intercept_direction/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/list/expected = list(
		"на север" = locate(center.x, center.y + 2, center.z),
		"на юг" = locate(center.x, center.y - 1, center.z),
		"на восток" = locate(center.x + 2, center.y, center.z),
		"на запад" = locate(center.x - 1, center.y, center.z),
		"на северо-восток" = locate(center.x + 2, center.y + 2, center.z),
		"на северо-запад" = locate(center.x - 1, center.y + 1, center.z),
		"на юго-восток" = locate(center.x + 1, center.y - 1, center.z),
		"на юго-запад" = locate(center.x - 1, center.y - 1, center.z),
		"в пределах узла" = center,
	)
	for(var/text in expected)
		TEST_ASSERT_EQUAL(comms_intercept_direction_text(center, expected[text]), text, "Wrong direction text")
	if(center.z > 1)
		var/turf/below = locate(center.x, center.y + 1, center.z - 1)
		TEST_ASSERT_EQUAL(comms_intercept_direction_text(center, below), "на север, уровнем ниже", "Level difference must be reported")
		TEST_ASSERT_EQUAL(comms_intercept_direction_text(below, center), "на юг, уровнем выше", "Level difference must be reported")
