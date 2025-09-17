/mob/living/basic/mouse
	var/non_standard = FALSE // for no "mouse_" with mouse_color
	//icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	death_sound = 'modular_bandastation/mobs/sound/rat_death.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/rat_talk.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/rat_wound.ogg')
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/food/meat/mouse = 1)

/mob/living/basic/mouse/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list("[squeak_sound]" = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

	mouse_color = initial(mouse_color) // сбрасываем из-за наследования чтобы своим проком переписать
	color_pick()
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

/mob/living/basic/mouse/proc/color_pick()
	if(!mouse_color)
		mouse_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"

/mob/living/basic/mouse/splat(obj/item/item = null, mob/living/user = null)
	if(non_standard)
		var/temp_state = initial(icon_state)
		icon_dead = "[temp_state]_splat"
		icon_state = "[temp_state]_splat"
	else
		..()

	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(item)
			item.add_mob_blood(src)
		if(user)
			user.add_mob_blood(src)

/mob/living/basic/mouse/death(gibbed)
	if(gibbed)
		make_remains()
	. = ..(gibbed)

/mob/living/basic/mouse/proc/make_remains()
	var/obj/effect/decal/remains = new /obj/effect/decal/remains/mouse(src.loc)
	remains.pixel_x = pixel_x
	remains.pixel_y = pixel_y


// /mob/living/basic/mouse/emote(act, m_type = 1, message = null, force)

// 		if("help")
// 			to_chat(src, "scream, squeak")
// 			playsound(src, damaged_sound, 40, 1)

/mob/living/basic/mouse/brown/tom
	maxHealth = 10
	health = 10

/mob/living/basic/mouse/fluff/clockwork
	name = "Chip"
	real_name = "Chip"
	mouse_color = "clockwork"
	icon_state = "mouse_clockwork"
	response_help  = "pets"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently pushes aside"
	response_harm_continuous = "stamps on"
	response_harm_simple   = "stamps on"
	gold_core_spawnable = NO_SPAWN
	can_collar = 0
	butcher_results = list(/obj/item/stack/sheet/metal = 1)
	maxHealth = 20
	health = 20
