/datum/id_trim/job/explorer
	assignment = JOB_EXPLORER
	// trim_state = "trim_blueshield"
 	// trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'

	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BITRUNNER // change
	minimal_access = list(
		ACCESS_EVA,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_GATEWAY,
	)
	job = /datum/job/explorer
