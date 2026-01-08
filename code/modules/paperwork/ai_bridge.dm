#define URGENCY_COLOR_LOW "green"
#define URGENCY_COLOR_MEDIUM "#ff9900"
#define URGENCY_COLOR_HIGH "red"
#define URGENCY_COLOR_CRITICAL "darkred"

// Configuration for LLM
#define OLLAMA_MODEL "qwen3-vl:235b-instruct"
#define SYSTEM_PROMPT_ANALYZE "ROLE: Elite Nanotrasen Secretary.\n\
TASK: Analyze incoming fax.\n\
OUTPUT FORMAT: Return a valid JSON object with fields: 'summary' (string, Russian language, 1 sentence) and 'urgency' (string: Low, Medium, High, Critical).\n\
\n\
URGENCY LOGIC:\n\
1. SENDER: 'Assistant', 'Clown', 'Mime', 'Unknown' -> LOW (unless confirmed by Heads).\n\
2. CONTENT: 'Reptilians', 'Vampires' -> LOW (Paranoia). 'Nuke', 'Blob', 'Rev' -> HIGH (if from Command). 'Pizza', 'Jokes' -> LOW."

#define SYSTEM_PROMPT_REPLY_BASE "ROLE: Central Command Officer (Nanotrasen).\n\
SETTING: Central Command, flagship Трурль.\n\
TASK: Write a formal reply fax based on the Administrator's decision.\n\
LANGUAGE: Russian.\n\
TONE: Bureaucratic, Official, Corporate.\n\
OUTPUT FORMAT: Return a valid JSON object with field: 'draft' (string, use <br> for new lines).\n\
\n\
CRITICAL RULES:\n\
1. LENGTH: STRICTLY UNDER 150 WORDS. Be concise.\n\
2. NO META-GAMING: Never mention 'Administrator' or 'Server'. Refer to 'Central Command Directives'.\n\
3. FORMAT: No headers. Only: Reply body + Signature."

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

	addtimer(CALLBACK(src, PROC_REF(cleanup_fax_data), fid), 30 MINUTES)

	// --- PREPARE OLLAMA REQUEST ---
	var/user_prompt = "Sender: [sender_name]\nTitle: [title]\nContent:\n[content]"
	
	var/list/messages = list(
		list("role" = "system", "content" = SYSTEM_PROMPT_ANALYZE),
		list("role" = "user", "content" = user_prompt)
	)

	send_ollama_chat(messages, 0.1, CALLBACK(src, PROC_REF(on_analyze_complete), fid, fax_data))

/datum/ai_bridge/proc/on_analyze_complete(fid, list/fax_data, list/llm_response_json)
	if(!llm_response_json) return
	if(!pending_faxes[fid]) return

	notify_admins(fid, fax_data, llm_response_json)

/datum/ai_bridge/proc/notify_admins(fid, list/fax_data, list/analysis)
	var/summary = get_json_value_case_insensitive(analysis, "summary")
	var/urgency = get_json_value_case_insensitive(analysis, "urgency")

	if(!summary) summary = "No summary generated."
	if(!urgency) urgency = "Unknown"

	var/color = URGENCY_COLOR_LOW
	var/urg_lower = LOWER_TEXT(urgency)
	
	if(findtext(urg_lower, "medium")) 
		color = URGENCY_COLOR_MEDIUM
	else if(findtext(urg_lower, "high"))
		color = URGENCY_COLOR_HIGH
	else if(findtext(urg_lower, "critical"))
		color = URGENCY_COLOR_CRITICAL

	var/msg = "<span class='notice'><b>AI SECRETARY:</b> Fax from [fax_data["sender"]]</span><br>"
	msg += "<b>Summary:</b> [summary]<br>"
	msg += "<b>Urgency:</b> <font color='[color]'>[urgency]</font><br>"
	msg += "<b>AI Actions: </b>"

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
	
	var/instruction = ""
	switch(mode)
		if("approve")
			instruction = "DECISION: APPROVE. State that the request aligns with Nanotrasen Strategic Interests."
		if("deny")
			instruction = "DECISION: DENY. Invent a bureaucratic excuse (e.g., Missing Form 27B-6, Budget Freeze, Low Social Credit)."
		if("custom")
			instruction = "DECISION: The Central Command dictates: '[custom_note]'.\nTASK: Rewrite this order into professional, threatening corporate language. Keep it direct."
		else
			instruction = "DECISION: Acknowledge receipt."

	var/system_prompt_full = "[SYSTEM_PROMPT_REPLY_BASE]\n\nCOMMAND:\n[instruction]"
	
	var/user_content = "Original Fax from: [fax_data["sender"]]\nSubject: [fax_data["title"]]\nMessage: \"[fax_data["content"]]\"\n\nWrite the reply:"

	var/list/messages = list(
		list("role" = "system", "content" = system_prompt_full),
		list("role" = "user", "content" = user_content)
	)

	// Saving user and fax_data in CALLBACK for further usage
	send_ollama_chat(messages, 0.8, CALLBACK(src, PROC_REF(on_generation_complete), user, fax_data))

