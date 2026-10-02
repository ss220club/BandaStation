// Wolf's Doom armor and the dressing unit using it.

// The worn sprites are 32x40. The renderer already centers a 32x40 worn icon
// against the 32x32 human icon; change this value when the sprite needs tuning.
#define NORMANDY_WORN_Y_OFFSET -4
#define NORMANDY_CHARACTER_Y_OFFSET 8

#define NORMANDY_ARMOR_TRAIT "normandy_suit_storage"

#define NORMANDY_DRESSING_TIME (8 SECONDS)
#define NORMANDY_DOOR_ANIMATION_TIME (5 SECONDS)

#define NORMANDY_STORAGE_STATE_OPEN "open"
#define NORMANDY_STORAGE_STATE_CLOSED "closed_stale"
#define NORMANDY_STORAGE_STATE_CLOSING "Down"
#define NORMANDY_STORAGE_STATE_OPENING "Up"
#define NORMANDY_STORAGE_STATE_ACTIVE "closed_active"
#define NORMANDY_STEP_SOUND "normandy_step"

/datum/sound_effect/assoc/normandy_step
	key = NORMANDY_STEP_SOUND
	file_paths = list(
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step1.ogg' = 1,
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step2.ogg' = 1,
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step3.ogg' = 1,
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step4.ogg' = 1,
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step5.ogg' = 1,
		'modular_bandastation/prime_only/sound/obj/armor/normandy/step6.ogg' = 1,
	)

// Clothing uses the 32x40 DMI as the worn icon, while these regular 32x32
// icons are only used when the item is on the floor or in an inventory slot.
/obj/item/clothing/suit/armor/normandy
	name = "Wolf's Doom armor"
	desc = "A heavy combat armor set with an unusually tall silhouette."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	icon_state = "armor"
	worn_icon = 'modular_bandastation/prime_only/icons/centcom/NormandySuit.dmi'
	worn_icon_state = "armor"
	worn_x_dimension = 32
	worn_y_dimension = 40
	worn_y_offset = NORMANDY_WORN_Y_OFFSET
	// The tall upper section of Wolf's Doom must render over its helmet.
	alternate_worn_layer = HEAD_LAYER - 0.1
	armor_type = /datum/armor/mod_theme_corporate
	clothing_traits = list(TRAIT_NODISMEMBER, TRAIT_GRABRESISTANCE)
	user_vars_to_edit = list("move_resist" = MOVE_FORCE_OVERPOWERING)

/obj/item/clothing/suit/armor/normandy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_attached_clothing,\
		deployable_type = /obj/item/clothing/head/helmet/normandy,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Helmet",\
		parent_icon_state_suffix = "",\
		auto_deploy_on_outfit_equip = TRUE,\
	)

/obj/item/clothing/gloves/combat/normandy
	name = "Wolf's Doom gloves"
	desc = "Armored combat gloves from the Wolf's Doom suit."
	icon_state = "black"
	worn_icon = 'modular_bandastation/prime_only/icons/centcom/NormandySuit.dmi'
	worn_icon_state = "gloves"
	worn_x_dimension = 32
	worn_y_dimension = 40
	worn_y_offset = NORMANDY_WORN_Y_OFFSET
	armor_type = /datum/armor/mod_theme_corporate

/obj/item/clothing/shoes/combat/normandy
	name = "Wolf's Doom boots"
	desc = "Armored combat boots from the Wolf's Doom suit."
	icon_state = "jackboots"
	worn_icon = 'modular_bandastation/prime_only/icons/centcom/NormandySuit.dmi'
	worn_icon_state = "boots"
	worn_x_dimension = 32
	worn_y_dimension = 40
	worn_y_offset = NORMANDY_WORN_Y_OFFSET
	clothing_traits = list(TRAIT_NO_SLIP_ALL, TRAIT_SILENT_FOOTSTEPS)
	armor_type = /datum/armor/mod_theme_corporate

/obj/item/clothing/shoes/combat/normandy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/item_equipped_movement_rustle, NORMANDY_STEP_SOUND, 2, 33, 0)

