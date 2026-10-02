/// An antag HUD visible only to a vampire and the thralls bound to them.
/datum/atom_hud/alternate_appearance/basic/vampire_network
	var/datum/weakref/vampire_ref

/datum/atom_hud/alternate_appearance/basic/vampire_network/New(key, image/hud_image, datum/antagonist/vampire/vampire)
	vampire_ref = WEAKREF(vampire)
	return ..(key, hud_image, NONE)

/datum/atom_hud/alternate_appearance/basic/vampire_network/mobShouldSee(mob/viewer)
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	if(!vampire)
		return FALSE
	if(viewer.mind == vampire.owner)
		return TRUE
	var/datum/antagonist/vampire_thrall/thrall = viewer.mind?.has_antag_datum(/datum/antagonist/vampire_thrall)
	return thrall?.get_master() == vampire
