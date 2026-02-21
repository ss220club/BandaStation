/// Station side

/area/station/cargo/bitrunning
	name = "Битран"

/area/station/cargo/bitrunning/den
	name = "Офис битрана"
	desc = "Офис битранеров, в котором находится их оборудование."
	icon_state = "bit_den"

/// VDOM

/area/virtual_domain
	name = "Руины виртуального домена"
	icon_state = "bit_ruin"
	icon = 'icons/area/areas_station.dmi'
	area_flags = LOCAL_TELEPORT | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = VIRTUAL_AREA
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE

/area/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/// Safehouse

/area/virtual_domain/safehouse
	name = "Убежище виртуального домена"
	area_flags = LOCAL_TELEPORT | EVENT_PROTECTED | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Лавовые руины виртуального домена"
	icon_state = "bit_ruin"
	area_flags = /area/virtual_domain::area_flags
	area_flags_mapping = /area/virtual_domain::area_flags_mapping

/area/icemoon/underground/explored/virtual_domain
	name = "Ледяные руины виртуального домена"
	icon_state = "bit_ice"
	area_flags = /area/virtual_domain::area_flags
	area_flags_mapping = /area/virtual_domain::area_flags_mapping

/area/ruin/space/virtual_domain
	name = "Неиследованное простраснтво виртуального домена"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_ruin"
	area_flags = /area/virtual_domain::area_flags
	area_flags_mapping = /area/virtual_domain::area_flags_mapping

/area/space/virtual_domain
	name = "Космичесский виртуальный домен"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
	area_flags = /area/virtual_domain::area_flags
	area_flags_mapping = /area/virtual_domain::area_flags_mapping

///Areas that virtual entities should not be in

/area/virtual_domain/protected_space
	name = "Безопасная зона виртуального домена"
	area_flags = /area/virtual_domain/safehouse::area_flags
	area_flags_mapping = /area/virtual_domain/safehouse::area_flags_mapping
	icon_state = "bit_safe"

/area/virtual_domain/protected_space/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/// A hash lookup list of all the virtual area types
GLOBAL_LIST_INIT_TYPED(virtual_areas, /area, populate_virtual_areas())

/// Constructs the list of virtual areas
/proc/populate_virtual_areas()
	RETURN_TYPE(/list/area)
	var/list/area/virtual_areas = list()
	for(var/area/area_type as anything in subtypesof(/area))
		if (area_type::area_flags_mapping & VIRTUAL_AREA)
			virtual_areas[area_type] = TRUE
	return virtual_areas
