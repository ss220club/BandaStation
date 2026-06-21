GLOBAL_LIST_EMPTY(radiation_lake_anomaly_points)
GLOBAL_LIST_EMPTY(radiation_lake2_grav_points)
GLOBAL_LIST_EMPTY(pyro_anomaly_points)

/obj/effect/landmark/radiation_lake_anomaly
	name = "EFTK Bluespace Anomaly Point"

	Initialize(mapload)
		. = ..()
		GLOB.radiation_lake_anomaly_points += src

	Destroy()
		GLOB.radiation_lake_anomaly_points -= src
		return ..()

/obj/effect/landmark/radiation_lake2_grav
	name = "EFTK Gravity Anomaly Point"

	Initialize(mapload)
		. = ..()
		GLOB.radiation_lake2_grav_points += src

	Destroy()
		GLOB.radiation_lake2_grav_points -= src
		return ..()

/obj/effect/landmark/pyro_anomaly
	name = "EFTK Pyro Anomaly Point"

	Initialize(mapload)
		. = ..()
		GLOB.pyro_anomaly_points += src

	Destroy()
		GLOB.pyro_anomaly_points -= src
		return ..()