/datum/ai_bridge/proc/on_generation_complete(mob/user, list/fax_data, list/llm_response_json)
	if(!llm_response_json) return
	if(!user || !user.client) return

	var/draft_text = get_json_value_case_insensitive(llm_response_json, "draft")

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
	
	var/obj/item/paper/P = ui.fax_paper
	P.name = ui.default_paper_name
	
	var/html_text = replacetext(draft_text, "\n", "<br>")
	
	if("info" in P.vars)
		P.vars["info"] = html_text
	
	P.update_icon() 

	ui.ui_interact(user)
	to_chat(user, "<span class='adminnotice'>AI Draft Generated!</span>")


// --- 3. UNIVERSAL SENDING (DIRECT TO OLLAMA CHAT API) ---

/datum/ai_bridge/proc/send_ollama_chat(list/messages, temp, datum/callback/cb)
	var/base_url = CONFIG_GET(string/ai_secretary_url)
	var/auth_token = CONFIG_GET(string/ai_secretary_token) // Load token
	if(!base_url) return

	// We use /api/chat now
	var/url = "[base_url]/api/chat"
	
	var/list/payload = list(
		"model" = OLLAMA_MODEL,
		"messages" = messages,
		"stream" = FALSE,
		"format" = "json", // Force JSON output
		"options" = list(
			"temperature" = temp,
			"num_ctx" = 2048,
			"top_p" = 0.9
		)
	)
	var/json_payload = json_encode(payload)
	//DM interpret FALSE in json_encode proc as 0. Ollama spec says it should be boolean...
	json_payload = replacetext(json_payload, "\"stream\":0", "\"stream\":false")
	var/list/headers = list("Content-Type" = "application/json")

	// ADD TOKEN IF EXISTS
	if(auth_token)
		headers["Authorization"] = "Bearer [auth_token]"

	var/datum/callback/wrapper = CALLBACK(src, PROC_REF(handle_ollama_response), cb)
	// FIX: Use RUSTG_HTTP_METHOD_POST (lowercase "post")
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, url, json_payload, headers, wrapper)


// Handler: Unpacks Ollama JSON envelope
/datum/ai_bridge/proc/handle_ollama_response(datum/callback/original_cb, datum/http_response/res)
	if(res.errored)
		message_admins("<span class='danger'>AI Connection Error: [res.error]</span>")
		return

	if(res.status_code != 200)
		message_admins("<span class='danger'>AI HTTP Error [res.status_code]: [res.body]</span>")
		return

	// 1. Decode Ollama Envelope
	var/list/ollama_envelope = null
	try
		ollama_envelope = json_decode(res.body)
	catch(var/exception/e)
		message_admins("<span class='danger'>AI Error: Invalid JSON from Ollama. [e]</span>")
		return

	// 2. Extract content from "message": { "content": "..." }
	var/list/msg_struct = ollama_envelope["message"]
	if(!msg_struct)
		message_admins("<span class='danger'>AI Error: Missing message field.</span>")
		return
		
	var/inner_json_text = msg_struct["content"]
	if(!inner_json_text)
		message_admins("<span class='danger'>AI Error: Empty content field.</span>")
		return

	// 3. Decode the inner content (summary/urgency OR draft)
	var/list/final_data = null
	try
		final_data = json_decode(inner_json_text)
	catch(var/exception/e2)
		message_admins("<span class='danger'>AI Error: Generated text is not valid JSON. [e2]</span>")
		return

	original_cb.Invoke(final_data)


// --- UTILITIES ---

/datum/ai_bridge/proc/cleanup_fax_data(fid)
	if(pending_faxes[fid])
		pending_faxes -= fid

/datum/ai_bridge/proc/get_json_value_case_insensitive(list/L, key)
	if(key in L) return L[key]
	var/cap_key = capitalize(key)
	if(cap_key in L) return L[cap_key]
	return null

// --- CONFIG DEFINITION ---
/datum/config_entry/string/ai_secretary_url
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/ai_secretary_token
	protection = CONFIG_ENTRY_LOCKED

#undef URGENCY_COLOR_LOW
#undef URGENCY_COLOR_MEDIUM
#undef URGENCY_COLOR_HIGH
#undef URGENCY_COLOR_CRITICAL
#undef OLLAMA_MODEL
#undef SYSTEM_PROMPT_ANALYZE
#undef SYSTEM_PROMPT_REPLY_BASE
