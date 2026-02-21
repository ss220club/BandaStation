#define ROTATION_DEFAULT 90
#define ROTATION_MIN -360
#define ROTATION_MAX 360
#define PARALYZE_DEFAULT 3
#define PARALYZE_MIN 0
#define PARALYZE_MAX 6

/datum/buildmode_mode/crush
	key = "crush"

	var/atom/movable/crush_atom = null
	var/damage = 0
	var/crit_chance = 0
	var/paralyze = PARALYZE_DEFAULT SECONDS
	var/rotation = ROTATION_DEFAULT

/datum/buildmode_mode/crush/Destroy()
	crush_atom = null
	return ..()

/datum/buildmode_mode/crush/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"[span_bold("Set damage")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Select")] -> Left Mouse Button on obj/mob\n\
		[span_bold("Crush")] -> Right Mouse Button on obj/mob"))
	)

/datum/buildmode_mode/crush/change_settings(client/c)
	damage = tgui_input_number(c, "Damage from crushing", "Input")
	crit_chance = tgui_input_number(c, "Crit Chance", "Input", 0, 100)
	rotation = tgui_input_number(c, "Rotation", "Input", ROTATION_DEFAULT, ROTATION_MAX, ROTATION_MIN)
	paralyze = tgui_input_number(c, "Paralyze in seconds", "Input", PARALYZE_DEFAULT, PARALYZE_MAX, PARALYZE_MIN) SECONDS

/datum/buildmode_mode/crush/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(isturf(object))
			return
		crush_atom = object
		to_chat(c, "Selected object '[crush_atom]'")
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(crush_atom)
			var/turf/crush_to = isturf(object) ? object : get_turf(object)
			crush_atom.fall_and_crush(crush_to, damage, crit_chance, paralyze_time=paralyze, rotation=rotation)
			log_admin("Build Mode: [key_name(c)] crushed [crush_atom] to [object] ([AREACOORD(object)])")
