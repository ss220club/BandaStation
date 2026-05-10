/obj/item/organ/brain
	var/death_trauma_applied = FALSE

/obj/item/organ/brain/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/brain_permanent_traumas))
		decay_factor = STANDARD_ORGAN_DECAY * CONFIG_GET(number/brain_decay_rate)

/datum/config_entry/flag/brain_permanent_traumas
	default = FALSE

/datum/config_entry/number/brain_decay_rate
	integer = FALSE
	default = 0.5

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
	/// Time required for a contained mob to break free through resistance
	breakout_time = 5 SECONDS

/// Handles breakout attempts when a contained mob uses the resist action
/// Players can escape the stasis bag through a timed escape sequence that persists
/// even if the bag is moved, preventing permanent entrapment
/obj/structure/closet/body_bag/stasis/container_resist_act(mob/living/user)
	// Early exit if bag is already open or interaction is already in progress
	if(opened || DOING_INTERACTION_WITH_TARGET(user, src))
		return

	// Set action cooldowns to prevent spam
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT

	// Notify nearby observers and the escaping mob of breakout attempt
	user.visible_message(
		span_warning("[src] начинает сильно трясти!"),
		span_notice("Вы прислоняетесь к [src] и начинаете рвать молнию... (это займёт около [DisplayTimeText(breakout_time)].)"),
		span_hear("Вы слышите сильный грохот из [src].")
	)

	// Queue visual shake effect check for animation
	addtimer(CALLBACK(src, PROC_REF(check_if_shake)), 1 SECONDS)

	// Attempt timed escape - IGNORE_TARGET_LOC_CHANGE allows success even if bag is moved
	if(do_after(user, breakout_time, target = src, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
		// Validate escape conditions after time delay completes
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened)
			return

		// Announce successful breakout to the area
		user.visible_message(
			span_danger("[user] успешно выбрался из [src]!"),
			span_notice("Вы успешно выбираетесь из [src]!")
		)
		bust_open()
	else
		// Inform user of failed escape attempt only if still inside
		if(user.loc == src)
			to_chat(user, span_warning("Вам не удалось выбраться из [src]!"))


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

/obj/item/reagent_containers/hypospray/medipen/survival
	list_reagents = list( /datum/reagent/medicine/epinephrine = 7, /datum/reagent/medicine/c2/aiuri = 7, /datum/reagent/medicine/c2/libital = 7, /datum/reagent/medicine/leporazine = 6, /datum/reagent/toxin/formaldehyde = 3)

/obj/item/reagent_containers/hypospray/medipen/survival/luxury
	list_reagents = list(/datum/reagent/medicine/salbutamol = 9, /datum/reagent/medicine/c2/penthrite = 9, /datum/reagent/medicine/oxandrolone = 9, /datum/reagent/medicine/sal_acid = 10, /datum/reagent/medicine/omnizine = 10, /datum/reagent/medicine/leporazine = 10, /datum/reagent/toxin/formaldehyde = 3)
