GLOBAL_LIST_INIT(raid_areas, list(
	/area/new_sydney,
	/area/new_sydney/building,
	/area/new_sydney/dark_forest,
	/area/new_sydney/dark_forest/radiation_lake,
	/area/new_sydney/dark_forest/building,
	/area/new_sydney/military_base
))

/mob/living/carbon/human/proc/in_raid()
	var/area/A = get_area(src)
	for(var/path in GLOB.raid_areas)
		if(istype(A, path))
			return TRUE
	return FALSE

/mob/living/carbon/human/death(gibbed)
	if(in_raid() && !ignore_raid_death)
		extract_from_raid()
		return TRUE

	return ..()

/mob/living/carbon/human/proc/extract_from_raid()
	var/turf/death_turf = get_turf(src)
	var/list/items_to_drop = list(
		head,
		wear_mask,
		glasses,
		ears,
		gloves,
		shoes,
		belt,
		back,
		s_store,
		l_store,
		r_store,
		wear_suit,
		get_active_held_item(),
		get_inactive_held_item(),
		wear_neck
	)

	for(var/obj/item/I as anything in items_to_drop)
		if(I)
			dropItemToGround(I, TRUE)
	if(w_uniform?.atom_storage)
		for(var/obj/item/I in w_uniform.atom_storage.real_location.contents.Copy())
			w_uniform.atom_storage.attempt_remove(I, death_turf)
			new /obj/effect/temp_visual/bluespace_fissure(death_turf)
	visible_message(
		span_danger("[src] рассыпается в пепел!")
	)

	new /obj/effect/decal/cleanable/ash(death_turf)
	var/obj/effect/landmark/raid_extract/L = pick(GLOB.raid_extract_landmarks)
	if(L)
		forceMove(get_turf(L))
	fully_heal()
	regenerate_icons()
	playsound_local(src, 'sound/effects/magic/blink.ogg', 25, TRUE)
	set_static_vision(2 SECONDS)
	set_temp_blindness(1 SECONDS)
	Paralyze(2 SECONDS)
	to_chat(src, span_notice("Система блюспейс-сброса активирована в результате получения серьёзных повреждений. Вы дезориентированы."))

