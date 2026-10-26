/// Cache the cropped HUD payload per outfit; UI refreshes do not recreate or encode it.
/datum/job/proc/get_job_variant_icon_base64(variant_id)
	var/static/list/icons = list()
	var/datum/job_variant/variant = resolve_job_variant(variant_id)
	var/datum/outfit/job/outfit_path = variant?.outfit_type
	var/cache_key = outfit_path || type
	if(icons[cache_key])
		return icons[cache_key]
	var/datum/id_trim/trim_path = outfit_path ? initial(outfit_path.id_trim) : null
	var/icon/glyph
	if(trim_path && initial(trim_path.sechud_icon) && initial(trim_path.sechud_icon_state))
		glyph = icon(initial(trim_path.sechud_icon), initial(trim_path.sechud_icon_state))
		glyph.Crop(1, 17, 8, 24)
	else
		glyph = get_job_hud_icon(src)
	icons[cache_key] = icon2base64(glyph)
	return icons[cache_key]
