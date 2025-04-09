/datum/config_entry/string/ss_central_url
	default = ""
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/ss_central_token
	default = ""
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/server_type
	default = "default"

SUBSYSTEM_DEF(central)
	dependencies = list(
		/datum/controller/subsystem/http
	)
	flags = SS_NO_FIRE
	init_stage = INITSTAGE_FIRST
	var/list/discord_links = list()

/datum/controller/subsystem/central/vv_edit_var(var_name, var_value)
	return FALSE

/datum/controller/subsystem/central/CanProcCall(procname)
	return FALSE

/datum/controller/subsystem/central/Initialize()
	if(!can_run())
		return SS_INIT_NO_NEED

	load_whitelist()
	// TODO: preload links
	return SS_INIT_SUCCESS

/datum/controller/subsystem/central/proc/can_run()
	return CONFIG_GET(string/ss_central_url) && CONFIG_GET(string/ss_central_token)

/datum/controller/subsystem/central/stat_entry(msg)
	if(!initialized || !can_run())
		msg = "OFFLINE"
	else
		msg = "WL: [CONFIG_GET(flag/usewhitelist)] [CONFIG_GET(string/server_type)]"
	return ..()

/datum/controller/subsystem/central/Recover()
	discord_links = SScentral.discord_links.Copy()

/datum/controller/subsystem/central/proc/load_whitelist()
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/whitelists/ckeys?server_type=[CONFIG_GET(string/server_type)]&active_only=true&page=1&page_size=9999"

	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(load_whitelist_callback)))

/datum/controller/subsystem/central/proc/load_whitelist_callback(datum/http_response/response)
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to load whitelist: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	var/list/result = json_decode(response.body)

	log_game("Loading whitelist with [result["total"]] entries")

	var/list/ckeys = result["items"]

	if(!GLOB.whitelist)
		GLOB.whitelist = list()
	GLOB.whitelist |= ckeys

/datum/controller/subsystem/central/proc/get_player_discord_async(ckey)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/players/ckey/[ckey]"

	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(get_player_discord_callback), ckey))

/datum/controller/subsystem/central/proc/get_player_discord_callback(ckey, datum/http_response/response)
	if(response.errored || response.status_code != 200 && response.status_code != 404)
		stack_trace("Failed to get player discord: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	if(response.status_code == 404)
		return

	var/list/data = json_decode(response.body)
	var/discord_id = data["discord_id"]
	discord_links[ckey] = discord_id

	GLOB.persistent_clients_by_ckey[ckey].discord_id = discord_id

/datum/controller/subsystem/central/proc/is_player_discord_linked(ckey)
	var/datum/persistent_client/pclient = GLOB.persistent_clients_by_ckey[ckey]

	if(!pclient)
		return FALSE

	if(pclient.discord_id)
		return TRUE

	// Update the info just in case
	get_player_discord_async(ckey)

	return FALSE

/// WARNING: only semi async - UNTIL based
/datum/controller/subsystem/central/proc/is_player_whitelisted(ckey)
	if(ckey in GLOB.whitelist)
		return TRUE

	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/whitelists?server_type=[CONFIG_GET(string/server_type)]&ckey=[ckey]&page=1&page_size=1"
	var/datum/http_response/response = SShttp.make_sync_request(RUSTG_HTTP_METHOD_GET, endpoint, "", list())
	if(response.errored || response.status_code != 200 && response.status_code != 404)
		stack_trace("Failed to check whitelist: HTTP error - [response.error]")
	if(response.status_code == 404)
		return FALSE

	var/result = json_decode(response.body)

	return result["total"]

/datum/controller/subsystem/central/proc/add_to_whitelist(ckey, added_by, duration_days = 0)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/whitelists"

	var/list/headers = list()
	headers["Authorization"] = "Bearer [CONFIG_GET(string/ss_central_token)]"
	var/list/body = list()
	body["player_ckey"] = ckey
	body["admin_ckey"] = added_by
	body["server_type"] = CONFIG_GET(string/server_type)
	body["duration_days"] = duration_days

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, json_encode(body), headers, CALLBACK(src, PROC_REF(add_to_whitelist_callback), ckey))

/datum/controller/subsystem/central/proc/add_to_whitelist_callback(ckey, datum/http_response/response)
	if(response.errored)
		stack_trace("Failed to add to whitelist: HTTP error - [response.error]")

	switch(response.status_code)
		if(201)
			. = . // noop
		if(404)
			message_admins("Не удалось добавить в вайтлист: Игрок не найден")
			return

		if(409)
			message_admins("Не удалось добавить в вайтлист: Игрок выписан")
			return

		else
			stack_trace("Could not add to whitelist: HTTP status code [response.status_code] - [response.body]")
			return

	log_admin("Игрок [ckey] успешно добавлен в вайтлист")
	GLOB.whitelist |= ckey

/datum/controller/subsystem/central/proc/whitelist_ban_player(player_ckey, admin_ckey, duration_days, reason)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/whitelist_bans"

	var/list/headers = list()
	headers["Authorization"] = "Bearer [CONFIG_GET(string/ss_central_token)]"
	var/list/body = list()
	body["player_ckey"] = player_ckey
	body["admin_ckey"] = admin_ckey
	body["server_type"] = CONFIG_GET(string/server_type)
	body["duration_days"] = duration_days
	body["reason"] = reason

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, endpoint, json_encode(body), headers, CALLBACK(src, PROC_REF(whitelist_ban_player_callback), player_ckey))

/datum/controller/subsystem/central/proc/whitelist_ban_player_callback(ckey, datum/http_response/response)
	if(response.errored || response.status_code != 201)
		stack_trace("Failed to ban player from whitelist: HTTP status code [response.status_code] - [response.error] - [response.body]")
		message_admins("Не удалось выписать [ckey]. Больше информации в рантаймах.")
		return

	GLOB.whitelist -= ckey

/datum/controller/subsystem/central/proc/update_player_donate_tier_async(client/player)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/donates?ckey=[player.ckey]&active_only=true&page=1&page_size=1"
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, endpoint, "", list(), CALLBACK(src, PROC_REF(update_player_donate_tier_callback), player))

/datum/controller/subsystem/central/proc/update_player_donate_tier_callback(client/player, datum/http_response/response)
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to get player donate tier: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	var/list/data = json_decode(response.body)
	player.donator_level = max(player.donator_level, get_max_donation_tier_from_response_data(data))
	player.can_save_donator_level = TRUE

/datum/controller/subsystem/central/proc/update_player_donate_tier_blocking(client/player)
	var/endpoint = "[CONFIG_GET(string/ss_central_url)]/donates?ckey=[player.ckey]&active_only=true&page=1&page_size=1"
	var/datum/http_response/response = SShttp.make_sync_request(RUSTG_HTTP_METHOD_GET, endpoint, "", list())
	if(response.errored || response.status_code != 200)
		stack_trace("Failed to get player donate tier: HTTP status code [response.status_code] - [response.error] - [response.body]")
		return

	var/list/data = json_decode(response.body)
	player.donator_level = max(player.donator_level, get_max_donation_tier_from_response_data(data))
	player.can_save_donator_level = TRUE

/datum/controller/subsystem/central/proc/get_max_donation_tier_from_response_data(list/data)
	if(!length(data["items"]))
		return BASIC_DONATOR_LEVEL

	var/list/tiers = list()
	for(var/list/item in data["items"])
		tiers += item["tier"]

	return max(tiers)
