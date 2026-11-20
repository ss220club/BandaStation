/datum/unit_test/fines_pro_preinstall/Run()
	var/list/security_pdas = list(
		/obj/item/modular_computer/pda/crew/security,
		/obj/item/modular_computer/pda/crew/detective,
		/obj/item/modular_computer/pda/crew/warden,
		/obj/item/modular_computer/pda/crew/heads/hos,
		/obj/item/modular_computer/pda/veteran_advisor,
	)
	for(var/pda_type in security_pdas)
		var/obj/item/modular_computer/pda/pda = allocate(pda_type)
		TEST_ASSERT(locate(/datum/computer_file/program/fines_pro) in pda.stored_files, "[pda_type] should have FinesPRO+ installed.")
		var/list/expected_programs = pda.default_programs + pda.pda_programs + pda.starting_programs
		if(istype(pda, /obj/item/modular_computer/pda/crew/heads))
			expected_programs += /obj/item/modular_computer/pda/crew/heads::head_programs
		for(var/program_type in expected_programs)
			TEST_ASSERT(locate(program_type) in pda.stored_files, "[pda_type] must retain its [program_type] program.")

	var/obj/item/modular_computer/pda/crew/heads/captain/captain_pda = EASY_ALLOCATE()
	TEST_ASSERT(!(locate(/datum/computer_file/program/fines_pro) in captain_pda.stored_files), "Captains download FinesPRO+ from the store.")

/datum/unit_test/fines_pro_access/Run()
	var/mob/living/carbon/human/consistent/user = EASY_ALLOCATE()
	var/obj/item/modular_computer/pda/crew/security/pda = EASY_ALLOCATE()
	var/obj/machinery/ntnet_relay/relay = EASY_ALLOCATE()
	relay.set_is_operational(TRUE)
	pda.long_ranged = TRUE
	TEST_ASSERT(pda.get_ntnet_status(), "The ID check must be exercised with NTNet available.")
	var/datum/computer_file/program/fines_pro/program = locate() in pda.stored_files
	TEST_ASSERT_NOTNULL(program, "The officer PDA must include FinesPRO+.")
	var/datum/record/crew/target = allocate(/datum/record/crew)
	var/datum/tgui/ui = allocate(/datum/tgui, user, pda, program.tgui_id)
	var/obj/item/card/id/advanced/id = EASY_ALLOCATE()
	id.set_access(list(ACCESS_SECURITY), FORCE_ADD_ALL)
	pda.insert_id(id)
	var/list/form = program.ui_data(user)
	TEST_ASSERT(form["authorized"], "Security access on a generic ID must be sufficient.")
	var/list/request = list(
		"program_uid" = program.uid,
		"submission_number" = form["submission_number"],
		"record_ref" = REF(target),
		"article" = "101",
		"details" = "Test",
		"amount" = 1,
	)

	pda.remove_id()
	pda.obj_flags |= EMAGGED
	var/paper_count = pda.stored_paper
	program.ui_act("issue_fine", request, ui)
	form = program.ui_data(user)
	TEST_ASSERT(!form["authorized"] && !length(form["records"]), "An emagged PDA without an ID must hide the manifest.")
	TEST_ASSERT_EQUAL(length(target.citations), 0, "Removing the ID after opening the form must block issuance.")
	TEST_ASSERT_EQUAL(pda.stored_paper, paper_count, "Removing the ID must not consume paper.")

	id.set_access(list(ACCESS_HYDROPONICS), FORCE_ADD_ALL)
	pda.insert_id(id)
	form = program.ui_data(user)
	request["submission_number"] = form["submission_number"]
	program.ui_act("issue_fine", request, ui)
	TEST_ASSERT(!form["authorized"], "An inserted ID without security access must still be rejected.")
	TEST_ASSERT_EQUAL(length(target.citations), 0, "Replacing the ID with a civilian one must block issuance.")
	TEST_ASSERT_EQUAL(pda.stored_paper, paper_count, "Replacing the ID must not consume paper.")

