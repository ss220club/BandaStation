// MARK: MORTAR OBJECT

#define DEPLOY_TIME 8 SECONDS
#define SHELL_TRAVEL_TIME 2.5 SECONDS

/obj/machinery/mortar
	name = "\improper M402 mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at."
	icon = 'modular_bandastation/weapon/icons/machinery/mortar.dmi'
	icon_state = "mortar_m402"
	anchored = TRUE
	density = TRUE
	// So you can't hide it under corpses
	layer = ABOVE_MOB_LAYER
	/// Initial target coordinates
	var/target_x = 1
	var/target_y = 1
	/// Automatic offsets from target. Currently not used
	var/offset_x = 0
	var/offset_y = 0
	var/is_busy = FALSE

/obj/machinery/mortar/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/mortar_shell))
		is_busy = TRUE
		fire(attacking_item, user)


/obj/machinery/mortar/wrench_act(mob/living/user, obj/item/wrench/used_wrench)
	if(!ishuman(user))
		return ITEM_INTERACT_SKIP_TO_ATTACK
	used_wrench.play_tool_sound(user)
	user.balloon_alert(user, "undeploying...")
	if(!do_after(user, DEPLOY_TIME))
		return ITEM_INTERACT_BLOCKING
	var/obj/undeployed_object = new /obj/item/mortar_kit
	//Keeps the health the same even if you redeploy the gun
	if(!user.put_in_hands(undeployed_object))
		undeployed_object.forceMove(loc)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mortar/proc/fire(var/obj/item/mortar_shell/shell, mob/living/user)
	var/turf/target_turf = locate(target_x, target_y, z)
	user.visible_message(span_warning("[user] начал заряжать \a [shell.name] внутрь [src]."), span_notice("Вы начали заряжать \a [shell.name] внутрь [src]"))
	playsound(loc, 'modular_bandastation/weapon/sound/machinery/mortar/gun_mortar_reload.ogg', 50, 1)
	if(!do_after(user, 2 SECONDS, src))
		return
	visible_message(span_alertwarning("[uppertext("[name]")] ДЕЛАЕТ ВЫСТРЕЛ!"))
	playsound(loc, 'modular_bandastation/weapon/sound/machinery/mortar/gun_mortar_fire.ogg', 50, 1)
	is_busy = FALSE
	flick(icon_state + "_fire", src)
	shell.forceMove(src)
	for(var/mob/mob in get_hearers_in_range(7, src, RECURSIVE_CONTENTS_CLIENT_MOBS))
		shake_camera(mob, 1 SECONDS, 1)
	addtimer(CALLBACK(src, PROC_REF(handle_shell), target_turf, shell), SHELL_TRAVEL_TIME)

/obj/machinery/mortar/proc/handle_shell(turf/target, obj/item/mortar_shell/shell)
	playsound(target, 'modular_bandastation/weapon/sound/machinery/mortar/gun_mortar_travel.ogg', 50, 1)
	var/relative_dir
	for(var/mob/mob in range(15, get_hearers_in_range(7, src, RECURSIVE_CONTENTS_CLIENT_MOBS)))
		if(get_turf(mob) == target)
			relative_dir = 0
		else
			relative_dir = get_dir(mob, target)
		to_chat(mob, span_bolddanger("СНАРЯД ПАДАЕТ [relative_dir ? uppertext(("НА " + dir2text(relative_dir) + " ОТ ВАС")) : uppertext("ПРЯМО НА ВАС")]!"))
	shell.detonate(target)
	qdel(shell)


// MARK: MORTAR UI
// Commented until future updates.
// I'm really bad with TGUI, but Markelly will kill me if I don't prepare this PR before saturday, sorry
/*
/obj/machinery/mortar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mortar", name)
		ui.open()

/obj/machinery/mortar/ui_data(mob/user)
	. = list()

	.["target_x"] = target_x
	.["target_y"] = target_y

	.["offset_x"] = offset_x
	.["offset_y"] = offset_y

	.["shell"] = "Loaded"
*/

// Debug mortar targeting

/obj/machinery/mortar/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/new_target_x = tgui_input_number(user, "Координата X (1-255)?", default = 1, max_value = 255, min_value = 1)
	var/new_target_y = tgui_input_number(user, "Координата Y (1-255)?", default = 1, max_value = 255, min_value = 1)
	if(QDELETED(src) || !in_range(src, user))
		return
	target_x = new_target_x
	target_y = new_target_y

// MARK: MORTAR ITEM

/obj/item/mortar_kit
	name = "\improper M402 mortar portable kit"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first"
	icon = 'modular_bandastation/weapon/icons/machinery/mortar.dmi'
	icon_state = "mortar_m402_carry"
	/*item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/jungle_righthand.dmi'
	)*/
	//w_class = SIZE_HUGE //No dumping this in a backpack. Carry it, fatso
	//flags_atom = FPRINT|CONDUCT|MAP_COLOR_INDEX
	/// Linked designator, keeping track of it on undeploy so we don't have to relink it everytime.
	//var/obj/item/device/binoculars/range/designator/linked_designator

/obj/item/mortar_kit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, DEPLOY_TIME, /obj/machinery/mortar)

#undef DEPLOY_TIME
#undef SHELL_TRAVEL_TIME

