/datum/unit_test/comms_intercept_threshold

/datum/unit_test/comms_intercept_threshold/Run()
	TEST_ASSERT_EQUAL(comms_intercept_threshold(0), 40, "Threshold must not go below 40")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(15), 40, "Minimal crew should hit the lower bound")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(30), 60, "Threshold should be 2 packets per crew member")
	TEST_ASSERT_EQUAL(comms_intercept_threshold(80), 100, "Threshold must not go above 100")

/datum/unit_test/comms_intercept_upload_time

/datum/unit_test/comms_intercept_upload_time/Run()
	TEST_ASSERT_EQUAL(comms_intercept_upload_time(0), 2 MINUTES, "Right next to the tap should be the fastest")
	TEST_ASSERT_EQUAL(comms_intercept_upload_time(50), 3.5 MINUTES, "Upload time should grow linearly with distance")
	TEST_ASSERT_EQUAL(comms_intercept_upload_time(250), 5 MINUTES, "Upload time must not go above the cap")
	TEST_ASSERT_EQUAL(comms_intercept_upload_time(null), 5 MINUTES, "No working tap should be the slowest")

	var/turf/center = run_loc_floor_bottom_left
	TEST_ASSERT_EQUAL(comms_intercept_tap_distance(center, locate(center.x + 3, center.y + 7, center.z)), 7, "Distance on one level should match get_dist()")
	if(center.z > 1)
		var/turf/below = locate(center.x + 3, center.y + 7, center.z - 1)
		TEST_ASSERT_EQUAL(comms_intercept_tap_distance(center, below), 37, "Each level of difference should add 30 tiles")

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

/datum/unit_test/comms_intercept_static

/datum/unit_test/comms_intercept_static/Run()
	TEST_ASSERT_EQUAL(comms_intercept_static_text(9), "оглушающий треск", "Static should be deafening right next to the receiver")
	TEST_ASSERT_EQUAL(comms_intercept_static_text(10), "отчётливый треск", "Static should be clear from 10 tiles")
	TEST_ASSERT_EQUAL(comms_intercept_static_text(30), "отчётливый треск", "Static should be clear up to 30 tiles")
	TEST_ASSERT_EQUAL(comms_intercept_static_text(31), "слабый треск", "Static should be weak further than 30 tiles")
