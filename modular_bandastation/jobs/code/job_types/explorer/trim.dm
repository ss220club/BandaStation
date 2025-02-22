/datum/id_trim/job/explorer
	assignment = JOB_EXPLORER
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_explorer"

	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_EXPLORER // change
	minimal_access = list(
		ACCESS_EVA,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_GATEWAY,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_QM,
	)
	job = /datum/job/explorer
