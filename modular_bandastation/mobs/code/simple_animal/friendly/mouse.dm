/mob/living/basic/mouse
	death_sound = 'modular_bandastation/mobs/sound/rat_death.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/rat_talk.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/rat_wound.ogg')
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)

/mob/living/basic/mouse/splat()
	. = ..()
	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		// if(item)
		// 	item.add_mob_blood(src)
		// if(user)
		// 	user.add_mob_blood(src)

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

/mob/living/basic/mouse/clockwork
	name = "Чип"
	real_name = "Чип"
	body_color = "clockwork"
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "mouse_clockwork"
	icon_living = "mouse_clockwork"
	icon_dead = "mouse_clockwork_dead"
	held_state = "mouse_clockwork"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	butcher_results = list(/obj/item/stack/sheet/iron = 5)
	maxHealth = 20
	health = 20
