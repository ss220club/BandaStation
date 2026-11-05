// shortcut: 32px hair with offsets <= 8px; expand the canvas when larger accessories are introduced.
#define HAIR_PAINT_SIZE 48
#define HAIR_PAINT_MARGIN 8
#define HAIR_PAINT_PIXEL_LENGTH 6
#define HAIR_PAINT_EMPTY "------"

/// Four canonical BYOND directions, encoded as JSON object keys.
/proc/hair_paint_directions()
	return list("2", "8", "1", "4")

/proc/hair_paint_copy_features(list/source, list/target)
	target["hair_paint"] = source["hair_paint"]
	target["facial_hair_paint"] = source["facial_hair_paint"]

/// RGB-only edits in top-first row order; ------ keeps the native pixel unchanged.
/proc/hair_paint_empty_frame()
	return repeat_string(HAIR_PAINT_SIZE * HAIR_PAINT_SIZE, HAIR_PAINT_EMPTY)

/// Validate the complete bounded payload before any indexing or mutation.
/proc/hair_paint_frames_valid(list/frames)
	if(!islist(frames) || length(frames) != 4)
		return FALSE
	var/static/regex/frame_pattern = regex(@"^([0-9a-fA-F]{6}|------){2304}$")
	for(var/direction in hair_paint_directions())
		var/frame = frames[direction]
		if(!istext(frame) || length(frame) != HAIR_PAINT_SIZE * HAIR_PAINT_SIZE * HAIR_PAINT_PIXEL_LENGTH || !frame_pattern.Find(frame))
			return FALSE
	return TRUE

/// Read a canvas pixel using BYOND's bottom-first icon coordinates.
/proc/hair_paint_pixel(frame, pixel_x, pixel_y)
	var/offset = ((HAIR_PAINT_SIZE - pixel_y) * HAIR_PAINT_SIZE + pixel_x - 1) * HAIR_PAINT_PIXEL_LENGTH + 1
	return copytext(frame, offset, offset + HAIR_PAINT_PIXEL_LENGTH)

/// Expand mask-only transport pixels using the server silhouette, never client-supplied coordinates.
/proc/hair_paint_unpack_frames(list/packed, list/masks)
	if(!islist(packed) || length(packed) != 4)
		return null
	var/list/frames = list()
	for(var/direction in hair_paint_directions())
		var/frame = packed[direction]
		var/list/mask = masks[direction]
		if(!istext(frame) || length(frame) > HAIR_PAINT_SIZE * HAIR_PAINT_SIZE * HAIR_PAINT_PIXEL_LENGTH || length(frame) % HAIR_PAINT_PIXEL_LENGTH || !islist(mask) || length(mask) != HAIR_PAINT_SIZE)
			return null
		var/list/pixels = list()
		var/offset = 1
		for(var/list/row as anything in mask)
			if(!islist(row) || length(row) != HAIR_PAINT_SIZE)
				return null
			for(var/pixel in row)
				if(!pixel || copytext(pixel, 8) == "00")
					pixels += HAIR_PAINT_EMPTY
					continue
				if(offset + HAIR_PAINT_PIXEL_LENGTH - 1 > length(frame))
					return null
				pixels += copytext(frame, offset, offset + HAIR_PAINT_PIXEL_LENGTH)
				offset += HAIR_PAINT_PIXEL_LENGTH
		if(offset != length(frame) + 1)
			return null
		frames[direction] = pixels.Join()
	return hair_paint_frames_valid(frames) ? frames : null

/// Reject the entire submission if even one edit falls outside its server-generated silhouette.
/proc/hair_paint_within_mask(list/frames, list/masks)
	if(!hair_paint_frames_valid(frames))
		return FALSE
	for(var/direction in hair_paint_directions())
		var/list/mask = masks[direction]
		if(!islist(mask) || length(mask) != HAIR_PAINT_SIZE)
			return FALSE
		for(var/row_index in 1 to HAIR_PAINT_SIZE)
			var/list/row = mask[row_index]
			if(!islist(row) || length(row) != HAIR_PAINT_SIZE)
				return FALSE
			for(var/pixel_x in 1 to HAIR_PAINT_SIZE)
				if(hair_paint_pixel(frames[direction], pixel_x, HAIR_PAINT_SIZE - row_index + 1) == HAIR_PAINT_EMPTY)
					continue
				var/pixel = row[pixel_x]
				if(!pixel || copytext(pixel, 8) == "00")
					return FALSE
	return TRUE

