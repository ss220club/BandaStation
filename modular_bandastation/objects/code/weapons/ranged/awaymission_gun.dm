// Awaymission gun
/obj/item/gun/energy/laser/awaymission_aeg
	name = "Wireless Energy Gun"
	desc = "An energy gun that recharges wirelessly during away missions. Does not work outside the gate."
	icon = 'modular_bandastation/objects/icons/laser.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/guns_righthand.dmi'
	icon_state = "laser_gate"
	inhand_icon_state = "laser_gate"
	force = 10
	selfcharge = TRUE // Selfcharge is enabled and disabled, and used as the away mission tracker
	can_charge = 0

// Проверка чтобы не было зарядки на станции
/obj/item/gun/energy/laser/awaymission_aeg/Initialize(mapload, /obj/item/M)
	. = ..()
	on_changed_z_level()

/obj/item/gun/energy/laser/awaymission_aeg/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(is_away_level(loc.z) || is_secret_level(loc.z))
		if(ismob(loc))
			to_chat(loc, span_notice("Ваш [src.name] активируется, начиная аккумулировать энергию из материи сущего."))
		selfcharge = TRUE
		return
	if(is_station_level(loc.z))
		to_chat(loc, span_danger("Ваш [src.name] деактивируется, так как он подавляется системами станции.</span>"))
	cell.charge = 0
	selfcharge = FALSE
	update_icon()

/obj/item/gun/energy/laser/awaymission_aeg/rnd
	name = "Exploreverse Mk.I"
	desc = "Прототип оружия с миниатюрным реактором для исследований в крайне отдаленных секторах. \
	\n Данная модель использует экспериментальную систему обратного восполнения, работающую на принципе огромной аккумуляции энергии, но крайне уязвимую к радиопомехам, которыми кишит сектор станции, попростую не работая там."

/obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2
	name = "Exploreverse Mk.II"
	desc = "Второй прототип оружия с миниатюрным реактором и забавным рычагом для исследований в крайне отдаленных секторах. \
	\nДанная модель оснащена системой ручного восполнения энергии \"Za.E.-8 A.L'sya\", \
	позволяющей в короткие сроки восполнить необходимую электроэнергию с помощью ручного труда и конвертации личной энергии подключенного к системе зарядки. \
	\nТеперь еще более нелепый дизайн с торчащими проводами!"
	icon_state = "laser_gate_mk2"

/obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2/attack_self(mob/living/user)
	var/msg_for_all = span_warning("[user.name] усердно давит на рычаг зарядки [src], но он не поддается!")
	var/msg_for_user = span_notice("Вы пытаетесь надавить на рычаг зарядки [src], но он заблокирован.")
	var/msg_recharge_all = span_notice("[user.name] усердно давит на рычаг зарядки [src]...")
	var/msg_recharge_user = span_notice("Вы со всей силы давите на рычаг зарядки [src], пытаясь зарядить её...")

	if(!is_away_level(loc.z) || !is_secret_level(loc.z))
		user.visible_message(msg_for_all, msg_for_user)
		return FALSE

	if(cell.charge >= cell.maxcharge)
		user.visible_message(msg_for_all, msg_for_user)
		return FALSE

	if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		user.visible_message(
			span_warning("[user.name] слабо давит на [src], но бесполезно: слишком мало сил!"),
			span_notice("Вы пытаетесь надавить на рычаг зарядки [src], но не можете из-за голода и усталости!"))
		return FALSE

	user.visible_message(msg_recharge_all, msg_recharge_user)
	playsound(loc, 'sound/effects/sparks3.ogg', 10, 1)
	do_sparks(1, 1, src)

	if(!do_after(user, 3 SECONDS, target = src))
		return
	cell.give(100000)
	user.adjust_nutrition(-25)
	. = ..()

/datum/design/gate_gun_mk1
	name = "Gate Energy Gun MK1"
	desc = "An energy gun with an experimental miniaturized reactor. Only works in the gate" //не отображаемое описание, т.к. печатается без кейса
	id = "gate_gun"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.75, /datum/material/uranium = SHEET_MATERIAL_AMOUNT * 0.75, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/rnd
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/gate_gun_mk2
	name = "Gate Energy Gun MK2"
	desc = "An energy gun with an experimental miniaturized reactor. Only works in the gate" //не отображаемое описание, т.к. печатается без кейса
	id = "gate_gun_mk2"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4, /datum/material/glass = SHEET_MATERIAL_AMOUNT, /datum/material/uranium = SHEET_MATERIAL_AMOUNT, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 0.25, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.5)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/techweb_node/awaymission_aeg
	id = "gate_gun"
	display_name = "Awaymission Laser Weaponary Research"
	description = "Изучение лазерного оружия для гейтвея."
	prereq_ids = list(
		"adv_weaponry",
	)
	design_ids = list(
		"gate_gun_mk2",
		"gate_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
