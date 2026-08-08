GLOBAL_LIST_EMPTY(radiation_lake_anomaly_points)
GLOBAL_LIST_EMPTY(radiation_lake2_grav_points)
GLOBAL_LIST_EMPTY(pyro_anomaly_points)

/obj/effect/landmark/radiation_lake_anomaly
	name = "EFTK Bluespace Anomaly Point"

/obj/effect/landmark/radiation_lake_anomaly/Initialize(mapload)
	. = ..()
	GLOB.radiation_lake_anomaly_points += src

/obj/effect/landmark/radiation_lake_anomaly/Destroy()
	GLOB.radiation_lake_anomaly_points -= src
	return ..()

/obj/effect/landmark/radiation_lake2_grav
	name = "EFTK Gravity Anomaly Point"

/obj/effect/landmark/radiation_lake2_grav/Initialize(mapload)
	. = ..()
	GLOB.radiation_lake2_grav_points += src

/obj/effect/landmark/radiation_lake2_grav/Destroy()
	GLOB.radiation_lake2_grav_points -= src
	return ..()

/obj/effect/landmark/pyro_anomaly
	name = "EFTK Pyro Anomaly Point"

/obj/effect/landmark/pyro_anomaly/Initialize(mapload)
	. = ..()
	GLOB.pyro_anomaly_points += src

/obj/effect/landmark/pyro_anomaly/Destroy()
	GLOB.pyro_anomaly_points -= src
	return ..()
