/// Component which handles Field of View masking for clients. FoV attributes are at /mob/living

// BANDASTATION ADDITION START: FOV — globals for VV tune/debug of texture offsets (mirror of defines in code/__DEFINES/fov.dm)
GLOBAL_VAR_INIT(fov_mask_cardinal_south_x, FOV_MASK_CARDINAL_SOUTH_X)
GLOBAL_VAR_INIT(fov_mask_cardinal_south_y, FOV_MASK_CARDINAL_SOUTH_Y)
GLOBAL_VAR_INIT(fov_mask_cardinal_west_x, FOV_MASK_CARDINAL_WEST_X)
GLOBAL_VAR_INIT(fov_mask_cardinal_west_y, FOV_MASK_CARDINAL_WEST_Y)
GLOBAL_VAR_INIT(fov_mask_cardinal_north_x, FOV_MASK_CARDINAL_NORTH_X)
GLOBAL_VAR_INIT(fov_mask_cardinal_north_y, FOV_MASK_CARDINAL_NORTH_Y)
GLOBAL_VAR_INIT(fov_mask_cardinal_east_x, FOV_MASK_CARDINAL_EAST_X)
GLOBAL_VAR_INIT(fov_mask_cardinal_east_y, FOV_MASK_CARDINAL_EAST_Y)
// BANDASTATION ADDITION END: FOV

// BANDASTATION EDIT START: FOV
/datum/component/fov_handler
	/// Currently applied x size of the fov masks
	var/current_fov_x = BASE_FOV_MASK_X_DIMENSION
	/// Currently applied y size of the fov masks
	var/current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	/// Whether we are applying the masks now
	var/applied_mask = FALSE
	/// The angle of the mask we are applying
	var/fov_angle = FOV_145_DEGREES
	/// The blocker mask applied to a client's screen
	var/image/fov_blocker_720/blocker_mask
	// fullscreen cursor_catcher/combat used to track cursor turf and update mob dir
	var/atom/movable/screen/fullscreen/cursor_catcher/combat/combat_cursor_tracker
	var/cursor_follow_timer_id
	var/current_fov_mask_angle = 0
	var/target_fov_mask_angle = 0
	/// Client we registered for map RMB (MouseDown/MouseUp) to drive fov_free_look
	var/client/fov_client
// BANDASTATION EDIT END: FOV

/datum/component/fov_handler/Initialize(fov_type = FOV_180_DEGREES)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/mob_parent = parent
	var/client/parent_client = mob_parent.client
	if(!parent_client) //Love client volatility!!
		qdel(src) //no QDEL hint for components, and we dont want this to print a warning regarding bad component application
		return

	ADD_TRAIT(mob_parent, TRAIT_FOV_APPLIED, REF(src))

	blocker_mask = new /image/fov_blocker_720(loc = mob_parent)
	blocker_mask.alpha = 255
	set_fov_angle(fov_type)
	on_dir_change(mob_parent, mob_parent.dir, mob_parent.dir)
	update_fov_size()
	update_mask()
	// BANDASTATION ADDITION START: FOV
	if(mob_parent.combat_mode || mob_parent.fov_free_look)
		start_combat_cursor_follow()
	fov_client = parent_client
	RegisterSignal(fov_client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_client_mousedown))
	RegisterSignal(fov_client, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_client_mouseup))
	// BANDASTATION ADDITION END: FOV

/datum/component/fov_handler/Destroy()
	// BANDASTATION ADDITION START: FOV
	if(fov_client)
		UnregisterSignal(fov_client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP))
	// BANDASTATION ADDITION END: FOV
	stop_combat_cursor_follow()
	var/mob/living/mob_parent = parent
	REMOVE_TRAIT(mob_parent, TRAIT_FOV_APPLIED, REF(src))
	// BANDASTATION ADDITION START: FOV
	mob_parent.fov_view_direction_angle = null
	// BANDASTATION ADDITION END: FOV
	if(applied_mask)
		remove_mask()
	if(blocker_mask) // In a case of early deletion due to volatile client
		QDEL_NULL(blocker_mask)
	return ..()