/// Convert the padded canvas into top-first frontend colour rows, preserving alpha.
/proc/hair_paint_icon_rows(icon/source)
	var/list/rows = list()
	for(var/pixel_y in HAIR_PAINT_SIZE to 1 step -1)
		var/list/row = list()
		for(var/pixel_x in 1 to HAIR_PAINT_SIZE)
			row += source.GetPixel(pixel_x, pixel_y) || "#00000000"
		rows += list(row)
	return rows

/// Put native appearances on a padded canvas without clipping offset hair above the body tile.
/proc/hair_paint_canvas(list/appearances)
	var/icon/blank = icon('icons/blanks/32x32.dmi', "nothing")
	blank.Scale(HAIR_PAINT_SIZE, HAIR_PAINT_SIZE)
	var/image/canvas = image(blank, dir = SOUTH)
	for(var/appearance in appearances)
		var/image/shifted = image(appearance)
		if(!shifted.icon)
			shifted.icon = blank
			shifted.icon_state = ""
		shifted.pixel_x += HAIR_PAINT_MARGIN
		shifted.pixel_y += HAIR_PAINT_MARGIN
		canvas.overlays += shifted
	return canvas

/// Apply canvas RGB edits to an individual native layer without creating pixels or changing alpha.
/proc/hair_paint_recolor(icon/source, frame, offset_x = 0, offset_y = 0)
	var/icon/result = icon(source)
	// State-container icons from getFlatIcon(no_anim) have valid pixels but unreliable dimensions.
	for(var/pixel_y in 1 to HAIR_PAINT_SIZE)
		for(var/pixel_x in 1 to HAIR_PAINT_SIZE)
			var/mask_x = pixel_x + offset_x + HAIR_PAINT_MARGIN
			var/mask_y = pixel_y + offset_y + HAIR_PAINT_MARGIN
			if(mask_x < 1 || mask_x > HAIR_PAINT_SIZE || mask_y < 1 || mask_y > HAIR_PAINT_SIZE)
				continue
			var/color = hair_paint_pixel(frame, mask_x, mask_y)
			if(color == HAIR_PAINT_EMPTY)
				continue
			var/original = source.GetPixel(pixel_x, pixel_y)
			if(!original)
				continue
			var/alpha = length(original) == 9 ? copytext(original, 8, 10) : "ff"
			result.DrawBox("#[color][alpha]", pixel_x, pixel_y, pixel_x, pixel_y)
	return result

/// Slot-local pixel edits, associated with the original hairstyle and species.
/datum/preference/hair_paint
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "hair_paint"
	priority = PREFERENCE_PRORITY_LATE_BODY_TYPE
	can_randomize = FALSE
	/// Whether this preference belongs to facial hair rather than top hair.
	var/facial = FALSE

/// Independent facial-hair edits using the same canonical pixel format.
/datum/preference/hair_paint/facial
	savefile_key = "facial_hair_paint"
	facial = TRUE

/datum/preference/hair_paint/create_default_value()
	return list()

/datum/preference/hair_paint/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return null
	var/list/data = input
	if(!length(data))
		return list()
	var/list/styles = facial ? SSaccessories.facial_hairstyles_list : SSaccessories.hairstyles_list
	if(length(data) != 3 || !istext(data["style"]) || !styles[data["style"]] || !istext(data["species"]) || !hair_paint_frames_valid(data["frames"]))
		return null
	return list("style" = data["style"], "species" = data["species"], "frames" = data["frames"].Copy())

/datum/preference/hair_paint/is_valid(value, datum/preferences/preferences)
	return islist(value)

/datum/preference/hair_paint/is_accessible(datum/preferences/preferences)
	return FALSE

/datum/preference/hair_paint/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(length(value))
		var/list/paint = value
		paint = paint.Copy()
		paint["base_color"] = preferences.read_preference(facial ? /datum/preference/color/facial_hair_color : /datum/preference/color/hair_color)
		paint["gradient_style"] = preferences.read_preference(facial ? /datum/preference/choiced/facial_hair_gradient : /datum/preference/choiced/hair_gradient)
		paint["gradient_color"] = preferences.read_preference(facial ? /datum/preference/color/facial_hair_gradient : /datum/preference/color/hair_gradient)
		value = paint
	target.dna.features[savefile_key] = value
	if(facial)
		target.facial_hair_paint = value
	else
		target.hair_paint = value
	var/obj/item/bodypart/head/head = target.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(facial)
			head.facial_hair_paint = value
		else
			head.hair_paint = value

