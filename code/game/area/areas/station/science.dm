/area/station/science
	name = "Science Division"
	icon_state = "science"
	airlock_wires = /datum/wires/airlock/science
	sound_environment = SOUND_AREA_STANDARD_STATION
	tacmap_color = TACMAP_AREA_SCIENCE

/area/station/science/lobby
	name = "Science Lobby"
	icon_state = "science_lobby"

/area/station/science/lower
	name = "Lower Science Division"
	icon_state = "lower_science"

/area/station/science/breakroom
	name = "Science Break Room"
	icon_state = "science_breakroom"

/area/station/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/station/science/xenobiology
	name = "Xenobiology Lab"
	icon_state = "xenobio"

/area/station/science/xenobiology/hallway
	name = "Xenobiology Hallway"
	icon_state = "xenobio_hall"

/area/station/science/cytology
	name = "Cytology Lab"
	icon_state = "cytology"

/area/station/science/cubicle
	name = "Science Cubicles"
	icon_state = "science"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/science/genetics
	name = "Genetics Lab"
	icon_state = "geneticssci"

/area/station/science/server
	name = "Research Division Server Room"
	icon_state = "server"

/area/station/science/circuits
	name = "Circuit Lab"
	icon_state = "cir_lab"

/area/station/science/explab
	name = "Experimentation Lab"
	icon_state = "exp_lab"

/area/station/science/auxlab
	name = "Auxiliary Lab"
	icon_state = "aux_lab"

/area/station/science/auxlab/firing_range
	name = "Research Firing Range"

/area/station/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/station/science/robotics/mechbay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/station/science/robotics/lab
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/station/science/robotics/storage
	name = "Robotics Storage"
	icon_state = "ass_line"

/area/station/science/robotics/augments
	name = "Augmentation Theater"
	icon_state = "robotics"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/station/science/research
	name = "Research Division"
	icon_state = "science"

/area/station/science/research/abandoned
	name = "Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/science/zoo
	name = "Science Public Zoo"
	icon_state = "cytology"

/*
* Ordnance Areas
*/

// Use this for the main lab. If test equipment, storage, etc is also present use this one too.
/area/station/science/ordnance
	name = "Ordnance Lab"
	icon_state = "ord_main"

/area/station/science/ordnance/office
	name = "Ordnance Office"
	icon_state = "ord_office"

/area/station/science/ordnance/storage
	name = "Ordnance Storage"
	icon_state = "ord_storage"

/area/station/science/ordnance/burnchamber
	name = "Ordnance Burn Chamber"
	icon_state = "ord_burn"
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED

/area/station/science/ordnance/freezerchamber
	name = "Ordnance Freezer Chamber"
	icon_state = "ord_freeze"
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED

// Room for equipments and such
/area/station/science/ordnance/testlab
	name = "Ordnance Testing Lab"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED

/area/station/science/ordnance/bomb
	name = "Ordnance Bomb Site"
	icon_state = "ord_boom"
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED | NO_GRAVITY
	skip_minimap_rendering = TRUE

/area/station/science/ordnance/bomb/planet
	area_flags = /area/station/science/ordnance/bomb::area_flags & ~NO_GRAVITY
