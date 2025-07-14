/obj/item/organ/brain/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/brain_permanent_death))
		decay_factor = STANDARD_ORGAN_DECAY * 2 //7 минут до полной смерти (в 4 раза быстрее чем по умолчанию (30 минут))

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/brain/brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	return !(brain.organ_flags & ORGAN_FAILING) || !CONFIG_GET(flag/brain_permanent_death)

/datum/config_entry/flag/brain_permanent_death
	default = TRUE

/datum/design/stasisbodybag
	name = "Stasis Body Bag"
	desc = "A folded bag designed for the storage and transportation of cadavers with portable stasis module and little space."
	id = "stasisbodybag"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/plasma =SHEET_MATERIAL_AMOUNT, /datum/material/diamond =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/bodybag/stasis
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/bodybag/stasis
	name = "Stasis body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers with portable stasis module and little space."
	icon = 'modular_bandastation/balance/icons/bodybag.dmi' //на замену
	icon_state = "stasisbag_folded" //на замену
	// Stored path we use for spawning a new body bag entity when unfolded.
	unfoldedbag_path = /obj/structure/closet/body_bag/stasis
	color = "#11978c"

/obj/item/bodybag/stasis/deploy_bodybag(mob/user, atom/location)
	. = ..()
	var/obj/structure/closet/body_bag/item_bag = .
	item_bag.color = color
	return item_bag

/obj/structure/closet/body_bag/stasis
	name = "stasis body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers with portable stasis module and little space."
	icon = 'modular_bandastation/balance/icons/bodybag.dmi' //на замену
	icon_state = "stasisbag"
	mob_storage_capacity = 1
	color = "#11978c"
	open_sound = 'sound/effects/spray.ogg'
	close_sound = 'sound/effects/spray.ogg'
	foldedbag_path = /obj/item/bodybag/stasis

/obj/structure/closet/body_bag/stasis/closet_update_overlays(list/new_overlays)
	. = ..()
	. = new_overlays
	var/overlay_state = isnull(base_icon_state) ? initial(icon_state) : base_icon_state
	if(opened && has_opened_overlay)
		var/mutable_appearance/door_underlay = mutable_appearance(icon, "[overlay_state]_open_over", alpha = src.alpha)
		. += door_underlay
		door_underlay.color = "#6bd5ff"
		door_underlay.overlays += emissive_blocker(door_underlay.icon, door_underlay.icon_state, src, alpha = door_underlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
	if(!opened && length(contents))
		var/mutable_appearance/door_underlay = mutable_appearance(icon, "[overlay_state]_over", alpha = src.alpha)
		. += door_underlay
		door_underlay.color = "#059900"
		door_underlay.overlays += emissive_blocker(door_underlay.icon, door_underlay.icon_state, src, alpha = door_underlay.alpha)
	return .

/obj/structure/closet/body_bag/stasis/undeploy_bodybag(atom/fold_loc)
	. = ..()
	var/obj/item/bodybag/folding_bodybag = .
	folding_bodybag.color = color
	return folding_bodybag

/obj/structure/closet/body_bag/stasis/close(mob/living/user)
	. = ..()
	for(var/mob/living/mob in contents)
		mob.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
		ADD_TRAIT(mob, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
		mob.extinguish_mob()

/obj/structure/closet/body_bag/stasis/Destroy()
	for(var/mob/living/mob in contents)
		mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
		REMOVE_TRAIT(mob, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	return ..()

/obj/structure/closet/body_bag/stasis/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/leaver = gone
		leaver.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
		REMOVE_TRAIT(leaver, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)

/obj/item/reagent_containers/hypospray/medipen
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/coagulant = 2)

/obj/item/reagent_containers/hypospray/medipen/survival
	list_reagents = list( /datum/reagent/medicine/epinephrine = 7, /datum/reagent/medicine/c2/aiuri = 7, /datum/reagent/medicine/c2/libital = 7, /datum/reagent/medicine/leporazine = 6, /datum/reagent/toxin/formaldehyde = 3)

/obj/item/reagent_containers/hypospray/medipen/survival/luxury
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/c2/penthrite = 10, /datum/reagent/medicine/oxandrolone = 10, /datum/reagent/medicine/sal_acid = 10 ,/datum/reagent/medicine/omnizine = 10 ,/datum/reagent/medicine/leporazine = 5, /datum/reagent/toxin/formaldehyde = 5)
