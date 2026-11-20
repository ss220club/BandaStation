#define FINES_PRO_ARTICLE_LIMIT 24
#define FINES_PRO_DETAILS_LIMIT (MAX_MESSAGE_LEN - 1)

/// PDA program for issuing a standard security citation and handing over a printed copy.
/datum/computer_file/program/fines_pro
	filename = "finespro"
	filedesc = "ШтрафыPRO+"
	downloader_category = PROGRAM_CATEGORY_SECURITY
	extended_desc = "Оформляет штрафы СБ и печатает уведомления."
	program_icon = "file-invoice-dollar"
	program_open_overlay = "id"
	tgui_id = "NtosFinesPro"
	size = 4
	can_run_on_flags = PROGRAM_PDA
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET | PROGRAM_UNIQUE_COPY
	download_access = list(ACCESS_SECURITY)
	run_access = list(ACCESS_SECURITY)

	/// Result of the most recent submission on this PDA.
	var/feedback
	/// Each submission consumes this number, so a repeated request cannot issue another fine.
	var/submission_number = 0
	/// Only the submitting viewer should clear their form when a request succeeds.
	var/last_submitter_ref

/// Issuing a citation always requires a physical ID, even on devices that bypass NTOS launch checks.
/datum/computer_file/program/fines_pro/proc/get_authorized_id()
	PRIVATE_PROC(TRUE)
	var/obj/item/card/id/officer_id = computer?.stored_id?.GetID()
	if(officer_id && (ACCESS_SECURITY in officer_id.GetAccess()))
		return officer_id
	return null

/datum/computer_file/program/fines_pro/ui_data(mob/user)
	var/authorized = !isnull(get_authorized_id())
	var/own_submission = authorized && last_submitter_ref == REF(user)
	var/list/records = list()
	if(authorized)
		for(var/datum/record/crew/record as anything in GLOB.manifest.general)
			records += list(list("ref" = REF(record), "name" = record.name, "rank" = record.rank))

	return list(
		"authorized" = authorized,
		"records" = records,
		"paper_count" = computer.stored_paper,
		"max_fine" = CONFIG_GET(number/maxfine),
		"article_limit" = FINES_PRO_ARTICLE_LIMIT,
		"details_limit" = FINES_PRO_DETAILS_LIMIT,
		"program_uid" = uid,
		"submission_number" = submission_number,
		"handled_submission" = own_submission ? submission_number - 1 : null,
		"feedback" = own_submission ? feedback : null,
	)

/datum/computer_file/program/fines_pro/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "issue_fine")
		return

	var/request_number = params["submission_number"]
	if(params["program_uid"] != uid || !isnum(request_number) || request_number != submission_number)
		return TRUE
	submission_number++
	last_submitter_ref = REF(ui.user)
	feedback = issue_fine(ui.user, params)
	return TRUE

/// Returns an error for the issuing viewer, or null once the notice and citation both exist.
/datum/computer_file/program/fines_pro/proc/issue_fine(mob/user, list/params)
	PRIVATE_PROC(TRUE)
	var/obj/item/card/id/officer_id = get_authorized_id()
	if(!officer_id)
		return "Вставьте в ПДА карту с доступом в службу безопасности."
	if(!computer.get_ntnet_status())
		return "Нет соединения с NTNet."

	var/datum/record/crew/target
	if(istext(params["record_ref"]))
		target = locate(params["record_ref"]) in GLOB.manifest.general
	if(!istype(target) || QDELETED(target) || !(target in GLOB.manifest.general))
		return "Запись сотрудника не найдена."

	var/amount = params["amount"]
	var/max_fine = CONFIG_GET(number/maxfine)
	if(!IS_FINITE(amount) || amount < 1 || amount > max_fine || amount != round(amount))
		return "Введите целую сумму от 1 до [max_fine]."

	var/article = istext(params["article"]) ? trim(params["article"]) : ""
	if(length_char(article) > FINES_PRO_ARTICLE_LIMIT)
		return "Номер статьи должен содержать не больше [FINES_PRO_ARTICLE_LIMIT] символов."
	if(!article)
		return "Укажите номер статьи."

	var/details = istext(params["details"]) ? trim(params["details"]) : ""
	if(length_char(details) > FINES_PRO_DETAILS_LIMIT)
		return "Детали должны содержать не больше [FINES_PRO_DETAILS_LIMIT] символов."
	if(!details)
		return "Укажите детали нарушения."

	// Citation text is also used as HTML in the warrant console's printout.
	article = html_encode(article)
	details = html_encode(details)
	var/reason = "Статья [article]"
	var/static/round_prefix = rand(10000, 99999)
	var/static/notices_issued = 0
	var/document_number = "[round_prefix]-[add_leading(notices_issued + 1, 3, "0")]"
	var/datum/paper_replacement/datetime/station_datetime = GLOB.paper_replacements["datetime"]
	var/issuer_signature = html_encode(trim(officer_id.registered_name || "") || "имя не зарегистрировано")
	if(officer_id.assignment)
		issuer_signature += " ([html_encode(job_title_ru(officer_id.assignment))])"
	var/notice = {"<center><h3>УВЕДОМЛЕНИЕ О ШТРАФЕ</h3></center>
		<hr>
		<b>Постановление:</b> № [document_number]<br>
		<b>Получатель:</b> [html_encode(target.name)]<br>
		<b>Статья и детали:</b> [article] - [replacetext(details, "\n", "<br>")]<br>
		<b>Сумма:</b> [amount][MONEY_SYMBOL]<br>
		<b>Уполномоченный сотрудник:</b> [issuer_signature]<br>
		<b>Дата и время:</b> [station_datetime.get_replacement(user)]
		<hr>
		<i>Для оплаты воспользуйтесь терминалом оплаты штрафов в отделе службы безопасности.</i>"}
	// PaperSheet expands bracketed form fields even after sanitization. Keep printed brackets literal.
	notice = replacetext(notice, html_encode("\["), "<span>\[</span>")
	if(!computer.print_text(notice, paper_type = /obj/item/paper/fine_notice, recipient = user))
		return "В принтере ПДА закончилась бумага."

	var/datum/crime/citation/citation = new(name = reason, details = details, author = user, fine = amount)
	target.citations += citation
	notices_issued++
	computer.investigate_log("New Citation: <strong>[reason]</strong> Fine: [amount] | Added to [target.name] by [key_name(user)]", INVESTIGATE_RECORDS)
	var/turf/print_location = get_turf(computer)
	if(print_location)
		playsound(print_location, 'sound/items/taperecorder/taperecorder_print.ogg', 40, FALSE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), print_location, 'sound/items/poster/poster_ripped.ogg', 30, FALSE), 0.8 SECONDS)
	// Telecomms delivery and SQL can yield. A later request must not receive this submission's result.
	ASYNC
		citation.alert_owner(user, computer, target.name, "Вам выписан штраф на [amount][MONEY_SYMBOL] по статье [article]. Оплата в отделе службы безопасности.")
	ASYNC
		SSblackbox.ReportCitation(REF(citation), user.ckey, user.real_name, target.name, reason, citation.details, amount)
	return null

#undef FINES_PRO_ARTICLE_LIMIT
#undef FINES_PRO_DETAILS_LIMIT
