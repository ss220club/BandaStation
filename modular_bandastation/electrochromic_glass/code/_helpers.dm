/proc/generate_glass_matrix(atom/target, alpha = 1)
	var/base_color = target.color || WINDOW_COLOR
	if(!islist(base_color))
		base_color = color_hex2color_matrix(base_color)

	var/red = base_color[1]
	var/green = base_color[6]
	var/blue = base_color[11]
	return list(red,0,0,0, 0,green,0,0, 0,0,blue,0, 0,0,0,alpha, 0,0,0,0)
