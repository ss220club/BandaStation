/** Проверяет право пользователя печатать аварийный код на этой консоли связи. */
/obj/machinery/computer/communications/proc/can_issue_ai_control_code(mob/user)
	return !syndicate && ishuman(user) && authenticated_as_silicon_or_captain(user) && has_communication()

/** Обновляет общий аварийный код и печатает его после проверки доступа и задержки. */
/obj/machinery/computer/communications/proc/issue_ai_control_code(mob/user)
	if(!can_issue_ai_control_code(user))
		return FALSE
	GLOB.ai_control_code = random_nukecode(6)
	new /obj/item/paper/ai_control_code(drop_location())
	user.log_message("issued a new AI control console emergency access code.", LOG_GAME)
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 30, FALSE)
	return TRUE
