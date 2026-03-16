#define SMOOTH_GROUP_WINDOWSILLS S_OBJ(56)

/obj/structure/table/windowsill
	name = "windowsill"
	smoothing_groups = SMOOTH_GROUP_WINDOWSILLS
	canSmoothWith = SMOOTH_GROUP_WINDOWSILLS
	desc = "Подоконник из металла. Архитектурный стандарт, который и не снился этим вашим НаноТрейзен."
	icon = 'icons/obj/smooth_structures/platform/window_frame_iron.dmi'
	icon_state = "window_frame_iron-0"
	base_icon_state = "window_frame_iron"
	deconstruction_ready = FALSE
	buildstack = /obj/item/stack/sheet/iron
	max_integrity = 200
	integrity_failure = 0.25
	armor_type = /datum/armor/table_reinforced
	can_flip = FALSE
