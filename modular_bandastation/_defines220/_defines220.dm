/datum/modpack/defines220
	name = "Дефайны220"
	desc = "Добавляет дефайны, которые нам нужны"
	author = "larentoun"

#define CONNECT_TO_RND_SERVER_ROUNDSTART_ON_STATION(server_var, holder) do { \
	var/turf/holder_turf = get_turf(holder); \
	if(holder_turf && is_station_level(holder_turf.z)) { \
		CONNECT_TO_RND_SERVER_ROUNDSTART(server_var, holder); \
	}; \
} while (FALSE)
