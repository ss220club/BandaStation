/// Rebuild the food image after its icon is changed by a HUD user.
/atom/movable/screen/hunger/proc/update_food_icon()
	underlays -= food_image
	food_image.icon = food_icon
	underlays += food_image

/atom/movable/screen/hunger/proc/set_food_icon(icon_file)
	food_icon = icon_file
	update_food_icon()

/atom/movable/screen/hunger/proc/reset_food_icon()
	set_food_icon(initial(food_icon))
