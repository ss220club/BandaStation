/** Находит заданную по имени цель только при её доступности для камер ИИ. */
/datum/ai_project/camera_tracker
	name = "Camera Memory Tracker"
	description = "Рекуррентные нейронные сети LSTM позволяют автоматически замечать, когда выбранный человек появляется в поле зрения камер."
	research_cost = 2500
	ram_required = 3
	research_requirements = list(/datum/ai_project/examine_humans)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/camera_tracker/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.can_track_camera_target = TRUE
	ASSIGN_GAME_VERB(ai, /mob/living/silicon/ai, choose_camera_target)

/datum/ai_project/camera_tracker/stop()
	ai.can_track_camera_target = FALSE
	ai.clear_camera_memory_track()
	UNASSIGN_GAME_VERB(ai, /mob/living/silicon/ai, choose_camera_target)
	return ..()

/mob/living/silicon/ai
	/// Разрешает автоматическое наблюдение при работающем проекте памяти камер.
	var/can_track_camera_target = FALSE
	/// Полное имя цели, заданное самим ИИ.
	var/camera_memory_target
	/// Секунды с предыдущего поиска цели в поле зрения камер.
	var/camera_memory_elapsed_seconds = 0
	/// Цель, которую выбрала программа памяти камер, без захвата ручного отслеживания.
	var/datum/weakref/camera_memory_tracked_ref

GAME_VERB_DESC(/mob/living/silicon/ai, choose_camera_target, "Цель наблюдения камер", "Отслеживать появление человека в поле зрения камер.", "AI Commands")
	if(incapacitated || !can_track_camera_target)
		return
	var/target_name = tgui_input_text(src, "Полное имя; оставьте пустым, чтобы снять отслеживание:", "Память камер", camera_memory_target, MAX_NAME_LEN)
	if(incapacitated || !can_track_camera_target || isnull(target_name))
		return
	set_camera_memory_target(target_name)

/** Меняет цель программы и снимает её прежнее отслеживание. */
/mob/living/silicon/ai/proc/set_camera_memory_target(target_name)
	clear_camera_memory_track()
	camera_memory_target = trim(target_name)
	camera_memory_elapsed_seconds = 0

/** Снимает только отслеживание, начатое программой памяти камер. */
/mob/living/silicon/ai/proc/clear_camera_memory_track()
	var/mob/living/previous_target = camera_memory_tracked_ref?.resolve()
	if(previous_target && ai_tracking_tool?.tracked_mob == previous_target)
		ai_tracking_tool.reset_tracking()
	camera_memory_tracked_ref = null

/** Раз в три секунды ищет видимую камерам цель по имени, не раскрывая недоступных персонажей. */
/mob/living/silicon/ai/proc/process_camera_memory(seconds_per_tick)
	if(!can_track_camera_target || !length(camera_memory_target) || control_disabled)
		return
	camera_memory_elapsed_seconds += seconds_per_tick
	if(camera_memory_elapsed_seconds < 3)
		return
	camera_memory_elapsed_seconds = 0
	if(ai_tracking_tool.tracked_mob?.name == camera_memory_target)
		return
	for(var/mob/living/target as anything in GLOB.alive_mob_list)
		if(target.name == camera_memory_target && target.can_track(src))
			ai_tracking_tool.track_mob(src, target)
			if(ai_tracking_tool.tracked_mob == target)
				camera_memory_tracked_ref = WEAKREF(target)
			return