/obj/item/clothing/head/helmet/normandy
	name = "Wolf's Doom helmet"
	desc = "A sealed combat helmet from the Wolf's Doom suit."
	icon_state = "helmet"
	base_icon_state = "helmet"
	worn_icon = 'modular_bandastation/prime_only/icons/centcom/NormandySuit.dmi'
	worn_icon_state = "head"
	worn_x_dimension = 32
	worn_y_dimension = 40
	worn_y_offset = NORMANDY_WORN_Y_OFFSET
	armor_type = /datum/armor/normandy_helmet
	var/tts_effect_active = FALSE

/datum/armor/normandy_helmet
	melee = 80
	bullet = 80
	laser = 70
	energy = 65
	bomb = 80
	bio = 100
	fire = 100
	acid = 100
	wound = 25

/obj/item/clothing/head/helmet/normandy/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	user.tts_effects_add(list(/datum/singleton/sound_effect/centcom_vox))
	tts_effect_active = TRUE

/obj/item/clothing/head/helmet/normandy/dropped(mob/living/user)
	. = ..()
	if(!tts_effect_active)
		return
	tts_effect_active = FALSE
	user.tts_effects_remove(list(/datum/singleton/sound_effect/centcom_vox))

/obj/item/clothing/neck/cloak/normandy
	name = "Wolf's Doom standard cloak"
	desc = "A standard cloak bearing the Wolf's Doom colors."
	icon_state = "qmcloak"
	worn_icon = 'modular_bandastation/prime_only/icons/centcom/NormandySuit.dmi'
	worn_icon_state = "cloak_standart"
	worn_x_dimension = 32
	worn_y_dimension = 40
	worn_y_offset = NORMANDY_WORN_Y_OFFSET
	// The cloak must render above the armor overlay.
	alternate_worn_layer = HEAD_LAYER - 0.2
	armor_type = /datum/armor/mod_theme_corporate

/obj/item/clothing/neck/cloak/normandy/wolf
	name = "Wolf's Doom wolf cloak"
	desc = "A wolf-themed alternative cloak for the Wolf's Doom suit."
	worn_icon_state = "cloak_wolf"

/datum/outfit/centcom/normandy
	name = "бронекостюм «Волчья Погибель»"
	suit = /obj/item/clothing/suit/armor/normandy
	gloves = /obj/item/clothing/gloves/combat/normandy
	shoes = /obj/item/clothing/shoes/combat/normandy
	neck = /obj/item/clothing/neck/cloak/normandy

/datum/outfit/centcom/normandy/wolf
	name = "бронекостюм «Волчья Погибель» с волчьим плащом"
	neck = /obj/item/clothing/neck/cloak/normandy/wolf

/obj/machinery/normandy_suit_storage
	name = "Wolf's Doom suit storage unit"
	desc = "A unit that seals around a person and equips the Wolf's Doom armor."
	icon = 'modular_bandastation/prime_only/icons/centcom/SuitStorage.dmi'
	icon_state = NORMANDY_STORAGE_STATE_OPEN
	state_open = TRUE
	density = FALSE
	use_power = NO_POWER_USE
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION | UNIQUE_RENAME | RENAME_NO_DESC
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	occupant_typecache = list(/mob/living/carbon/human)
	max_integrity = 250

	// The machine sprite is 64x64 and is centered on its map tile.
	SET_BASE_PIXEL(-4, 0)

	/// Outfit path used when the unit finishes its cycle.
	var/cloak_type = /obj/item/clothing/neck/cloak/normandy
	/// The one physical set belonging to this unit. It is moved between the
	/// unit and the wearer instead of creating a fresh outfit every cycle.
	var/obj/item/clothing/suit/armor/normandy/stored_armor
	var/obj/item/clothing/gloves/combat/normandy/stored_gloves
	var/obj/item/clothing/shoes/combat/normandy/stored_boots
	var/obj/item/clothing/head/helmet/normandy/stored_helmet
	var/obj/item/clothing/neck/cloak/normandy/stored_cloak
	var/list/kit_items
	var/mob/living/carbon/human/kit_wearer
	/// Timer for the door-closing animation before dressing starts.
	var/dressing_start_timer = TIMER_ID_NULL
	/// Timer for restoring the machine layer after a door animation.
	var/door_layer_reset_timer = TIMER_ID_NULL
	/// TRUE while the occupant is being dressed or undressed.
	var/is_dressing = FALSE
	/// TRUE when the current cycle removes the stored set from its wearer.
	var/is_removing_kit = FALSE

/obj/machinery/normandy_suit_storage/wolf
	name = "Wolf's Doom suit storage unit (wolf cloak)"
	cloak_type = /obj/item/clothing/neck/cloak/normandy/wolf

/obj/machinery/normandy_suit_storage/Initialize(mapload)
	. = ..()
	stored_armor = new /obj/item/clothing/suit/armor/normandy(src)
	stored_gloves = new /obj/item/clothing/gloves/combat/normandy(src)
	stored_boots = new /obj/item/clothing/shoes/combat/normandy(src)
	var/datum/component/toggle_attached_clothing/helmet_component = stored_armor.GetComponent(/datum/component/toggle_attached_clothing)
	stored_helmet = helmet_component.deployable
	stored_cloak = new cloak_type(src)
	kit_items = list(stored_armor, stored_gloves, stored_boots, stored_helmet, stored_cloak)
	for(var/obj/item/kit_item as anything in kit_items)
		ADD_TRAIT(kit_item, TRAIT_NODROP, NORMANDY_ARMOR_TRAIT)
	update_appearance()

/obj/machinery/normandy_suit_storage/Destroy()
	cancel_dressing_start_timer()
	cancel_door_layer_reset_timer()
	for(var/obj/item/kit_item as anything in kit_items)
		REMOVE_TRAIT(kit_item, TRAIT_NODROP, NORMANDY_ARMOR_TRAIT)
	return ..()

/obj/machinery/normandy_suit_storage/update_icon_state()
	. = ..()
	if(state_open)
		icon_state = NORMANDY_STORAGE_STATE_OPEN
	else if(is_dressing)
		icon_state = NORMANDY_STORAGE_STATE_ACTIVE
	else
		icon_state = NORMANDY_STORAGE_STATE_CLOSED

/obj/machinery/normandy_suit_storage/interact(mob/living/user, list/modifiers)
	if(!ishuman(user))
		balloon_alert(user, "только человек может использовать установку")
		return TRUE

	if(machine_stat & (BROKEN|NOPOWER))
		balloon_alert(user, "установка не работает")
		return TRUE

	if(is_dressing)
		balloon_alert(user, "установка занята")
		return TRUE

	if(state_open)
		if(get_turf(user) != get_turf(src))
			balloon_alert(user, "встаньте внутрь установки")
			return TRUE
		if(user.buckled || user.mob_size >= MOB_SIZE_LARGE || user.has_buckled_mobs())
			balloon_alert(user, "невозможно закрыть установку")
			return TRUE
		close_machine(user)
		return TRUE

	// A free click from outside opens the unit and releases its occupant.
	open_machine()
	return TRUE

/obj/machinery/normandy_suit_storage/close_machine(atom/movable/target, density_to_set = TRUE)
	if(!state_open || is_dressing || !target || !can_be_occupant(target))
		return FALSE

	var/mob/living/mob_target = target
	if(mob_target.buckled || mob_target.mob_size >= MOB_SIZE_LARGE || target.has_buckled_mobs())
		return FALSE

	if(kit_wearer && QDELETED(kit_wearer))
		kit_wearer = null

	// Closing on the exact wearer means this cycle is a removal cycle. Any
	// other occupant can only start a dressing cycle when the physical set is
	// actually back inside this unit.
	is_removing_kit = is_kit_worn_by(mob_target)
	if(!is_removing_kit && !is_kit_stored())
		balloon_alert(mob_target, "комплект уже используется")
		return FALSE

	. = ..()
	if(!occupant)
		return .

	start_door_animation()
	flick(NORMANDY_STORAGE_STATE_CLOSING, src)
	cancel_dressing_start_timer()
	dressing_start_timer = addtimer(CALLBACK(src, PROC_REF(begin_dressing)), NORMANDY_DOOR_ANIMATION_TIME, TIMER_STOPPABLE)
	return .

/obj/machinery/normandy_suit_storage/open_machine(drop = TRUE, density_to_set = FALSE)
	cancel_dressing_start_timer()
	is_dressing = FALSE
	is_removing_kit = FALSE
	start_door_animation()
	flick(NORMANDY_STORAGE_STATE_OPENING, src)
	return ..()

