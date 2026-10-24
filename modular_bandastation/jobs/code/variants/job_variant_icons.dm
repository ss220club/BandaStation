/// Use the outfit's actual ID trim, including variants with their own HUD glyph.
/datum/job/proc/get_job_variant_icon(variant_id)
	var/datum/job_variant/variant = resolve_job_variant(variant_id)
	if(!variant)
		return get_job_hud_icon(src)
	var/datum/outfit/job/outfit_path = variant.outfit_type
	var/datum/id_trim/trim_path = initial(outfit_path.id_trim)
	var/icon/glyph = icon(initial(trim_path.sechud_icon), initial(trim_path.sechud_icon_state))
	glyph.Crop(1, 17, 8, 24)
	return glyph
