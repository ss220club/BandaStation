#define COMMUNICATION_COOLDOWN (30 SECONDS)
#define COMMUNICATION_COOLDOWN_AI (30 SECONDS)
#define COMMUNICATION_COOLDOWN_MEETING (5 MINUTES)
#define STATION_REPORT_TEMPLATE_PATH "modular_bandastation/paperwork/templates/station_report.md" /// BANDASTATION ADDITION - UPDATED INTERCEPT TEMPLATE

GLOBAL_DATUM_INIT(communications_controller, /datum/communciations_controller, new)

/datum/communciations_controller
	COOLDOWN_DECLARE(silicon_message_cooldown)
	COOLDOWN_DECLARE(nonsilicon_message_cooldown)

	/// Are we trying to send a cross-station message that contains soft-filtered words? If so, flip to TRUE to extend the time admins have to cancel the message.
	var/soft_filtering = FALSE

	/// A list of footnote datums, to be added to the bottom of the roundstart command report.
	var/list/command_report_footnotes = list()
	/// A counter of conditions that are blocking the command report from printing. Counter incremements up for every blocking condition, and de-incrememnts when it is complete.
	var/block_command_report = 0
	/// Has a special xenomorph egg been delivered?
	var/xenomorph_egg_delivered = FALSE
	/// The location where the special xenomorph egg was planted
	var/area/captivity_area

	/// What is the lower bound of when the roundstart announcement is sent out?
	var/waittime_l = 1 SECONDS /// BANDASTATION EDIT
	/// What is the higher bound of when the roundstart announcement is sent out?
	var/waittime_h = 5 SECONDS /// BANDASTATION EDIT

/datum/communciations_controller/proc/can_announce(mob/living/user, is_silicon)
	if(is_silicon && COOLDOWN_FINISHED(src, silicon_message_cooldown))
		return TRUE
	else if(!is_silicon && COOLDOWN_FINISHED(src, nonsilicon_message_cooldown))
		return TRUE
	else
		return FALSE

/datum/communciations_controller/proc/make_announcement(mob/living/user, is_silicon, input, syndicate, list/players)
	if(!can_announce(user, is_silicon))
		return FALSE
	if(is_silicon)
		minor_announce(html_decode(input),"[user.name] объявляет", players = players)
		COOLDOWN_START(src, silicon_message_cooldown, COMMUNICATION_COOLDOWN_AI)
	else
		var/list/message_data = user.treat_message(input)
		if(syndicate)
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE, players = players, color_override = "red", tts_override = user.GetComponent(/datum/component/tts_component)) // Bandastation Addition: "tts_override = user.GetComponent(/datum/component/tts_component)"
		else
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE, players = players, tts_override = user.GetComponent(/datum/component/tts_component)) // Bandastation Addition: "tts_override = user.GetComponent(/datum/component/tts_component)"
		COOLDOWN_START(src, nonsilicon_message_cooldown, COMMUNICATION_COOLDOWN)
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/datum/communciations_controller/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.machine_stat & (BROKEN|NOPOWER)) && is_station_level(C.z))
			if(unique)
				C.add_message(sending)
			else //We copy the message for each console, answers and deletions won't be shared
				var/datum/comm_message/M = new(sending.title,sending.content,sending.possible_answers.Copy())
				C.add_message(M)
			if(print)
				var/obj/item/paper/printed_paper = new /obj/item/paper(C.loc)
				printed_paper.name = "paper - '[sending.title]'"
				printed_paper.add_raw_text(sending.content)
				printed_paper.update_appearance()

// Called AFTER everyone is equipped with their job
/datum/communciations_controller/proc/queue_roundstart_report()
	addtimer(CALLBACK(src, PROC_REF(send_roundstart_report)), rand(waittime_l, waittime_h))

/// BANDASTATION EDIT START - UPDATED INTERCEPT TEMPLATE

/datum/communciations_controller/proc/send_roundstart_report(greenshift)
	if(block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(send_roundstart_report), greenshift), 10 SECONDS)
		return

	SSstation.generate_station_goals(CONFIG_GET(number/station_goal_budget))
	if(!fexists(STATION_REPORT_TEMPLATE_PATH))
		stack_trace("station report template doesn't exist at path: [STATION_REPORT_TEMPLATE_PATH]")
		return

	var/station_report_template = file2text(STATION_REPORT_TEMPLATE_PATH)
	if(!station_report_template)
		stack_trace("station report template is empty at path: [STATION_REPORT_TEMPLATE_PATH]")
		return

	var/list/datum/station_goal/goals = SSstation.get_station_goals()
	var/station_goals_section = ""
	if(length(goals))
		var/list/station_goal_reports = list()
		for(var/datum/station_goal/station_goal as anything in goals)
			station_goal.on_report()
			station_goal_reports += station_goal.get_report()

		station_goals_section = list(
			"# === Цели на смену ===\n",
			station_goal_reports.Join("\n\n---\n\n"),
		).Join()

	station_report_template = replacetext(station_report_template, "%STATION_GOALS", station_goals_section);

	var/list/trait_reports = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue

		trait_reports += "- [station_trait.get_report()]"

	var/trait_reports_sections = ""
	if(length(trait_reports))
		trait_reports_sections = list(
			"\n\n---\n\n",
			"# === Обнаруженные отклонения ===\n",
			trait_reports.Join("\n")
		).Join()

	station_report_template = replacetext(station_report_template, "%TRAIT_REPORTS", trait_reports_sections);

	var/footnote_section = ""
	if(length(command_report_footnotes))
		var/list/footnotes = list()
		for(var/datum/command_footnote/footnote in command_report_footnotes)
			footnotes += "[footnote.message]<BR>"
			footnotes += "<i>[footnote.signature]</i><BR>"
			footnotes += "<BR>"

		footnote_section = list(
			"\n\n---\n\n",
			"# === Дополнительная информация ===\n",
			footnotes.Join()
		).Join()

	station_report_template = replacetext(station_report_template, "%FOOTNOTES", footnote_section);
	station_report_template = replacetext(station_report_template, "%SIGNING_OFFICER", "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]");

	station_report_template = replace_text_keys(station_report_template)

#ifndef MAP_TEST
	print_command_report(station_report_template, "[command_name()] Status Summary", announce=FALSE)
	priority_announce("Отчет был скопирован и распечатан на всех консолях связи.", "Отчет о безопасности", SSstation.announcer.get_rand_report_sound())
#endif

/// BANDASTATION EDIT END - UPDATED INTERCEPT TEMPLATE

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
#undef COMMUNICATION_COOLDOWN_MEETING

/// BANDASTATION ADDITION - UPDATED INTERCEPT TEMPLATE
#undef STATION_REPORT_TEMPLATE_PATH