/datum/unit_test/fines_pro_issuance/Run()
	var/mob/living/carbon/human/consistent/user = EASY_ALLOCATE()
	var/obj/item/card/id/advanced/id = EASY_ALLOCATE()
	id.set_access(list(ACCESS_SECURITY), FORCE_ADD_ALL)
	var/datum/record/crew/target = allocate(/datum/record/crew)
	// The test room is on a reserved Z-level outside the station's normal wireless range.
	var/obj/machinery/ntnet_relay/relay = EASY_ALLOCATE()
	relay.set_is_operational(TRUE)
	var/regex/number_format = regex(@"(\d{5})-(\d{3,})")
	var/first_prefix
	var/first_sequence
	var/list/first_request
	for(var/document in 1 to 2)
		var/obj/item/modular_computer/pda/crew/security/pda = EASY_ALLOCATE()
		pda.long_ranged = TRUE
		id.registered_name = document == 1 ? "Card Owner" : null
		id.assignment = document == 1 ? JOB_WARDEN : null
		pda.insert_id(id)
		var/datum/computer_file/program/fines_pro/program = locate() in pda.stored_files
		TEST_ASSERT_NOTNULL(program, "Expected the app to be preinstalled.")
		var/datum/tgui/ui = allocate(/datum/tgui, user, pda, program.tgui_id)
		var/list/request = list(
			"program_uid" = program.uid,
			"submission_number" = program.submission_number,
			"record_ref" = REF(target),
			"article" = "101",
			"details" = "Test",
			"amount" = 1,
		)

		if(document == 2)
			program.ui_act("issue_fine", first_request, ui)
			TEST_ASSERT_EQUAL(length(target.citations), 1, "A past request cannot be replayed on a fresh installation.")
			pda.stored_paper = 0
			program.ui_act("issue_fine", request, ui)
			TEST_ASSERT_EQUAL(length(target.citations), 1, "Failed printing must leave the record intact.")
			TEST_ASSERT_NULL(user.get_inactive_held_item(), "An empty printer produced a notice.")
			request["submission_number"] = program.submission_number

		pda.stored_paper = 2
		program.ui_act("issue_fine", request, ui)
		program.ui_act("issue_fine", request, ui)
		TEST_ASSERT_EQUAL(length(target.citations), document, "A repeated request must issue exactly one citation.")
		TEST_ASSERT_EQUAL(pda.stored_paper, 1, "A repeated request must print exactly one notice.")
		var/datum/crime/citation/citation = target.citations[document]
		TEST_ASSERT_EQUAL(citation.author, user, "The security record must retain the actual operator as author.")
		TEST_ASSERT_EQUAL(citation.fine, 1, "The citation must retain the entered amount.")
		TEST_ASSERT_EQUAL(citation.details, "Test", "The citation must retain the entered details.")
		TEST_ASSERT_EQUAL(target.wanted_status, WANTED_NONE, "A fine must preserve the wanted status.")
		var/obj/item/paper/fine_notice/notice = user.get_inactive_held_item()
		TEST_ASSERT(istype(notice), "The recipient should receive the printed notice.")
		var/printed_text = notice.get_raw_text()
		var/expected_signer = document == 1 ? "Card Owner ([JOB_WARDEN_RU])" : "имя не зарегистрировано"
		TEST_ASSERT(findtext(printed_text, "[expected_signer]<br>"), "The notice should show the name and job from the inserted card.")
		TEST_ASSERT(number_format.Find(printed_text), "A printed ruling must contain its round prefix and serial number.")
		if(document == 1)
			first_request = request
			first_prefix = number_format.group[1]
			first_sequence = text2num(number_format.group[2])
		else
			TEST_ASSERT_EQUAL(number_format.group[1], first_prefix, "All PDAs must print the same round prefix.")
			TEST_ASSERT_EQUAL(text2num(number_format.group[2]), first_sequence + 1, "Separate PDAs must share the sequence; failed printing must not consume a number.")
		user.dropItemToGround(notice)
		pda.remove_id()
