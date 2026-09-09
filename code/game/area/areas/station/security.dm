// When adding a new area to the security areas, make sure to add it to /datum/bounty/patrol as well!

/area/station/security
	name = "Security"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
	sound_environment = SOUND_AREA_STANDARD_STATION
	tacmap_color = TACMAP_AREA_SECURITY

/area/station/security/office
	name = "Security Office"
	icon_state = "security"

/area/station/security/breakroom
	name = "Security Break Room"
	icon_state = "brig"

/area/station/security/tram
	name = "Security Transfer Tram"
	icon_state = "security"

/area/station/security/lockers
	name = "Security Locker Room"
	icon_state = "securitylockerroom"

/area/station/security/brig
	name = "Brig"
	icon_state = "brig"

/area/station/security/holding_cell
	name = "Holding Cell"
	icon_state = "holding_cell"

/area/station/security/medical
	name = "Security Medical"
	icon_state = "security_medical"

/area/station/security/brig/upper
	name = "Brig Overlook"
	icon_state = "upperbrig"

/area/station/security/brig/lower
	name = "Lower Brig"
	icon_state = "lower_brig"

/area/station/security/brig/entrance
	name = "Brig Entrance"
	icon_state = "brigentry"

/area/station/security/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/security/courtroom/holding
	name = "Courtroom Prisoner Holding Room"

/area/station/security/processing
	name = "Labor Shuttle Dock"
	icon_state = "sec_labor_processing"

/area/station/security/processing/cremation
	name = "Security Crematorium"
	icon_state = "sec_cremation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/interrogation
	name = "Interrogation Room"
	icon_state = "interrogation"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/warden
	name = "Brig Control"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/evidence
	name = "Evidence Storage"
	icon_state = "evidence"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/security/armory
	name = "Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	motion_monitored = TRUE

/area/station/security/armory/upper
	name = "Upper Armory"

/area/station/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
		)

/area/station/security/detectives_office/private_investigators_office
	name = "Private Investigator's Office"
	icon_state = "investigate_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/station/security/eva
	name = "Security EVA"
	icon_state = "sec_eva"

/area/station/security/execution
	icon_state = "execution_room"

/area/station/security/execution/transfer
	name = "Transfer Centre"
	icon_state = "sec_processing"

/area/station/security/execution/education
	name = "Prisoner Education Chamber"

/area/station/security/mechbay
	name = "Security Mechbay"
	icon_state = "sec_mechbay"

/*
* Security Checkpoints
*/

/area/station/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/checkpoint/escape
	name = "Departures Security Checkpoint"
	icon_state = "checkpoint_esc"

/area/station/security/checkpoint/arrivals
	name = "Arrivals Security Checkpoint"
	icon_state = "checkpoint_arr"

/area/station/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/station/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/station/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/station/security/checkpoint/medical/medsci
	name = "Security Post - Medsci"

/area/station/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/station/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/station/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/station/security/checkpoint/customs/auxiliary
	name = "Auxiliary Customs"
	icon_state = "customs_point_aux"

/area/station/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/station/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

/area/station/security/checkpoint/first
	name = "Security Post - First Floor"
	icon_state = "checkpoint_1"

/area/station/security/checkpoint/second
	name = "Security Post - Second Floor"
	icon_state = "checkpoint_2"

/area/station/security/checkpoint/third
	name = "Security Post - Third Floor"
	icon_state = "checkpoint_3"


/area/station/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | CULT_PERMITTED | PERSISTENT_ENGRAVINGS

//Rad proof
/area/station/security/prison/toilet
	name = "Prison Toilet"
	icon_state = "sec_prison_safe"

// Rad proof
/area/station/security/prison/safe
	name = "Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/station/security/prison/upper
	name = "Upper Prison Wing"
	icon_state = "prison_upper"

/area/station/security/prison/visit
	name = "Prison Visitation Area"
	icon_state = "prison_visit"

/area/station/security/prison/rec
	name = "Prison Rec Room"
	icon_state = "prison_rec"

/area/station/security/prison/mess
	name = "Prison Mess Hall"
	icon_state = "prison_mess"

/area/station/security/prison/work
	name = "Prison Work Room"
	icon_state = "prison_work"

/area/station/security/prison/shower
	name = "Prison Shower"
	icon_state = "prison_shower"

/area/station/security/prison/workout
	name = "Prison Gym"
	icon_state = "prison_workout"

/area/station/security/prison/garden
	name = "Prison Garden"
	icon_state = "prison_garden"
