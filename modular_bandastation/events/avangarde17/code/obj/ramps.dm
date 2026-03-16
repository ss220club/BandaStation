/obj/structure/stairs/ramp
	name = "ramp"
	desc = "Этот склон выглядит удобным для безопасного спуска и подъёма."
	icon = 'modular_bandastation/events/avangarde17/icons/ramps.dmi'
	icon_state = "shadow_ramp"
	has_merged_sprites = FALSE
	opacity = TRUE

/obj/structure/stairs/ramp/inverted
	icon_state = "shadow_ramp_inverted"

/obj/structure/stairs/ramp/on_exit_stairs(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return

	if(!isobserver(leaving) && isTerminator() && direction & dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT
