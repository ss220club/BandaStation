#define TAGGER_TRAIT "tagger_trait"

// MARK: Gate

/obj/machinery/scanner_gate/preset_store
	locked = TRUE
	req_access = list(ACCESS_SERVICE)
	scangate_mode = "Store"

// Fix for a bugger overlay direction during mapload
/obj/machinery/scanner_gate/Initialize(mapload)
	. = ..()
	setDir(dir)

// MARK: Tagger

/obj/item/store_tagger
	name = "store tagger"
	desc = "Инструмент для установки снятия специального блю-спейс маячка, пикающего на рамках выхода из магазина."
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	icon = 'modular_bandastation/events/avangarde17/icons/store_tagger.dmi'
	icon_state = "tagger"

/obj/item/store_tagger/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!toggle_tag(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/item/store_tagger/proc/toggle_tag(obj/item/target, mob/living/user)
	if(!istype(target))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_STORE_TAGGED))
		REMOVE_TRAIT(target, TRAIT_STORE_TAGGED, TAGGER_TRAIT)
		balloon_alert(user, "маячок убран!")
	else
		ADD_TRAIT(target, TRAIT_STORE_TAGGED, TAGGER_TRAIT)
		balloon_alert(user, "маячок установлен!")
	playsound(target, 'sound/machines/beep/beep.ogg', 20, TRUE)
	return TRUE

// MARK: Mapping helper

/obj/effect/mapping_helpers/item_autotagger
	name = "item autotagger"
	icon = 'modular_bandastation/events/avangarde17/icons/mapping_helpers.dmi'
	icon_state = "item_autotagger"

/obj/effect/mapping_helpers/item_autotagger/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return

	if(!isturf(loc))
		return
	for(var/obj/item/current_item in loc.contents)
		if(!istype(current_item))
			continue
		ADD_TRAIT(current_item, TRAIT_STORE_TAGGED, TAGGER_TRAIT)

#undef TAGGER_TRAIT
