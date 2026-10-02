///Автоматическое открывание шлюзов по настройке у ИИ

/mob/living/silicon/ai
	var/datum/ai_door_autoapprove/door_autoapprove

/mob/living/silicon/ai/Destroy()
	QDEL_NULL(door_autoapprove)
	return ..()

GAME_VERB_DESC(/mob/living/silicon/ai, door_autoapprove_verb, "Airlock Auto-Approve", "Настройка автоодобрения запросов на шлюзы (по имени).", "AI Commands")
	if(incapacitated())
		return

	if(!door_autoapprove)
		door_autoapprove = new(src)

	door_autoapprove.ui_interact(usr)


/datum/ai_door_autoapprove
	var/mob/living/silicon/ai/owner_ai
	var/enabled = FALSE
	var/list/names = list()

/datum/ai_door_autoapprove/New(mob/living/silicon/ai/new_owner)
	owner_ai = new_owner
	. = ..()

/datum/ai_door_autoapprove/Destroy(force = FALSE)
	if(owner_ai?.door_autoapprove == src)
		owner_ai.door_autoapprove = null
	owner_ai = null
	return ..()

/datum/ai_door_autoapprove/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_door_autoapprove/ui_status(mob/user, datum/ui_state/state)
	if(!owner_ai || owner_ai.incapacitated())
		return UI_CLOSE

	if(user == owner_ai || (owner_ai.deployed_shell && user == owner_ai.deployed_shell))
		return UI_INTERACTIVE

	return UI_CLOSE

/datum/ai_door_autoapprove/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDoorAutoApprove")
		ui.open()

/datum/ai_door_autoapprove/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = enabled

	var/list/entries = list()
	for(var/key in names)
		entries += list(list(
			"key" = key,
			"name" = names[key],
		))
	data["names"] = entries
	return data

/datum/ai_door_autoapprove/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			enabled = !enabled
			return TRUE

		if("add")
			var/new_name = params["name"]
			if(!istext(new_name))
				return FALSE

			new_name = trim(new_name)
			if(!length(new_name))
				return FALSE

			var/key = LOWER_TEXT(new_name)
			key = copytext_char(key, 1, 64)
			new_name = copytext_char(new_name, 1, 64)

			names[key] = new_name
			return TRUE

		if("remove")
			var/key = params["key"]
			if(!istext(key))
				return FALSE
			if(names[key])
				names -= key
				return TRUE
			return FALSE

		if("clear")
			names.Cut()
			return TRUE

	return FALSE


/mob/living/silicon/ai/proc/_door_autoapprove_key(mob/living/requester)
	if(!requester)
		return null

	var/mob/living/viewer = deployed_shell ? deployed_shell : src

	var/display_name
	if(hascall(requester, "get_examine_name"))
		display_name = call(requester, "get_examine_name")(viewer)
	else
		display_name = requester.name

	if(!istext(display_name))
		return null

	return LOWER_TEXT(trim("[display_name]"))


/mob/living/silicon/ai/proc/is_requester_autoapproved(mob/living/requester)
	if(!door_autoapprove || !door_autoapprove.enabled)
		return FALSE
	var/key = _door_autoapprove_key(requester)
	if(!key)
		return FALSE
	return !!door_autoapprove.names[key]

/mob/living/silicon/ai/proc/_shell_has_camera_visibility(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return FALSE
	if(!SScameras.is_visible_by_cameras(target_turf))
		return FALSE

	for(var/obj/machinery/camera/camera in range(7, target))
		if(QDELETED(camera)) continue
		if(!camera.camera_enabled) continue
		if(camera.machine_stat & BROKEN) continue
		if(camera.emped) continue
		if(camera.wires && (camera.wires.is_cut(WIRE_CAMERA) || camera.wires.is_cut(WIRE_POWER)))
			continue
		return TRUE

	return FALSE

/mob/living/silicon/ai/proc/_can_observe_for_autoapprove(atom/target)
	if(!target)
		return FALSE

	if(istype(loc, /obj/item/aicard))
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return FALSE

	if(deployed_shell)
		var/turf/shell_turf = get_turf(deployed_shell)
		if(!shell_turf || !is_valid_z_level(shell_turf, target_turf))
			return FALSE

		if(get_dist(deployed_shell, target) <= 7)
			return TRUE

		return _shell_has_camera_visibility(target)

	// ИИ в ядре
	var/turf/ai_turf = get_turf(src)
	if(!ai_turf || !is_valid_z_level(ai_turf, target_turf))
		return FALSE

	return can_see(target)

/mob/living/silicon/ai/proc/try_autoapprove_open_door(mob/living/requester, obj/machinery/door/airlock/door)
	if(!istype(requester) || !istype(door))
		return FALSE

	if(stat == DEAD || control_disabled)
		return FALSE

	if(!is_requester_autoapproved(requester))
		return FALSE

	if(QDELETED(door))
		return FALSE
	if(door.hackProof)
		return FALSE
	if(!door.hasPower() || !door.canAIControl())
		return FALSE
	if(door.obj_flags & EMAGGED)
		return FALSE
	if(door.wires && door.wires.is_cut(WIRE_AI))
		return FALSE
	if(door.welded)
		return FALSE

	if(!_can_observe_for_autoapprove(requester))
		return FALSE
	if(!_can_observe_for_autoapprove(door))
		return FALSE

	if(door.locked)
		door.unbolt()
	door.open()

	log_silicon("auto-opened [door] for [key_name(requester)] via auto-approve at [AREACOORD(door)]")
	return TRUE
