/// Global singleton for AI bridge, initialized automatically
GLOBAL_DATUM_INIT(global_ai_bridge, /datum/ai_bridge, new)

/proc/get_ai_bridge()
	return GLOB.global_ai_bridge

/datum/ai_bridge
	var/list/pending_faxes = list()
	var/fax_uid_counter = 0

// --- 1. INCOMING FAX ---

/datum/ai_bridge/proc/process_incoming_fax(title, content, sender_name, sender_id)
	set waitfor = FALSE
	
	// Check config immediately
	if(!CONFIG_GET(string/ai_secretary_url))
		return

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

	// Cleanup timer after 30 minutes
	// LINT FIX: Use PROC_REF macro
	addtimer(CALLBACK(src, PROC_REF(cleanup_fax_data), fid), 30 MINUTES)

	// LINT FIX: Use PROC_REF macro
	send_request_sshttp("/fax/analyze", fax_data, CALLBACK(src, PROC_REF(on_analyze_complete), fid, fax_data))

/datum/ai_bridge/proc/on_analyze_complete(fid, list/fax_data, list/response_data)
	if(!response_data) return
	// If data was already cleaned up by timer, do not continue
	if(!pending_faxes[fid]) return

	notify_admins(fid, fax_data, response_data)

/datum/ai_bridge/proc/notify_admins(fid, list/fax_data, list/analysis)
	var/summary = get_json_value_case_insensitive(analysis, "summary")
	var/urgency = get_json_value_case_insensitive(analysis, "urgency")

	if(!summary) summary = "No summary generated."
	if(!urgency) urgency = "Unknown"

	var/color = "green"
	// LINT FIX: Use LOWER_TEXT macro
	var/urg_lower = LOWER_TEXT(urgency)
	
	if(findtext(urg_lower, "medium")) color = "#ff9900"
	if(findtext(urg_lower, "high")) color = "red"
	if(findtext(urg_lower, "critical")) color = "darkred"

	var/msg = "<span class='notice'><b>AI SECRETARY:</b> Fax from [fax_data["sender"]]</span><br>"
	msg += "<b>Summary:</b> [summary]<br>"
	msg += "<b>Urgency:</b> <font color='[color]'>[urgency]</font><br>"
	msg += "<b>AI Actions: </b>"
	// LINT FIX: Use REF() macro and byond:// prefix
	msg += "<a href='byond://?src=[REF(src)];action=reply;mode=approve;fid=[fid]'>APPROVE</a> "
	msg += "<a href='byond://?src=[REF(src)];action=reply;mode=deny;fid=[fid]'>DENY</a> "
	msg += "<a href='byond://?src=[REF(src)];action=reply;mode=custom;fid=[fid]'>CUSTOM</a>"

	message_admins(msg)

// --- 2. ADMIN ACTIONS ---

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

	// LINT FIX: Use PROC_REF macro
	send_request_sshttp("/fax/reply", request_data, CALLBACK(src, PROC_REF(on_generation_complete), user, fax_data))

/datum/ai_bridge/proc/on_generation_complete(mob/user, list/fax_data, list/response_data)
	if(!response_data) return
	if(!user || !user.client) return

	var/draft_text = get_json_value_case_insensitive(response_data, "draft")

	if(!draft_text)
		to_chat(user, "<span class='danger'>AI Error: Empty draft received.</span>")
		return

	// --- FAX INTERFACE ---
	var/datum/fax_panel_interface/ui = new /datum/fax_panel_interface(user)

	var/plain_text = replacetext(draft_text, "<br>", "\n")
	ui.prefill_sender = "Central Command"
	ui.prefill_paper_name = "Reply to [fax_data["sender"]]"
	ui.prefill_text = plain_text

	ui.sending_fax_name = "Central Command"
	ui.default_paper_name = "Reply to [fax_data["sender"]]"
	
	// Explicitly casting to paper
	var/obj/item/paper/P = ui.fax_paper
	P.name = ui.default_paper_name
	
	var/html_text = replacetext(draft_text, "\n", "<br>")
	
	// WORKAROUND: Compiler does not see 'info' variable on paper object in this codebase.
	// Using vars[] access as a fallback.
	if("info" in P.vars)
		P.vars["info"] = html_text
	
	P.update_icon() 

	ui.ui_interact(user)
	to_chat(user, "<span class='adminnotice'>AI Draft Generated!</span>")


// --- 3. SENDING VIA SSHTTP ---

/datum/ai_bridge/proc/send_request_sshttp(endpoint, list/data, datum/callback/cb)
	var/base_url = CONFIG_GET(string/ai_secretary_url)
	if(!base_url) return

	var/url = "[base_url][endpoint]"
	var/json_payload = json_encode(data)

	// SShttp accepts a list of headers
	var/list/headers = list("Content-Type" = "application/json")

	// LINT FIX: Use PROC_REF macro
	var/datum/callback/wrapper = CALLBACK(src, PROC_REF(handle_sshttp_response), cb)

	// Call the built-in subsystem
	SShttp.create_async_request("POST", url, json_payload, headers, wrapper)


// Response handler from SShttp
/datum/ai_bridge/proc/handle_sshttp_response(datum/callback/original_cb, datum/http_response/res)
	if(res.errored)
		message_admins("<span class='danger'>AI Bridge Connection Error: [res.error]</span>")
		return

	if(res.status_code != 200)
		message_admins("<span class='danger'>AI Bridge HTTP Error [res.status_code]: [res.body]</span>")
		return

	var/list/decoded_data = null
	try
		decoded_data = json_decode(res.body)
	catch(var/exception/e)
		message_admins("<span class='danger'>AI Bridge JSON Parse Error: [e] | Data: [copytext(res.body, 1, 50)]...</span>")
		return

	original_cb.Invoke(decoded_data)


// --- UTILITIES ---

// Memory cleanup
/datum/ai_bridge/proc/cleanup_fax_data(fid)
	if(pending_faxes[fid])
		pending_faxes -= fid

// Safe JSON lookup (case-insensitive)
/datum/ai_bridge/proc/get_json_value_case_insensitive(list/L, key)
	if(key in L) return L[key]
	
	// If no exact match, try capitalized key (Go often sends Capitalized keys)
	var/cap_key = capitalize(key)
	if(cap_key in L) return L[cap_key]
	
	return null

// --- CONFIG DEFINITION ---
/datum/config_entry/string/ai_secretary_url
	protection = CONFIG_ENTRY_LOCKED
