/obj/structure/closet/supplypod/teleporter
	style = /datum/pod_style/teleport
	bluespace = TRUE
	explosionSize = list(0,0,0,0)
	fallingSound = null
	landingSound = /datum/sound_effect/portal_created
	openingSound = /datum/sound_effect/portal_enter
	leavingSound = /datum/sound_effect/portal_close
	pod_flags = FIRST_SOUNDS

/obj/structure/closet/supplypod/teleporter/set_style(chosenStyle)
	. = ..()
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"

/obj/effect/pod_landingzone/setup_smoke(rotation)
	if(pod.style == /datum/pod_style/teleport)
		return
	. = ..()

/obj/effect/pod_landingzone/draw_smoke()
	if(pod.style == /datum/pod_style/teleport)
		return
	. = ..()

/obj/effect/pod_landingzone/end_launch()
	if(pod.style == /datum/pod_style/teleport)
		pod.pixel_x = 0
		pod.pixel_z = 0
		pod.transform = matrix()
	. = ..()

/obj/structure/closet/supplypod/teleporter/syndicate/set_style(chosenStyle)
	. = ..()
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal1"