/obj/machinery/normandy_suit_storage/dump_inventory_contents(list/subset = null)
	var/turf/this_turf = get_turf(src)
	for(var/atom/movable/movable_atom in contents)
		// The kit is part of the machine and must not be dumped when the door
		// opens. It is intentionally dropped only by dump_contents/deconstruction.
		if(movable_atom in kit_items)
			continue
		if(wires && (movable_atom in assoc_to_values(wires.assemblies)))
			continue
		if(subset && !(movable_atom in subset))
			continue
		if(movable_atom in component_parts)
			continue
		movable_atom.forceMove(this_turf)
		if(occupant == movable_atom)
			set_occupant(null)

/obj/machinery/normandy_suit_storage/relaymove(mob/living/user, direction)
	if(user != occupant || state_open)
		return
	if(is_dressing)
		balloon_alert(user, "сначала дождитесь завершения переодевания")
		return
	container_resist_act(user)

/obj/machinery/normandy_suit_storage/container_resist_act(mob/living/user)
	if(user != occupant || state_open)
		return
	if(is_dressing)
		balloon_alert(user, "дверь заблокирована на время переодевания")
		return
	visible_message(span_notice("[user] выбирается из [src]."), span_notice("Вы выбираетесь из [src]."))
	open_machine()

/obj/machinery/normandy_suit_storage/Exited(atom/movable/gone, direction)
	var/was_occupant = gone == occupant
	. = ..()
	if(!was_occupant || QDELETED(src))
		return

	cancel_dressing_start_timer()
	is_dressing = FALSE
	if(!state_open)
		open_machine(drop = FALSE)
	apply_exit_pose(gone)

/obj/machinery/normandy_suit_storage/proc/cancel_dressing_start_timer()
	if(dressing_start_timer == TIMER_ID_NULL)
		return
	deltimer(dressing_start_timer)
	dressing_start_timer = TIMER_ID_NULL

/obj/machinery/normandy_suit_storage/proc/cancel_door_layer_reset_timer()
	if(door_layer_reset_timer == TIMER_ID_NULL)
		return
	deltimer(door_layer_reset_timer)
	door_layer_reset_timer = TIMER_ID_NULL

/obj/machinery/normandy_suit_storage/proc/start_door_animation()
	cancel_door_layer_reset_timer()
	layer = ABOVE_MOB_LAYER
	door_layer_reset_timer = addtimer(CALLBACK(src, PROC_REF(reset_door_animation_layer)), NORMANDY_DOOR_ANIMATION_TIME, TIMER_STOPPABLE)

/obj/machinery/normandy_suit_storage/proc/reset_door_animation_layer()
	door_layer_reset_timer = TIMER_ID_NULL
	layer = initial(layer)

/obj/machinery/normandy_suit_storage/proc/can_finish_cycle(mob/living/carbon/human/target)
	return is_dressing && !state_open && is_operational && target == occupant && target.loc == src && target.stat != DEAD

/obj/machinery/normandy_suit_storage/proc/begin_dressing()
	dressing_start_timer = TIMER_ID_NULL
	if(state_open || is_dressing || !is_operational)
		return

	var/mob/living/carbon/human/target = occupant
	if(!istype(target))
		open_machine()
		return

	is_dressing = TRUE
	update_appearance()
	balloon_alert(target, is_removing_kit ? "снятие брони началось" : "переодевание началось")

	if(!do_after(target, NORMANDY_DRESSING_TIME, src, timed_action_flags = IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(can_finish_cycle), target)))
		cancel_dressing(target)
		return

	if(!can_finish_cycle(target))
		cancel_dressing(target)
		return

	if(is_removing_kit)
		if(!store_kit_from(target))
			balloon_alert(target, "не удалось снять комплект")
		else
			balloon_alert(target, "броня «Волчья Погибель» снята")
	else
		if(!equip_kit_on(target))
			balloon_alert(target, "не удалось надеть комплект")
			cancel_dressing(target)
			return
		kit_wearer = target
		target.set_base_pixel_y(target.base_pixel_y + NORMANDY_CHARACTER_Y_OFFSET)
		balloon_alert(target, "броня «Волчья Погибель» надета")
	is_dressing = FALSE
	open_machine()

/obj/machinery/normandy_suit_storage/proc/cancel_dressing(mob/living/carbon/human/target)
	is_dressing = FALSE
	is_removing_kit = FALSE
	if(target)
		balloon_alert(target, "переодевание прервано")
	if(!state_open)
		open_machine()

