#define STATION_REPORT_TEMPLATE_PATH "modular_bandastation/storyteller/templates/station_report.md"

SUBSYSTEM_DEF(gamemode)
	name = "Gamemode"
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND | SS_KEEP_TIMING
	priority = 20
	wait = 2 SECONDS

/datum/controller/subsystem/gamemode/Initialize(time, zlevel)

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/controller/subsystem/gamemode/proc/generate_station_goal_report()
	if(GLOB.communications_controller.block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(generate_station_goal_report)), 10 SECONDS)
		return

	if(!fexists(STATION_REPORT_TEMPLATE_PATH))
		stack_trace("station report template doesn't exist at path: [STATION_REPORT_TEMPLATE_PATH]")
		return

	var/station_report_template = file2text(STATION_REPORT_TEMPLATE_PATH)
	if(!station_report_template)
		stack_trace("station report template doesn't is empty at path: [STATION_REPORT_TEMPLATE_PATH]")
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
	if(length(GLOB.communications_controller.command_report_footnotes))
		var/list/footnotes = list()
		for(var/datum/command_footnote/footnote in GLOB.communications_controller.command_report_footnotes)
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

#undef STATION_REPORT_TEMPLATE_PATH
