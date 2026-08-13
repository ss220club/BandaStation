/area/station/service
	airlock_wires = /datum/wires/airlock/service
	tacmap_color = TACMAP_AREA_SERVICE

/*
* Bar/Kitchen Areas
*/

/area/station/service/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/station/service/minibar
	name = "Mini Bar"
	icon_state = "minibar"

/area/station/service/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/station/service/kitchen/coldroom
	name = "Kitchen Cold Room"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/kitchen/diner
	name = "Diner"
	icon_state = "diner"

/area/station/service/kitchen/kitchen_backroom
	name = "Kitchen Backroom"
	icon_state = "kitchen_backroom"

/area/station/service/bar
	name = "Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "I love being in the bar!"
	mood_trait = TRAIT_EXTROVERT
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/station/service/bar/atrium
	name = "Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/bar/backroom
	name = "Bar Backroom"
	icon_state = "bar_backroom"

/*
* Entertainment/Library Areas
*/

/area/station/service/theater
	name = "Theater"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/theater_dressing
	name = "Theater Dressing Room"
	icon_state = "theatre_dressing"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/greenroom
	name = "Greenroom"
	icon_state = "theatre_green"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library
	name = "Library"
	icon_state = "library"
	mood_bonus = 5
	mood_message = "I love being in the library!"
	mood_trait = TRAIT_INTROVERT
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/station/service/library/garden
	name = "Library Garden"
	icon_state = "library_garden"

/area/station/service/library/lounge
	name = "Library Lounge"
	icon_state = "library_lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/library/artgallery
	name = " Art Gallery"
	icon_state = "library_gallery"

/area/station/service/library/private
	name = "Library Private Study"
	icon_state = "library_gallery_private"

/area/station/service/library/upper
	name = "Library Upper Floor"
	icon_state = "library"

/area/station/service/library/printer
	name = "Library Printer Room"
	icon_state = "library"

/*
* Chapel/Pubby Monestary Areas
*/

/area/station/service/chapel
	name = "Chapel"
	icon_state = "chapel"
	mood_bonus = 4
	mood_message = "Being in the chapel brings me peace."
	mood_trait = TRAIT_SPIRITUAL
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/chapel/monastery
	name = "Monastery"

/area/station/service/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"

/area/station/service/chapel/asteroid
	name = "Chapel Asteroid"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/station/service/chapel/asteroid/monastery
	name = "Monastery Asteroid"

/area/station/service/chapel/dock
	name = "Chapel Dock"
	icon_state = "construction"

/area/station/service/chapel/storage
	name = "Chapel Storage"
	icon_state = "chapelstorage"

/area/station/service/chapel/funeral
	name = "Chapel Funeral Room"
	icon_state = "chapelfuneral"

/area/station/service/hydroponics/garden/monastery
	name = "Monastery Garden"
	icon_state = "hydro"

/*
* Hydroponics/Garden Areas
*/

/area/station/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/service/hydroponics/upper
	name = "Upper Hydroponics"
	icon_state = "hydro"

/area/station/service/hydroponics/garden
	name = "Garden"
	icon_state = "garden"

/*
* Misc/Unsorted Rooms
*/

/area/station/service/lawoffice
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/service/janitor
	name = "Custodial Closet"
	icon_state = "janitor"
	area_flags = CULT_PERMITTED | BLOBS_ALLOWED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/barber
	name = "Barber"
	icon_state = "barber"

/area/station/service/boutique
	name = "Boutique"
	icon_state = "boutique"

/*
* Abandoned Rooms
*/

/area/station/service/hydroponics/garden/abandoned
	name = "Abandoned Garden"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/kitchen/abandoned
	name = "Abandoned Kitchen"
	icon_state = "abandoned_kitchen"
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/electronic_marketing_den
	name = "Electronic Marketing Den"
	icon_state = "abandoned_marketing_den"
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/abandoned_gambling_den
	name = "Abandoned Gambling Den"
	icon_state = "abandoned_gambling_den"
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/abandoned_gambling_den/gaming
	name = "Abandoned Gaming Den"
	icon_state = "abandoned_gaming_den"
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/theater/abandoned
	name = "Abandoned Theater"
	icon_state = "abandoned_theatre"
	tacmap_color = TACMAP_AREA_MAINTENANCE

/area/station/service/library/abandoned
	name = "Abandoned Library"
	icon_state = "abandoned_library"
	tacmap_color = TACMAP_AREA_MAINTENANCE
