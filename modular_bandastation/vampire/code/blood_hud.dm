#define ui_blood "WEST:6,CENTER-1:15"
#define FORMAT_VAMPIRE_BLOOD_HUD_MAPTEXT(value) MAPTEXT_SPESSFONT("<span style='color: #ce0202; text-align: center; line-height: 1.9;'>[value]</span>")

/atom/movable/screen/vampire_blood
	name = "usable blood"
	icon_state = "blood_display"
	screen_loc = ui_blood
	maptext_x = 1
	maptext_y = 8

/atom/movable/screen/vampire_blood/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_maptext()

/atom/movable/screen/vampire_blood/proc/update_maptext()
	var/datum/antagonist/vampire/vampire = hud?.mymob?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		maptext = null
		return
	maptext = FORMAT_VAMPIRE_BLOOD_HUD_MAPTEXT(vampire.bloodusable)

#undef FORMAT_VAMPIRE_BLOOD_HUD_MAPTEXT
#undef ui_blood
