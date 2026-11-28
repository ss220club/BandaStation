/** Обучает пониманию разрешённых языков по разным услышанным фразам. */
/datum/ai_project/translation
	name = "Heuristic Language Translation"
	description = "Позволяет понимать незнакомый язык после восьми разных услышанных фраз. Во время работы требует 10% CPU. Зашифрованные и закрытые языки изучить нельзя."
	research_cost = 1500
	ram_required = 2
	category = AI_PROJECT_MISC
	/// Уникальные образцы услышанных фраз по типам разрешённых языков.
	var/list/heard_languages = list()

/datum/ai_project/translation/can_run()
	if(!..())
		return FALSE
	var/used_cpu = 0
	for(var/project_name in dashboard.cpu_usage)
		used_cpu += dashboard.cpu_usage[project_name]
	return used_cpu <= 0.9

/datum/ai_project/translation/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return
	RegisterSignal(ai, COMSIG_MOVABLE_HEAR, PROC_REF(heard_message))
	dashboard.cpu_usage[name] = 0.1

/** Учитывает разные услышанные фразы только разрешённых языков и выдаёт понимание после восьми образцов. */
/datum/ai_project/translation/proc/heard_message(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/language = hearing_args[HEARING_LANGUAGE]
	var/phrase = hearing_args[HEARING_RAW_MESSAGE]
	if(!running || !ispath(language, /datum/language) || !istext(phrase) || !length(trim(phrase)))
		return
	if(ai.has_language(language, UNDERSTOOD_LANGUAGE))
		return
	if(!(language in list(/datum/language/common, /datum/language/calcic, /datum/language/draconic, /datum/language/moffic, /datum/language/nekomimetic, /datum/language/uncommon, /datum/language/slime, /datum/language/terrum, /datum/language/spinwarder)))
		return
	var/list/samples = heard_languages[language]
	if(!samples)
		samples = list()
		heard_languages[language] = samples
	samples |= md5(LOWER_TEXT(trim(phrase)))
	if(length(samples) < 8)
		return
	ai.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SOFTWARE)
	heard_languages -= language
	to_chat(ai, span_notice("Анализ языка завершён. Доступна новая модель понимания."))

/datum/ai_project/translation/stop()
	UnregisterSignal(ai, COMSIG_MOVABLE_HEAR)
	dashboard.cpu_usage[name] = 0
	return ..()
