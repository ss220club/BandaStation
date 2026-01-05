var/base_url = CONFIG_GET(string/ai_secretary_url)
if(!base_url) return
var/global/datum/ai_bridge/global_ai_bridge

/proc/get_ai_bridge()
	if(!global_ai_bridge)
		global_ai_bridge = new /datum/ai_bridge()
	return global_ai_bridge

/datum/ai_bridge
	var/list/pending_faxes = list()
	var/fax_uid_counter = 0

// --- 1. ВХОДЯЩИЙ ФАКС ---

/datum/ai_bridge/proc/process_incoming_fax(title, content, sender_name, sender_id)
	set waitfor = FALSE
	if(!content) content = "(Empty Page)"

	fax_uid_counter++
	var/fid = "[fax_uid_counter]"

	var/list/fax_data = list(
		"sender" = sender_name,
		"title" = title,
		"content" = content,
		"sender_id" = sender_id
	)
	pending_faxes[fid] = fax_data

    addtimer(CALLBACK(src, .proc/cleanup_fax_data, fid), 30 MINUTES)

	send_request_sshttp("/fax/analyze", fax_data, CALLBACK(src, .proc/on_analyze_complete, fid, fax_data))

/datum/ai_bridge/proc/on_analyze_complete(fid, list/fax_data, list/response_data)
	if(!response_data) return
	notify_admins(fid, fax_data, response_data)

/datum/ai_bridge/proc/notify_admins(fid, list/fax_data, list/analysis)

    var/summary = get_json_value_case_insensitive(analysis, "summary")
    var/urgency = get_json_value_case_insensitive(analysis, "urgency")

	if(!summary) summary = "No summary generated."
	if(!urgency) urgency = "Unknown"

	var/color = "green"
	var/urg_lower = lowertext(urgency)
	if(findtext(urg_lower, "medium")) color = "#ff9900"
	if(findtext(urg_lower, "high")) color = "red"
	if(findtext(urg_lower, "critical")) color = "darkred"

	var/msg = "<span class='notice'><b>AI SECRETARY:</b> Fax from [fax_data["sender"]]</span><br>"
	msg += "<b>Summary:</b> [summary]<br>"
	msg += "<b>Urgency:</b> <font color='[color]'>[urgency]</font><br>"
	msg += "<b>AI Actions: </b>"
	msg += "<a href='?src=\ref[src];action=reply;mode=approve;fid=[fid]'>APPROVE</a> "
	msg += "<a href='?src=\ref[src];action=reply;mode=deny;fid=[fid]'>DENY</a> "
	msg += "<a href='?src=\ref[src];action=reply;mode=custom;fid=[fid]'>CUSTOM</a>"

	message_admins(msg)

// --- 2. ДЕЙСТВИЯ АДМИНА ---

/datum/ai_bridge/Topic(href, href_list)
	if(..()) return
	if(!check_rights(R_ADMIN)) return

	if(href_list["action"] == "reply")
		var/fid = href_list["fid"]
		var/mode = href_list["mode"]
		var/list/fax_data = pending_faxes[fid]

		if(!fax_data)
			to_chat(usr, "<span class='warning'>Error: Fax data expired.</span>")
			return

		var/custom_note = ""
		if(mode == "custom")
			custom_note = input(usr, "Enter instructions:", "AI") as text|null
			if(!custom_note) return

		to_chat(usr, "<span class='notice'>AI generating reply... (Wait 10-20s)</span>")
		start_generation(usr, fax_data, mode, custom_note)

/datum/ai_bridge/proc/start_generation(mob/user, list/fax_data, mode, custom_note)
	var/list/request_data = list(
		"original_fax" = list(
			"sender" = fax_data["sender"],
			"title" = fax_data["title"],
			"content" = fax_data["content"]
		),
		"action" = mode,
		"custom_note" = custom_note
	)

	send_request_sshttp("/fax/reply", request_data, CALLBACK(src, .proc/on_generation_complete, user, fax_data))

/datum/ai_bridge/proc/on_generation_complete(mob/user, list/fax_data, list/response_data)
	if(!response_data) return
	if(!user || !user.client) return

	var/draft_text = get_json_value_case_insensitive(response_data, "draft")

	if(!draft_text)
		to_chat(user, "<span class='danger'>AI Error: Empty draft received.</span>")
		return

	// --- ИНТЕРФЕЙС ФАКСА ---
	var/datum/fax_panel_interface/ui = new /datum/fax_panel_interface(user)

	var/plain_text = replacetext(draft_text, "<br>", "\n")
	ui.prefill_sender = "Central Command"
	ui.prefill_paper_name = "Reply to [fax_data["sender"]]"
	ui.prefill_text = plain_text

	ui.sending_fax_name = "Central Command"
	ui.default_paper_name = "Reply to [fax_data["sender"]]"
	var/obj/item/paper/P = ui.fax_paper
    P.name = ui.default_paper_name
    
    var/html_text = replacetext(draft_text, "\n", "<br>")
    
    P.info = html_text
    P.update_icon() 

	ui.ui_interact(user)
	to_chat(user, "<span class='adminnotice'>AI Draft Generated!</span>")


// --- 3. ОТПРАВКА ЧЕРЕЗ SSHTTP (МАГИЯ ТУТ) ---

/datum/ai_bridge/proc/send_request_sshttp(endpoint, list/data, datum/callback/cb)
	var/url = "[base_url][endpoint]"
	var/json_payload = json_encode(data)

	// SShttp принимает список заголовков
	var/list/headers = list("Content-Type" = "application/json")

	// Мы создаем обертку (wrapper), которая сначала проверит ошибки HTTP,
	// распакует JSON, и только потом вызовет твой cb
	var/datum/callback/wrapper = CALLBACK(src, .proc/handle_sshttp_response, cb)

	// Вызываем встроенную подсистему
	SShttp.create_async_request("POST", url, json_payload, headers, wrapper)


// Обработчик ответа от SShttp
// SShttp всегда передает datum/http_response первым аргументом при вызове коллбека
/datum/ai_bridge/proc/handle_sshttp_response(datum/callback/original_cb, datum/http_response/res)

	// 1. Проверка на ошибки сети
	if(res.errored)
		message_admins("<span class='danger'>AI Bridge Connection Error: [res.error]</span>")
		return

	// 2. Проверка статуса (например, 500 или 404)
	if(res.status_code != 200)
		message_admins("<span class='danger'>AI Bridge HTTP Error [res.status_code]: [res.body]</span>")
		return

	// 3. Декодирование JSON
	// SShttp уже достал тело ответа из Rust конверта и положил в res.body
	var/list/decoded_data = null
	try
		decoded_data = json_decode(res.body)
	catch(var/exception/e)
		message_admins("<span class='danger'>AI Bridge JSON Parse Error: [e] | Data: [copytext(res.body, 1, 50)]...</span>")
		return

	// 4. Вызов целевого коллбека с готовыми данными
	original_cb.Invoke(decoded_data)

//Cleanup procedure
/datum/ai_bridge/proc/cleanup_fax_data(fid)
    if(pending_faxes[fid])
        pending_faxes -= fid

/datum/ai_bridge/proc/get_json_value_case_insensitive(list/L, key)
    if(key in L) return L[key]
    
    // Если точного совпадения нет, ищем перебором (медленнее, но надежно)
    // Либо просто проверяем с большой буквы, как самое частое поведение Go
    var/cap_key = capitalize(key)
    if(cap_key in L) return L[cap_key]
    
    return null