/// Returns the lowest visible pixel row of the item's base sprite.
/// Transparent padding below the sprite is deliberately excluded.
/// The result is an offset from the item's normal turf origin, where 0 is the bottom row.
/obj/item/proc/get_lowest_visible_pixel()
	if(!icon)
		return 0

	var/icon_state_to_use = icon_state
	// Dropped item sprites are evaluated in the same SOUTH orientation used by
	// the project's existing item-icon helpers. Do not mutate the item's dir.
	var/item_dir = SOUTH
	var/item_frame = 1
	var/datum/universal_icon/universal_item_icon

	if(istype(icon, /datum/universal_icon))
		// Batched spritesheet icons are datums, not /icon objects. Keep their
		// selected values for the cache key and convert them only on a cache miss.
		universal_item_icon = icon
		icon_state_to_use = universal_item_icon.icon_state
		item_dir = universal_item_icon.dir || item_dir
		item_frame = universal_item_icon.frame || item_frame

	// Compiled DMI files are stable values, while runtime-generated icons and
	// universal icons need identity-based keys. Include the selected state,
	// direction and frame so different sprites do not share a result.
	var/icon_key = (istype(icon, /icon) || istype(icon, /datum/universal_icon)) ? REF(icon) : "[icon]"
	var/cache_key = "[icon_key]:[icon_state_to_use]:[item_dir]:[item_frame]"
	var/static/list/lowest_visible_pixel_cache = list()
	var/cached_lowest_pixel = lowest_visible_pixel_cache[cache_key]
	if(!isnull(cached_lowest_pixel))
		return cached_lowest_pixel

	var/icon/item_icon
	if(universal_item_icon)
		item_icon = universal_item_icon.to_icon()
	else
		// Extract one concrete state/direction/frame first. GetPixel() can then
		// read the resulting one-state icon directly.
		item_icon = new(icon, icon_state_to_use, item_dir, item_frame)

	if(!item_icon)
		return 0

	var/icon_width = item_icon.Width()
	var/icon_height = item_icon.Height()
	var/center_x = clamp(round(icon_width * 0.5), 1, icon_width)

	// GetPixel() uses (1, 1) as the lower-left pixel. Inspect only the horizontal
	// center and iterate upwards so the first matching pixel is the lowest visible
	// point used for shelf placement.
	for(var/pixel_y in 0 to icon_height - 1)
		var/pixel = item_icon.GetPixel(center_x, pixel_y + 1)
		if(!pixel)
			continue
		// GetPixel() normally returns RGB for visible pixels and RGBA for
		// pixels with an explicit alpha channel. Ignore fully transparent ones.
		if(length(pixel) >= 9 && copytext(pixel, 8, 10) == "00")
			continue
		lowest_visible_pixel_cache[cache_key] = pixel_y
		return pixel_y

	lowest_visible_pixel_cache[cache_key] = 0
	return 0