/obj/machinery/normandy_suit_storage/proc/is_kit_stored()
	if(!length(kit_items))
		return FALSE
	for(var/obj/item/kit_item as anything in kit_items)
		if(kit_item.loc == src)
			continue
		if(kit_item == stored_helmet && stored_armor.loc == src && kit_item.loc == stored_armor)
			continue
		return FALSE
	return TRUE

/obj/machinery/normandy_suit_storage/proc/is_kit_worn_by(mob/living/carbon/human/target)
	if(!target || !stored_armor || !stored_gloves || !stored_boots || !stored_helmet || !stored_cloak)
		return FALSE
	var/hidden_helmet = FALSE
	var/datum/component/toggle_attached_clothing/helmet_component = stored_armor.GetComponent(/datum/component/toggle_attached_clothing)
	if(helmet_component)
		hidden_helmet = !helmet_component.currently_deployed && stored_helmet.loc == stored_armor
	return target.wear_suit == stored_armor \
		&& target.gloves == stored_gloves \
		&& target.shoes == stored_boots \
		&& (target.head == stored_helmet || hidden_helmet) \
		&& target.wear_neck == stored_cloak

/obj/machinery/normandy_suit_storage/proc/remove_conflicting_item(mob/living/carbon/human/target, slot)
	var/obj/item/existing_item = target.get_item_by_slot(slot)
	if(!existing_item || (existing_item in kit_items))
		return TRUE
	return target.transferItemToLoc(existing_item, get_turf(src), force = TRUE, silent = TRUE, animated = FALSE)

/obj/machinery/normandy_suit_storage/proc/equip_kit_on(mob/living/carbon/human/target)
	for(var/slot in list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_NECK))
		if(!remove_conflicting_item(target, slot))
			return FALSE

	if(!target.equip_to_slot_if_possible(stored_armor, ITEM_SLOT_OCLOTHING, disable_warning = TRUE, redraw_mob = FALSE, bypass_equip_delay_self = TRUE, indirect_action = TRUE))
		return FALSE
	if(!target.equip_to_slot_if_possible(stored_gloves, ITEM_SLOT_GLOVES, disable_warning = TRUE, redraw_mob = FALSE, bypass_equip_delay_self = TRUE, indirect_action = TRUE))
		store_kit_from(target)
		return FALSE
	if(!target.equip_to_slot_if_possible(stored_boots, ITEM_SLOT_FEET, disable_warning = TRUE, redraw_mob = FALSE, bypass_equip_delay_self = TRUE, indirect_action = TRUE))
		store_kit_from(target)
		return FALSE
	if(!target.equip_to_slot_if_possible(stored_cloak, ITEM_SLOT_NECK, disable_warning = TRUE, redraw_mob = FALSE, bypass_equip_delay_self = TRUE, indirect_action = TRUE))
		store_kit_from(target)
		return FALSE
	var/datum/component/toggle_attached_clothing/component = stored_armor.GetComponent(/datum/component/toggle_attached_clothing)
	if(!component)
		store_kit_from(target)
		return FALSE
	if(!component.currently_deployed)
		component.toggle_deployable()
	if(target.head != stored_helmet)
		store_kit_from(target)
		return FALSE
	return TRUE

/obj/machinery/normandy_suit_storage/proc/store_kit_from(mob/living/carbon/human/target)
	if(!is_kit_worn_by(target) && target.wear_suit != stored_armor && target.gloves != stored_gloves && target.shoes != stored_boots && target.head != stored_helmet && target.wear_neck != stored_cloak)
		return FALSE

	for(var/obj/item/kit_item as anything in kit_items)
		if(kit_item.loc == src)
			continue
		if(target.get_slot_by_item(kit_item))
			if(!target.temporarilyRemoveItemFromInventory(kit_item, force = TRUE, idrop = FALSE, newloc = src))
				return FALSE
		kit_item.forceMove(src)

	if(target == kit_wearer)
		target.set_base_pixel_y(target.base_pixel_y - NORMANDY_CHARACTER_Y_OFFSET)
	kit_wearer = null
	return is_kit_stored()

/obj/machinery/normandy_suit_storage/proc/apply_exit_pose(mob/living/carbon/human/target)
	if(!target || QDELETED(target))
		return

	target.setDir(SOUTH)
