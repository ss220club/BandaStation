GLOBAL_LIST_EMPTY(raid_extract_landmarks)

/obj/effect/landmark/raid_extract
	name = "EFTK Raid Death Rejuve Subsystem"

	Initialize(mapload)
		. = ..()
		GLOB.raid_extract_landmarks += src

	Destroy()
		GLOB.raid_extract_landmarks -= src
		return ..()
