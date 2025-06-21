/datum/overmap_shuttle_controller
	var/mob/living/mob_controller

	var/datum/overmap_object/shuttle/overmap_obj

	var/datum/action/innate/quit_control/quit_control_button
	var/datum/action/innate/stop_shuttle/stop_shuttle_button
	var/datum/action/innate/open_shuttle_control/shuttle_control_button
	var/busy = FALSE

	var/datum/shuttle_freeform_docker/freeform_docker

/datum/overmap_shuttle_controller/proc/ShuttleMovedOnOvermap()
	if(mob_controller)
		mob_controller.update_parallax_contents()

/datum/overmap_shuttle_controller/New(datum/overmap_object/shuttle/passed_ov_obj)
	overmap_obj = passed_ov_obj
	quit_control_button = new
	quit_control_button.target = src
	stop_shuttle_button = new
	stop_shuttle_button.target = src
	shuttle_control_button = new
	shuttle_control_button.target = src

/datum/overmap_shuttle_controller/proc/SetController(mob/living/our_guy)
	if(mob_controller)
		RemoveCurrentControl()
	AddControl(our_guy)

/datum/overmap_shuttle_controller/proc/AddControl(mob/living/our_guy)
	mob_controller = our_guy
	RegisterSignal(mob_controller, COMSIG_CLICKON, .proc/ControllerClick)
	mob_controller.client.perspective = EYE_PERSPECTIVE
	mob_controller.client.eye = overmap_obj.my_visual
	mob_controller.client.show_popup_menus = FALSE
	mob_controller.remote_control = overmap_obj.my_visual
	mob_controller.update_parallax_contents()
	quit_control_button.Grant(mob_controller)
	stop_shuttle_button.Grant(mob_controller)
	shuttle_control_button.Grant(mob_controller)


/datum/overmap_shuttle_controller/proc/RemoveCurrentControl(removing_overmap = FALSE)
	if(mob_controller)
		if(freeform_docker)
			AbortFreeform(removing_overmap)
		UnregisterSignal(mob_controller, COMSIG_CLICKON)
		mob_controller.client.perspective = MOB_PERSPECTIVE
		mob_controller.client.eye = mob_controller
		mob_controller.client.show_popup_menus = TRUE
		quit_control_button.Remove(mob_controller)
		stop_shuttle_button.Remove(mob_controller)
		shuttle_control_button.Remove(mob_controller)
		playsound(mob_controller, 'sound/machines/computer/computer_end.ogg', 25, FALSE)
		mob_controller.remote_control = null
		mob_controller.update_parallax_contents()
		mob_controller = null
	if(removing_overmap)
		QDEL_NULL(overmap_obj)

/datum/overmap_shuttle_controller/proc/AbortFreeform(removing_overmap)
	if(!freeform_docker)
		return
	freeform_docker.remove_eye_control()
	qdel(freeform_docker)
	if(!removing_overmap)
		mob_controller.client.perspective = EYE_PERSPECTIVE
		mob_controller.client.eye = overmap_obj.my_visual
		mob_controller.update_parallax_contents()
		mob_controller.remote_control = overmap_obj.my_visual

/datum/overmap_shuttle_controller/proc/ControllerClick(datum/source, atom/A, params)
	SIGNAL_HANDLER
	if(A.z != overmap_obj.current_system.z_level)
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(source)
		return COMSIG_CANCEL_CLICKON
	if(modifiers["right"])
		overmap_obj.CommandMove(A.x,A.y)
		return COMSIG_CANCEL_CLICKON

	return COMSIG_CANCEL_CLICKON

/datum/action/innate/quit_control
	name = "Quit Control"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/quit_control/Trigger(trigger_flags)
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.RemoveCurrentControl()

/datum/action/innate/stop_shuttle
	name = "Stop Shuttle"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/stop_shuttle/Trigger(trigger_flags)
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.overmap_obj.StopMove()

/datum/action/innate/open_shuttle_control
	name = "Shuttle Controls"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/open_shuttle_control/Trigger(trigger_flags)
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.overmap_obj.DisplayUI(OSC.mob_controller)
