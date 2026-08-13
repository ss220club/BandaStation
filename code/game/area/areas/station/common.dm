/area/station/commons
	name = "Crew Facilities"
	icon_state = "commons"
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED

/*
* Dorm Areas
*/

/area/station/commons/dorms
	name = "Dormitories"
	icon_state = "dorms"

/area/station/commons/dorms/room1
	name = "Dorms Room 1"
	icon_state = "room1"

/area/station/commons/dorms/room2
	name = "Dorms Room 2"
	icon_state = "room2"

/area/station/commons/dorms/room3
	name = "Dorms Room 3"
	icon_state = "room3"

/area/station/commons/dorms/room4
	name = "Dorms Room 4"
	icon_state = "room4"

/area/station/commons/dorms/apartment1
	name = "Dorms Apartment 1"
	icon_state = "apartment1"

/area/station/commons/dorms/apartment2
	name = "Dorms Apartment 2"
	icon_state = "apartment2"

/area/station/commons/dorms/barracks
	name = "Sleep Barracks"

/area/station/commons/dorms/barracks/male
	name = "Male Sleep Barracks"
	icon_state = "dorms_male"

/area/station/commons/dorms/barracks/female
	name = "Female Sleep Barracks"
	icon_state = "dorms_female"

/area/station/commons/dorms/laundry
	name = "Laundry Room"
	icon_state = "laundry_room"

/area/station/commons/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/commons/toilet/auxiliary
	name = "Auxiliary Restrooms"
	icon_state = "toilet"

/area/station/commons/toilet/locker
	name = "Locker Toilets"
	icon_state = "toilet"

/area/station/commons/toilet/restrooms
	name = "Restrooms"
	icon_state = "toilet"

/area/station/commons/toilet/shower
	name = "Shower Room"
	icon_state = "shower"

/*
* Rec and Locker Rooms
*/

/area/station/commons/locker
	name = "Locker Room"
	icon_state = "locker"

/area/station/commons/lounge
	name = "Bar Lounge"
	icon_state = "lounge"
	mood_bonus = 5
	mood_message = "I love being in the bar!"
	mood_trait = TRAIT_EXTROVERT
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	tacmap_color = TACMAP_AREA_SERVICE

/area/station/commons/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/station/commons/fitness/locker_room
	name = "Unisex Locker Room"
	icon_state = "locker"

/area/station/commons/fitness/locker_room/male
	name = "Male Locker Room"
	icon_state = "locker_male"

/area/station/commons/fitness/locker_room/female
	name = "Female Locker Room"
	icon_state = "locker_female"

/area/station/commons/fitness/recreation
	name = "Recreation Area"
	icon_state = "rec"

/area/station/commons/fitness/recreation/entertainment
	name = "Entertainment Center"
	icon_state = "entertainment"

/area/station/commons/fitness/recreation/pool
	name = "Swimming Pool"
	icon_state = "pool"

/area/station/commons/fitness/recreation/lasertag
	name = "Laser Tag Arena"
	icon_state = "lasertag"

/area/station/commons/fitness/recreation/sauna
	name = "Sauna"
	icon_state = "sauna"

/*
* Vacant Rooms
*/

/area/station/commons/vacant_room
	name = "Vacant Room"
	icon_state = "vacant_room"
	ambience_index = AMBIENCE_MAINT

/area/station/commons/vacant_room/office
	name = "Vacant Office"
	icon_state = "vacant_office"

/area/station/commons/vacant_room/commissary
	name = "Vacant Commissary"
	icon_state = "vacant_commissary"

/*
* Storage Rooms
*/

/area/station/commons/storage
	name = "Commons Storage"

/area/station/commons/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/station/commons/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primary_storage"

/area/station/commons/storage/art
	name = "Art Supply Storage"
	icon_state = "art_storage"

/area/station/commons/storage/emergency/starboard
	name = "Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/emergency/port
	name = "Port Emergency Storage"
	icon_state = "emergency_storage"

/area/station/commons/storage/mining
	name = "Public Mining Storage"
	icon_state = "mining_storage"