/datum/component/fov_handler/proc/set_fov_angle(new_angle)
	fov_angle = new_angle
	// BANDASTATION ADDITION START: FOV
	var/state = "[fov_angle > 0 ? fov_angle : (360 + fov_angle)]"
	blocker_mask.icon_state = state
	// BANDASTATION ADDITION END: FOV

// texture offset per cardinal so cutout aligns with character (mask angles are 0 = S, 90 = W, 180 = N, 270 = E)
/datum/component/fov_handler/proc/get_fov_mask_texture_offset(angle_deg)
	var/angle = angle_deg
	while(angle < 0)
		angle += 360
	while(angle >= 360)
		angle -= 360

	var/south_x = GLOB.fov_mask_cardinal_south_x
	var/south_y = GLOB.fov_mask_cardinal_south_y
	var/west_x = GLOB.fov_mask_cardinal_west_x
	var/west_y = GLOB.fov_mask_cardinal_west_y
	var/north_x = GLOB.fov_mask_cardinal_north_x
	var/north_y = GLOB.fov_mask_cardinal_north_y
	var/east_x = GLOB.fov_mask_cardinal_east_x
	var/east_y = GLOB.fov_mask_cardinal_east_y
	var/ox
	var/oy
	if(angle < 90)
		var/t = angle / 90
		ox = south_x + (west_x - south_x) * t
		oy = south_y + (west_y - south_y) * t
	else if(angle < 180)
		var/t = (angle - 90) / 90
		ox = west_x + (north_x - west_x) * t
		oy = west_y + (north_y - west_y) * t
	else if(angle < 270)
		var/t = (angle - 180) / 90
		ox = north_x + (east_x - north_x) * t
		oy = north_y + (east_y - north_y) * t
	else
		var/t = (angle - 270) / 90
		ox = east_x + (south_x - east_x) * t
		oy = east_y + (south_y - east_y) * t
	return list(ox, oy)

/datum/component/fov_handler/proc/apply_fov_transform()
	var/state = "[fov_angle > 0 ? fov_angle : (360 + fov_angle)]"
	blocker_mask.icon_state = state
	var/matrix/base = matrix()
	var/x_scale = current_fov_x / BASE_FOV_MASK_X_DIMENSION
	var/y_scale = current_fov_y / BASE_FOV_MASK_Y_DIMENSION
	if(fov_angle < 0)
		x_scale *= -1
		y_scale *= -1
	var/list/dim = get_icon_dimensions(blocker_mask.icon)
	var/icon_center_x = dim ? (dim["width"] / 2) : (BASE_FOV_MASK_X_DIMENSION * (ICON_SIZE_X / 2))
	var/icon_center_y = dim ? (dim["height"] / 2) : (BASE_FOV_MASK_Y_DIMENSION * (ICON_SIZE_Y / 2))
	base.Scale(x_scale, y_scale * FOV_MASK_SCALE)
	base.Translate(-icon_center_x, -icon_center_y)
	var/dir_angle = dir2angle(blocker_mask.dir)
	if(!isnull(dir_angle))
		var/mask_angle = (dir_angle + 180) % 360
		var/list/texture_off = get_fov_mask_texture_offset(mask_angle)
		var/tex_off_x = texture_off[1]
		var/tex_off_y = texture_off[2]
		if(tex_off_x != 0 || tex_off_y != 0)
			base.Translate(tex_off_x, tex_off_y)
	blocker_mask.transform = base
	//animate(blocker_mask, transform = base, time = FOV_MASK_ANIMATE_TIME SECONDS, flags = ANIMATION_END_NOW)

/datum/component/fov_handler/proc/update_mask_attachment_position()
	blocker_mask.pixel_x = 0
	blocker_mask.pixel_y = 0

/// Updates the size of the FOV masks by comparing them to client view size.
/datum/component/fov_handler/proc/update_fov_size()
	SIGNAL_HANDLER
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	var/list/view_size = getviewsize(parent_client.view)
	if(view_size[1] == current_fov_x && view_size[2] == current_fov_y)
		return
	current_fov_x = BASE_FOV_MASK_X_DIMENSION
	current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	current_fov_x = view_size[1]
	current_fov_y = view_size[2]
	// BANDASTATION ADDITION START: FOV
	apply_fov_transform()
	// BANDASTATION ADDITION END: FOV

