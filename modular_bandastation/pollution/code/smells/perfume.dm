/obj/item/perfume
	desc = "Флакон с приятно пахнущим ароматом."
	icon = 'modular_bandastation/pollution/icons/obj/perfume.dmi'
	icon_state = "perfume"
	inhand_icon_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	/// What type of the pollutant will this perfume be using
	var/fragrance_type
	/// How many uses remaining has it got
	var/uses_remaining = 10
	/// Whether the cap of the perfume is on or off
	var/cap = TRUE
	/// Whether we have a cap or not
	var/has_cap = TRUE

/obj/item/perfume/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/perfume/update_icon_state()
	icon_state = (has_cap && cap) ? "[initial(icon_state)]_cap" : initial(icon_state)
	return ..()

/obj/item/perfume/examine(mob/user)
	. = ..()
	if(uses_remaining)
		. += "Имеет [uses_remaining] использований"
	else
		. += "Пуст."
	if(has_cap)
		. += span_notice("Альт клик по [src] чтобы [ cap ? "снять крышку" : "надеть крышку"].")

/obj/item/perfume/attack_self(mob/user, modifiers)
	toggle_cap(user)

/// Proc to handle removing the cap of the perfume bottle.
/obj/item/perfume/proc/toggle_cap(mob/user)
	if(has_cap && user.can_perform_action(src, NEED_DEXTERITY))
		cap = !cap
		to_chat(user, span_notice("Крыша на [src] теперь [cap ? "снята" : "надета"]."))
		update_appearance()

/obj/item/perfume/afterattack(atom/attacked, mob/user, proximity)
	. = ..()
	if(.)
		return
	if(!ismovable(attacked))
		return
	if(has_cap && cap)
		to_chat(user, span_warning("Снимите крышку!"))
		return TRUE
	if(uses_remaining <= 0)
		to_chat(user, span_warning("[src] пуст!"))
		return TRUE
	uses_remaining--
	var/turf/my_turf = get_turf(user)
		if(my_turf)
			my_turf.pollute_turf(fragrance_type, 20)
	user.visible_message(span_notice("[user] распыляет аэрозоль на [attacked] с помощью [src]."), span_notice("Вы распыляете аэрозоль [attacked] с помощью [src]."))
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(my_turf, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	attacked.AddComponent(/datum/component/temporary_pollution_emission, fragrance_type, 5, 10 MINUTES)

/obj/item/perfume/cologne
	name = "cologne bottle"
	desc = "Эта вещь несомненно привлечет внимание женщин."
	fragrance_type = /datum/pollutant/fragrance/cologne

/obj/item/perfume/wood
	name = "wood perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/wood

/obj/item/perfume/rose
	name = "rose perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/rose

/obj/item/perfume/jasmine
	name = "jasmine perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/jasmine

/obj/item/perfume/mint
	name = "mint perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/mint

/obj/item/perfume/vanilla
	name = "vanilla perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/vanilla

/obj/item/perfume/pear
	name = "pear perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/pear

/obj/item/perfume/strawberry
	name = "strawberry perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/strawberry

/obj/item/perfume/cherry
	name = "cherry perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/cherry

/obj/item/perfume/amber
	name = "amber perfume bottle"
	fragrance_type = /datum/pollutant/fragrance/amber
