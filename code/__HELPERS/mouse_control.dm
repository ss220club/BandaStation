///Returns an angle in degrees relative to the position of the mouse and that of the client eye.
/proc/mouse_angle_from_client(client/client, params)
	if(!client)
		return
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, SCREEN_LOC))
		return
	var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
	var/x = (text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32)
	var/y = (text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32)
	var/list/screenview = getviewsize(client.view)
	var/screenviewX = screenview[1] * ICON_SIZE_X
	var/screenviewY = screenview[2] * ICON_SIZE_Y
	var/ox = round(screenviewX/2) - client.pixel_x //"origin" x
	var/oy = round(screenviewY/2) - client.pixel_y //"origin" y
	var/angle = SIMPLIFY_DEGREES(ATAN2(y - oy, x - ox))
	return angle

// BANDASTATION ADDITION START: FOV
// tries to get mouse pos and size from map, then mapwindow
/proc/_get_map_cursor_winget(client/client)
	if(!client || !client.mob)
		return null
	var/mouse_pos = winget(client, "mapwindow.map", "mouse-pos")
	var/size_str = winget(client, "mapwindow.map", "size")
	if(mouse_pos && size_str)
		return list(mouse_pos, size_str)
	mouse_pos = winget(client, "mapwindow", "mouse-pos")
	size_str = winget(client, "mapwindow", "size")
	if(mouse_pos && size_str)
		return list(mouse_pos, size_str)
	// when window is inactive it may still expose root mouse
	mouse_pos = winget(client, null, "mouse-pos")
	size_str = winget(client, "mapwindow", "size") || winget(client, "mapwindow.map", "size")
	if(mouse_pos && size_str)
		return list(mouse_pos, size_str)
	return null

// name kinda speeks for itself, returns angle in degrees from view center to map cursor using pixel pos
/proc/get_angle_from_map_cursor_pixels(client/client)
	if(!client?.mob?.loc)
		return null
	var/list/win = _get_map_cursor_winget(client)
	if(!win || length(win) < 2)
		return null
	var/mouse_pos = win[1]
	var/size_str = win[2]
	var/list/mp = splittext(mouse_pos, ",")
	if(length(mp) < 2)
		return null
	var/mousepos_x = text2num(mp[1])
	var/mousepos_y = text2num(mp[2])
	if(isnull(mousepos_x) || isnull(mousepos_y))
		return null
	var/list/sz = splittext(size_str, "x")
	if(length(sz) < 2)
		return null
	var/sizex = text2num(sz[1])
	var/sizey = text2num(sz[2])
	if(!sizex || !sizey)
		return null
	var/list/actual_view = getviewsize(client?.view || world.view)
	var/screen_width = actual_view[1] * ICON_SIZE_X
	var/screen_height = actual_view[2] * ICON_SIZE_Y
	var/size_ratio = sizex / sizey
	var/screen_ratio = screen_width / screen_height
	if(size_ratio < screen_ratio)
		var/effective_height = sizex / screen_ratio
		var/banner_height = (sizey - effective_height) / 2
		mousepos_y -= banner_height
		sizey -= (banner_height * 2)
	else if(size_ratio > screen_ratio)
		var/effective_width = sizey * screen_ratio
		var/banner_width = (sizex - effective_width) / 2
		mousepos_x -= banner_width
		sizex -= (banner_width * 2)
	mousepos_x = max(mousepos_x, 0)
	mousepos_y = max(mousepos_y, 0)
	var/x_ratio = sizex / screen_width
	var/y_ratio = sizey / screen_height
	mousepos_x /= x_ratio
	mousepos_y /= y_ratio
	var/center_x = screen_width / 2
	var/center_y = screen_height / 2
	var/dx = mousepos_x - center_x
	var/dy = center_y - mousepos_y
	if(!dx && !dy)
		return null
	return SIMPLIFY_DEGREES(ATAN2(dx, dy))
// BANDASTATION ADDITION END: FOV

//Wow, specific name!
/proc/mouse_absolute_datum_map_position_from_client(client/client)
	if(!isloc(client.mob.loc))
		return
	var/list/modifiers = params2list(client.mouseParams)
	var/atom/A = client.eye
	var/turf/T = get_turf(A)
	var/cx = T.x
	var/cy = T.y
	var/cz = T.z
	if(LAZYACCESS(modifiers, SCREEN_LOC))
		var/x = 0
		var/y = 0
		var/z = 0
		var/p_x = 0
		var/p_y = 0
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")
		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/sx = text2num(screen_loc_X[1])
		var/sy = text2num(screen_loc_Y[1])
		//Get the resolution of the client's current screen size.
		var/list/screenview = getviewsize(client.view)
		var/svx = screenview[1]
		var/svy = screenview[2]
		var/cox = round((svx - 1) / 2)
		var/coy = round((svy - 1) / 2)
		x = cx + (sx - 1 - cox)
		y = cy + (sy - 1 - coy)
		z = cz
		p_x = text2num(screen_loc_X[2])
		p_y = text2num(screen_loc_Y[2])
		return new /datum/position(x, y, z, p_x, p_y)
