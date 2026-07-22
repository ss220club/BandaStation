GLOBAL_LIST_EMPTY(raid_extract_landmarks)

/obj/effect/landmark/raid_extract
	name = "EFTK Raid Death Rejuve Subsystem"

/obj/effect/landmark/raid_extract/Initialize(mapload)
	. = ..()
	GLOB.raid_extract_landmarks += src

/obj/effect/landmark/raid_extract/Destroy()
	GLOB.raid_extract_landmarks -= src
	return ..()
