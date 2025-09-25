// MARK: MORTAR STRUCTURE

#define DEPLOY_TIME 8 SECONDS

/obj/machinery/mortar
	name = "\improper M402 mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at."
	icon = 'modular_bandastation/weapon/icons/structures/mortar.dmi'
	icon_state = "mortar_m402"
	anchored = TRUE
	density = TRUE
	// So you can't hide it under corpses
	layer = ABOVE_MOB_LAYER
	// Initial target coordinates
	var/target_x = 0
	var/target_y = 0
	var/target_z = 0
	// Automatic offsets from target
	var/offset_x = 0
	var/offset_y = 0

/*
/obj/machinery/mortar/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/mortar_shell))
		//Loading logic
*/

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

// MARK: MORTAR UI

/obj/machinery/mortar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mortar", name)
		ui.open()

/obj/machinery/mortar/ui_data(mob/user)
	. = list()

	.["target_x"] = target_x
	.["target_y"] = target_y
	.["target_z"] = target_z

	.["offset_x"] = offset_x
	.["offset_y"] = offset_y

	.["shell"] = "Loaded"


// MARK: MORTAR ITEM

/obj/item/mortar_kit
	name = "\improper M402 mortar portable kit"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first"
	icon = 'modular_bandastation/weapon/icons/structures/mortar.dmi'
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

/obj/machinery/chem_master