/// Updates the mask application to client by checking `stat` and `eye`
/datum/component/fov_handler/proc/update_mask()
	SIGNAL_HANDLER
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	var/user_living = parent_mob != DEAD
	var/atom/top_most_atom = get_atom_on_turf(parent_mob)
	var/user_extends_eye = parent_client.eye != top_most_atom
	var/should_apply_mask = user_living && !user_extends_eye

	if(should_apply_mask == applied_mask)
		return

	if(should_apply_mask)
		add_mask()
	else
		remove_mask()

/datum/component/fov_handler/proc/remove_mask()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(parent_client)
		parent_client.images -= blocker_mask
	applied_mask = FALSE

/datum/component/fov_handler/proc/add_mask()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	applied_mask = TRUE
	update_mask_attachment_position()
	blocker_mask.dir = parent_mob.dir
	parent_client.images += blocker_mask
	// sync immediately so FOV follows from first frame
	apply_fov_transform() // BANDASTATION ADDITION: FOV

// BANDASTATION ADDITION START: FOV
// when dir changes, masks follow (for now non-combat only combat uses cursor)
/datum/component/fov_handler/proc/on_dir_change(mob/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return
	var/mob/parent_mob = parent
	if(parent_mob?.client && combat_cursor_tracker)
		return
	var/dir_angle = dir2angle(new_dir)
	if(!isnull(dir_angle))
		current_fov_mask_angle = (dir_angle + 180) % 360
		target_fov_mask_angle = current_fov_mask_angle
	if(applied_mask)
		blocker_mask.dir = new_dir
		apply_fov_transform()
// BANDASTATION ADDITION END: FOV

// BANDASTATION ADDITION START: FOV
/datum/component/fov_handler/proc/on_combat_mode_toggled(mob/source)
	SIGNAL_HANDLER
	var/mob/living/mob_parent = parent
	if(mob_parent.combat_mode || mob_parent.fov_free_look)
		start_combat_cursor_follow()
	else
		stop_combat_cursor_follow()
		mob_parent.remove_movespeed_modifier(MOVESPEED_ID_WALKING_BACKWARDS)

/datum/component/fov_handler/proc/start_combat_cursor_follow()
	var/mob/living/mob_parent = parent
	if(!mob_parent.client || combat_cursor_tracker)
		return
	combat_cursor_tracker = mob_parent.overlay_fullscreen("combat_cursor", /atom/movable/screen/fullscreen/cursor_catcher/combat)
	combat_cursor_tracker.alpha = 0
	combat_cursor_tracker.assign_to_mob(mob_parent)
	var/update_ds = min(world.tick_lag, FOV_MASK_CURSOR_UPDATE_DS)
	cursor_follow_timer_id = addtimer(CALLBACK(src, PROC_REF(_process_cursor_tick)), update_ds, TIMER_LOOP | TIMER_STOPPABLE)

/datum/component/fov_handler/proc/_process_cursor_tick()
	var/update_ds = min(world.tick_lag, FOV_MASK_CURSOR_UPDATE_DS)
	process(update_ds / 10)

/datum/component/fov_handler/proc/stop_combat_cursor_follow()
	if(cursor_follow_timer_id)
		deltimer(cursor_follow_timer_id)
		cursor_follow_timer_id = null
	if(combat_cursor_tracker)
		var/mob/living/mob_parent = parent
		if(mob_parent?.client)
			mob_parent.clear_fullscreen("combat_cursor")
		combat_cursor_tracker = null
	if(!istype(parent, /mob/living))
		return
	var/mob/living/mob_parent = parent
	mob_parent.fov_view_direction_angle = null
	// sync mask to mob dir so it doesn't stay at last cursor angle
	var/dir_angle = dir2angle(mob_parent.dir)
	if(!isnull(dir_angle))
		current_fov_mask_angle = (dir_angle + 180) % 360
		target_fov_mask_angle = current_fov_mask_angle
	if(applied_mask)
		blocker_mask.dir = mob_parent.dir
		apply_fov_transform()

// lotta checks to do, but we should be fine
/datum/component/fov_handler/process(seconds_per_tick)
	if(QDELETED(src))
		return
	var/mob/living/mob_parent = parent
	var/want_cursor_follow = mob_parent?.client && combat_cursor_tracker && (mob_parent.combat_mode || mob_parent.fov_free_look)
	if(!want_cursor_follow)
		stop_combat_cursor_follow()
		if(istype(mob_parent))
			mob_parent.fov_view_direction_angle = null
		return
	// so we refetching client right before use so we don't use a destroyed client and get runtimes
	var/client/user_client = mob_parent.client
	if(!user_client || user_client.mob != mob_parent)
		stop_combat_cursor_follow()
		mob_parent.fov_view_direction_angle = null
		return
	combat_cursor_tracker.calculate_params()
	var/angle_deg = combat_cursor_tracker.given_angle
	if(isnull(angle_deg))
		angle_deg = get_angle_from_map_cursor_pixels(user_client)
	if(!isnull(angle_deg))
		// quantize to 45 deg
		var/discrete_angle = SIMPLIFY_DEGREES(round(angle_deg / 45) * 45)
		mob_parent.fov_view_direction_angle = discrete_angle
		if(mob_parent.combat_mode || mob_parent.fov_free_look)
			var/dir_angle = SIMPLIFY_DEGREES(90 - discrete_angle)
			mob_parent.setDir(angle2dir(dir_angle))
		if(applied_mask)
			blocker_mask.dir = mob_parent.dir
			apply_fov_transform()
	else
		mob_parent.fov_view_direction_angle = null
// BANDASTATION ADDITION END: FOV

/// When a mob logs out, delete the component
/datum/component/fov_handler/proc/mob_logout(mob/source)
	SIGNAL_HANDLER
	var/mob/living/L = parent
	if(istype(L))
		L.fov_free_look = FALSE
	qdel(src)

// BANDASTATION ADDITION START: FOV
/datum/component/fov_handler/proc/on_living_death(mob/source)
	SIGNAL_HANDLER
	update_mask()
	var/mob/living/L = parent
	if(istype(L))
		L.fov_free_look = FALSE
// BANDASTATION ADDITION END: FOV

// so to avoid duplicating trigger with the keybind - free look starts only when user bound free look to RMB and we have to check this every time, which is sucks, but that's gonna work for now @FIXME
/datum/component/fov_handler/proc/on_client_mousedown(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(control != "mapwindow.map")
		return
	var/list/p = params2list(params)
	if(LAZYACCESS(p, BUTTON) != RIGHT_CLICK)
		return
	var/client/C = source
	if(!istype(C))
		return
	var/list/keys_for_freelook = C.prefs?.key_bindings?["fov_free_look"]
	if(!length(keys_for_freelook) || !("Right" in keys_for_freelook))
		return
	var/mob/living/L = parent
	if(!istype(L) || L != C.mob)
		return
	L.fov_free_look = TRUE
	start_combat_cursor_follow()

// only relevant when free look was started via map RMB
/datum/component/fov_handler/proc/on_client_mouseup(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(control != "mapwindow.map")
		return
	var/list/p = params2list(params)
	if(LAZYACCESS(p, BUTTON) != RIGHT_CLICK)
		return
	var/client/C = source
	if(!istype(C))
		return
	var/list/keys_for_freelook = C.prefs?.key_bindings?["fov_free_look"]
	if(!length(keys_for_freelook) || !("Right" in keys_for_freelook))
		return
	var/mob/living/L = parent
	if(istype(L))
		L.fov_free_look = FALSE
// BANDASTATION ADDITION END: FOV

/datum/component/fov_handler/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_living_death)) // BANDASTATION ADDITION: FOV
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(update_mask))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_CHANGE_VIEW, PROC_REF(update_fov_size))
	RegisterSignal(parent, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(update_mask))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(mob_logout))
	// BANDASTATION ADDITION START: FOV
	RegisterSignal(parent, COMSIG_COMBAT_MODE_TOGGLED, PROC_REF(on_combat_mode_toggled))
	// BANDASTATION ADDITION END: FOV

/datum/component/fov_handler/UnregisterFromParent()
	. = ..()
	// BANDASTATION ADDITION START: FOV
	UnregisterSignal(parent, list(COMSIG_MOB_RESET_PERSPECTIVE, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_MOB_LOGOUT, COMSIG_COMBAT_MODE_TOGGLED))
	// BANDASTATION ADDITION END: FOV
