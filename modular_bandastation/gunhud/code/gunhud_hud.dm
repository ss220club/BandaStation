/datum/hud
	var/atom/movable/screen/gunhud_screen

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	gunhud_screen = new /atom/movable/screen/gunhud_screen(null, src)
	infodisplay += gunhud_screen

/datum/hud/human/Destroy(force)
	if(gunhud_screen)
		qdel(gunhud_screen)
		gunhud_screen = null

	// remove from infodisplay list if needed
	if(infodisplay && islist(infodisplay))
		infodisplay -= gunhud_screen

	return ..(force)