/obj/item/bodypart/head
	/// Canonical saved edits for the current appearance.
	var/list/hair_paint
	/// Independent canonical facial-hair edits.
	var/list/facial_hair_paint
	/// Separate top/facial caches containing source data, state and recoloured native icons.
	var/list/hair_paint_cache

/mob/living/carbon/human
	var/list/hair_paint
	var/list/facial_hair_paint

/mob/living/carbon/human/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	if(dna)
		hair_paint = dna.features["hair_paint"]
		facial_hair_paint = dna.features["facial_hair_paint"]
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.hair_paint = hair_paint
		head.facial_hair_paint = facial_hair_paint
	return ..()

/obj/item/bodypart/head/copy_appearance_from(mob/living/carbon/human/target, overwrite_eyes = FALSE)
	. = ..()
	hair_paint = target.hair_paint
	facial_hair_paint = target.facial_hair_paint

/obj/item/bodypart/head/try_attach_limb(mob/living/carbon/new_head_owner, special, lazy)
	. = ..()
	if(. && !special && !lazy && ishuman(new_head_owner))
		var/mob/living/carbon/human/human_owner = new_head_owner
		human_owner.hair_paint = hair_paint
		human_owner.facial_hair_paint = facial_hair_paint

/// Recolour native hair layers while retaining their visibility, layering and emissive blockers.
/obj/item/bodypart/head/proc/paint_hair_overlays(list/hair_overlays, facial = FALSE)
	var/list/paint = facial ? facial_hair_paint : hair_paint
	var/style = facial ? facial_hairstyle : hairstyle
	if(!length(paint) || paint["style"] != style || fixed_hair_color || override_hair_color)
		return hair_overlays
	if(owner && paint["species"] != "[owner.dna.species.type]")
		return hair_overlays
	var/color = facial ? facial_hair_color : hair_color
	var/gradient_key = facial ? GRADIENT_FACIAL_HAIR_KEY : GRADIENT_HAIR_KEY
	if(lowertext(paint["base_color"] || "") != lowertext(color))
		return hair_overlays
	var/gradient_style = get_hair_gradient_style(gradient_key)
	if(paint["gradient_style"] != gradient_style)
		return hair_overlays
	if(gradient_style != /datum/sprite_accessory/gradient/none::name && lowertext(paint["gradient_color"] || "") != lowertext(get_hair_gradient_color(gradient_key)))
		return hair_overlays
	var/alpha = facial ? facial_hair_alpha : hair_alpha
	var/cache_key = "[style]|[color]|[alpha]|[json_encode(gradient_styles)]|[json_encode(gradient_colors)]|[species_hair_mask]|[json_encode(owner?.hair_masks)]"
	LAZYINITLIST(hair_paint_cache)
	var/cache_slot = facial ? "facial" : "hair"
	var/list/cache = hair_paint_cache[cache_slot]
	if(!cache || cache["data"] != paint || cache["state"] != cache_key)
		cache = list("data" = paint, "state" = cache_key, "icons" = list())
		hair_paint_cache[cache_slot] = cache
	var/list/icons = cache["icons"]
	var/list/painted_overlays = list()
	for(var/overlay_index in 1 to length(hair_overlays))
		var/image/original = hair_overlays[overlay_index]
		if(original.plane != FLOAT_PLANE)
			painted_overlays += original
			continue
		var/key = "[overlay_index]|[original.dir]|[original.alpha]|[original.pixel_x]|[original.pixel_w]|[original.pixel_y]|[original.pixel_z]"
		var/icon/painted_icon = icons[key]
		if(!painted_icon)
			painted_icon = icon('icons/blanks/32x32.dmi', "nothing")
			var/image/flat_source = image(original)
			if(!flat_source.icon)
				var/icon/bounds = icon('icons/blanks/32x32.dmi', "nothing")
				bounds.Scale(HAIR_PAINT_SIZE, HAIR_PAINT_SIZE)
				flat_source.icon = bounds
				flat_source.icon_state = ""
			for(var/direction in hair_paint_directions())
				var/icon/frame = getFlatIcon(flat_source, defdir = text2num(direction), no_anim = TRUE)
				var/icon/painted_frame = hair_paint_recolor(frame, paint["frames"][direction], original.pixel_x + original.pixel_w, original.pixel_y + original.pixel_z)
				painted_icon.Insert(painted_frame, dir = text2num(direction))
			icons[key] = painted_icon
		var/image/painted = image(original)
		painted.icon = painted_icon
		painted.icon_state = ""
		painted.color = null
		painted.alpha = 255
		painted.overlays = null
		painted.underlays = null
		painted_overlays += painted
	return painted_overlays
